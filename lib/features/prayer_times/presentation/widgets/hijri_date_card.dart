import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/theme/prayer_theme_colors.dart';
import '../../core/theme/prayer_dimensions.dart';
import '../../core/theme/prayer_text_styles.dart';

/// 📅 Hijri Date Card - كارت التاريخ الهجري
/// Features:
/// - Current Hijri date display
/// - Gregorian date display
/// - Islamic month name
/// - Decorative design
/// - Tap to show calendar
class HijriDateCard extends StatelessWidget {
  final VoidCallback? onTap;

  const HijriDateCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final hijriDate = HijriCalendar.fromDate(now);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: PrayerDimensions.hijriCardHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              PrayerThemeColors.gold.withValues(alpha: 0.15),
              PrayerThemeColors.surfaceVariant,
            ],
          ),
          borderRadius: BorderRadius.circular(PrayerDimensions.radiusLarge),
          border: Border.all(
            color: PrayerThemeColors.gold.withValues(alpha: 0.3),
            width: PrayerDimensions.borderStandard,
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: _HilalPatternPainter(
                    color: PrayerThemeColors.gold,
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: EdgeInsets.all(PrayerDimensions.space20),
              child: Row(
                children: [
                  // Right Side - Hijri Date
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Label
                        Text(
                          'التاريخ الهجري',
                          style: PrayerTextStyles.arabicCaption(
                            color: PrayerThemeColors.getTextColor(
                              'secondary',
                              isDark,
                            ),
                          ),
                        ),
                        
                        SizedBox(height: PrayerDimensions.space8),
                        
                        // Hijri Date
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              hijriDate.hDay.toString(),
                              style: PrayerTextStyles.hijriDate(
                                color: PrayerThemeColors.gold,
                                isLarge: true,
                              ),
                            ),
                            SizedBox(width: PrayerDimensions.space8),
                            Flexible(
                              child: Text(
                                _getHijriMonthName(hijriDate.hMonth),
                                style: PrayerTextStyles.hijriMonth(
                                  color: PrayerThemeColors.getTextColor(
                                    'primary',
                                    isDark,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: PrayerDimensions.space4),
                        
                        // Hijri Year
                        Text(
                          '${hijriDate.hYear} هـ',
                          style: PrayerTextStyles.arabicBody(
                            color: PrayerThemeColors.getTextColor(
                              'secondary',
                              isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Divider
                  Container(
                    width: PrayerDimensions.borderThin,
                    height: double.infinity,
                    margin: EdgeInsets.symmetric(
                      horizontal: PrayerDimensions.space16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          PrayerThemeColors.gold.withValues(alpha: 0),
                          PrayerThemeColors.gold.withValues(alpha: 0.5),
                          PrayerThemeColors.gold.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  
                  // Left Side - Gregorian Date
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Gregorian Date
                        Text(
                          DateFormat('d', 'ar').format(now),
                          style: PrayerTextStyles.hijriDate(
                            color: PrayerThemeColors.getTextColor(
                              'primary',
                              isDark,
                            ),
                            isLarge: true,
                          ),
                        ),
                        
                        SizedBox(height: PrayerDimensions.space4),
                        
                        Text(
                          DateFormat('MMMM', 'ar').format(now),
                          style: PrayerTextStyles.arabicBody(
                            color: PrayerThemeColors.getTextColor(
                              'secondary',
                              isDark,
                            ),
                          ),
                          textAlign: TextAlign.end,
                        ),
                        
                        SizedBox(height: PrayerDimensions.space4),
                        
                        Text(
                          DateFormat('yyyy', 'ar').format(now),
                          style: PrayerTextStyles.arabicCaption(
                            color: PrayerThemeColors.getTextColor(
                              'muted',
                              isDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tap Indicator
            if (onTap != null)
              Positioned(
                bottom: PrayerDimensions.space12,
                left: PrayerDimensions.space12,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: PrayerDimensions.space12,
                    vertical: PrayerDimensions.space8,
                  ),
                  decoration: BoxDecoration(
                    color: PrayerThemeColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      PrayerDimensions.radiusSmall,
                    ),
                    border: Border.all(
                      color: PrayerThemeColors.gold.withValues(alpha: 0.3),
                      width: PrayerDimensions.borderThin,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'عرض التقويم',
                        style: PrayerTextStyles.arabicCaption(
                          color: PrayerThemeColors.gold,
                        ),
                      ),
                      SizedBox(width: PrayerDimensions.space4),
                      Icon(
                        Icons.calendar_month_rounded,
                        size: PrayerDimensions.iconSmall,
                        color: PrayerThemeColors.gold,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getHijriMonthName(int month) {
    const months = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    
    return months[month - 1];
  }
}

/// Custom painter for Hilal (crescent) pattern
class _HilalPatternPainter extends CustomPainter {
  final Color color;

  _HilalPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw crescent moon in top right
    final center = Offset(size.width * 0.85, size.height * 0.2);
    final radius = size.width * 0.15;
    
    // Outer arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5,
      3.0,
      false,
      paint,
    );
    
    // Inner arc (to create crescent)
    final innerCenter = Offset(center.dx + radius * 0.3, center.dy);
    canvas.drawArc(
      Rect.fromCircle(center: innerCenter, radius: radius * 0.8),
      -1.5,
      3.0,
      false,
      paint..color = color.withValues(alpha: 0.5),
    );
    
    // Draw star
    _drawStar(canvas, paint, Offset(size.width * 0.75, size.height * 0.35), 8);
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    const points = 5;
    final path = Path();
    
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi) / points - math.pi / 2;
      final r = i % 2 == 0 ? radius : radius * 0.4;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
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
