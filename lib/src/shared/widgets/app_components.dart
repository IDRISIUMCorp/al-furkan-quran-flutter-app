import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../constants/app_sizes.dart';

/// App-style card — consistent card styling across all feature modules
/// Uses theme tokens only. ZERO hardcoded colors/radius.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;

  const AppCard({
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ??
        (isDark ? AppColors.darkCard : AppColors.lightCard);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM.w,
          vertical: AppSizes.paddingXS.h,
        ),
        padding: padding ?? EdgeInsets.all(AppSizes.paddingM.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(
            (borderRadius ?? AppSizes.cardRadius).r,
          ),
          border: Border.all(
            color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
            width: 0.5,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Section header — consistent section title styling
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    required this.title,
    this.subtitle,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM.w,
        vertical: AppSizes.paddingS.h,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextMain
                            : AppColors.lightTextMain,
                      ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted,
                        ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Chip/tag widget — consistent badge styling
class AppChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const AppChip({
    required this.label,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimaryContainer);
    final fgColor = textColor ??
        (isDark ? AppColors.darkPrimary : AppColors.lightPrimary);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.paddingS.w,
        vertical: AppSizes.paddingXS.h,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusXS.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fgColor),
      ),
    );
  }
}
