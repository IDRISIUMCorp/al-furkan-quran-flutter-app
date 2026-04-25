import "package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_repeat_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:flutter_animate/flutter_animate.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Ayah Repeat Bottom Sheet — تكرار الآية أو النطاق
// ═══════════════════════════════════════════════════════════════════

class AyahRepeatBottomSheet extends StatelessWidget {
  const AyahRepeatBottomSheet({super.key});

  static const _repeatOptions = [1, 3, 5, 7, 10, 0]; // 0 = infinite

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = context.read<ThemeCubit>().state.primary;

    return BlocBuilder<AyahRepeatCubit, AyahRepeatState>(
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
                    Icon(Icons.repeat_rounded, color: accent, size: 22),
                    const Gap(10),
                    Text(
                      "تكرار التلاوة",
                      style: TextStyle(
                        color: isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529),
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    if (state.isActive)
                      _cancelChip(context, isDark),
                  ],
                ),
              ),

              const Gap(16),

              // ─── Active Repeat Info ───
              if (state.isActive) ...[
                _activeRepeatCard(state, accent, isDark),
                const Gap(16),
              ],

              // ─── Repeat Single Ayah ───
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  "تكرار الآية الحالية",
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
                children: _repeatOptions.map((count) {
                  final isSelected =
                      state.mode == AyahRepeatMode.singleAyah &&
                      state.repeatCount == count &&
                      state.isActive;
                  return _presetChip(
                    context: context,
                    label: count == 0 ? "∞" : "$count مرات",
                    isSelected: isSelected,
                    accent: accent,
                    isDark: isDark,
                    onTap: () => context.read<AyahRepeatCubit>().startSingleAyah(count: count),
                  );
                }).toList(),
              ),

              const Gap(16),

              // ─── Repeat Current Surah Range ───
              Directionality(
                textDirection: TextDirection.rtl,
                child: Text(
                  "تكرار السورة الحالية",
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
                children: _repeatOptions.map((count) {
                  final ayahState = context.read<AyahKeyCubit>().state;
                  final surahNum = ayahState.current.split(":").first;
                  final isSelected =
                      state.mode == AyahRepeatMode.range &&
                      state.repeatCount == count &&
                      state.isActive;
                  return _presetChip(
                    context: context,
                    label: count == 0 ? "∞" : "$count مرات",
                    isSelected: isSelected,
                    accent: accent,
                    isDark: isDark,
                    onTap: () => context.read<AyahRepeatCubit>().startRange(
                          start: "$surahNum:1",
                          end: ayahState.end,
                          count: count,
                        ),
                  );
                }).toList(),
              ),
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

  Widget _activeRepeatCard(AyahRepeatState state, Color accent, bool isDark) {
    final sub = isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057);

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
            Icon(Icons.repeat_one_rounded, color: accent, size: 20),
            const Gap(10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "التكرار نشط",
                    style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const Gap(2),
                  Text(
                    state.label,
                    style: TextStyle(color: sub, fontSize: 13),
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

  Widget _cancelChip(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => context.read<AyahRepeatCubit>().stop(),
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
