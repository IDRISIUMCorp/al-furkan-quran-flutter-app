import "package:al_furkan/src/core/reading_stats/reading_stats_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:flutter_animate/flutter_animate.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Reading Stats Screen — إحصائيات القراءة
// ═══════════════════════════════════════════════════════════════════

class ReadingStatsScreen extends StatelessWidget {
  const ReadingStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = context.read<ThemeCubit>().state.primary;
    final bg = isDark ? const Color(0xFF212529) : const Color(0xFFF7F1E6);
    final surface = isDark ? const Color(0xFF343A40) : const Color(0xFFF5EBE0);
    final text = isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529);
    final sub = isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          title: Text("إحصائيات القراءة", style: TextStyle(color: text, fontWeight: FontWeight.w800)),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_rounded, color: text), onPressed: () => Navigator.pop(context)),
        ),
        body: BlocBuilder<ReadingStatsCubit, ReadingStatsState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ─── Streak Card ───
                _statCard(
                  surface: surface,
                  isDark: isDark,
                  accent: accent,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(Icons.local_fire_department_rounded, color: accent, size: 32),
                      ),
                      const Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.streak > 0 ? "${state.streak} يوم متتالي" : "ابدأ سلسلتك!",
                              style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 20),
                            ),
                            const Gap(4),
                            Text(
                              state.streak > 0 ? "استمر! كل يوم بيعد سلسلتك" : "اقرأ صفحة واحدة اليوم",
                              style: TextStyle(color: sub, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      if (state.streak > 0)
                        Text(
                          "🔥",
                          style: TextStyle(fontSize: 36 - (state.streak > 7 ? 8 : 0)),
                        ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0),

                const Gap(16),

                // ─── Today Stats ───
                Text("اليوم", style: TextStyle(color: sub, fontWeight: FontWeight.w700, fontSize: 16)),
                const Gap(10),
                Row(
                  children: [
                    Expanded(
                      child: _miniStatCard(
                        surface: surface,
                        isDark: isDark,
                        accent: accent,
                        icon: Icons.menu_book_rounded,
                        label: "صفحات",
                        value: "${state.pagesToday}",
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: _miniStatCard(
                        surface: surface,
                        isDark: isDark,
                        accent: accent,
                        icon: Icons.format_list_numbered_rounded,
                        label: "آيات",
                        value: "${state.ayahsToday}",
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: _miniStatCard(
                        surface: surface,
                        isDark: isDark,
                        accent: accent,
                        icon: Icons.timer_rounded,
                        label: "وقت",
                        value: state.formattedTimeToday,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 350.ms, delay: 100.ms),

                const Gap(16),

                // ─── All Time Stats ───
                Text("الإجمالي", style: TextStyle(color: sub, fontWeight: FontWeight.w700, fontSize: 16)),
                const Gap(10),
                Row(
                  children: [
                    Expanded(
                      child: _miniStatCard(
                        surface: surface,
                        isDark: isDark,
                        accent: accent,
                        icon: Icons.book_rounded,
                        label: "إجمالي الصفحات",
                        value: "${state.totalPagesAllTime}",
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: _miniStatCard(
                        surface: surface,
                        isDark: isDark,
                        accent: accent,
                        icon: Icons.text_fields_rounded,
                        label: "إجمالي الآيات",
                        value: "${state.totalAyahsAllTime}",
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 150.ms),

                const Gap(24),

                // ─── Khatma Completion ───
                Text("إنجاز الختمة", style: TextStyle(color: sub, fontWeight: FontWeight.w700, fontSize: 16)),
                const Gap(10),
                _statCard(
                  surface: surface,
                  isDark: isDark,
                  accent: accent,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.totalPagesAllTime >= 604
                                      ? "تمت الختمة! 🎉"
                                      : "تقدم الختمة",
                                  style: TextStyle(
                                    color: state.totalPagesAllTime >= 604 ? accent : text,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  "${state.totalPagesAllTime} من 604 صفحة",
                                  style: TextStyle(color: sub, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 64,
                            height: 64,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: (state.totalPagesAllTime / 604).clamp(0.0, 1.0),
                                  strokeWidth: 5,
                                  backgroundColor: accent.withValues(alpha: 0.12),
                                  valueColor: AlwaysStoppedAnimation(accent),
                                ),
                                Text(
                                  "${(state.totalPagesAllTime / 604 * 100).round()}%",
                                  style: TextStyle(
                                    color: accent,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 420.ms, delay: 175.ms),

                const Gap(24),

                // ─── Daily Goal ───
                Text("الورد اليومي", style: TextStyle(color: sub, fontWeight: FontWeight.w700, fontSize: 16)),
                const Gap(10),
                _statCard(
                  surface: surface,
                  isDark: isDark,
                  accent: accent,
                  child: Column(
                    children: [
                      if (state.hasGoal) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                state.goalReached ? "🎉 تم الورد!" : "تقدم الورد",
                                style: TextStyle(
                                  color: state.goalReached ? accent : text,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              "${(state.goalProgress * 100).round()}%",
                              style: TextStyle(
                                color: accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: state.goalProgress,
                            minHeight: 10,
                            backgroundColor: accent.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation(accent),
                          ),
                        ),
                        const Gap(8),
                        Text(
                          state.dailyGoalPages > 0
                              ? "${state.pagesToday} / ${state.dailyGoalPages} صفحة"
                              : "${state.ayahsToday} / ${state.dailyGoalAyahs} آية",
                          style: TextStyle(color: sub, fontSize: 13),
                        ),
                      ] else ...[
                        Text(
                          "حدد وردك اليومي عشان تتابع تقدمك",
                          style: TextStyle(color: sub, fontSize: 14),
                        ),
                      ],
                      const Gap(12),
                      _goalSettingRow(context, state, accent, isDark, text, sub),
                    ],
                  ),
                ).animate().fadeIn(duration: 450.ms, delay: 200.ms),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _goalSettingRow(BuildContext context, ReadingStatsState state, Color accent, bool isDark, Color text, Color sub) {
    final goalOptions = [3, 5, 10, 20];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goalOptions.map((pages) {
        final isSelected = state.dailyGoalPages == pages;
        return GestureDetector(
          onTap: () => context.read<ReadingStatsCubit>().setDailyGoal(pages: pages),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? accent.withValues(alpha: 0.15) : isDark ? const Color(0xFF495057).withValues(alpha: 0.3) : const Color(0xFFE3D5CA).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? accent : Colors.transparent, width: 1.5),
            ),
            child: Text(
              "$pages صفحات",
              style: TextStyle(
                color: isSelected ? accent : sub,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _statCard({
    required Color surface,
    required bool isDark,
    required Color accent,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFFADB5BD).withValues(alpha: 0.1) : const Color(0xFFD6CCC2).withValues(alpha: 0.3),
        ),
      ),
      child: child,
    );
  }

  Widget _miniStatCard({
    required Color surface,
    required bool isDark,
    required Color accent,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final text = isDark ? const Color(0xFFF8F9FA) : const Color(0xFF212529);
    final sub = isDark ? const Color(0xFFADB5BD) : const Color(0xFF495057);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFFADB5BD).withValues(alpha: 0.1) : const Color(0xFFD6CCC2).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 22),
          const Gap(8),
          Text(value, style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 18)),
          const Gap(2),
          Text(label, style: TextStyle(color: sub, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
