import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../theme/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../domain/entities/azkar.dart';
import 'azkar_bloc.dart';

/// Azkar Categories Screen — shows all azkar categories with type filter
/// Visual hierarchy: Type filter chips → Category cards grid
class AzkarCategoriesScreen extends StatelessWidget {
  const AzkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<AzkarBloc>()..add(const LoadCategories()),
      child: const _AzkarCategoriesView(),
    );
  }
}

class _AzkarCategoriesView extends StatelessWidget {
  const _AzkarCategoriesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Directionality.of(context) == TextDirection.rtl ? 'الأذكار' : 'Azkar',
        ),
        elevation: 0,
      ),
      body: BlocBuilder<AzkarBloc, AzkarState>(
        builder: (context, state) {
          switch (state.status) {
            case AzkarStatus.initial:
            case AzkarStatus.loading:
              return const SkeletonList(itemCount: 6);
            case AzkarStatus.error:
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Failed to load azkar',
                onRetry: () => context.read<AzkarBloc>().add(const LoadCategories()),
              );
            case AzkarStatus.loaded:
              if (state.categories.isEmpty) {
                return EmptyStateWidget(
                  title: Directionality.of(context) == TextDirection.rtl
                      ? 'لا توجد أذكار'
                      : 'No azkar found',
                  subtitle: Directionality.of(context) == TextDirection.rtl
                      ? 'سيتم إضافة أذكار قريباً'
                      : 'Azkar will be added soon',
                  icon: Icons.menu_book_outlined,
                );
              }
              return _AzkarContent(categories: state.categories);
          }
        },
      ),
    );
  }
}

class _AzkarContent extends StatelessWidget {
  final List<AzkarCategory> categories;

  const _AzkarContent({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Type filter chips
        SizedBox(
          height: 48.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingM.w),
            children: AzkarType.values.map((type) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingS.w / 2),
                child: _TypeFilterChip(type: type),
              );
            }).toList(),
          ),
        ),
        Divider(height: 1, color: AppColors.lightBorderSubtle),
        // Categories grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(AppSizes.paddingM.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSizes.paddingS.h,
              crossAxisSpacing: AppSizes.paddingS.w,
              childAspectRatio: 1.1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryCard(
                category: category,
                index: index,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TypeFilterChip extends StatelessWidget {
  final AzkarType type;

  const _TypeFilterChip({required this.type});

  String _label(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return switch (type) {
      AzkarType.morning => isRtl ? 'الصباح' : 'Morning',
      AzkarType.evening => isRtl ? 'المساء' : 'Evening',
      AzkarType.prayer => isRtl ? 'الصلاة' : 'Prayer',
      AzkarType.sleep => isRtl ? 'النوم' : 'Sleep',
      AzkarType.wakeup => isRtl ? 'الاستيقاظ' : 'Wakeup',
      AzkarType.general => isRtl ? 'عامة' : 'General',
      AzkarType.quran => isRtl ? 'القرآن' : 'Quran',
      AzkarType.ruqyah => isRtl ? 'الرقية' : 'Ruqyah',
    };
  }

  IconData _icon() => switch (type) {
        AzkarType.morning => Icons.wb_sunny_outlined,
        AzkarType.evening => Icons.nights_stay_outlined,
        AzkarType.prayer => Icons.mosque_outlined,
        AzkarType.sleep => Icons.bedtime_outlined,
        AzkarType.wakeup => Icons.alarm_outlined,
        AzkarType.general => Icons.auto_awesome_outlined,
        AzkarType.quran => Icons.menu_book_outlined,
        AzkarType.ruqyah => Icons.healing_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarBloc, AzkarState>(
      builder: (context, state) {
        final isSelected = state.selectedType == type;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return PressableOpacity(
          onTap: () => context.read<AzkarBloc>().add(LoadAzkarByType(type)),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.paddingM.w,
              vertical: AppSizes.paddingS.h,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
              borderRadius: BorderRadius.circular(AppSizes.radiusXL.r),
              border: Border.all(
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                    : (isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle),
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _icon(),
                  size: AppSizes.iconS.w,
                  color: isSelected
                      ? (isDark ? AppColors.darkTextMain : Colors.white)
                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
                SizedBox(width: AppSizes.paddingXS.w),
                Text(
                  _label(context),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isSelected
                            ? (isDark ? AppColors.darkTextMain : Colors.white)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final AzkarCategory category;
  final int index;

  const _CategoryCard({required this.category, required this.index});

  IconData _categoryIcon() {
    // Map iconKey to IconData — fallback to category icon
    return switch (category.iconKey) {
      'morning' => Icons.wb_sunny_outlined,
      'evening' => Icons.nights_stay_outlined,
      'prayer' => Icons.mosque_outlined,
      'sleep' => Icons.bedtime_outlined,
      'wakeup' => Icons.alarm_outlined,
      'quran' => Icons.menu_book_outlined,
      'ruqyah' => Icons.healing_outlined,
      'general' => Icons.auto_awesome_outlined,
      _ => Icons.auto_awesome_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Pressable(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<AzkarBloc>()
                ..add(LoadAzkarByCategory(category.id)),
              child: const AzkarItemsScreen(),
            ),
          ),
        );
      },
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingM.w),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkPrimaryContainer
                    : AppColors.lightPrimaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _categoryIcon(),
                size: AppSizes.iconXL.w,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
            SizedBox(height: AppSizes.paddingS.h),
            Text(
              isRtl ? category.nameArabic : category.nameEnglish,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSizes.paddingXS.h),
            Text(
              '${category.azkarCount}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Azkar Items Screen — shows azkar list with counter for a category
class AzkarItemsScreen extends StatelessWidget {
  const AzkarItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Directionality.of(context) == TextDirection.rtl ? 'الأذكار' : 'Azkar',
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset daily counts',
            onPressed: () => context.read<AzkarBloc>().add(const ResetDailyCounts()),
          ),
        ],
      ),
      body: BlocBuilder<AzkarBloc, AzkarState>(
        builder: (context, state) {
          switch (state.status) {
            case AzkarStatus.initial:
            case AzkarStatus.loading:
              return const SkeletonList(itemCount: 8);
            case AzkarStatus.error:
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Failed to load azkar',
                onRetry: () => context.read<AzkarBloc>().add(const LoadCategories()),
              );
            case AzkarStatus.loaded:
              if (state.currentAzkar.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No azkar in this category',
                  icon: Icons.auto_awesome_outlined,
                );
              }
              return _AzkarItemsList(items: state.currentAzkar, counts: state.remainingCounts);
          }
        },
      ),
    );
  }
}

