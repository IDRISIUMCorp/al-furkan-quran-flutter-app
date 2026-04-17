import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/prayer_theme_colors.dart';
import '../../core/theme/prayer_dimensions.dart';
import '../../core/theme/prayer_text_styles.dart';

/// ⚡ Quick Actions Section - الإجراءات السريعة
/// Features:
/// - Grid of action buttons
/// - Icon + Label design
/// - Press feedback animation
/// - Customizable actions
class QuickActionsSection extends StatelessWidget {
  final VoidCallback? onQiblaTap;
  final VoidCallback? onAdhanTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onCalendarTap;

  const QuickActionsSection({
    super.key,
    this.onQiblaTap,
    this.onAdhanTap,
    this.onSettingsTap,
    this.onCalendarTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: PrayerDimensions.space12,
      crossAxisSpacing: PrayerDimensions.space12,
      childAspectRatio: 1.5,
      children: [
        _QuickActionButton(
          icon: Icons.explore_rounded,
          label: 'اتجاه القبلة',
          color: PrayerThemeColors.green,
          onTap: onQiblaTap,
          isDark: isDark,
        ),
        _QuickActionButton(
          icon: Icons.volume_up_rounded,
          label: 'الأذان',
          color: PrayerThemeColors.gold,
          onTap: onAdhanTap,
          isDark: isDark,
        ),
        _QuickActionButton(
          icon: Icons.calendar_month_rounded,
          label: 'التقويم الإسلامي',
          color: PrayerThemeColors.info,
          onTap: onCalendarTap,
          isDark: isDark,
        ),
        _QuickActionButton(
          icon: Icons.settings_rounded,
          label: 'إعدادات الصلاة',
          color: PrayerThemeColors.getTextColor('secondary', isDark),
          onTap: onSettingsTap,
          isDark: isDark,
        ),
      ],
    );
  }
}

/// Quick Action Button Widget
class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isDark;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: PrayerDimensions.durationInstant),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) {
          _scaleController.reverse();
          widget.onTap?.call();
        },
        onTapCancel: () => _scaleController.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: PrayerThemeColors.surfaceVariant,
            borderRadius: BorderRadius.circular(PrayerDimensions.radiusMedium),
            border: Border.all(
              color: PrayerThemeColors.getBorderColor(widget.isDark),
              width: PrayerDimensions.borderStandard,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(
                    PrayerDimensions.opacityLight,
                  ),
                  borderRadius: BorderRadius.circular(
                    PrayerDimensions.radiusMedium,
                  ),
                ),
                child: Icon(
                  widget.icon,
                  size: PrayerDimensions.iconNav,
                  color: widget.color,
                ),
              ),
              
              SizedBox(height: PrayerDimensions.space12),
              
              // Label
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: PrayerDimensions.space12,
                ),
                child: Text(
                  widget.label,
                  style: PrayerTextStyles.arabicBody(
                    color: PrayerThemeColors.getTextColor(
                      'primary',
                      widget.isDark,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
