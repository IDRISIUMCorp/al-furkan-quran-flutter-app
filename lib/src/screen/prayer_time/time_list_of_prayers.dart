import "dart:async";

import "package:adhan_dart/adhan_dart.dart" hide Prayer;
import "package:adhan_dart/adhan_dart.dart" as adhan;
import "package:al_quran_v3/l10n/app_localizations.dart";
import "package:al_quran_v3/src/core/notifications/wahy_notification_service.dart";
import "package:al_quran_v3/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:al_quran_v3/src/screen/location_handler/location_aquire.dart";
import "package:al_quran_v3/src/screen/location_handler/model/lat_lon.dart";
import "package:al_quran_v3/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:al_quran_v3/src/screen/prayer_time/models/calculation_method_enum.dart";
import "package:al_quran_v3/src/screen/prayer_time/models/prayer_enum.dart";
import "package:al_quran_v3/src/screen/prayer_time/prayer_time_extensions.dart";
import "package:al_quran_v3/src/screen/prayer_time/prayer_time_functions/prayer_time_helper.dart";
import "package:al_quran_v3/src/screen/qibla/qibla_direction.dart";
import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:al_quran_v3/src/theme/controller/theme_state.dart";
import "package:al_quran_v3/src/utils/format_time_of_day.dart";
import "package:al_quran_v3/src/utils/hijri_date.dart";
import "package:al_quran_v3/src/utils/location_geocoding.dart";
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
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _iconPill(Icons.location_on_rounded, themeState.primary),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      locationName?.isNotEmpty == true
                          ? locationName!
                          : "جاري تحديد اسم الموقع...",
                      textAlign: TextAlign.right,
                      style: _titleStyle(isDark),
                    ),
                    const Gap(4),
                    Text(
                      hijriDate(context),
                      textAlign: TextAlign.right,
                      style: _mutedStyle(isDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(14),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 8,
            runSpacing: 8,
            children: [
              _actionPill(
                icon: Icons.explore_rounded,
                label: "القبلة",
                color: themeState.primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const QiblaDirection()),
                  );
                },
              ),
              _actionPill(
                icon: Icons.refresh_rounded,
                label: "تحديث",
                color: themeState.primary,
                onTap: () => _refreshLocation(),
              ),
              _infoPill(Icons.pin_drop_rounded, locationHint, isDark),
            ],
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            const Color(0xFF171717),
            themeState.primary.withValues(alpha: 0.20),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "الصلاة القادمة",
            textAlign: TextAlign.right,
            style: _mutedStyle(true),
          ),
          const Gap(8),
          Text(
            PrayerTimeHelper.localizedPrayerName(context, next) ?? "-",
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const Gap(6),
          Text(
            PrayerTimeHelper.formatDuration(nextTime.difference(_now)),
            textAlign: TextAlign.right,
            style: GoogleFonts.dmMono(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Gap(14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const Gap(12),
          Row(
            children: [
              Expanded(
                child: _metricBox(
                  title: "الحالية",
                  value:
                      PrayerTimeHelper.localizedPrayerName(context, current) ??
                      "-",
                  subtitle: formatTimeOfDay(
                    context,
                    TimeOfDay.fromDateTime(currentTime),
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: _metricBox(
                  title: "التالي",
                  value:
                      PrayerTimeHelper.localizedPrayerName(context, next) ??
                      "-",
                  subtitle: formatTimeOfDay(
                    context,
                    TimeOfDay.fromDateTime(nextTime),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
    LocationQiblaPrayerDataState state,
    ThemeState themeState,
    bool isDark,
  ) {
    return _card(
      isDark: isDark,
      child: Row(
        children: [
          Expanded(
            child: _dropdownShell(
              "المذهب",
              DropdownButton<Madhab>(
                value: state.madhab ?? Madhab.shafi,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: Madhab.shafi, child: Text("شافعي")),
                  DropdownMenuItem(value: Madhab.hanafi, child: Text("حنفي")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context.read<LocationQiblaPrayerDataCubit>().saveMadhab(
                      value,
                    );
                  }
                },
              ),
              isDark,
            ),
          ),
          const Gap(10),
          Expanded(
            child: _dropdownShell(
              "طريقة الحساب",
              DropdownButton<CalculationMethodEnum>(
                value: fromLibraryEnum(
                  state.calculationMethod?.method ?? CalculationMethod.egyptian,
                ),
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: CalculationMethodEnum.values
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e.fullName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    context
                        .read<LocationQiblaPrayerDataCubit>()
                        .saveCalculationMethod(getCalculationParameters(value));
                  }
                },
              ),
              isDark,
            ),
          ),
        ],
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
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _iconPill(Icons.notifications_active_rounded, themeState.primary),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "تنبيهات الصلوات",
                      textAlign: TextAlign.right,
                      style: _titleStyle(isDark),
                    ),
                    const Gap(4),
                    Text(
                      _syncing
                          ? "جاري تحديث المواعيد القادمة..."
                          : _notifEnabled
                          ? "مفعلة حسب إعداداتك الحالية."
                          : "فعّلها لتصلك التنبيهات قبل الصلاة أو عند دخول الوقت.",
                      textAlign: TextAlign.right,
                      style: _mutedStyle(isDark),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: _notifEnabled,
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
          const Gap(14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [0, 10, 20, 30]
                .map(
                  (minutes) => _selectablePill(
                    label: minutes == 0 ? "عند الوقت" : "قبل $minutes د",
                    selected: _leadMinutes == minutes,
                    isDark: isDark,
                    color: themeState.primary,
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
          const Gap(12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: _prayers
                .map(
                  (prayer) => _selectablePill(
                    label:
                        PrayerTimeHelper.localizedPrayerName(context, prayer) ??
                        prayer.name,
                    selected: _selectedAlerts.contains(prayer),
                    isDark: isDark,
                    color: themeState.primary,
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
    );
  }

  Widget _buildPrayerRows(
    PrayerTimes today,
    Prayer current,
    Prayer next,
    ThemeState themeState,
    bool isDark,
  ) {
    return _card(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "جدول الصلوات والتعديلات",
            textAlign: TextAlign.right,
            style: _titleStyle(isDark),
          ),
          const Gap(12),
          ..._prayers.map((prayer) {
            final isCurrent = prayer == current;
            final isNext = prayer == next;
            final activeColor = isCurrent
                ? themeState.primary
                : isNext
                ? const Color(0xFFC6922D)
                : (isDark ? Colors.white24 : Colors.black26);
            
            final time = _timeOf(today, prayer);
            final iqamahTime = time.add(Duration(minutes: _iqamahTimes[prayer] ?? 0));
            
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent
                    ? themeState.primary.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: activeColor.withValues(alpha: 0.22)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedAlerts.contains(prayer)
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_none_rounded,
                        color: _selectedAlerts.contains(prayer)
                            ? themeState.primary
                            : activeColor,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              PrayerTimeHelper.localizedPrayerName(
                                    context,
                                    prayer,
                                  ) ??
                                  "-",
                              textAlign: TextAlign.right,
                              style: _titleStyle(isDark),
                            ),
                            const Gap(4),
                            Text(
                              isCurrent
                                  ? "الوقت الحالي"
                                  : isNext
                                  ? "القادمة"
                                  : "موعد اليوم",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: activeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            formatTimeOfDay(
                              context,
                              TimeOfDay.fromDateTime(time),
                            ),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          if (_iqamahTimes[prayer] != null && _iqamahTimes[prayer]! > 0)
                            Text(
                              "الإقامة: ${formatTimeOfDay(context, TimeOfDay.fromDateTime(iqamahTime))}",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: _actionPill(
                          icon: Icons.edit_notifications_rounded,
                          label: "تعديل الأذان",
                          color: themeState.primary,
                          onTap: () => _editPrayerAdjustment(prayer, isDark, themeState),
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: _actionPill(
                          icon: Icons.timer_rounded,
                          label: "وقت الإقامة",
                          color: themeState.primary,
                          onTap: () => _editIqamahTime(prayer, isDark, themeState),
                        ),
                      ),
                    ],
                  ),
                  if (prayer == Prayer.fajr) ...[
                    const Gap(8),
                    Row(
                      children: [
                        Expanded(
                          child: _actionPill(
                            icon: Icons.menu_book_rounded,
                            label: "سنن الوضوء",
                            color: const Color(0xFF0F766E),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SunnahWuduPage()),
                               );
                             },
                           ),
                         ),
                         const Gap(8),
                         Expanded(
                           child: _actionPill(
                             icon: Icons.book_rounded,
                             label: "سنن الصلاة",
                             color: const Color(0xFF0F766E),
                             onTap: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(builder: (_) => const SunnahPrayerPage()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _editPrayerAdjustment(Prayer prayer, bool isDark, ThemeState themeState) async {
    int currentAdj = _adjustments[prayer] ?? 0;
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
    int currentIqamah = _iqamahTimes[prayer] ?? 0;
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
