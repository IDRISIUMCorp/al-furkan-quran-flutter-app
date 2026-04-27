import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/prayer_theme_colors.dart';
import '../../core/theme/prayer_dimensions.dart';
import '../../core/theme/prayer_text_styles.dart';

/// ⛔ Forbidden Times Section - أوقات النهي عن الصلاة
/// Features:
/// - Three forbidden times (sunrise, noon, sunset)
/// - Visual indicators with images
/// - Time ranges display
/// - Warning styling
class ForbiddenTimesSection extends StatelessWidget {
  final PrayerTimes prayerTimes;

  const ForbiddenTimesSection({
    super.key,
    required this.prayerTimes,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate forbidden times
    final sunriseTime = prayerTimes.sunrise;
    final dhuhrTime = prayerTimes.dhuhr;
    final sunsetTime = prayerTimes.maghrib;
    
    // Forbidden time ranges (approximate)
    final sunriseEnd = sunriseTime.add(const Duration(minutes: 15));
    final noonStart = dhuhrTime.subtract(const Duration(minutes: 10));
    final noonEnd = dhuhrTime.add(const Duration(minutes: 10));
    final sunsetStart = sunsetTime.subtract(const Duration(minutes: 10));
    
    return Container(
      decoration: BoxDecoration(
        color: PrayerThemeColors.errorLight,
        borderRadius: BorderRadius.circular(PrayerDimensions.radiusMedium),
        border: Border.all(
          color: PrayerThemeColors.error.withValues(alpha: 0.3),
          width: PrayerDimensions.borderStandard,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(PrayerDimensions.space16),
            decoration: BoxDecoration(
              color: PrayerThemeColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(PrayerDimensions.radiusMedium),
                topRight: Radius.circular(PrayerDimensions.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: PrayerDimensions.iconInline,
                  color: PrayerThemeColors.error,
                ),
                SizedBox(width: PrayerDimensions.space12),
                Expanded(
                  child: Text(
                    'أوقات يُكره فيها الصلاة',
                    style: PrayerTextStyles.arabicBody(
                      color: PrayerThemeColors.getTextColor('primary', isDark),
                    ),
                  ),
                ),
                Icon(
                  Icons.info_outline_rounded,
                  size: PrayerDimensions.iconInline,
                  color: PrayerThemeColors.getTextColor('secondary', isDark),
                ),
              ],
            ),
          ),
          
          // Forbidden Times List
          Padding(
            padding: EdgeInsets.all(PrayerDimensions.space16),
            child: Column(
              children: [
                _buildForbiddenTimeItem(
                  context,
                  'من بعد طلوع الشمس',
                  'حتى ارتفاعها قيد رمح',
                  sunriseTime,
                  sunriseEnd,
                  'assets/img/sunrise_forbidden_time.png',
                  isDark,
                ),
                
                SizedBox(height: PrayerDimensions.space12),
                
                _buildForbiddenTimeItem(
                  context,
                  'عند استواء الشمس',
                  'حتى تزول عن وسط السماء',
                  noonStart,
                  noonEnd,
                  'assets/img/noon_forbidden_time.png',
                  isDark,
                ),
                
                SizedBox(height: PrayerDimensions.space12),
                
                _buildForbiddenTimeItem(
                  context,
                  'من بعد صلاة العصر',
                  'حتى غروب الشمس',
                  sunsetStart,
                  sunsetTime,
                  'assets/img/sunset_forbidden_time.png',
                  isDark,
                ),
              ],
            ),
          ),
          
          // Footer Note
          Container(
            padding: EdgeInsets.all(PrayerDimensions.space12),
            decoration: BoxDecoration(
              color: PrayerThemeColors.surfaceVariant,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(PrayerDimensions.radiusMedium),
                bottomRight: Radius.circular(PrayerDimensions.radiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: PrayerDimensions.iconSmall,
                  color: PrayerThemeColors.getTextColor('muted', isDark),
                ),
                SizedBox(width: PrayerDimensions.space8),
                Expanded(
                  child: Text(
                    'يُستثنى من ذلك الصلوات ذات الأسباب كتحية المسجد وصلاة الكسوف',
                    style: PrayerTextStyles.arabicCaption(
                      color: PrayerThemeColors.getTextColor('muted', isDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForbiddenTimeItem(
    BuildContext context,
    String title,
    String description,
    DateTime startTime,
    DateTime endTime,
    String imagePath,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.all(PrayerDimensions.space12),
      decoration: BoxDecoration(
        color: PrayerThemeColors.surfaceVariant,
        borderRadius: BorderRadius.circular(PrayerDimensions.radiusSmall),
        border: Border.all(
          color: PrayerThemeColors.getBorderColor(isDark),
          width: PrayerDimensions.borderStandard,
        ),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: PrayerThemeColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(PrayerDimensions.radiusSmall),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PrayerDimensions.radiusSmall),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.block_rounded,
                    size: PrayerDimensions.iconNav,
                    color: PrayerThemeColors.error,
                  );
                },
              ),
            ),
          ),
          
          SizedBox(width: PrayerDimensions.space12),
          
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: PrayerTextStyles.arabicBody(
                    color: PrayerThemeColors.getTextColor('primary', isDark),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: PrayerTextStyles.arabicCaption(
                    color: PrayerThemeColors.getTextColor('secondary', isDark),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(width: PrayerDimensions.space12),
          
          // Time Range
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('hh:mm a', 'ar').format(startTime),
                style: PrayerTextStyles.arabicCaption(
                  color: PrayerThemeColors.error,
                ),
              ),
              Text(
                '→',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: PrayerThemeColors.getTextColor('muted', isDark),
                ),
              ),
              Text(
                DateFormat('hh:mm a', 'ar').format(endTime),
                style: PrayerTextStyles.arabicCaption(
                  color: PrayerThemeColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
