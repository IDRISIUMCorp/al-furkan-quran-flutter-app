import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/prayer_theme_colors.dart';
import '../../core/theme/prayer_dimensions.dart';
import '../../core/theme/prayer_text_styles.dart';
import '../../core/utils/prayer_names.dart';

/// 🌟 Hero Card - عرض الصلاة القادمة مع العد التنازلي
/// Features:
/// - Large countdown timer
/// - Prayer name and time
/// - Animated pulse effect
/// - Gradient background
/// - Glass morphism effect
class NextPrayerHeroCard extends StatelessWidget {
  final Prayer nextPrayer;
  final DateTime prayerTime;
  final Duration timeUntilNext;
  final AnimationController pulseAnimation;

  const NextPrayerHeroCard({
    super.key,
    required this.nextPrayer,
    required this.prayerTime,
    required this.timeUntilNext,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: PrayerDimensions.heroCardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? PrayerThemeColors.heroGradientDark
              : PrayerThemeColors.heroGradientLight,
        ),
        borderRadius: BorderRadius.circular(PrayerDimensions.radiusLarge),
        border: Border.all(
          color: PrayerThemeColors.borderAccent,
          width: PrayerDimensions.borderStandard,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PrayerDimensions.radiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: PrayerDimensions.blurSubtle,
            sigmaY: PrayerDimensions.blurSubtle,
          ),
          child: Stack(
            children: [
              // Background Pattern
              _buildBackgroundPattern(isDark),
              
              // Content
              Padding(
                padding: EdgeInsets.all(PrayerDimensions.space20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - "الصلاة القادمة"
                    Row(
                      children: [
                        // Animated Pulse Indicator
                        AnimatedBuilder(
                          animation: pulseAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 12.w,
                              height: 12.h,
                              decoration: BoxDecoration(
                                color: PrayerThemeColors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: PrayerThemeColors.green
                                        .withOpacity(pulseAnimation.value),
                                    blurRadius: 8 * pulseAnimation.value,
                                    spreadRadius: 4 * pulseAnimation.value,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(width: PrayerDimensions.space12),
                        
                        Text(
                          'الصلاة القادمة',
                          style: PrayerTextStyles.arabicBody(
                            color: PrayerThemeColors.getTextColor(
                              'secondary',
                              isDark,
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        // Prayer Icon
                        Container(
                          padding: EdgeInsets.all(PrayerDimensions.space8),
                          decoration: BoxDecoration(
                            color: PrayerThemeColors.green.withOpacity(
                              PrayerDimensions.opacityLight,
                            ),
                            borderRadius: BorderRadius.circular(
                              PrayerDimensions.radiusSmall,
                            ),
                          ),
                          child: Icon(
                            _getPrayerIcon(nextPrayer),
                            size: PrayerDimensions.iconInline,
                            color: PrayerThemeColors.green,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Prayer Name
                    Text(
                      PrayerNames.getArabicName(nextPrayer),
                      style: PrayerTextStyles.arabicHeadline(
                        color: PrayerThemeColors.getTextColor(
                          'primary',
                          isDark,
                        ),
                      ),
                    ),
                    
                    SizedBox(height: PrayerDimensions.space8),
                    
                    // Prayer Time
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: PrayerDimensions.iconInline,
                          color: PrayerThemeColors.gold,
                        ),
                        SizedBox(width: PrayerDimensions.space8),
                        Text(
                          DateFormat('hh:mm a', 'ar').format(prayerTime),
                          style: PrayerTextStyles.prayerTime(
                            color: PrayerThemeColors.gold,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Countdown Timer
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: PrayerDimensions.space16,
                        vertical: PrayerDimensions.space12,
                      ),
                      decoration: BoxDecoration(
                        color: PrayerThemeColors.prayerNextBg,
                        borderRadius: BorderRadius.circular(
                          PrayerDimensions.radiusMedium,
                        ),
                        border: Border.all(
                          color: PrayerThemeColors.prayerNext.withOpacity(0.3),
                          width: PrayerDimensions.borderThin,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'متبقي',
                            style: PrayerTextStyles.arabicCaption(
                              color: PrayerThemeColors.getTextColor(
                                'secondary',
                                isDark,
                              ),
                            ),
                          ),
                          SizedBox(width: PrayerDimensions.space12),
                          Text(
                            _formatDuration(timeUntilNext),
                            style: PrayerTextStyles.countdown(
                              color: PrayerThemeColors.prayerNext,
                            ),
                          ),
                        ],
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

  Widget _buildBackgroundPattern(bool isDark) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.03,
        child: CustomPaint(
          painter: _IslamicPatternPainter(
            color: PrayerThemeColors.getTextColor('primary', isDark),
          ),
        ),
      ),
    );
  }

  IconData _getPrayerIcon(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return Icons.wb_twilight;
      case Prayer.sunrise:
        return Icons.wb_sunny;
      case Prayer.dhuhr:
        return Icons.wb_sunny_outlined;
      case Prayer.asr:
        return Icons.wb_cloudy;
      case Prayer.maghrib:
        return Icons.wb_twilight;
      case Prayer.isha:
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}

/// Custom painter for Islamic geometric pattern
class _IslamicPatternPainter extends CustomPainter {
  final Color color;

  _IslamicPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw simple star pattern
        _drawStar(canvas, paint, Offset(x, y), 8);
      }
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    const points = 8;
    final path = Path();
    
    for (int i = 0; i < points; i++) {
      final angle = (i * 2 * math.pi) / points;
      final x = center.dx + radius * (i % 2 == 0 ? 1 : 0.5) * math.cos(angle);
      final y = center.dy + radius * (i % 2 == 0 ? 1 : 0.5) * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
