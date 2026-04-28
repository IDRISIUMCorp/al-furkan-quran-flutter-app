import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_compass_v2/flutter_compass_v2.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../theme/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../domain/entities/qibla.dart';
import 'qibla_bloc.dart';

/// Qibla Screen — compass with qibla direction indicator
class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<QiblaBloc>()..add(const LoadQiblaInfo()),
      child: const _QiblaView(),
    );
  }
}

class _QiblaView extends StatelessWidget {
  const _QiblaView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Directionality.of(context) == TextDirection.rtl ? 'القبلة' : 'Qibla',
        ),
        elevation: 0,
      ),
      body: BlocBuilder<QiblaBloc, QiblaState>(
        builder: (context, state) {
          switch (state.status) {
            case QiblaStatus.initial:
            case QiblaStatus.loading:
              return const Center(child: CircularProgressIndicator.adaptive());
            case QiblaStatus.error:
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Failed to load qibla',
                onRetry: () => context.read<QiblaBloc>().add(const LoadQiblaInfo()),
              );
            case QiblaStatus.loaded:
              final qiblaInfo = state.qiblaInfo;
              if (qiblaInfo == null) {
                return const EmptyStateWidget(
                  title: 'No location set',
                  subtitle: 'Please enable location to find Qibla direction',
                  icon: Icons.location_off_outlined,
                );
              }
              return _QiblaCompass(qiblaInfo: qiblaInfo);
          }
        },
      ),
    );
  }
}

class _QiblaCompass extends StatelessWidget {
  final QiblaInfo qiblaInfo;

  const _QiblaCompass({required this.qiblaInfo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        final heading = snapshot.data?.heading ?? 0;

        return Column(
          children: [
            // Location info
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingM.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on_outlined, size: AppSizes.iconM.w, color: accentColor),
                  SizedBox(width: AppSizes.paddingXS.w),
                  Text(
                    '${qiblaInfo.latitude.toStringAsFixed(2)}, ${qiblaInfo.longitude.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                  ),
                ],
              ),
            ),
            // Compass
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 280.w,
                  height: 280.w,
                  child: CustomPaint(
                    painter: _QiblaCompassPainter(
                      heading: heading,
                      qiblaBearing: qiblaInfo.qiblaBearing,
                      accentColor: accentColor,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            ),
            // Bearing info
            Padding(
              padding: EdgeInsets.all(AppSizes.paddingM.w),
              child: Text(
                '${qiblaInfo.qiblaBearing.toStringAsFixed(1)}\u00b0 ${Directionality.of(context) == TextDirection.rtl ? "من الشمال" : "from North"}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: accentColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom painter for qibla compass
class _QiblaCompassPainter extends CustomPainter {
  final double heading;
  final double qiblaBearing;
  final Color accentColor;
  final bool isDark;

  _QiblaCompassPainter({
    required this.heading,
    required this.qiblaBearing,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Outer ring
    final ringPaint = Paint()
      ..color = isDark ? AppColors.darkSurface : AppColors.lightSurface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    // Tick marks for N/E/S/W
    final tickPaint = Paint()
      ..color = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (int i = 0; i < 360; i += 15) {
      final angle = (i - heading) * math.pi / 180;
      final isMajor = i % 90 == 0;
      final innerRadius = isMajor ? radius - 16 : radius - 8;

      final x1 = center.dx + innerRadius * math.sin(angle);
      final y1 = center.dy - innerRadius * math.cos(angle);
      final x2 = center.dx + radius * math.sin(angle);
      final y2 = center.dy - radius * math.cos(angle);

      tickPaint.strokeWidth = isMajor ? 2.5 : 1;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), tickPaint);
    }

    // Qibla indicator (kaaba icon arrow)
    final qiblaAngle = (qiblaBearing - heading) * math.pi / 180;
    final qiblaX = center.dx + (radius - 30) * math.sin(qiblaAngle);
    final qiblaY = center.dy - (radius - 30) * math.cos(qiblaAngle);

    final qiblaPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // Draw kaaba-shaped indicator
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(qiblaX, qiblaY), width: 16, height: 16),
        Radius.circular(4),
      ),
      qiblaPaint,
    );

    // Center dot
    canvas.drawCircle(center, 4, qiblaPaint);
  }

  @override
  bool shouldRepaint(covariant _QiblaCompassPainter oldDelegate) {
    return oldDelegate.heading != heading || oldDelegate.qiblaBearing != qiblaBearing;
  }
}
