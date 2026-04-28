import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme/app_colors.dart';
import '../../constants/app_sizes.dart';

/// Skeleton shimmer loading widget — placeholder for async content
/// Usage: wrap any content area with this during loading state
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius,
    super.key,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final highlightColor = isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(AppSizes.radiusXS.r),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, 0),
              end: Alignment(1 + 2 * _controller.value, 0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton line — horizontal shimmer for text placeholders
class SkeletonLine extends StatelessWidget {
  final double? width;
  final double height;
  final double topMargin;

  const SkeletonLine({
    this.width,
    this.height = 14,
    this.topMargin = 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topMargin.h),
      child: SkeletonBox(
        width: width ?? double.infinity,
        height: height.h,
      ),
    );
  }
}

/// Skeleton card — full card placeholder with title + 3 lines
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSizes.paddingM.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusM.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLine(width: 120, height: 18),
          const SkeletonLine(height: 12),
          const SkeletonLine(height: 12),
          const SkeletonLine(width: 180, height: 12),
        ],
      ),
    );
  }
}

/// Skeleton list — vertical list of skeleton cards
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final EdgeInsets? padding;

  const SkeletonList({
    this.itemCount = 5,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? EdgeInsets.all(AppSizes.paddingM.w),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}
