import "dart:ui";

import "package:al_quran_v3/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";

class QuranSettingsBottomSheet extends StatelessWidget {
  const QuranSettingsBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<QuranSettingsCubit>(),
        child: const QuranSettingsBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<QuranSettingsCubit, QuranSettingsState>(
        builder: (context, state) {
          final primary = Theme.of(context).colorScheme.primary;
          final surface = isDarkMode
              ? const Color(0xFF121214)
              : const Color(0xFFFFFCF7);
          final cardColor = isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.025);
          final stroke = isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06);
          final onSurface = isDarkMode ? Colors.white : const Color(0xFF151515);

          final bool themeMatchesMode = isDarkMode
              ? state.isDarkTheme
              : !state.isDarkTheme;

          if (state.isInitialized && !themeMatchesMode) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              context.read<QuranSettingsCubit>().updateTheme(
                isDarkMode ? QuranTheme.nightBlue : QuranTheme.cream,
              );
            });
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.82,
            minChildSize: 0.45,
            maxChildSize: 0.94,
            builder: (context, controller) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.96),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      border: Border(top: BorderSide(color: stroke)),
                    ),
                    child: ListView(
                      controller: controller,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                      children: [
                        Center(
                          child: Container(
                            width: 42,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white24
                                  : Colors.black12,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const Gap(18),
                        Row(
                          children: [
                            _CircleActionButton(
                              icon: Icons.close_rounded,
                              onTap: () => Navigator.of(context).pop(),
                              color: onSurface,
                              backgroundColor: cardColor,
                            ),
                            const Spacer(),
                            Column(
                              children: [
                                Text(
                                  "إعدادات المصحف",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: onSurface,
                                  ),
                                ),
                                Text(
                                  "تحكم في القراءة والمظهر والمكتبة",
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: onSurface.withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            _CircleActionButton(
                              icon: Icons.restart_alt_rounded,
                              onTap: () => context
                                  .read<QuranSettingsCubit>()
                                  .resetToDefaults(),
                              color: primary,
                              backgroundColor: primary.withValues(alpha: 0.12),
                            ),
                          ],
                        ),
                        const Gap(18),
                        _PreviewCard(
                          state: state,
                          cardColor: cardColor,
                          stroke: stroke,
                          primary: primary,
                        ),
                        const Gap(18),
                        _SectionCard(
                          title: "أوضاع جاهزة",
                          subtitle:
                              "بدّل بين أسلوب قراءة سريع بدل الضبط اليدوي كل مرة.",
                          icon: FluentIcons.apps_list_detail_24_regular,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _PresetChip(
                                label: "نظيف",
                                subtitle: "أخف وأهدأ",
                                selected:
                                    state.fontSize <= 21.5 &&
                                    state.pageScale <= 0.98 &&
                                    !state.showPageInfo,
                                onTap: () => context
                                    .read<QuranSettingsCubit>()
                                    .applyPreset(QuranSettingsPreset.minimal),
                                primary: primary,
                                isDark: isDarkMode,
                              ),
                              _PresetChip(
                                label: "متوازن",
                                subtitle: "الافتراضي الأفضل",
                                selected:
                                    (state.fontSize - 23.0).abs() < 0.6 &&
                                    (state.pageScale - 1.0).abs() < 0.03 &&
                                    state.showPageInfo,
                                onTap: () => context
                                    .read<QuranSettingsCubit>()
                                    .applyPreset(QuranSettingsPreset.balanced),
                                primary: primary,
                                isDark: isDarkMode,
                              ),
                              _PresetChip(
                                label: "غامر",
                                subtitle: "أكبر وأكثر تركيزًا",
                                selected:
                                    state.fontSize >= 26.5 &&
                                    state.pageScale >= 1.05 &&
                                    !state.showVerseNumbers,
                                onTap: () => context
                                    .read<QuranSettingsCubit>()
                                    .applyPreset(QuranSettingsPreset.immersive),
                                primary: primary,
                                isDark: isDarkMode,
                              ),
                            ],
                          ),
                        ),
                        const Gap(14),
                        _SectionCard(
                          title: "القراءة",
                          subtitle:
                              "تكبير الخط الآن يوسّع الإحساس البصري للصفحة عرضًا وارتفاعًا معًا.",
                          icon: FluentIcons.text_font_size_24_regular,
                          child: Column(
                            children: [
                              _SliderSettingCard(
                                label: "حجم الخط",
                                valueLabel: state.fontSize.toStringAsFixed(0),
                                icon: FluentIcons.text_font_size_24_regular,
                                min: 18,
                                max: 34,
                                divisions: 16,
                                value: state.fontSize,
                                primary: primary,
                                isDark: isDarkMode,
                                onChanged: (value) => context
                                    .read<QuranSettingsCubit>()
                                    .updateFontSize(value),
                              ),
                              const Gap(12),
                              _SliderSettingCard(
                                label: "اتساع الصفحة",
                                valueLabel:
                                    "${(state.pageScale * 100).round()}%",
                                icon:
                                    FluentIcons.panel_left_contract_24_regular,
                                min: 0.94,
                                max: 1.10,
                                divisions: 16,
                                value: state.pageScale,
                                primary: primary,
                                isDark: isDarkMode,
                                onChanged: (value) => context
                                    .read<QuranSettingsCubit>()
                                    .updatePageScale(value),
                              ),
                            ],
                          ),
                        ),
                        const Gap(14),
                        _SectionCard(
                          title: "الثيم",
                          subtitle: "اختيار ثيم هادئ ومقروء بنفس روح التطبيق.",
                          icon: FluentIcons.color_24_regular,
                          child: _QuranThemeSelector(
                            state: state,
                            primary: primary,
                            isDark: isDarkMode,
                          ),
                        ),
                        const Gap(14),
                        _SectionCard(
                          title: "أدوات القراءة",
                          subtitle: "كل مفتاح هنا ينعكس مباشرة داخل المصحف.",
                          icon: FluentIcons.book_open_24_regular,
                          child: Column(
                            children: [
                              _SwitchTile(
                                icon: FluentIcons.sparkle_circle_24_regular,
                                title: "تجويد ملون",
                                subtitle: "إظهار أحكام التجويد داخل النص.",
                                value: state.tajweedEnabled,
                                onChanged: (value) => context
                                    .read<QuranSettingsCubit>()
                                    .toggleTajweed(value),
                                primary: primary,
                                isDark: isDarkMode,
                              ),
                              const Gap(10),
                              _SwitchTile(
                                icon: FluentIcons.number_symbol_24_regular,
                                title: "أرقام الآيات",
                                subtitle: "إظهار رموز أرقام الآيات وعلاماتها.",
                                value: state.showVerseNumbers,
                                onChanged: (value) => context
                                    .read<QuranSettingsCubit>()
                                    .toggleVerseNumbers(value),
                                primary: primary,
                                isDark: isDarkMode,
                              ),
                              const Gap(10),
                              _SwitchTile(
                                icon: FluentIcons.document_header_24_regular,
                                title: "زخرفة السورة",
                                subtitle: "إظهار عنوان السورة في بداية الصفحة.",
                                value: state.showSurahHeader,
                                onChanged: (value) => context
                                    .read<QuranSettingsCubit>()
                                    .toggleSurahHeader(value),
                                primary: primary,
                                isDark: isDarkMode,
                              ),
                              const Gap(10),
                              _SwitchTile(
                                icon:
                                    FluentIcons.text_bullet_list_ltr_24_regular,
                                title: "معلومات الصفحة",
                                subtitle: "اسم السورة والجزء والصفحة والحزب.",
                                value: state.showPageInfo,
                                onChanged: (value) => context
                                    .read<QuranSettingsCubit>()
                                    .togglePageInfo(value),
                                primary: primary,
                                isDark: isDarkMode,
                              ),
                              const Gap(10),
                              _SwitchTile(
                                icon: Icons.short_text_rounded,
                                title: "البسملة",
                                subtitle: "إظهار البسملة في مواضعها المعتادة.",
                                value: state.showBasmala,
                                onChanged: (value) => context
                                    .read<QuranSettingsCubit>()
                                    .toggleBasmala(value),
                                primary: primary,
                                isDark: isDarkMode,
                              ),
                            ],
                          ),
                        ),
                        const Gap(14),
                        _SectionCard(
                          title: "المكتبة الذكية",
                          subtitle:
                              "إعدادات افتراضية للوصول السريع من نافذة المكتبة.",
                          icon: FluentIcons.library_24_regular,
                          child: Column(
                            children: [
                              _SwitchTile(
                                icon: FluentIcons.book_database_24_regular,
                                title: "إظهار التفاسير",
                                subtitle:
                                    "إبقاء بطاقات التفسير مفعلة داخل المكتبة.",
                                value: state.enableTafsir,
                                onChanged: (value) => context
                                    .read<QuranSettingsCubit>()
                                    .toggleTafsir(value),
                                primary: primary,
                                isDark: isDarkMode,
                              ),
                              const Gap(10),
                              _SwitchTile(
                                icon: FluentIcons
                                    .text_grammar_arrow_left_24_regular,
                                title: "الإعراب والتحليل",
                                subtitle: "السماح بتبويب الإعراب من المكتبة.",
                                value: state.enableIrab,
                                onChanged: (value) => context
                                    .read<QuranSettingsCubit>()
                                    .toggleIrab(value),
                                primary: primary,
                                isDark: isDarkMode,
                              ),
                            ],
                          ),
                        ),
                        const Gap(14),
                        _SectionCard(
                          title: "لون التظليل",
                          subtitle:
                              "لون إبراز الكلمة أو الآية أثناء التفاعل أو الاستماع.",
                          icon: FluentIcons.highlight_24_regular,
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _highlightColors
                                .map(
                                  (color) => _HighlightColorDot(
                                    color: color,
                                    selected:
                                        state.highlightColor.value ==
                                        color.value,
                                    primary: primary,
                                    onTap: () => context
                                        .read<QuranSettingsCubit>()
                                        .updateHighlightColor(color),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final QuranSettingsState state;
  final Color cardColor;
  final Color stroke;
  final Color primary;

  const _PreviewCard({
    required this.state,
    required this.cardColor,
    required this.stroke,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      state.tajweedEnabled ? "تجويد" : "نص صافي",
      state.showPageInfo ? "معلومات الصفحة" : "واجهة هادئة",
      state.showVerseNumbers ? "أرقام الآيات" : "تركيز أعلى",
    ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: state.backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: stroke),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: state.textColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        color: state.textColor.withValues(alpha: 0.78),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const Gap(16),
          Text(
            "سورة الفاتحة • آية ٦",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: state.textColor.withValues(alpha: 0.55),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(12),
          DefaultTextStyle(
            style: TextStyle(
              fontFamily: "KFGQPC-Uthmanic-HAFS-Regular",
              fontSize: state.fontSize,
              color: state.textColor,
              height: 1.9 * state.verseHeightScale,
            ),
            textAlign: TextAlign.center,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: "ٱهْدِنَا "),
                  TextSpan(
                    text: "ٱلصِّرَٰطَ",
                    style: TextStyle(
                      backgroundColor: state.highlightColor.withValues(
                        alpha: 0.28,
                      ),
                    ),
                  ),
                  const TextSpan(text: " ٱلْمُسْتَقِيمَ"),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "الاتساع الحالي ${(state.contentScale * 100).round()}% ويزداد تلقائيًا مع تكبير الخط.",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: state.textColor.withValues(alpha: 0.72),
                    ),
                  ),
                ),
                const Gap(10),
                Icon(
                  FluentIcons.arrow_maximize_24_regular,
                  size: 18,
                  color: primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: primary, size: 20),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF151515),
                      ),
                    ),
                    const Gap(2),
                    Text(
                      subtitle,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(14),
          child,
        ],
      ),
    );
  }
}

