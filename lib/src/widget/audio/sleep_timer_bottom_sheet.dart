import "package:al_furkan/src/core/audio/cubit/sleep_timer_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:flutter_animate/flutter_animate.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Sleep Timer Bottom Sheet — مؤقت النوم
// ═══════════════════════════════════════════════════════════════════

class SleepTimerBottomSheet extends StatelessWidget {
  const SleepTimerBottomSheet({super.key});

  static const _presetMinutes = [15, 30, 45, 60, 90, 120];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = context.read<ThemeCubit>().state.primary;

    return BlocBuilder<SleepTimerCubit, SleepTimerState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Handle ───
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFADB5BD).withValues(alpha: 0.3)
                      : const Color(0xFFD6CCC2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ─── Title ───
              Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    Icon(Icons.bedtime_rounded, color: accent, size: 22),
                    const Gap(10),
                    Text(
                      "مؤقت النوم",
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529),
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    if (state.isActive)
                      _cancelChip(context, accent, isDark),
                  ],
                ),
              ),

              const Gap(16),

              // ─── Active Timer Info ───
              if (state.isActive) ...[
                _activeTimerCard(state, accent, isDark),
                const Gap(16),
              ],

              // ─── Preset Buttons ───
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  "اختر الوقت",
                  style: TextStyle(
                    color: isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const Gap(10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _presetMinutes.map((m) {
                  final isSelected =
                      state.mode == SleepTimerMode.minutes &&
                      state.totalMinutes == m &&
                      state.isActive;
                  return _presetChip(
                    context: context,
                    label: "$m دقيقة",
                    isSelected: isSelected,
                    accent: accent,
                    isDark: isDark,
                    onTap: () => context.read<SleepTimerCubit>().startMinutesTimer(m),
                  );
                }).toList(),
              ),

              const Gap(16),

              // ─── End of Surah Option ───
              _endOfSurahChip(context, accent, isDark,
                  isActive: state.mode == SleepTimerMode.endOfSurah && state.isActive),
            ],
          ),
        ),
      )
          .animate()
            .fadeIn(duration: 250.ms)
            .slideY(begin: 0.1, end: 0, duration: 250.ms);
      },
    );
  }

  Widget _activeTimerCard(SleepTimerState state, Color accent, bool isDark) {
    final text = isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529);
    final sub = isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057);

    String label;
    if (state.mode == SleepTimerMode.endOfSurah) {
      label = "نهاية السورة الحالية";
    } else {
      final mins = state.remainingMinutes;
      final hrs = mins ~/ 60;
      final rem = mins % 60;
      label = hrs > 0 ? "$hrs ساعة ${rem > 0 ? 'و $rem دقيقة' : ''}" : "$mins دقيقة";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Icon(Icons.timer_rounded, color: accent, size: 20),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "المؤقت نشط",
                    style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const Gap(2),
                  Text(
                    "متبقي: $label",
                    style: TextStyle(color: sub, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (state.mode == SleepTimerMode.minutes)
              SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: state.progress,
                      strokeWidth: 3,
                      backgroundColor: accent.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation(accent),
                    ),
                    Center(
                      child: Text(
                        "${state.remainingMinutes}",
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _presetChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required Color accent,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.15)
              : isDark
                  ? const Color(0xFF495057).withValues(alpha: 0.5)
                  : const Color(0xFFE3D5CA).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? accent : isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _endOfSurahChip(BuildContext context, Color accent, bool isDark,
      {required bool isActive}) {
    return GestureDetector(
      onTap: () => context.read<SleepTimerCubit>().startEndOfSurah(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? accent.withValues(alpha: 0.15)
              : isDark
                  ? const Color(0xFF495057).withValues(alpha: 0.5)
                  : const Color(0xFFE3D5CA).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stop_circle_rounded, color: isActive ? accent : isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057), size: 18),
              const Gap(8),
              Text(
                "نهاية السورة الحالية",
                style: TextStyle(
                  color: isActive ? accent : isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cancelChip(BuildContext context, Color accent, bool isDark) {
    return GestureDetector(
      onTap: () => context.read<SleepTimerCubit>().cancelTimer(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: const Text(
          "إلغاء",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }
}
