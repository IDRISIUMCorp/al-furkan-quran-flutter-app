import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../theme/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../domain/entities/hifz.dart';
import '../domain/repositories/hifz_repository.dart' show HifzStats;
import 'hifz_bloc.dart';

/// Hifz Dashboard Screen — memorization progress overview
/// Visual hierarchy: Stats cards → Due for review → All progress list
class HifzDashboardScreen extends StatelessWidget {
  const HifzDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<HifzBloc>()
        ..add(const LoadAllProgress())
        ..add(const LoadStats())
        ..add(const LoadDueForReview()),
      child: const _HifzDashboardView(),
    );
  }
}

class _HifzDashboardView extends StatelessWidget {
  const _HifzDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Directionality.of(context) == TextDirection.rtl ? 'الحفظ' : 'Hifz',
        ),
        elevation: 0,
      ),
      body: BlocBuilder<HifzBloc, HifzState>(
        builder: (context, state) {
          switch (state.status) {
            case HifzStatus.initial:
            case HifzStatus.loading:
              return const SkeletonList(itemCount: 6);
            case HifzStatus.error:
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Failed to load hifz data',
                onRetry: () {
                  context.read<HifzBloc>()
                    ..add(const LoadAllProgress())
                    ..add(const LoadStats());
                },
              );
            case HifzStatus.loaded:
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HifzBloc>()
                    ..add(const LoadAllProgress())
                    ..add(const LoadStats())
                    ..add(const LoadDueForReview());
                },
                child: _HifzContent(state: state),
              );
          }
        },
      ),
    );
  }
}

class _HifzContent extends StatelessWidget {
  final HifzState state;

  const _HifzContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (state.allProgress.isEmpty && state.stats == null) {
      return const EmptyStateWidget(
        title: 'No memorization progress',
        subtitle: 'Start memorizing to track your progress here',
        icon: Icons.school_outlined,
      );
    }

    return ListView(
      padding: EdgeInsets.all(AppSizes.paddingM.w),
      children: [
        // Stats overview cards
        if (state.stats != null) ...[
          _StatsGrid(stats: state.stats!),
          SizedBox(height: AppSizes.paddingM.h),
        ],
        // Due for review section
        if (state.dueForReview.isNotEmpty) ...[
          SectionHeader(
            title: isRtl ? 'مراجعة اليوم' : 'Due for Review',
            subtitle: '${state.dueForReview.length} ${isRtl ? 'سور' : 'surahs'}',
          ),
          ...state.dueForReview.map((progress) => _ProgressCard(progress: progress)),
          SizedBox(height: AppSizes.paddingM.h),
        ],
        // All progress section
        SectionHeader(
          title: isRtl ? 'كل التقدم' : 'All Progress',
          subtitle: '${state.allProgress.length} ${isRtl ? 'سور' : 'surahs'}',
        ),
        if (state.allProgress.isEmpty)
          const EmptyStateWidget(
            title: 'No progress yet',
            icon: Icons.menu_book_outlined,
          )
        else
          ...state.allProgress.map((progress) => _ProgressCard(progress: progress)),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final HifzStats stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.paddingS.h,
      crossAxisSpacing: AppSizes.paddingS.w,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: 'Surahs',
          value: '${stats.totalSurahsMemorized}',
          icon: Icons.menu_book_outlined,
          color: accentColor,
        ),
        _StatCard(
          label: 'Ayahs',
          value: '${stats.totalAyahsMemorized}',
          icon: Icons.format_list_numbered_outlined,
          color: isDark ? AppColors.successDark : AppColors.success,
        ),
        _StatCard(
          label: 'Mastery',
          value: '${stats.overallMasteryPercentage.toStringAsFixed(0)}%',
          icon: Icons.trending_up_outlined,
          color: isDark ? AppColors.warningDark : AppColors.warning,
        ),
        _StatCard(
          label: 'Sessions',
          value: '${stats.totalSessions}',
          icon: Icons.timer_outlined,
          color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: AppSizes.iconM.w, color: color),
              const Spacer(),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                    ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingXS.h),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final HifzProgress progress;

  const _ProgressCard({required this.progress});

  String _masteryLabel() => switch (progress.mastery) {
        HifzMasteryLevel.notStarted => 'Not Started',
        HifzMasteryLevel.learning => 'Learning',
        HifzMasteryLevel.familiar => 'Familiar',
        HifzMasteryLevel.confident => 'Confident',
        HifzMasteryLevel.mastered => 'Mastered',
      };

  Color _masteryColor(bool isDark) => switch (progress.mastery) {
        HifzMasteryLevel.notStarted => isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        HifzMasteryLevel.learning => isDark ? AppColors.errorDark : AppColors.error,
        HifzMasteryLevel.familiar => isDark ? AppColors.warningDark : AppColors.warning,
        HifzMasteryLevel.confident => isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
        HifzMasteryLevel.mastered => isDark ? AppColors.successDark : AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Surah ${progress.surahId}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                      ),
                ),
              ),
              AppChip(
                label: _masteryLabel(),
                backgroundColor: _masteryColor(isDark).withValues(alpha: 0.15),
                textColor: _masteryColor(isDark),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingS.h),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.radiusXS.r),
                  child: LinearProgressIndicator(
                    value: progress.progressPercentage / 100,
                    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    valueColor: AlwaysStoppedAnimation(_masteryColor(isDark)),
                    minHeight: 4.h,
                  ),
                ),
              ),
              SizedBox(width: AppSizes.paddingS.w),
              Text(
                '${progress.progressPercentage.toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.paddingXS.h),
          Text(
            'Ayahs ${progress.ayahStart}-${progress.ayahEnd} | Reviews: ${progress.reviewCount} | Accuracy: ${progress.masteryPercentage.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
          ),
        ],
      ),
    );
  }
}
