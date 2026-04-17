import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/prayer_theme_colors.dart';
import '../../core/theme/prayer_dimensions.dart';
import '../../core/theme/prayer_text_styles.dart';

/// 🎨 Custom App Bar with blur-glass effect
/// Features:
/// - Transparent background with blur
/// - Smooth opacity change on scroll
/// - Location display with tap action
/// - Refresh button
/// - RTL support
class PrayerTimesAppBar extends StatelessWidget {
  final String locationName;
  final bool isLoading;
  final bool isScrolled;
  final VoidCallback? onLocationTap;
  final VoidCallback? onRefresh;

  const PrayerTimesAppBar({
    super.key,
    required this.locationName,
    this.isLoading = false,
    this.isScrolled = false,
    this.onLocationTap,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = PrayerThemeColors.getSurfaceColor(isDark);
    
    // Opacity increases when scrolled
    final opacity = isScrolled ? 1.0 : PrayerDimensions.opacityAppBar;
    
    return Container(
      height: PrayerDimensions.appBarHeight,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(opacity),
        border: isScrolled
            ? Border(
                bottom: BorderSide(
                  color: PrayerThemeColors.getBorderColor(isDark),
                  width: PrayerDimensions.borderThin,
                ),
              )
            : null,
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: PrayerDimensions.blurStandard,
            sigmaY: PrayerDimensions.blurStandard,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: PrayerDimensions.pagePadding,
            ),
            child: Row(
              children: [
                // Location Section
                Expanded(
                  child: InkWell(
                    onTap: onLocationTap,
                    borderRadius: BorderRadius.circular(
                      PrayerDimensions.radiusMedium,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: PrayerDimensions.space8,
                        horizontal: PrayerDimensions.space4,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Location Icon
                          Container(
                            width: 32.w,
                            height: 32.h,
                            decoration: BoxDecoration(
                              color: PrayerThemeColors.green.withOpacity(
                                PrayerDimensions.opacityLight,
                              ),
                              borderRadius: BorderRadius.circular(
                                PrayerDimensions.radiusSmall,
                              ),
                            ),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: PrayerDimensions.iconInline,
                              color: PrayerThemeColors.green,
                            ),
                          ),
                          
                          SizedBox(width: PrayerDimensions.space12),
                          
                          // Location Name
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'الموقع',
                                  style: PrayerTextStyles.arabicCaption(
                                    color: PrayerThemeColors.getTextColor(
                                      'secondary',
                                      isDark,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                isLoading
                                    ? SizedBox(
                                        width: 100.w,
                                        height: 12.h,
                                        child: LinearProgressIndicator(
                                          backgroundColor: PrayerThemeColors
                                              .surfaceVariant,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            PrayerThemeColors.green,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            PrayerDimensions.radiusSmall,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        locationName,
                                        style: PrayerTextStyles.arabicBody(
                                          color: PrayerThemeColors.getTextColor(
                                            'primary',
                                            isDark,
                                          ),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ],
                            ),
                          ),
                          
                          SizedBox(width: PrayerDimensions.space8),
                          
                          // Dropdown Icon
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: PrayerDimensions.iconInline,
                            color: PrayerThemeColors.getTextColor(
                              'secondary',
                              isDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: PrayerDimensions.space8),
                
                // Refresh Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onRefresh,
                    borderRadius: BorderRadius.circular(
                      PrayerDimensions.radiusMedium,
                    ),
                    child: Container(
                      width: PrayerDimensions.touchTarget,
                      height: PrayerDimensions.touchTarget,
                      decoration: BoxDecoration(
                        color: PrayerThemeColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(
                          PrayerDimensions.radiusMedium,
                        ),
                        border: Border.all(
                          color: PrayerThemeColors.getBorderColor(isDark),
                          width: PrayerDimensions.borderThin,
                        ),
                      ),
                      child: Icon(
                        Icons.refresh_rounded,
                        size: PrayerDimensions.iconInline,
                        color: PrayerThemeColors.getTextColor(
                          'primary',
                          isDark,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