class _AzkarItemsList extends StatelessWidget {
  final List<AzkarItem> items;
  final Map<int, int> counts;

  const _AzkarItemsList({required this.items, required this.counts});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.paddingM.w),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSizes.paddingS.h),
      itemBuilder: (context, index) {
        final item = items[index];
        final remaining = counts[item.id] ?? item.count;
        final total = item.count;
        final progress = total > 0 ? (total - remaining) / total : 0.0;
        final isComplete = remaining <= 0;

        return _AzkarItemCard(
          item: item,
          remaining: remaining,
          total: total,
          progress: progress,
          isComplete: isComplete,
        );
      },
    );
  }
}

class _AzkarItemCard extends StatelessWidget {
  final AzkarItem item;
  final int remaining;
  final int total;
  final double progress;
  final bool isComplete;

  const _AzkarItemCard({
    required this.item,
    required this.remaining,
    required this.total,
    required this.progress,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Pressable(
      onTap: isComplete
          ? null
          : () => context.read<AzkarBloc>().add(DecrementAzkarCount(item.id)),
      child: AppCard(
        color: isComplete
            ? (isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimaryContainer)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Arabic text
            Text(
              item.textArabic,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                    height: 1.8,
                  ),
            ),
            // Translation
            if (item.textTranslation != null) ...[
              SizedBox(height: AppSizes.paddingXS.h),
              Text(
                item.textTranslation!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
              ),
            ],
            // Reference
            if (item.reference != null) ...[
              SizedBox(height: AppSizes.paddingXS.h),
              Text(
                item.reference!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
            SizedBox(height: AppSizes.paddingS.h),
            // Progress bar + counter
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusXS.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      valueColor: AlwaysStoppedAnimation(accentColor),
                      minHeight: 4.h,
                    ),
                  ),
                ),
                SizedBox(width: AppSizes.paddingS.w),
                Text(
                  '$remaining',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: isComplete
                            ? (isDark ? AppColors.successDark : AppColors.success)
                            : accentColor,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
