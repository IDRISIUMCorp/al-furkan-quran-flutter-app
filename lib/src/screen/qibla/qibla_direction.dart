import "dart:math" as math;

import "package:al_quran_v3/l10n/app_localizations.dart";
import "package:al_quran_v3/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:al_quran_v3/src/screen/location_handler/location_aquire.dart";
import "package:al_quran_v3/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:al_quran_v3/src/screen/qibla/ar_qibla_screen.dart";
import "package:al_quran_v3/src/screen/qibla/compass_view/compass_view.dart";
import "package:al_quran_v3/src/screen/qibla/qibla_guidance.dart";
import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:al_quran_v3/src/theme/controller/theme_state.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_qiblah/flutter_qiblah.dart" as fq;
import "package:flutter_svg/flutter_svg.dart";
import "package:gap/gap.dart";
import "package:vibration/vibration.dart";

class QiblaDirection extends StatefulWidget {
  final bool showAppBar;
  const QiblaDirection({super.key, this.showAppBar = false});

  @override
  State<QiblaDirection> createState() => _QiblaDirectionState();
}

class _QiblaDirectionState extends State<QiblaDirection> {
  double? _smoothedHeading;
  bool _showTips = true;
  bool _alignedLatch = false;
  bool _hasVibrator = false;
  bool _hasAmplitudeSupport = false;
  late final Future<bool?> _sensorSupportFuture;

  @override
  void initState() {
    super.initState();
    _sensorSupportFuture = fq.FlutterQiblah.androidDeviceSensorSupport();
    _initVibration();
  }

  Future<void> _initVibration() async {
    _hasVibrator = await Vibration.hasVibrator();
    if (_hasVibrator) {
      _hasAmplitudeSupport = await Vibration.hasCustomVibrationsSupport();
    }
  }

  Future<void> _refreshLocation() async {
    await context.read<LocationQiblaPrayerDataCubit>().getLocation();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم تحديث الموقع واتجاه القبلة."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _vibrateOnAlignment() async {
    if (!_hasVibrator || _alignedLatch) return;
    _alignedLatch = true;
    await Vibration.vibrate(
      amplitude: _hasAmplitudeSupport ? 180 : -1,
      duration: 70,
    );
  }

