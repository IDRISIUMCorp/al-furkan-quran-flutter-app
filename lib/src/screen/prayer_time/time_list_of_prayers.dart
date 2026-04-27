import "dart:async";

import "package:adhan_dart/adhan_dart.dart" hide Prayer;
import "package:adhan_dart/adhan_dart.dart" as adhan;
import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/core/notifications/wahy_notification_service.dart";
import "package:al_furkan/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:al_furkan/src/screen/location_handler/location_aquire.dart";
import "package:al_furkan/src/screen/location_handler/model/lat_lon.dart";
import "package:al_furkan/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:al_furkan/src/screen/prayer_time/models/calculation_method_enum.dart";
import "package:al_furkan/src/screen/prayer_time/models/prayer_enum.dart";
import "package:al_furkan/src/screen/prayer_time/prayer_time_extensions.dart";
import "package:al_furkan/src/screen/prayer_time/prayer_time_functions/prayer_time_helper.dart";
import "package:al_furkan/src/screen/qibla/qibla_direction.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_state.dart";
import "package:al_furkan/src/utils/format_time_of_day.dart";
import "package:al_furkan/src/utils/hijri_date.dart";
import "package:al_furkan/src/utils/location_geocoding.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:google_fonts/google_fonts.dart";
import "package:permission_handler/permission_handler.dart";
import "package:url_launcher/url_launcher.dart";

import "package:hive_ce_flutter/hive_flutter.dart";
import "sunnah_wudu_page.dart";
import "sunnah_prayer_page.dart";

// Design System Colors
const _primaryGreen = Color(0xFF2D7A5F);
const _accentGold = Color(0xFFD4AF37);
const _darkBg = Color(0xFF0F1419);
const _cardDark = Color(0xFF1A1F26);
const _cardLight = Color(0xFFFFFCF7);
const _textLight = Color(0xFFF8F9FA);
const _textDark = Color(0xFF1A1F26);
const _mutedLight = Color(0xFFB8BCC2);
const _mutedDark = Color(0xFF6B7280);

class TimeListOfPrayers extends StatefulWidget {
  const TimeListOfPrayers({super.key});

  @override
  State<TimeListOfPrayers> createState() => _TimeListOfPrayersState();
}

