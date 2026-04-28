import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../theme/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../domain/entities/tafsir.dart';
import 'tafsir_bloc.dart';

/// Tafsir Screen — browse tafsirs and view ayah-level commentary
class TafsirScreen extends StatelessWidget {
  const TafsirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<TafsirBloc>()..add(const LoadAllTafsirs()),
      child: const _TafsirView(),
    );
  }
}

class _TafsirView extends StatelessWidget {
  const _TafsirView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Directionality.of(context) == TextDirection.rtl ? 'التفسير' : 'Tafsir',
        ),
        elevation: 0,
      ),
      body: BlocBuilder<TafsirBloc, TafsirState>(
        builder: (context, state) {
          switch (state.status) {
            case TafsirStatus.initial:
            case TafsirStatus.loading:
              return const SkeletonList(itemCount: 6);
            case TafsirStatus.error:
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Failed to load tafsirs',
                onRetry: () => context.read<TafsirBloc>().add(const LoadAllTafsirs()),
              );
            case TafsirStatus.loaded:
              if (state.tafsirs.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No tafsirs available',
                  subtitle: 'Download tafsirs for offline use',
                  icon: Icons.menu_book_outlined,
                );
              }
              return _TafsirList(tafsirs: state.tafsirs);
          }
        },
      ),
    );
  }
}

class _TafsirList extends StatelessWidget {
  final List<Tafsir> tafsirs;

  const _TafsirList({required this.tafsirs});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.paddingM.w),
      itemCount: tafsirs.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSizes.paddingS.h),
      itemBuilder: (context, index) {
        final tafsir = tafsirs[index];
        return _TafsirCard(tafsir: tafsir);
      },
    );
  }
}

class _TafsirCard extends StatelessWidget {
  final Tafsir tafsir;

  const _TafsirCard({required this.tafsir});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Pressable(
      onTap: () => context.read<TafsirBloc>().add(SelectTafsir(tafsir.id)),
      child: AppCard(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSizes.paddingM.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimaryContainer,
                borderRadius: BorderRadius.circular(AppSizes.radiusS.r),
              ),
              child: Icon(
                Icons.menu_book_outlined,
                size: AppSizes.iconL.w,
                color: accentColor,
              ),
            ),
            SizedBox(width: AppSizes.paddingM.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tafsir.nameEnglish,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (tafsir.languageCode.isNotEmpty) ...[
                    SizedBox(height: AppSizes.paddingXS.h),
                    AppChip(label: tafsir.languageCode),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: AppSizes.iconL.w,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tafsir Detail Screen — shows tafsir entries for a surah
class TafsirDetailScreen extends StatelessWidget {
  final int tafsirId;
  final int surahId;

  const TafsirDetailScreen({
    required this.tafsirId,
    required this.surahId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<TafsirBloc>()
        ..add(LoadTafsirForSurah(tafsirId: tafsirId, surahId: surahId)),
      child: const _TafsirDetailView(),
    );
  }
}

class _TafsirDetailView extends StatelessWidget {
  const _TafsirDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: BlocBuilder<TafsirBloc, TafsirState>(
        builder: (context, state) {
          switch (state.status) {
            case TafsirStatus.initial:
            case TafsirStatus.loading:
              return const SkeletonList(itemCount: 10);
            case TafsirStatus.error:
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Failed to load tafsir',
                onRetry: () => context.read<TafsirBloc>().add(const LoadAllTafsirs()),
              );
            case TafsirStatus.loaded:
              if (state.currentEntries.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No tafsir entries found',
                  icon: Icons.menu_book_outlined,
                );
              }
              return ListView.separated(
                padding: EdgeInsets.all(AppSizes.paddingM.w),
                itemCount: state.currentEntries.length,
                separatorBuilder: (_, __) => Divider(
                  height: AppSizes.paddingM.h,
                  color: AppColors.lightBorderSubtle,
                ),
                itemBuilder: (context, index) {
                  final entry = state.currentEntries[index];
                  return _TafsirEntryCard(entry: entry);
                },
              );
          }
        },
      ),
    );
  }
}

class _TafsirEntryCard extends StatelessWidget {
  final TafsirEntry entry;

  const _TafsirEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSizes.paddingS.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ayah reference
          AppChip(label: entry.ayahKey),
          SizedBox(height: AppSizes.paddingS.h),
          // Arabic text
          if (entry.text.isNotEmpty)
            Text(
              entry.text,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                    height: 1.8,
                  ),
            ),
        ],
      ),
    );
  }
}