class _SliderSettingCard extends StatelessWidget {
  final String label;
  final String valueLabel;
  final IconData icon;
  final double min;
  final double max;
  final int divisions;
  final double value;
  final Color primary;
  final bool isDark;
  final ValueChanged<double> onChanged;

  const _SliderSettingCard({
    required this.label,
    required this.valueLabel,
    required this.icon,
    required this.min,
    required this.max,
    required this.divisions,
    required this.value,
    required this.primary,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.035)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 18, color: primary),
              ),
              const Spacer(),
              Text(
                valueLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: primary,
                ),
              ),
              const Gap(8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF151515),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              activeColor: primary,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color primary;
  final bool isDark;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.035)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        children: [
          Switch.adaptive(
            value: value,
            activeColor: primary,
            onChanged: onChanged,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF151515),
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: primary),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Color primary;
  final bool isDark;

  const _PresetChip({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 110,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? primary.withValues(alpha: 0.12)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.035)
                    : Colors.black.withValues(alpha: 0.025)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? primary.withValues(alpha: 0.28)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.04)),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : Icons.tune_rounded,
              size: 18,
              color: selected
                  ? primary
                  : (isDark ? Colors.white54 : Colors.black54),
            ),
            const Gap(12),
            Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF151515),
              ),
            ),
            const Gap(2),
            Text(
              subtitle,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: (isDark ? Colors.white : Colors.black).withValues(
                  alpha: 0.55,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color backgroundColor;

  const _CircleActionButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _HighlightColorDot extends StatelessWidget {
  final Color color;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _HighlightColorDot({
    required this.color,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? primary : Colors.transparent,
            width: selected ? 3 : 0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: selected
            ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
            : null,
      ),
    );
  }
}

class _QuranThemeSelector extends StatelessWidget {
  final QuranSettingsState state;
  final Color primary;
  final bool isDark;

  const _QuranThemeSelector({
    required this.state,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final themes = _themeOptions.where((entry) {
      final theme = entry.$1;
      if (isDark) return theme.isDark;
      return !theme.isDark;
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: themes.map((entry) {
          final theme = entry.$1;
          final swatch = entry.$2;
          final foreground = entry.$3;
          final selected = state.theme == theme;

          return Padding(
            padding: const EdgeInsets.only(left: 10),
            child: InkWell(
              onTap: () =>
                  context.read<QuranSettingsCubit>().updateTheme(theme),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: 112,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: swatch,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected
                        ? primary
                        : foreground.withValues(alpha: 0.14),
                    width: selected ? 2.2 : 1,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: selected
                            ? primary
                            : foreground.withValues(alpha: 0.5),
                      ),
                    ),
                    const Gap(20),
                    Text(
                      theme.label,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: foreground,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      theme.description,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: foreground.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

extension on QuranTheme {
  String get label {
    switch (this) {
      case QuranTheme.oled:
        return "OLED";
      case QuranTheme.nightBlue:
        return "أزرق ليلي";
      case QuranTheme.custom:
        return "داكن ناعم";
      case QuranTheme.graphite:
        return "جرافيت";
      case QuranTheme.midnightPurple:
        return "ليلي بنفسجي";
      case QuranTheme.sepia:
        return "سيبيا";
      case QuranTheme.cream:
        return "كريمي";
      case QuranTheme.paperWhite:
        return "ورقي أبيض";
      case QuranTheme.sand:
        return "رملي";
    }
  }

  String get description {
    switch (this) {
      case QuranTheme.oled:
        return "أسود عميق";
      case QuranTheme.nightBlue:
        return "هادئ ومريح";
      case QuranTheme.custom:
        return "داكن متزن";
      case QuranTheme.graphite:
        return "محترف محايد";
      case QuranTheme.midnightPurple:
        return "عميق وحالم";
      case QuranTheme.sepia:
        return "كلاسيكي دافئ";
      case QuranTheme.cream:
        return "الأقرب للمصحف";
      case QuranTheme.paperWhite:
        return "أوضح تباين";
      case QuranTheme.sand:
        return "فاتح هادئ";
    }
  }

  bool get isDark {
    switch (this) {
      case QuranTheme.oled:
      case QuranTheme.nightBlue:
      case QuranTheme.custom:
      case QuranTheme.graphite:
      case QuranTheme.midnightPurple:
        return true;
      case QuranTheme.sepia:
      case QuranTheme.cream:
      case QuranTheme.paperWhite:
      case QuranTheme.sand:
        return false;
    }
  }
}

const List<Color> _highlightColors = [
  Color(0xFFFFC857),
  Color(0xFF25A18E),
  Color(0xFF3D5AFE),
  Color(0xFFAA5CEB),
  Color(0xFFFF7A59),
  Color(0xFFEF476F),
  Color(0xFF00B4D8),
  Color(0xFF5C7C47),
];

final List<(QuranTheme, Color, Color)> _themeOptions = [
  (QuranTheme.oled, Colors.black, Colors.white),
  (QuranTheme.nightBlue, const Color(0xFF0F172A), Colors.white),
  (QuranTheme.custom, const Color(0xFF111318), Colors.white),
  (QuranTheme.graphite, const Color(0xFF161A1D), Colors.white),
  (QuranTheme.midnightPurple, const Color(0xFF1B1234), Colors.white),
  (QuranTheme.sepia, const Color(0xFFF4ECD8), const Color(0xFF3E2723)),
  (QuranTheme.cream, const Color(0xFFFFF7DD), const Color(0xFF2F2417)),
  (QuranTheme.paperWhite, Colors.white, const Color(0xFF151515)),
  (QuranTheme.sand, const Color(0xFFF3E7D3), const Color(0xFF2E241B)),
];
