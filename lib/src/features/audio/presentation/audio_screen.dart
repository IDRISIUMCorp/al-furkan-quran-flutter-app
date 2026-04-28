import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../theme/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../domain/entities/reciter.dart';
import 'audio_bloc.dart';

/// Audio Screen — browse reciters and manage audio playback
class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<AudioBloc>()..add(const LoadReciters()),
      child: const _AudioView(),
    );
  }
}

class _AudioView extends StatelessWidget {
  const _AudioView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Directionality.of(context) == TextDirection.rtl ? 'القراء' : 'Reciters',
        ),
        elevation: 0,
      ),
      body: BlocBuilder<AudioBloc, AudioState>(
        builder: (context, state) {
          switch (state.status) {
            case AudioStatus.initial:
            case AudioStatus.loading:
              return const SkeletonList(itemCount: 8);
            case AudioStatus.error:
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Failed to load reciters',
                onRetry: () => context.read<AudioBloc>().add(const LoadReciters()),
              );
            case AudioStatus.loaded:
            case AudioStatus.playing:
            case AudioStatus.paused:
              if (state.reciters.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No reciters available',
                  subtitle: 'Check your connection and try again',
                  icon: Icons.record_voice_over_outlined,
                );
              }
              return _ReciterList(reciters: state.reciters);
          }
        },
      ),
    );
  }
}

class _ReciterList extends StatelessWidget {
  final List<Reciter> reciters;

  const _ReciterList({required this.reciters});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(AppSizes.paddingM.w),
      itemCount: reciters.length,
      separatorBuilder: (_, __) => SizedBox(height: AppSizes.paddingS.h),
      itemBuilder: (context, index) {
        return _ReciterCard(reciter: reciters[index]);
      },
    );
  }
}

class _ReciterCard extends StatelessWidget {
  final Reciter reciter;

  const _ReciterCard({required this.reciter});

  String _styleLabel() => switch (reciter.style) {
        ReciterStyle.murattal => 'Murattal',
        ReciterStyle.mujawwad => 'Mujawwad',
        ReciterStyle.muallim => 'Muallim',
        ReciterStyle.warsh => 'Warsh',
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Pressable(
      onTap: () => context.read<AudioBloc>().add(SelectReciter(reciter.id)),
      child: AppCard(
        child: Row(
          children: [
            // Avatar circle
            Container(
              width: AppSizes.avatarL.w,
              height: AppSizes.avatarL.w,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.record_voice_over_rounded,
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
                    isRtl ? reciter.nameArabic : reciter.nameEnglish,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSizes.paddingXS.h),
                  Row(
                    children: [
                      AppChip(label: _styleLabel()),
                      if (reciter.isOfflineAvailable) ...[
                        SizedBox(width: AppSizes.paddingXS.w),
                        Icon(
                          Icons.download_done_rounded,
                          size: AppSizes.iconS.w,
                          color: isDark ? AppColors.successDark : AppColors.success,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.play_circle_outline_rounded,
              size: AppSizes.iconXL.w,
              color: accentColor,
            ),
          ],
        ),
      ),
    );
  }
}
