import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../shared/widgets/widgets.dart';
import '../../../theme/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../domain/entities/prayer_time.dart';
import '../presentation/prayer_bloc.dart';

/// Prayer Times Screen — today's schedule with next prayer highlight
class PrayerTimesScreen extends StatelessWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<PrayerBloc>()..add(const LoadTodayPrayerTimes()),
      child: const _PrayerTimesView(),
    );
  }
}

class _PrayerTimesView extends StatelessWidget {
  const _PrayerTimesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Directionality.of(context) == TextDirection.rtl ? 'مواقيت الصلاة' : 'Prayer Times',
        ),
        elevation: 0,
      ),
      body: BlocBuilder<PrayerBloc, PrayerState>(
        builder: (context, state) {
          switch (state.status) {
            case PrayerStatus.initial:
            case PrayerStatus.loading:
              return const SkeletonList(itemCount: 6);
            case PrayerStatus.error:
              return ErrorStateWidget(
                message: state.errorMessage ?? 'Failed to load prayer times',
                onRetry: () => context.read<PrayerBloc>().add(const LoadTodayPrayerTimes()),
              );
            case PrayerStatus.loaded:
              final schedule = state.schedule;
              if (schedule == null) {
                return const EmptyStateWidget(
                  title: 'No prayer times available',
                  subtitle: 'Enable location to get accurate times',
                  icon: Icons.location_off_outlined,
                );
              }
              return _PrayerScheduleView(schedule: schedule);
          }
        },
      ),
    );
  }
}

class _PrayerScheduleView extends StatelessWidget {
  final DailyPrayerSchedule schedule;

  const _PrayerScheduleView({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nextPrayer = schedule.nextPrayer;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PrayerBloc>().add(const RefreshPrayerTimes());
      },
      child: ListView(
        padding: EdgeInsets.all(AppSizes.paddingM.w),
        children: [
          // Hijri date header
          AppCard(
            color: isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimaryContainer,
            child: Column(
              children: [
                Text(
                  '${schedule.hijriDate} ${schedule.hijriMonth} ${schedule.hijriYear}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isDark ? AppColors.darkTextMain : AppColors.lightTextMain,
                      ),
                ),
                SizedBox(height: AppSizes.paddingXS.h),
                Text(
                  schedule.location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSizes.paddingM.h),
          // Next prayer highlight
          if (nextPrayer != null) ...[
            _NextPrayerCard(prayer: nextPrayer),
            SizedBox(height: AppSizes.paddingM.h),
          ],
          // Prayer times list
          ...schedule.prayers.map((prayer) => _PrayerTimeCard(
                prayer: prayer,
                isNext: nextPrayer?.type == prayer.type,
              )),
        ],
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  final PrayerTime prayer;

  const _NextPrayerCard({required this.prayer});

  String _prayerName(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return switch (prayer.type) {
      PrayerType.fajr => isRtl ? 'الفجر' : 'Fajr',
      PrayerType.sunrise => isRtl ? 'الشروق' : 'Sunrise',
      PrayerType.dhuhr => isRtl ? 'الظهر' : 'Dhuhr',
      PrayerType.asr => isRtl ? 'العصر' : 'Asr',
      PrayerType.maghrib => isRtl ? 'المغرب' : 'Maghrib',
      PrayerType.isha => isRtl ? 'العشاء' : 'Isha',
    };
  }

  IconData _prayerIcon() => switch (prayer.type) {
        PrayerType.fajr => Icons.wb_twilight_outlined,
        PrayerType.sunrise => Icons.wb_sunny_outlined,
        PrayerType.dhuhr => Icons.wb_sunny,
        PrayerType.asr => Icons.light_mode_outlined,
        PrayerType.maghrib => Icons.nights_stay_outlined,
        PrayerType.isha => Icons.dark_mode_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return AppCard(
      color: accentColor,
      child: Row(
        children: [
          Icon(_prayerIcon(), size: AppSizes.iconXXL.w, color: Colors.white),
          SizedBox(width: AppSizes.paddingM.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _prayerName(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                SizedBox(height: AppSizes.paddingXS.h),
                Text(
                  _formatTime(prayer.time),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Directionality.of(context) == TextDirection.rtl ? 'الصلاة القادمة' : 'Next Prayer',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerTimeCard extends StatelessWidget {
  final PrayerTime prayer;
  final bool isNext;

  const _PrayerTimeCard({required this.prayer, required this.isNext});

  String _prayerName(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return switch (prayer.type) {
      PrayerType.fajr => isRtl ? 'الفجر' : 'Fajr',
      PrayerType.sunrise => isRtl ? 'الشروق' : 'Sunrise',
      PrayerType.dhuhr => isRtl ? 'الظهر' : 'Dhuhr',
      PrayerType.asr => isRtl ? 'العصر' : 'Asr',
      PrayerType.maghrib => isRtl ? 'المغرب' : 'Maghrib',
      PrayerType.isha => isRtl ? 'العشاء' : 'Isha',
    };
  }

  IconData _prayerIcon() => switch (prayer.type) {
        PrayerType.fajr => Icons.wb_twilight_outlined,
        PrayerType.sunrise => Icons.wb_sunny_outlined,
        PrayerType.dhuhr => Icons.wb_sunny,
        PrayerType.asr => Icons.light_mode_outlined,
        PrayerType.maghrib => Icons.nights_stay_outlined,
        PrayerType.isha => Icons.dark_mode_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return AppCard(
      color: isNext
          ? (isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimaryContainer)
          : null,
      child: Row(
        children: [
          Icon(
            _prayerIcon(),
            size: AppSizes.iconL.w,
            color: isNext ? accentColor : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
          ),
          SizedBox(width: AppSizes.paddingM.w),
          Expanded(
            child: Text(
              _prayerName(context),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isNext
                        ? accentColor
                        : (isDark ? AppColors.darkTextMain : AppColors.lightTextMain),
                    fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
          Text(
            _formatTime(prayer.time),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isNext
                      ? accentColor
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
                ),
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final hour = time.hour;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  return '$displayHour:$minute $period';
}
