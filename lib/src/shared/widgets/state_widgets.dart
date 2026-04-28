import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Error state widget — designed error display with retry action
/// Use when async operations fail with a meaningful message
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorStateWidget({
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = isDark ? AppColors.errorDark : AppColors.error;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingL.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconXXL.w, color: errorColor),
            SizedBox(height: AppSizes.paddingM.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: AppSizes.paddingM.h),
              TextButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh_rounded, size: AppSizes.iconM.w),
                label: Text(
                  MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: errorColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty state widget — illustrated empty display with optional action
/// Use when a list/screen has no data to show
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const EmptyStateWidget({
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.paddingL.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.iconXXL.w, color: mutedColor),
            SizedBox(height: AppSizes.paddingM.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSizes.paddingXS.h),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: mutedColor,
                    ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              SizedBox(height: AppSizes.paddingM.h),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
