import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:adhan_dart/adhan_dart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/prayer_theme_colors.dart';
import '../../core/theme/prayer_dimensions.dart';
import '../../core/theme/prayer_text_styles.dart';
import '../../core/utils/prayer_names.dart';

/// 📋 Prayer Time List Item - Wahy + Ayah Hybrid Design
/// 
/// Features:
/// - Wahy colors (calm & spiritual)
/// - Ayah spacing (generous & comfortable)
/// - Ayah borders (clear & organized)
/// - Ayah touch targets (44dp - accessible)
class PrayerTimeListItem extends StatefulWidget {
  final Prayer prayer;
  final DateTime prayerTime;
  final bool isPassed;
  final bool isCurrent;
  final bool isNext;
  final VoidCallback? onTap;

  const PrayerTimeListItem({
    super.key,
    required this.prayer,
    required this.prayerTime,
    this.isPassed = false,
    this.isCurrent = false,
    this.isNext = false,
    this.onTap,
  });

  @override
  State<PrayerTimeListItem> createState() => _PrayerTimeListItemState();
}

class _PrayerTimeListItemState extends State<PrayerTimeListItem>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors based on status
    final bgColor = widget.isNext || widget.isCurrent
        ? PrayerThemeColors.greenLight
        : PrayerThemeColors.surface;
    
    final borderColor = widget.isNext || widget.isCurrent
        ? PrayerThemeColors.green
        : PrayerThemeColors.border;
    
    final textColor = widget.isPassed
        ? PrayerThemeColors.textMuted
        : PrayerThemeColors.textPrimary;
    
    final timeColor = widget.isPassed
        ? PrayerThemeColors.textMuted
        : PrayerThemeColors.green;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _scaleController.forward(),
          onTapUp: (_) => _scaleController.reverse(),
          onTapCancel: () => _scaleController.reverse(),
          borderRadius: BorderRadius.circular(PrayerDimensions.radiusMedium),
          child: Container(
            height: PrayerDimensions.prayerCardHeight,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(PrayerDimensions.radiusMedium),
              border: Border.all(
                color: borderColor,
                width: PrayerDimensions.borderStandard,
              ),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: PrayerDimensions.cardPadding,
              vertical: 16.h,
            ),
            child: Row(
              children: [
                // Prayer Icon
                _buildPrayerIcon(timeColor),
                
                SizedBox(width: PrayerDimensions.space16),
                
                // Prayer Name
                Expanded(
                  child: Text(
                    PrayerNames.getArabicName(widget.prayer),
                    style: PrayerTextStyles.prayerName(
                      color: textColor,
                      isBold: widget.isNext || widget.isCurrent,
                    ),
                  ),
                ),
                
                SizedBox(width: PrayerDimensions.space16),
                
                // Prayer Time
                Text(
                  DateFormat('hh:mm', 'ar').format(widget.prayerTime),
                  style: PrayerTextStyles.prayerTime(
                    color: timeColor,
                    isLarge: false,
                  ),
                ),
                
                SizedBox(width: PrayerDimensions.space8),
                
                // Status Indicator
                _buildStatusIndicator(timeColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerIcon(Color color) {
    return Container(
      width: PrayerDimensions.touchTargetMin,
      height: PrayerDimensions.touchTargetMin,
      decoration: BoxDecoration(
        color: widget.isNext || widget.isCurrent
            ? PrayerThemeColors.green.withValues(alpha: 0.15)
            : PrayerThemeColors.greenLight,
        borderRadius: BorderRadius.circular(PrayerDimensions.radiusSmall),
      ),
      child: Icon(
        _getPrayerIcon(widget.prayer),
        size: PrayerDimensions.iconInline,
        color: color,
      ),
    );
  }

  Widget _buildStatusIndicator(Color color) {
    if (widget.isPassed) {
      return Icon(
        Icons.check_circle_rounded,
        size: PrayerDimensions.iconInline,
        color: PrayerThemeColors.textMuted,
      );
    }
    
    if (widget.isNext) {
      return Container(
        width: 8.w,
        height: 8.h,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }
    
    return SizedBox(width: 8.w);
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
}