class _TimeListOfPrayersState extends State<TimeListOfPrayers> {
  static const List<Prayer> _prayers = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];

  // Prayer Icons
  IconData _prayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return Icons.wb_twilight_rounded;
      case Prayer.dhuhr:
        return Icons.wb_sunny_rounded;
      case Prayer.asr:
        return Icons.wb_cloudy_rounded;
      case Prayer.maghrib:
        return Icons.wb_twilight_rounded;
      case Prayer.isha:
        return Icons.nightlight_round;
      default:
        return Icons.access_time_rounded;
    }
  }

  // Prayer Colors
  Color _prayerColor(Prayer prayer, bool isDark) {
    switch (prayer) {
      case Prayer.fajr:
        return const Color(0xFF6366F1); // Indigo
      case Prayer.dhuhr:
        return const Color(0xFFF59E0B); // Amber
      case Prayer.asr:
        return const Color(0xFF10B981); // Emerald
      case Prayer.maghrib:
        return const Color(0xFFEC4899); // Pink
      case Prayer.isha:
        return const Color(0xFF8B5CF6); // Purple
      default:
        return _primaryGreen;
    }
  }

  final _notifications = WahyNotificationService.instance;
  Timer? _ticker;
  DateTime _now = DateTime.now();
  Future<String?>? _locationFuture;
  String? _locationKey;
  bool _notifLoaded = false;
  bool _notifEnabled = false;
  bool _syncing = false;
  int _leadMinutes = 0;
  Set<Prayer> _selectedAlerts = _prayers.toSet();
  String? _scheduleSignature;
  Map<Prayer, int> _adjustments = {
    Prayer.fajr: 0,
    Prayer.dhuhr: 0,
    Prayer.asr: 0,
    Prayer.maghrib: 0,
    Prayer.isha: 0,
  };
  Map<Prayer, int> _iqamahTimes = {
    Prayer.fajr: 20,
    Prayer.dhuhr: 15,
    Prayer.asr: 15,
    Prayer.maghrib: 10,
    Prayer.isha: 20,
  };
  
  // New features state
  bool _mosqueMode = false;
  String? _savedMosqueName;
  Map<String, dynamic>? _savedMosqueSettings;

  @override
  void initState() {
    super.initState();
    _loadAdjustments();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _restoreNotifications();
  }

  void _loadAdjustments() {
    final box = Hive.box("user");
    final adj = box.get("prayer_adjustments");
    if (adj is Map) {
      _adjustments = {
        for (final p in _prayers) p: (adj[p.name] as int?) ?? 0,
      };
    }
    final iqamah = box.get("iqamah_times");
    if (iqamah is Map) {
      _iqamahTimes = {
        for (final p in _prayers) p: (iqamah[p.name] as int?) ?? _iqamahTimes[p]!,
      };
    }
    
    // Load new features
    _mosqueMode = box.get("mosque_mode", defaultValue: false) as bool;
    _savedMosqueName = box.get("saved_mosque_name") as String?;
    final savedSettings = box.get("saved_mosque_settings");
    if (savedSettings is Map) {
      _savedMosqueSettings = Map<String, dynamic>.from(savedSettings);
    }
  }

  Future<void> _saveAdjustments() async {
    final box = Hive.box("user");
    await box.put(
      "prayer_adjustments",
      {for (final p in _prayers) p.name: _adjustments[p]},
    );
    await box.put(
      "iqamah_times",
      {for (final p in _prayers) p.name: _iqamahTimes[p]},
    );
  }

  Future<void> _restoreNotifications() async {
    if (!mounted) return;
    setState(() {
      _notifEnabled = _notifications.isPrayerEnabled();
      _leadMinutes = _notifications.getPrayerOffsetMinutes();
      _selectedAlerts = _notifications.getPrayerSelections();
      _notifLoaded = true;
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _ensureLocationFuture(LocationQiblaPrayerDataState state) {
    if (state.latLon == null) return;
    final key =
        "${state.latLon!.latitude.toStringAsFixed(4)}:${state.latLon!.longitude.toStringAsFixed(4)}";
    if (_locationKey == key && _locationFuture != null) return;
    _locationKey = key;
    _locationFuture = locationName(
      context,
      LatLon(
        latitude: state.latLon!.latitude,
        longitude: state.latLon!.longitude,
      ),
    );
  }

  CalculationParameters _params(LocationQiblaPrayerDataState state) {
    final method =
        state.calculationMethod?.method ?? CalculationMethod.egyptian;
    final params = getCalculationParameters(fromLibraryEnum(method));
    params.madhab = state.madhab ?? Madhab.shafi;
    params.adjustments[adhan.Prayer.fajr] = _adjustments[Prayer.fajr] ?? 0;
    params.adjustments[adhan.Prayer.dhuhr] = _adjustments[Prayer.dhuhr] ?? 0;
    params.adjustments[adhan.Prayer.asr] = _adjustments[Prayer.asr] ?? 0;
    params.adjustments[adhan.Prayer.maghrib] = _adjustments[Prayer.maghrib] ?? 0;
    params.adjustments[adhan.Prayer.isha] = _adjustments[Prayer.isha] ?? 0;
    return params;
  }

  PrayerTimes _times(LocationQiblaPrayerDataState state, DateTime date) {
    return PrayerTimes(
      date: date,
      coordinates: Coordinates(state.latLon!.latitude, state.latLon!.longitude),
      calculationParameters: _params(state),
      precision: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<
      LocationQiblaPrayerDataCubit,
      LocationQiblaPrayerDataState
    >(
      builder: (context, state) {
        if (state.latLon == null) return const LocationAcquire();
        _ensureLocationFuture(state);
        final today = _times(state, _now);
        final tomorrow = _times(state, _now.add(const Duration(days: 1)));
        return FutureBuilder<String?>(
          future: _locationFuture,
          builder: (context, snapshot) {
            return _buildPage(
              context: context,
              state: state,
              today: today,
              tomorrow: tomorrow,
              locationName: snapshot.data?.trim(),
              themeState: themeState,
              isDark: isDark,
              l10n: l10n,
            );
          },
        );
      },
    );
  }

  DateTime _timeOf(PrayerTimes t, Prayer prayer) {
    return t.timeForCustomPrayer(prayer) ?? _now;
  }

  double _progress(DateTime start, DateTime end) {
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 0;
    return (_now.difference(start).inSeconds / total).clamp(0.0, 1.0);
  }

  Future<void> _saveNotifPrefs() {
    return _notifications.savePrayerAlertPreferences(
      enabled: _notifEnabled,
      selectedPrayers: _selectedAlerts,
      minutesBefore: _leadMinutes,
    );
  }

  Future<void> _syncNotifications({
    required PrayerTimes today,
    required PrayerTimes tomorrow,
    required String locationHint,
  }) async {
    if (!_notifEnabled) return;
    final alerts = <Prayer, DateTime>{};
    final offset = Duration(minutes: _leadMinutes);
    for (final prayer in _prayers) {
      var when = _timeOf(today, prayer).subtract(offset);
      if (!when.isAfter(_now.add(const Duration(seconds: 30)))) {
        when = _timeOf(tomorrow, prayer).subtract(offset);
      }
      alerts[prayer] = when;
    }
    setState(() => _syncing = true);
    try {
      await _notifications.schedulePrayerAlerts(
        alertTimes: alerts,
        selectedPrayers: _selectedAlerts,
        minutesBefore: _leadMinutes,
        locationLabel: locationHint,
      );
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  void _scheduleSync(
    LocationQiblaPrayerDataState state,
    PrayerTimes today,
    PrayerTimes tomorrow,
  ) {
    if (!_notifLoaded || !_notifEnabled) return;
    final locationHint =
        "${state.latLon!.latitude.toStringAsFixed(2)},${state.latLon!.longitude.toStringAsFixed(2)}";
    final signature =
        "${_now.year}-${_now.month}-${_now.day}|$locationHint|${state.calculationMethod?.method.name}|${state.madhab?.name}|$_leadMinutes|${_selectedAlerts.map((e) => e.name).toList()..sort()}";
    if (_scheduleSignature == signature) return;
    _scheduleSignature = signature;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncNotifications(
        today: today,
        tomorrow: tomorrow,
        locationHint: locationHint,
      );
    });
  }

  Future<void> _refreshLocation() async {
    final permission = await Permission.location.status;
    if (permission.isGranted) {
      await context.read<LocationQiblaPrayerDataCubit>().getLocation();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("تم تحديث الموقع ومواقيت الصلاة."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LocationAcquire(backToPage: true),
      ),
    );
  }

  // Save Mosque Settings
  Future<void> _saveMosqueSettings() async {
    final box = Hive.box("user");
    await box.put("mosque_mode", _mosqueMode);
    await box.put("saved_mosque_name", _savedMosqueName);
    if (_savedMosqueSettings != null) {
      await box.put("saved_mosque_settings", _savedMosqueSettings);
    }
  }

  // Toggle Mosque Mode
  Future<void> _toggleMosqueMode() async {
    setState(() => _mosqueMode = !_mosqueMode);
    await _saveMosqueSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_mosqueMode ? "تم تفعيل وضع المسجد" : "تم إيقاف وضع المسجد"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Save Current Settings as Mosque
  Future<void> _saveAsMosque(String mosqueName) async {
    setState(() {
      _savedMosqueName = mosqueName;
      _savedMosqueSettings = {
        'adjustments': {for (final p in _prayers) p.name: _adjustments[p]},
        'iqamah_times': {for (final p in _prayers) p.name: _iqamahTimes[p]},
      };
    });
    await _saveMosqueSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ إعدادات مسجد "$mosqueName"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Load Mosque Settings
  Future<void> _loadMosqueSettings() async {
    if (_savedMosqueSettings == null) return;
    
    final adj = _savedMosqueSettings!['adjustments'] as Map?;
    if (adj != null) {
      setState(() {
        _adjustments = {
          for (final p in _prayers) p: (adj[p.name] as int?) ?? 0,
        };
      });
    }
    
    final iqamah = _savedMosqueSettings!['iqamah_times'] as Map?;
    if (iqamah != null) {
      setState(() {
        _iqamahTimes = {
          for (final p in _prayers) p: (iqamah[p.name] as int?) ?? _iqamahTimes[p]!,
        };
      });
    }
    
    await _saveAdjustments();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحميل إعدادات مسجد "$_savedMosqueName"'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Share Prayer Times
  Future<void> _sharePrayerTimes(PrayerTimes today, String? locationName) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم نسخ مواقيت الصلاة"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Export Settings
  Future<void> _exportSettings() async {
    // Convert to JSON string
    // final jsonString = jsonEncode(settings);
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم تصدير الإعدادات"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPage({
    required BuildContext context,
    required LocationQiblaPrayerDataState state,
    required PrayerTimes today,
    required PrayerTimes tomorrow,
    required String? locationName,
    required ThemeState themeState,
    required bool isDark,
    required AppLocalizations l10n,
  }) {
    final current = today.currentPrayerExtension(date: _now);
    final next = today.nextPrayerExtension(date: _now);
    final currentTime = today.currentPrayerDateTime(now: _now);
    final nextTime = today.nextPrayerDateTime(now: _now);
    final progress = _progress(currentTime, nextTime);
    final locationHint =
        "${state.latLon!.latitude.toStringAsFixed(2)}, ${state.latLon!.longitude.toStringAsFixed(2)}";
    _scheduleSync(state, today, tomorrow);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      children: [
        _buildHeaderCard(
          state,
          locationName,
          themeState,
          isDark,
        ).animate().fadeIn(duration: 240.ms).slideY(begin: -0.04),
        const Gap(12),
        _buildSummaryCard(
          current,
          next,
          currentTime,
          nextTime,
          progress,
          themeState,
        ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.03),
        const Gap(12),
        _buildSettingsCard(state, themeState, isDark),
        const Gap(12),
        _buildNotificationsCard(
          today: today,
          tomorrow: tomorrow,
          locationHint: locationName?.isNotEmpty == true
              ? locationName!
              : locationHint,
          themeState: themeState,
          isDark: isDark,
        ).animate().fadeIn(duration: 360.ms).slideY(begin: 0.03),
        const Gap(12),
        _buildFeaturesCard(today, locationName, themeState, isDark)
            .animate().fadeIn(duration: 380.ms).slideY(begin: 0.03),
        const Gap(12),
        _buildPrayerRows(today, current, next, themeState, isDark),
        const Gap(12),
        _buildForbiddenCard(today, l10n, themeState, isDark),
        const Gap(12),
        _buildExtraTimes(today, isDark),
      ],
    );
  }

  Widget _buildHeaderCard(
    LocationQiblaPrayerDataState state,
    String? locationName,
    ThemeState themeState,
    bool isDark,
  ) {
    final locationHint =
        "${state.latLon!.latitude.toStringAsFixed(2)}, ${state.latLon!.longitude.toStringAsFixed(2)}";
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  _cardDark,
                  _cardDark.withValues(alpha: 0.8),
                ]
              : [
                  _cardLight,
                  const Color(0xFFFFF8E7),
                ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _primaryGreen,
                      _primaryGreen.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locationName?.isNotEmpty == true
                          ? locationName!
                          : "جاري تحديد اسم الموقع...",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? _textLight : _textDark,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      hijriDate(context),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? _mutedLight : _mutedDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(18),
          Row(
            children: [
              Expanded(
                child: _modernActionPill(
                  icon: Icons.explore_rounded,
                  label: "القبلة",
                  color: _primaryGreen,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QiblaDirection()),
                    );
                  },
                ),
              ),
              const Gap(8),
              Expanded(
                child: _modernActionPill(
                  icon: Icons.refresh_rounded,
                  label: "تحديث",
                  color: const Color(0xFF3B82F6),
                  isDark: isDark,
                  onTap: () => _refreshLocation(),
                ),
              ),
            ],
          ),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pin_drop_rounded,
                  size: 14,
                  color: isDark ? _mutedLight : _mutedDark,
                ),
                const Gap(6),
                Text(
                  locationHint,
                  style: GoogleFonts.dmMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? _mutedLight : _mutedDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernActionPill({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const Gap(8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    Prayer current,
    Prayer next,
    DateTime currentTime,
    DateTime nextTime,
    double progress,
    ThemeState themeState,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeLeft = nextTime.difference(_now);
    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes.remainder(60);
    final seconds = timeLeft.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            _prayerColor(next, isDark).withValues(alpha: 0.9),
            _prayerColor(next, isDark).withValues(alpha: 0.7),
            _prayerColor(next, isDark).withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _prayerColor(next, isDark).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _prayerIcon(next),
                  color: Colors.white,
                  size: 28,
                ),
              ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3)),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الصلاة القادمة",
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                    const Gap(2),
                    Text(
                      PrayerTimeHelper.localizedPrayerName(context, next) ?? "-",
                      style: GoogleFonts.cairo(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms).slideX(begin: -0.1),
                  ],
                ),
              ),
            ],
          ),
          
          const Gap(20),
          
          // Countdown Timer
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _timeUnit(hours.toString().padLeft(2, '0'), "ساعة")
                    .animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(begin: const Offset(0.8, 0.8)),
                _timeSeparator()
                    .animate(onPlay: (controller) => controller.repeat())
                    .fadeOut(duration: 500.ms).then().fadeIn(duration: 500.ms),
                _timeUnit(minutes.toString().padLeft(2, '0'), "دقيقة")
                    .animate().fadeIn(duration: 400.ms, delay: 250.ms).scale(begin: const Offset(0.8, 0.8)),
                _timeSeparator()
                    .animate(onPlay: (controller) => controller.repeat())
                    .fadeOut(duration: 500.ms).then().fadeIn(duration: 500.ms),
                _timeUnit(seconds.toString().padLeft(2, '0'), "ثانية")
                    .animate().fadeIn(duration: 400.ms, delay: 300.ms).scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 150.ms).scale(begin: const Offset(0.95, 0.95)),
          
          const Gap(16),
          
          // Progress Bar
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideX(begin: -0.2),
              const Gap(12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _progressLabel(
                    PrayerTimeHelper.localizedPrayerName(context, current) ?? "-",
                    formatTimeOfDay(context, TimeOfDay.fromDateTime(currentTime)),
                  ).animate().fadeIn(duration: 500.ms, delay: 350.ms).slideX(begin: -0.1),
                  _progressLabel(
                    PrayerTimeHelper.localizedPrayerName(context, next) ?? "-",
                    formatTimeOfDay(context, TimeOfDay.fromDateTime(nextTime)),
                  ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideX(begin: 0.1),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timeUnit(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.dmMono(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            height: 1,
          ),
        ),
        const Gap(4),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _timeSeparator() {
    return Text(
      ":",
      style: GoogleFonts.dmMono(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: Colors.white.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _progressLabel(String title, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        Text(
          time,
          style: GoogleFonts.dmMono(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(
    LocationQiblaPrayerDataState state,
    ThemeState themeState,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _primaryGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.settings_rounded,
                  color: _primaryGreen,
                  size: 20,
                ),
              ),
              const Gap(12),
              Text(
                "إعدادات الحساب",
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? _textLight : _textDark,
                ),
              ),
            ],
          ),
          const Gap(16),
          
          // Madhab Selection
          InkWell(
            onTap: () => _showMadhabPicker(state, isDark),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _primaryGreen.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.book_rounded,
                      color: _primaryGreen,
                      size: 20,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "المذهب الفقهي",
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? _mutedLight : _mutedDark,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          state.madhab == Madhab.shafi ? "شافعي" : "حنفي",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark ? _textLight : _textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: _primaryGreen,
                  ),
                ],
              ),
            ),
          ),
          
          const Gap(12),
          
          // Calculation Method Selection
          InkWell(
            onTap: () => _showCalculationMethodPicker(state, isDark),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _primaryGreen.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.calculate_rounded,
                      color: _primaryGreen,
                      size: 20,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "طريقة الحساب",
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? _mutedLight : _mutedDark,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          fromLibraryEnum(
                            state.calculationMethod?.method ?? CalculationMethod.egyptian,
                          ).fullName,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark ? _textLight : _textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: _primaryGreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showMadhabPicker(LocationQiblaPrayerDataState state, bool isDark) async {
    final result = await showModalBottomSheet<Madhab>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? _cardDark : _cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(20),
            Text(
              "اختر المذهب الفقهي",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? _textLight : _textDark,
              ),
            ),
            const Gap(8),
            Text(
              "يؤثر على حساب وقت صلاة العصر",
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? _mutedLight : _mutedDark,
              ),
            ),
            const Gap(24),
            _madhabOption(
              title: "المذهب الشافعي",
              subtitle: "العصر عندما يصبح ظل الشيء مثله",
              value: Madhab.shafi,
              selected: state.madhab == Madhab.shafi,
              isDark: isDark,
            ),
            const Gap(12),
            _madhabOption(
              title: "المذهب الحنفي",
              subtitle: "العصر عندما يصبح ظل الشيء مثليه",
              value: Madhab.hanafi,
              selected: state.madhab == Madhab.hanafi,
              isDark: isDark,
            ),
            const Gap(20),
          ],
        ),
      ),
    );
    
    if (result != null) {
      context.read<LocationQiblaPrayerDataCubit>().saveMadhab(result);
    }
  }

  Widget _madhabOption({
    required String title,
    required String subtitle,
    required Madhab value,
    required bool selected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? _primaryGreen.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _primaryGreen
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: selected ? _primaryGreen : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                size: 24,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: selected ? _primaryGreen : (isDark ? _textLight : _textDark),
                    ),
                  ),
                  const Gap(4),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? _mutedLight : _mutedDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCalculationMethodPicker(LocationQiblaPrayerDataState state, bool isDark) async {
    final result = await showModalBottomSheet<CalculationMethodEnum>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? _cardDark : _cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Gap(20),
            Text(
              "اختر طريقة الحساب",
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? _textLight : _textDark,
              ),
            ),
            const Gap(8),
            Text(
              "تختلف طرق حساب أوقات الصلاة حسب المنطقة",
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? _mutedLight : _mutedDark,
              ),
            ),
            const Gap(24),
            SizedBox(
              height: 400,
              child: ListView(
                children: CalculationMethodEnum.values.map((method) {
                  final selected = fromLibraryEnum(
                    state.calculationMethod?.method ?? CalculationMethod.egyptian,
                  ) == method;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _calculationMethodOption(
                      method: method,
                      selected: selected,
                      isDark: isDark,
                    ),
                  );
                }).toList(),
              ),
            ),
            const Gap(20),
          ],
        ),
      ),
    );
    
    if (result != null) {
      context.read<LocationQiblaPrayerDataCubit>().saveCalculationMethod(
        getCalculationParameters(result),
      );
    }
  }

  Widget _calculationMethodOption({
    required CalculationMethodEnum method,
    required bool selected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, method),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? _primaryGreen.withValues(alpha: 0.15)
              : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? _primaryGreen
                : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08)),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _primaryGreen : (isDark ? Colors.white60 : Colors.black54),
              size: 24,
            ),
            const Gap(14),
            Expanded(
              child: Text(
                method.fullName,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: selected ? _primaryGreen : (isDark ? _textLight : _textDark),
                ),
              ),
            ),
            if (selected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "محدد",
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsCard({
    required PrayerTimes today,
    required PrayerTimes tomorrow,
    required String locationHint,
    required ThemeState themeState,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Toggle
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _notifEnabled
                        ? [_primaryGreen, _primaryGreen.withValues(alpha: 0.7)]
                        : [Colors.grey, Colors.grey.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _notifEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "تنبيهات الصلوات",
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? _textLight : _textDark,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      _syncing
                          ? "جاري تحديث المواعيد..."
                          : _notifEnabled
                          ? "مفعلة"
                          : "معطلة",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _syncing
                            ? const Color(0xFFF59E0B)
                            : (_notifEnabled ? _primaryGreen : (isDark ? _mutedLight : _mutedDark)),
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _notifEnabled,
                activeThumbColor: _primaryGreen,
                onChanged: !_notifLoaded
                    ? null
                    : (value) async {
                        setState(() => _notifEnabled = value);
                        await _saveNotifPrefs();
                        _scheduleSignature = null;
                        if (!value) {
                          await _notifications.cancelPrayerAlerts();
                        } else {
                          await _syncNotifications(
                            today: today,
                            tomorrow: tomorrow,
                            locationHint: locationHint,
                          );
                        }
                      },
              ),
            ],
          ),
          
          if (_notifEnabled) ...[
            const Gap(20),
            
            // Timing Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 18,
                        color: _primaryGreen,
                      ),
                      const Gap(8),
                      Text(
                        "توقيت التنبيه",
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? _textLight : _textDark,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [0, 10, 20, 30]
                        .map(
                          (minutes) => _selectablePill(
                            label: minutes == 0 ? "عند الوقت" : "قبل $minutes د",
                            selected: _leadMinutes == minutes,
                            isDark: isDark,
                            color: _primaryGreen,
                            onTap: () async {
                              setState(() => _leadMinutes = minutes);
                              await _saveNotifPrefs();
                              _scheduleSignature = null;
                              if (_notifEnabled) {
                                await _syncNotifications(
                                  today: today,
                                  tomorrow: tomorrow,
                                  locationHint: locationHint,
                                );
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            
            const Gap(12),
            
            // Prayer Selection Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: _primaryGreen,
                      ),
                      const Gap(8),
                      Text(
                        "الصلوات المفعلة",
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark ? _textLight : _textDark,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${_selectedAlerts.length} من ${_prayers.length}",
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const Gap(12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _prayers
                        .map(
                          (prayer) => _selectablePill(
                            label:
                                PrayerTimeHelper.localizedPrayerName(context, prayer) ??
                                prayer.name,
                            selected: _selectedAlerts.contains(prayer),
                            isDark: isDark,
                            color: _prayerColor(prayer, isDark),
                            onTap: () async {
                              final nextSet = Set<Prayer>.from(_selectedAlerts);
                              if (nextSet.contains(prayer)) {
                                nextSet.remove(prayer);
                              } else {
                                nextSet.add(prayer);
                              }
                              if (nextSet.isEmpty) nextSet.add(prayer);
                              setState(() => _selectedAlerts = nextSet);
                              await _saveNotifPrefs();
                              _scheduleSignature = null;
                              if (_notifEnabled) {
                                await _syncNotifications(
                                  today: today,
                                  tomorrow: tomorrow,
                                  locationHint: locationHint,
                                );
                              }
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            
            const Gap(12),
            
            // Info Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _primaryGreen.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_rounded,
                    size: 16,
                    color: _primaryGreen,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      "سيتم إرسال التنبيهات للصلوات المحددة حسب التوقيت المختار",
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _primaryGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeaturesCard(
    PrayerTimes today,
    String? locationName,
    ThemeState themeState,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFEC4899), const Color(0xFFEC4899).withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  "المساجد القريبة",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? _textLight : _textDark,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          
          // Add Mosque Button
          InkWell(
            onTap: () => _showAddMosqueSheet(isDark),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    const Color(0xFFEC4899).withValues(alpha: 0.15),
                    const Color(0xFFEC4899).withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_location_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "إضافة مسجد جديد",
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark ? _textLight : _textDark,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "احفظ موقع المسجد وأوقات الإقامة",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? _mutedLight : _mutedDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: const Color(0xFFEC4899),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, curve: Curves.easeOutCubic),
          
          const Gap(12),
          
          // My Mosques Button
          InkWell(
            onTap: () => _showMyMosquesSheet(isDark),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.list_rounded,
                      color: Color(0xFF8B5CF6),
                      size: 24,
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "مساجدي المحفوظة",
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark ? _textLight : _textDark,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "عرض وإدارة المساجد المحفوظة",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? _mutedLight : _mutedDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 350.ms, delay: 50.ms).slideX(begin: 0.1, curve: Curves.easeOutCubic),
          
          const Gap(12),
          
          // Map View Button
          InkWell(
            onTap: () => _showMosquesMapSheet(isDark),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "عرض الخريطة",
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark ? _textLight : _textDark,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          "شاهد المساجد على الخريطة",
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? _mutedLight : _mutedDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 18,
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: 0.1, curve: Curves.easeOutCubic),
        ],
      ),
    ).animate().fadeIn(duration: 380.ms).slideY(begin: 0.03, curve: Curves.easeOutCubic);
  }

  Widget _featureButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(14),
      child: Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const Gap(6),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSaveMosqueDialog(bool isDark) async {
    final controller = TextEditingController(text: _savedMosqueName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? _cardDark : _cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "حفظ إعدادات المسجد",
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w900,
            color: isDark ? _textLight : _textDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "أدخل اسم المسجد لحفظ الإعدادات الحالية",
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: isDark ? _mutedLight : _mutedDark,
              ),
            ),
            const Gap(16),
            TextField(
              controller: controller,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: "مثال: مسجد النور",
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.03),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.mosque_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "إلغاء",
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
            ),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx, name);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: _primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "حفظ",
              style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty) {
      await _saveAsMosque(result);
    }
  }

  // Add Mosque Sheet
  Future<void> _showAddMosqueSheet(bool isDark) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? _cardDark : _cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 1)),
            const Gap(20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color(0xFFEC4899), const Color(0xFFEC4899).withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.add_location_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                const Gap(12),
                Expanded(
                  child: Text(
                    "إضافة مسجد جديد",
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark ? _textLight : _textDark,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: -0.1),
                ),
              ],
            ),
            const Gap(24),
            _buildAddMosqueForm(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMosqueForm(bool isDark) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    
    return Column(
      children: [
        TextField(
          controller: nameController,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            labelText: "اسم المسجد",
            hintText: "مثال: مسجد النور",
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.mosque_rounded),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 150.ms).slideY(begin: 0.2),
        const Gap(16),
        TextField(
          controller: addressController,
          textAlign: TextAlign.right,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: "العنوان",
            hintText: "أدخل عنوان المسجد",
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.location_on_rounded),
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.2),
        const Gap(20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "سيتم فتح الخريطة لتحديد الموقع",
                        style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF10B981),
                    ),
                  );
                },
                icon: const Icon(Icons.map_rounded),
                label: Text(
                  "تحديد على الخريطة",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 250.ms).scale(begin: const Offset(0.9, 0.9)),
        const Gap(12),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم إضافة "${nameController.text.trim()}" بنجاح',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: _primaryGreen,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_rounded),
                label: Text(
                  "حفظ المسجد",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, delay: 300.ms).scale(begin: const Offset(0.9, 0.9)),
      ],
    );
  }

  // My Mosques Sheet
  Future<void> _showMyMosquesSheet(bool isDark) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? _cardDark : _cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 1)),
                  const Gap(20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF8B5CF6), const Color(0xFF8B5CF6).withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.list_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          "مساجدي المحفوظة",
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? _textLight : _textDark,
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: -0.1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 3, // Demo data
                itemBuilder: (context, index) {
                  return _buildMosqueCard(
                    name: "مسجد ${['النور', 'الرحمن', 'الهدى'][index]}",
                    address: "شارع ${['الملك فهد', 'العليا', 'الروضة'][index]}",
                    rating: [4.5, 4.8, 4.2][index],
                    distance: "${[0.5, 1.2, 2.1][index]} كم",
                    isDark: isDark,
                    index: index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMosqueCard({
    required String name,
    required String address,
    required double rating,
    required String distance,
    required bool isDark,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primaryGreen, _primaryGreen.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? _textLight : _textDark,
                      ),
                    ),
                    const Gap(4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: isDark ? _mutedLight : _mutedDark,
                        ),
                        const Gap(4),
                        Text(
                          address,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? _mutedLight : _mutedDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _accentGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: _accentGold,
                    ),
                    const Gap(4),
                    Text(
                      rating.toString(),
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _accentGold,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.near_me_rounded,
                      size: 14,
                      color: const Color(0xFF10B981),
                    ),
                    const Gap(4),
                    Text(
                      distance,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showRateMosqueDialog(name, isDark),
                icon: const Icon(Icons.edit_rounded),
                iconSize: 20,
                color: const Color(0xFF8B5CF6),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index))
        .slideX(begin: 0.1, curve: Curves.easeOutCubic);
  }

  // Rate Mosque Dialog
  Future<void> _showRateMosqueDialog(String mosqueName, bool isDark) async {
    double rating = 4.0;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: isDark ? _cardDark : _cardLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accentGold, _accentGold.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const Gap(16),
              Text(
                "تقييم $mosqueName",
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.w900,
                  color: isDark ? _textLight : _textDark,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => rating = index + 1.0),
                    icon: Icon(
                      index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: _accentGold,
                      size: 36,
                    ),
                  ).animate(delay: Duration(milliseconds: 50 * index))
                      .scale(duration: 300.ms, curve: Curves.easeOutBack);
                }),
              ),
              const Gap(12),
              Text(
                rating == 5.0 ? "ممتاز!" : rating >= 4.0 ? "جيد جداً" : rating >= 3.0 ? "جيد" : "مقبول",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: _accentGold,
                ),
              ).animate().fadeIn(duration: 200.ms),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "إلغاء",
                style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تقييم $mosqueName بـ $rating نجوم',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: _accentGold,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: _accentGold,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "تقييم",
                style: GoogleFonts.cairo(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mosques Map Sheet
  Future<void> _showMosquesMapSheet(bool isDark) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? _cardDark : _cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 1)),
                  const Gap(20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFF10B981), const Color(0xFF10B981).withValues(alpha: 0.7)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          "خريطة المساجد",
                          style: GoogleFonts.cairo(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: isDark ? _textLight : _textDark,
                          ),
                        ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideX(begin: -0.1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 64,
                        color: const Color(0xFF10B981),
                      ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                      const Gap(16),
                      Text(
                        "سيتم عرض الخريطة هنا",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? _mutedLight : _mutedDark,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                      const Gap(8),
                      Text(
                        "يمكنك تحديد موقع المساجد على الخريطة",
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? _mutedLight : _mutedDark,
                        ),
                      ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
            ),
            const Gap(24),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerRows(
    PrayerTimes today,
    Prayer current,
    Prayer next,
    ThemeState themeState,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(10),
              Text(
                "جدول الصلوات اليومية",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? _textLight : _textDark,
                ),
              ),
            ],
          ),
        ),
        const Gap(12),
        
        // Prayer Cards
        ..._prayers.asMap().entries.map((entry) {
          final index = entry.key;
          final prayer = entry.value;
          final isCurrent = prayer == current;
          final isNext = prayer == next;
          final time = _timeOf(today, prayer);
          final iqamahTime = time.add(Duration(minutes: _iqamahTimes[prayer] ?? 0));
          final prayerColor = _prayerColor(prayer, isDark);
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildPrayerCard(
              prayer: prayer,
              time: time,
              iqamahTime: iqamahTime,
              isCurrent: isCurrent,
              isNext: isNext,
              prayerColor: prayerColor,
              isDark: isDark,
              themeState: themeState,
              index: index,
            ),
          ).animate().fadeIn(
            duration: Duration(milliseconds: 300 + (index * 80)),
            curve: Curves.easeOutCubic,
          ).slideX(
            begin: 0.1,
            end: 0,
            duration: Duration(milliseconds: 400 + (index * 80)),
            curve: Curves.easeOutCubic,
          );
        }),
      ],
    );
  }

  Widget _buildPrayerCard({
    required Prayer prayer,
    required DateTime time,
    required DateTime iqamahTime,
    required bool isCurrent,
    required bool isNext,
    required Color prayerColor,
    required bool isDark,
    required ThemeState themeState,
    required int index,
  }) {
    final hasIqamah = _iqamahTimes[prayer] != null && _iqamahTimes[prayer]! > 0;
    final hasNotification = _selectedAlerts.contains(prayer);
    
    return Container(
      decoration: BoxDecoration(
        gradient: isCurrent
            ? LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  prayerColor.withValues(alpha: 0.15),
                  prayerColor.withValues(alpha: 0.08),
                ],
              )
            : null,
        color: isCurrent
            ? null
            : (isDark ? _cardDark : _cardLight),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent
              ? prayerColor.withValues(alpha: 0.4)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
          width: isCurrent ? 2 : 1,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: prayerColor.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Show prayer details
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  // Main Row
                  Row(
                    children: [
                      // Prayer Icon
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              prayerColor.withValues(alpha: 0.9),
                              prayerColor.withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: prayerColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _prayerIcon(prayer),
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      
                      const Gap(16),
                      
                      // Prayer Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  PrayerTimeHelper.localizedPrayerName(context, prayer) ?? "-",
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? _textLight : _textDark,
                                  ),
                                ),
                                const Gap(8),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: prayerColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "الآن",
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                else if (isNext)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _accentGold,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "القادمة",
                                      style: GoogleFonts.cairo(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Gap(6),
                            Row(
                              children: [
                                if (hasNotification)
                                  Icon(
                                    Icons.notifications_active_rounded,
                                    size: 14,
                                    color: prayerColor,
                                  ),
                                if (hasNotification) const Gap(6),
                                Text(
                                  hasNotification ? "التنبيه مفعّل" : "بدون تنبيه",
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? _mutedLight : _mutedDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Time Display
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatTimeOfDay(context, TimeOfDay.fromDateTime(time)),
                            style: GoogleFonts.dmMono(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: isDark ? _textLight : _textDark,
                            ),
                          ),
                          if (hasIqamah) ...[
                            const Gap(4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: prayerColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    size: 12,
                                    color: prayerColor,
                                  ),
                                  const Gap(4),
                                  Text(
                                    formatTimeOfDay(context, TimeOfDay.fromDateTime(iqamahTime)),
                                    style: GoogleFonts.dmMono(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: prayerColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  
                  const Gap(14),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _modernActionButton(
                          icon: Icons.tune_rounded,
                          label: "تعديل",
                          color: prayerColor,
                          isDark: isDark,
                          onTap: () => _editPrayerAdjustment(prayer, isDark, themeState),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _modernActionButton(
                          icon: Icons.timer_rounded,
                          label: "الإقامة",
                          color: prayerColor,
                          isDark: isDark,
                          onTap: () => _editIqamahTime(prayer, isDark, themeState),
                        ),
                      ),
                      if (prayer == Prayer.fajr) ...[
                        const Gap(8),
                        Expanded(
                          child: _modernActionButton(
                            icon: Icons.menu_book_rounded,
                            label: "السنن",
                            color: const Color(0xFF0F766E),
                            isDark: isDark,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => _sunnahOptionsSheet(isDark),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modernActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const Gap(6),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sunnahOptionsSheet(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _cardDark : _cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(20),
          Text(
            "السنن والآداب",
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? _textLight : _textDark,
            ),
          ),
          const Gap(20),
          _sunnahOption(
            icon: Icons.water_drop_rounded,
            title: "سنن الوضوء",
            subtitle: "تعلم كيفية الوضوء الصحيح",
            color: const Color(0xFF0EA5E9),
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SunnahWuduPage()),
              );
            },
          ),
          const Gap(12),
          _sunnahOption(
            icon: Icons.book_rounded,
            title: "سنن الصلاة",
            subtitle: "تعلم سنن وآداب الصلاة",
            color: const Color(0xFF10B981),
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SunnahPrayerPage()),
              );
            },
          ),
          const Gap(20),
        ],
      ),
    );
  }

  Widget _sunnahOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark ? _textLight : _textDark,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? _mutedLight : _mutedDark,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editPrayerAdjustment(Prayer prayer, bool isDark, ThemeState themeState) async {
    final int currentAdj = _adjustments[prayer] ?? 0;
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) {
        int tempAdj = currentAdj;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              title: Text("تعديل وقت الأذان", textAlign: TextAlign.right, style: _titleStyle(isDark)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("يمكنك تقديم أو تأخير الأذان بالدقائق ليتوافق مع المسجد.", textAlign: TextAlign.right, style: _mutedStyle(isDark)),
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => setDialogState(() => tempAdj--),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        color: themeState.primary,
                      ),
                      const Gap(12),
                      Text("$tempAdj دقيقة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const Gap(12),
                      IconButton(
                        onPressed: () => setDialogState(() => tempAdj++),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        color: themeState.primary,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
                FilledButton(onPressed: () => Navigator.pop(ctx, tempAdj), child: const Text("حفظ")),
              ],
            );
          },
        );
      },
    );

    if (res != null && res != currentAdj) {
      setState(() => _adjustments[prayer] = res);
      await _saveAdjustments();
      _scheduleSignature = null;
    }
  }

  Future<void> _editIqamahTime(Prayer prayer, bool isDark, ThemeState themeState) async {
    final int currentIqamah = _iqamahTimes[prayer] ?? 0;
    final res = await showDialog<int>(
      context: context,
      builder: (ctx) {
        int tempIqamah = currentIqamah;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              title: Text("وقت الإقامة", textAlign: TextAlign.right, style: _titleStyle(isDark)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("كم دقيقة بين الأذان والإقامة؟", textAlign: TextAlign.right, style: _mutedStyle(isDark)),
                  const Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: tempIqamah > 0 ? () => setDialogState(() => tempIqamah--) : null,
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                        color: themeState.primary,
                      ),
                      const Gap(12),
                      Text("$tempIqamah دقيقة", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                      const Gap(12),
                      IconButton(
                        onPressed: () => setDialogState(() => tempIqamah++),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                        color: themeState.primary,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("إلغاء")),
                FilledButton(onPressed: () => Navigator.pop(ctx, tempIqamah), child: const Text("حفظ")),
              ],
            );
          },
        );
      },
    );

    if (res != null && res != currentIqamah) {
      setState(() => _iqamahTimes[prayer] = res);
      await _saveAdjustments();
    }
  }

  Widget _buildForbiddenCard(
    PrayerTimes today,
    AppLocalizations l10n,
    ThemeState themeState,
    bool isDark,
  ) {
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(l10n.forbiddenSalatTimes, style: _titleStyle(isDark)),
              const Spacer(),
              IconButton(
                onPressed: () {
                  launchUrl(
                    Uri.parse(
                      "https://islamqa.info/en/answers/48998/forbidden-prayer-times",
                    ),
                    mode: LaunchMode.externalApplication,
                  );
                },
                icon: Icon(
                  Icons.info_outline_rounded,
                  color: themeState.primary,
                ),
              ),
            ],
          ),
          const Gap(10),
          _forbiddenRow(
            l10n.sunrise,
            today.sunrise,
            today.sunrise.add(const Duration(minutes: 15)),
            isDark,
          ),
          const Gap(8),
          _forbiddenRow(
            l10n.noon,
            today.dhuhr.subtract(const Duration(minutes: 10)),
            today.dhuhr,
            isDark,
          ),
          const Gap(8),
          _forbiddenRow(
            l10n.sunset,
            today.maghrib.subtract(const Duration(minutes: 15)),
            today.maghrib,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildExtraTimes(PrayerTimes today, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _extraTile(
            "انتهاء السحور",
            today.fajr.subtract(const Duration(minutes: 1)),
            const Color(0xFF0F766E),
            isDark,
          ),
        ),
        const Gap(10),
        Expanded(
          child: _extraTile(
            "بداية الإفطار",
            today.maghrib,
            const Color(0xFFC2410C),
            isDark,
          ),
        ),
        const Gap(10),
        Expanded(
          child: _extraTile(
            "بداية التهجد",
            today.tahajjud,
            const Color(0xFF7C3AED),
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _card({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171717) : const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: child,
    );
  }

  Widget _iconPill(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _actionPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const Gap(6),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoPill(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.white60 : Colors.black54),
          const Gap(6),
          Text(label, style: _mutedStyle(isDark)),
        ],
      ),
    );
  }

  Widget _metricBox({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, textAlign: TextAlign.right, style: _mutedStyle(true)),
          const Gap(8),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Gap(4),
          Text(subtitle, textAlign: TextAlign.right, style: _mutedStyle(true)),
        ],
      ),
    );
  }

  Widget _dropdownShell(String title, Widget child, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, textAlign: TextAlign.right, style: _mutedStyle(isDark)),
          child,
        ],
      ),
    );
  }

  Widget _selectablePill({
    required String label,
    required bool selected,
    required bool isDark,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.02)),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.34)
                : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected
                ? color
                : (isDark ? Colors.white70 : Colors.black54),
          ),
        ),
      ),
    );
  }

  Widget _forbiddenRow(
    String title,
    DateTime start,
    DateTime end,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 6, backgroundColor: Color(0xFFB91C1C)),
          const Gap(12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: _titleStyle(isDark),
            ),
          ),
          const Gap(12),
          Text(
            "${formatTimeOfDay(context, TimeOfDay.fromDateTime(start))} - ${formatTimeOfDay(context, TimeOfDay.fromDateTime(end))}",
            style: _mutedStyle(isDark),
          ),
        ],
      ),
    );
  }

  Widget _extraTile(String title, DateTime time, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
          const Gap(10),
          Text(
            formatTimeOfDay(context, TimeOfDay.fromDateTime(time)),
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w900,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _titleStyle(bool isDark) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: isDark ? Colors.white : Colors.black87,
  );

  TextStyle _mutedStyle(bool isDark) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: isDark ? Colors.white60 : Colors.black54,
  );
}
