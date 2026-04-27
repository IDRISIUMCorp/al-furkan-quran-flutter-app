import "dart:math" as math;
import "dart:ui" as ui;

import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:al_furkan/src/screen/location_handler/location_aquire.dart";
import "package:al_furkan/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:al_furkan/src/screen/qibla/qibla_guidance.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_state.dart";
import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_qiblah/flutter_qiblah.dart" as fq;
import "package:flutter_svg/flutter_svg.dart";
import "package:gap/gap.dart";
import "package:vibration/vibration.dart";

class ARQiblaScreen extends StatefulWidget {
  const ARQiblaScreen({super.key});

  @override
  State<ARQiblaScreen> createState() => _ARQiblaScreenState();
}

class _ARQiblaScreenState extends State<ARQiblaScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  double? _smoothedHeading;
  bool _alignedLatch = false;
  bool _hasVibrator = false;
  bool _hasAmplitudeSupport = false;
  late final Future<bool?> _sensorSupportFuture;
  
  // Advanced Kalman Filter parameters for AR mode
  final double _kalmanQ = 0.0005; // Process noise (lower = smoother)
  final double _kalmanR = 0.05; // Measurement noise (lower = trust sensor more)
  double _kalmanP = 1.0; // Estimation error
  double _kalmanK = 0.0; // Kalman gain
  double? _kalmanX; // Filtered value
  
  // Complementary filter for sensor fusion
  final List<double> _headingHistory = [];
  static const int _historySize = 8;
  
  // Dead zone to prevent micro-jitters
  static const double _deadZone = 0.3;

  @override
  void initState() {
    super.initState();
    _sensorSupportFuture = fq.FlutterQiblah.androidDeviceSensorSupport();
    _initCamera();
    _initVibration();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (_) {}
  }

  Future<void> _initVibration() async {
    _hasVibrator = await Vibration.hasVibrator();
    if (_hasVibrator) {
      _hasAmplitudeSupport = await Vibration.hasCustomVibrationsSupport();
    }
  }

  Future<void> _vibrateOnAlignment() async {
    if (!_hasVibrator || _alignedLatch) return;
    _alignedLatch = true;
    await Vibration.vibrate(
      amplitude: _hasAmplitudeSupport ? 180 : -1,
      duration: 60,
    );
  }

  void _handleAlignment(QiblaGuidance guidance) {
    if (guidance.isAligned) {
      _vibrateOnAlignment();
    } else {
      _alignedLatch = false;
    }
  }
  
  /// Advanced Kalman Filter for AR mode - provides superior smoothing
  double _applyKalmanFilter(double measurement) {
    if (_kalmanX == null) {
      _kalmanX = measurement;
      return measurement;
    }
    
    // Prediction update
    _kalmanP = _kalmanP + _kalmanQ;
    
    // Measurement update
    _kalmanK = _kalmanP / (_kalmanP + _kalmanR);
    
    // Handle circular angle wrapping (0-360 degrees)
    final double delta = shortestSignedAngleDifference(_kalmanX!, measurement);
    _kalmanX = normalizeDegrees(_kalmanX! + _kalmanK * delta);
    
    _kalmanP = (1 - _kalmanK) * _kalmanP;
    
    return _kalmanX!;
  }
  
  /// Complementary filter using weighted moving average
  double _applyComplementaryFilter(double value) {
    _headingHistory.add(value);
    if (_headingHistory.length > _historySize) {
      _headingHistory.removeAt(0);
    }
    
    if (_headingHistory.length == 1) return value;
    
    // Calculate weighted average with more weight on recent values
    double sum = 0;
    double weightSum = 0;
    for (int i = 0; i < _headingHistory.length; i++) {
      final double weight = (i + 1).toDouble(); // Linear weight increase
      double angle = _headingHistory[i];
      
      // Handle circular averaging
      if (i > 0) {
        final double delta = shortestSignedAngleDifference(_headingHistory[i - 1], angle);
        angle = normalizeDegrees(_headingHistory[i - 1] + delta);
      }
      
      sum += angle * weight;
      weightSum += weight;
    }
    
    return normalizeDegrees(sum / weightSum);
  }
  
  /// Apply dead zone to prevent micro-jitters
  double _applyDeadZone(double newValue, double? oldValue) {
    if (oldValue == null) return newValue;
    
    final double delta = shortestSignedAngleDifference(oldValue, newValue).abs();
    if (delta < _deadZone) {
      return oldValue; // Stay at old value if change is too small
    }
    
    return newValue;
  }
  
  /// Master smoothing function combining all filters
  double _smoothHeadingForAR(double rawHeading) {
    // Step 1: Apply Kalman Filter (primary smoothing)
    final double kalmanFiltered = _applyKalmanFilter(rawHeading);
    
    // Step 2: Apply Complementary Filter (secondary smoothing)
    final double complementaryFiltered = _applyComplementaryFilter(kalmanFiltered);
    
    // Step 3: Apply Dead Zone (prevent micro-jitters)
    final double finalValue = _applyDeadZone(complementaryFiltered, _smoothedHeading);
    
    return finalValue;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.black.withValues(alpha: 0.26),
              child: Text(
                l10n.qibla,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.32),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildCameraLayer()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.35),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child:
                BlocBuilder<
                  LocationQiblaPrayerDataCubit,
                  LocationQiblaPrayerDataState
                >(
                  builder: (context, state) {
                    if (state.latLon == null) {
                      return const Center(child: LocationAcquire());
                    }
                    if (state.kaabaAngle == null) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: themeState.primary,
                        ),
                      );
                    }

                    return FutureBuilder<bool?>(
                      future: _sensorSupportFuture,
                      builder: (context, supportSnapshot) {
                        if (supportSnapshot.connectionState !=
                            ConnectionState.done) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: themeState.primary,
                            ),
                          );
                        }

                        if (supportSnapshot.data == false) {
                          return _buildUnavailableOverlay(
                            title: "حساسات القبلة غير مدعومة",
                            subtitle:
                                "هذا الجهاز لا يوفّر حساس اتجاه مناسب لقراءة قبلة دقيقة.",
                          );
                        }

                        return StreamBuilder<fq.QiblahDirection>(
                          stream: fq.FlutterQiblah.qiblahStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return _buildUnavailableOverlay(
                                title: "تعذر قراءة البوصلة",
                                subtitle: l10n.unableToGetCompassData,
                              );
                            }

                            final rawHeading = snapshot.data?.direction;
                            if (rawHeading == null || !rawHeading.isFinite) {
                              return _buildUnavailableOverlay(
                                title: "الحساسات غير متاحة",
                                subtitle: l10n.deviceDoesNotHaveSensors,
                              );
                            }

                            // Apply advanced multi-stage smoothing for AR mode
                            _smoothedHeading = _smoothHeadingForAR(rawHeading);

                            final guidance = resolveQiblaGuidance(
                              headingDegrees: _smoothedHeading!,
                              qiblaDegrees: state.kaabaAngle!,
                            );
                            _handleAlignment(guidance);

                            return _buildArOverlay(
                              guidance: guidance,
                              themeState: themeState,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraLayer() {
    if (_isCameraInitialized && _cameraController != null) {
      return CameraPreview(_cameraController!);
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1B1E27), Color(0xFF0A0B10)],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white70),
      ),
    );
  }

  Widget _buildArOverlay({
    required QiblaGuidance guidance,
    required ThemeState themeState,
  }) {
    final statusColor = _statusColor(guidance, themeState);
    
    // Use exponential smoothing for the offset to prevent sudden jumps
    final targetOffset = (guidance.signedDifference / 45).clamp(-1.0, 1.0);
    
    // Apply additional smoothing to the visual offset
    final smoothedOffset = _smoothOffset(targetOffset);
    
    final arrowVisible = guidance.absoluteDifference > 7;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                _buildGlassChip(
                  icon: Icons.explore_rounded,
                  label: "${guidance.heading.round()}°",
                ),
                const Gap(8),
                _buildGlassChip(
                  icon: Icons.place_rounded,
                  label: "${guidance.bearing.round()}°",
                ),
                const Spacer(),
                _buildStatusBadge(guidance, statusColor),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 320,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer circle with smooth animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 110, end: guidance.isAligned ? 120 : 110),
                  builder: (context, size, child) {
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.88),
                          width: 3,
                        ),
                        boxShadow: guidance.isAligned
                            ? [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.26),
                                  blurRadius: 26,
                                  spreadRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    );
                  },
                ),
                // Center dot
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: 18, end: guidance.isAligned ? 22 : 18),
                  builder: (context, size, child) {
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        boxShadow: guidance.isAligned
                            ? [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.5),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    );
                  },
                ),
                // Crosshair lines
                Positioned(
                  top: 40,
                  child: Container(
                    width: 2,
                    height: 60,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 40,
                  right: 40,
                  child: Container(
                    height: 2,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                // Kaaba icon with ultra-smooth animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: smoothedOffset, end: smoothedOffset),
                  builder: (context, offset, child) {
                    return Align(
                      alignment: Alignment(offset, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Kaaba icon with scale animation
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutBack,
                            tween: Tween(begin: 1.0, end: guidance.isAligned ? 1.15 : 1.0),
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: SizedBox(
                                  width: 90,
                                  height: 90,
                                  child: SvgPicture.asset(
                                    "assets/img/kaaba.svg",
                                    colorFilter: ColorFilter.mode(
                                      statusColor,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const Gap(10),
                          // Aligned badge with fade animation
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: guidance.isAligned ? 1.0 : 0.0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: statusColor.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Text(
                                "القبلة في المنتصف",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // Direction arrows with fade animation
                if (arrowVisible)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    right: guidance.turn == QiblaTurn.right ? 26 : null,
                    left: guidance.turn == QiblaTurn.left ? 26 : null,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, opacity, child) {
                        return Opacity(
                          opacity: opacity,
                          child: Icon(
                            guidance.turn == QiblaTurn.right
                                ? Icons.arrow_forward_ios_rounded
                                : Icons.arrow_back_ios_rounded,
                            color: Colors.white,
                            size: 56,
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.36),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _guidanceLabel(guidance),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        guidance.isAligned
                            ? "ثبّت الهاتف قليلًا، والرمز الموجود أمامك هو اتجاه القبلة الآن."
                            : "حرّك الهاتف ببطء نحو ${guidance.turn == QiblaTurn.right ? "اليمين" : "اليسار"} حتى يختفي الفرق ويقترب الرمز من المنتصف.",
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.7,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const Gap(12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBottomMetric(
                              title: "فرق الزاوية",
                              value: "${guidance.absoluteDifference.round()}°",
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: _buildBottomMetric(
                              title: "الحالة",
                              value: guidance.isAligned
                                  ? "مطابق"
                                  : guidance.isClose
                                  ? "قريب"
                                  : "اضبط الاتجاه",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Smooth offset for Kaaba icon position
  double? _lastOffset;
  double _smoothOffset(double targetOffset) {
    if (_lastOffset == null) {
      _lastOffset = targetOffset;
      return targetOffset;
    }
    
    // Exponential moving average for ultra-smooth transitions
    const double alpha = 0.15; // Lower = smoother
    _lastOffset = alpha * targetOffset + (1 - alpha) * _lastOffset!;
    
    return _lastOffset!;
  }

  Widget _buildUnavailableOverlay({
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black.withValues(alpha: 0.36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sensors_off_rounded,
                    size: 42,
                    color: Colors.white,
                  ),
                  const Gap(12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.7,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassChip({required IconData icon, required String label}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.black.withValues(alpha: 0.24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white70, size: 16),
              const Gap(6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(QiblaGuidance guidance, Color statusColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: statusColor.withValues(alpha: 0.45)),
      ),
      child: Text(
        guidance.isAligned
            ? "مطابق"
            : guidance.isClose
            ? "قريب"
            : "وجّه الهاتف",
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildBottomMetric({required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white60,
            ),
          ),
          const Gap(6),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
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
        return const Color(0xFFE5E7EB);
    }
  }

  String _guidanceLabel(QiblaGuidance guidance) {
    if (guidance.isAligned) {
      return "القبلة أمامك مباشرة";
    }
    final direction = guidance.turn == QiblaTurn.right ? "اليمين" : "اليسار";
    return "اتجه إلى $direction ${math.max(1, guidance.absoluteDifference.round())}°";
  }
}