  void _handleAlignment(QiblaGuidance guidance) {
    if (guidance.isAligned) {
      _vibrateOnAlignment();
    } else {
      _alignedLatch = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.qibla,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: cs.onSurface,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_rounded, color: cs.primary),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ARQiblaScreen()),
              );
            },
            icon: Icon(Icons.view_in_ar_rounded, color: cs.primary),
            tooltip: "القبلة بالواقع المعزز",
          ),
          const Gap(4),
        ],
      ),
      body: BlocBuilder<LocationQiblaPrayerDataCubit, LocationQiblaPrayerDataState>(
        builder: (context, state) {
          if (state.latLon == null) {
            return const LocationAcquire();
          }
          if (state.kaabaAngle == null) {
            return Center(
              child: CircularProgressIndicator(
                color: themeState.primary,
                backgroundColor: themeState.primaryShade100,
              ),
            );
          }

          return FutureBuilder<bool?>(
            future: _sensorSupportFuture,
            builder: (context, supportSnapshot) {
              if (supportSnapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: CircularProgressIndicator(
                    color: themeState.primary,
                    backgroundColor: themeState.primaryShade100,
                  ),
                );
              }

              if (supportSnapshot.data == false) {
                return _buildUnavailableState(
                  icon: Icons.sensors_off_rounded,
                  title: "حساسات القبلة غير مدعومة",
                  subtitle:
                      "هذا الجهاز لا يوفّر حساس اتجاه مناسب لقراءة قبلة دقيقة.",
                );
              }

              return StreamBuilder<fq.QiblahDirection>(
                stream: fq.FlutterQiblah.qiblahStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildUnavailableState(
                      icon: Icons.explore_off_rounded,
                      title: "تعذر قراءة بيانات البوصلة",
                      subtitle: l10n.unableToGetCompassData,
                    );
                  }

                  final rawHeading = snapshot.data?.direction;
                  if (rawHeading == null || !rawHeading.isFinite) {
                    return _buildUnavailableState(
                      icon: Icons.sensors_off_rounded,
                      title: "الحساسات غير متاحة",
                      subtitle: l10n.deviceDoesNotHaveSensors,
                    );
                  }

                  _smoothedHeading = smoothHeading(
                    previousDegrees: _smoothedHeading,
                    nextDegrees: rawHeading,
                    factor: 0.24,
                    jitterThreshold: 0.35,
                  );

                  final guidance = resolveQiblaGuidance(
                    headingDegrees: _smoothedHeading!,
                    qiblaDegrees: state.kaabaAngle!,
                  );
                  _handleAlignment(guidance);

                  return _buildQiblaBody(
                    context: context,
                    themeState: themeState,
                    guidance: guidance,
                    state: state,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQiblaBody({
    required BuildContext context,
    required ThemeState themeState,
    required QiblaGuidance guidance,
    required LocationQiblaPrayerDataState state,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _statusColor(guidance, themeState);
    final screenWidth = MediaQuery.of(context).size.width;
    final compassSize = math.min(screenWidth - 48, 320.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildHeroCard(
          guidance: guidance,
          themeState: themeState,
          isDark: isDark,
          state: state,
        ),
        const Gap(14),
        if (_showTips) _buildTipsCard(isDark: isDark, themeState: themeState),
        if (_showTips) const Gap(14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171717) : const Color(0xFFFFFCF7),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                width: compassSize,
                height: compassSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: isDark
                                ? [
                                    Colors.white.withValues(alpha: 0.05),
                                    Colors.transparent,
                                  ]
                                : [
                                    themeState.primary.withValues(alpha: 0.06),
                                    Colors.transparent,
                                  ],
                          ),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: -(guidance.heading * math.pi / 180),
                      child: SizedBox(
                        width: compassSize,
                        height: compassSize,
                        child: CustomPaint(
                          painter: CompassView(
                            themeState,
                            context: context,
                            kaabaAngle: guidance.bearing,
                            appLocalizations: AppLocalizations.of(context),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      child: Column(
                        children: [
                          Icon(
                            Icons.navigation_rounded,
                            color: statusColor,
                            size: 36,
                          ),
                          const Gap(4),
                          Text(
                            "اتجاهك",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 260),
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.75),
                          width: 3,
                        ),
                        boxShadow: guidance.isAligned
                            ? [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.22),
                                  blurRadius: 28,
                                  spreadRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: SvgPicture.asset(
                              "assets/img/kaaba.svg",
                              colorFilter: ColorFilter.mode(
                                statusColor,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        Text(
                          _guidanceText(guidance),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(14),
              LinearProgressIndicator(
                minHeight: 8,
                value: guidance.progress,
                borderRadius: BorderRadius.circular(999),
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
              const Gap(12),
              Text(
                guidance.isAligned
                    ? "الآن أنت في نطاق دقيق جدًا. ثبّت الهاتف للحظة."
                    : "حرّك الهاتف بهدوء، وكلما اقترب الفرق من 0° أصبحت المحاذاة أدق.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.7,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const Gap(14),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "زاوية القبلة",
                value: "${guidance.bearing.round()}°",
                subtitle: "من الشمال الحقيقي",
                color: themeState.primary,
                isDark: isDark,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _buildStatCard(
                title: "اتجاه الهاتف",
                value: "${guidance.heading.round()}°",
                subtitle: "قراءة مستقرة",
                color: Colors.blueGrey,
                isDark: isDark,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _buildStatCard(
                title: "الفرق الحالي",
                value: "${guidance.absoluteDifference.round()}°",
                subtitle: guidance.isAligned ? "مطابق" : "قابل للتحسين",
                color: statusColor,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const Gap(14),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.my_location_rounded,
                title: "تحديث الموقع",
                subtitle: "إعادة حساب القبلة",
                color: themeState.primary,
                onTap: () => _refreshLocation(),
                isDark: isDark,
              ),
            ),
            const Gap(10),
            Expanded(
              child: _buildActionCard(
                icon: Icons.view_in_ar_rounded,
                title: "وضع AR",
                subtitle: "رؤية إرشادية مباشرة",
                color: statusColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ARQiblaScreen()),
                  );
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCard({
    required QiblaGuidance guidance,
    required ThemeState themeState,
    required bool isDark,
    required LocationQiblaPrayerDataState state,
  }) {
    final statusColor = _statusColor(guidance, themeState);
    final latitude = state.latLon!.latitude.toStringAsFixed(4);
    final longitude = state.latLon!.longitude.toStringAsFixed(4);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  const Color(0xFF1A1A1A),
                  themeState.primary.withValues(alpha: 0.18),
                ]
              : [Colors.white, themeState.primary.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusLabel(guidance),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              if (_showTips)
                IconButton(
                  onPressed: () => setState(() => _showTips = false),
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  tooltip: "إخفاء النصائح",
                ),
            ],
          ),
          const Gap(8),
          Text(
            _guidanceText(guidance),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Gap(8),
          Text(
            "يتم الحساب الآن من موقعك الحالي عند ($latitude, $longitude). حرّك الهاتف ببطء حتى يثبت المؤشر.",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              height: 1.7,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard({
    required bool isDark,
    required ThemeState themeState,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171717) : const Color(0xFFFFFCF6),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_rounded, color: themeState.primary),
              const Gap(8),
              Text(
                "لأفضل دقة",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const Gap(10),
          _buildTipLine(
            "أبعد الهاتف عن المعادن أو السماعات المغناطيسية.",
            isDark,
          ),
          _buildTipLine(
            "حرّك الهاتف حركة رقم 8 إذا لاحظت اهتزازًا في القراءة.",
            isDark,
          ),
          _buildTipLine(
            "استخدم وضع AR عندما تحتاج إشارة اتجاهية أكبر.",
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTipLine(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(top: 7),
            decoration: BoxDecoration(
              color: isDark ? Colors.white54 : Colors.black45,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.7,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171717) : const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          const Gap(8),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const Gap(4),
          Text(
            subtitle,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF171717) : const Color(0xFFFFFCF7),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: color.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnavailableState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 46, color: Theme.of(context).colorScheme.primary),
            const Gap(14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const Gap(8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.7,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(QiblaGuidance guidance, ThemeState themeState) {
    switch (guidance.alignment) {
      case QiblaAlignment.aligned:
        return themeState.primary;
      case QiblaAlignment.close:
        return const Color(0xFFC6922D);
      case QiblaAlignment.adjusting:
        return const Color(0xFF6B7280);
    }
  }

  String _statusLabel(QiblaGuidance guidance) {
    switch (guidance.alignment) {
      case QiblaAlignment.aligned:
        return "محاذاة ممتازة";
      case QiblaAlignment.close:
        return "قريب جدًا";
      case QiblaAlignment.adjusting:
        return "يحتاج ضبط";
    }
  }

  String _guidanceText(QiblaGuidance guidance) {
    if (guidance.isAligned) {
      return "القبلة أمامك الآن";
    }
    if (guidance.turn == QiblaTurn.right) {
      return "لف يمين ${guidance.absoluteDifference.round()}°";
    }
    if (guidance.turn == QiblaTurn.left) {
      return "لف يسار ${guidance.absoluteDifference.round()}°";
    }
    return "ثبّت الهاتف";
  }
}
