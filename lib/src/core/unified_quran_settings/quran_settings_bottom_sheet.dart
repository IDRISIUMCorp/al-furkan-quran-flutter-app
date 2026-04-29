import "package:al_furkan/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flex_color_picker/flex_color_picker.dart";
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
              ? Theme.of(context).colorScheme.surface
              : const Color(0xFFFFFCF7);
          final cardColor = isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.025);
          final stroke = isDarkMode
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06);
          final onSurface = isDarkMode ? Colors.white : const Color(0xFF151515);

          // Don't auto-switch themes at all - let user control it
          // The postFrameCallback was causing the custom theme to reset

          return DraggableScrollableSheet(
            initialChildSize: 0.82,
            minChildSize: 0.45,
            maxChildSize: 0.94,
            builder: (context, controller) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: surface.withValues(alpha: 0.98),
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
                                    fontWeight: FontWeight.w800,
                                    color: onSurface,
                                  ),
                                ),
                                Text(
                                  "تحكم في القراءة والمظهر",
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
                          title: "خلفيات المصحف",
                          subtitle: "اختر من الخلفيات الجاهزة أو أضف خلفيتك الخاصة.",
                          icon: FluentIcons.color_background_24_regular,
                          child: _UnifiedBackgroundsSection(
                            state: state,
                            primary: primary,
                            isDark: isDarkMode,
                          ),
                        ),
                        const Gap(14),
                        _SectionCard(
                          title: "لون التظليل",
                          subtitle:
                              "لون إبراز الكلمة أو الآية أثناء التفاعل أو الاستماع.",
                          icon: FluentIcons.highlight_24_regular,
                          child: _HighlightColorSection(
                            state: state,
                            primary: primary,
                            isDark: isDarkMode,
                          ),
                        ),
                        const Gap(14),
                        _SectionCard(
                          title: "القراءة",
                          subtitle:
                              "تكبير الخط يوسّع الإحساس البصري للصفحة.",
                          icon: FluentIcons.text_font_size_24_regular,
                          child: _SliderSettingCard(
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
                        ),
                        const Gap(14),
                        _SectionCard(
                          title: "طريقة العرض",
                          subtitle: "اختر كيف تظهر صفحات المصحف أثناء القراءة.",
                          icon: FluentIcons.document_landscape_24_regular,
                          child: _LayoutModeSection(
                            state: state,
                            primary: primary,
                            isDark: isDarkMode,
                          ),
                        ),
                        const Gap(14),
                        _SectionCard(
                          title: "خط القرآن",
                          subtitle: "اختر خط عرض النص القرآني في وضع الآيات.",
                          icon: FluentIcons.text_font_24_regular,
                          child: _FontFamilySection(
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
                      ].animate(interval: 50.ms).fade(duration: 400.ms, curve: Curves.easeOutCubic).slideY(begin: 0.1, curve: Curves.easeOutCubic),
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
                    text: "ٱلصِّرَٰطَ",
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
                        fontWeight: FontWeight.w800,
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
                  fontWeight: FontWeight.w800,
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
            activeThumbColor: primary,
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

class _HighlightColorSection extends StatefulWidget {
  final QuranSettingsState state;
  final Color primary;
  final bool isDark;

  const _HighlightColorSection({
    required this.state,
    required this.primary,
    required this.isDark,
  });

  @override
  State<_HighlightColorSection> createState() => _HighlightColorSectionState();
}

class _HighlightColorSectionState extends State<_HighlightColorSection> {
  bool _showColorPicker = false;
  Color _pickerColor = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ..._highlightColors.map(
              (color) => _HighlightColorDot(
                color: color,
                selected: widget.state.highlightColor.toARGB32() == color.toARGB32(),
                primary: widget.primary,
                onTap: () => context
                    .read<QuranSettingsCubit>()
                    .updateHighlightColor(color),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _showColorPicker = !_showColorPicker;
                  _pickerColor = widget.state.highlightColor;
                });
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _showColorPicker
                      ? null
                      : const SweepGradient(
                          colors: [
                            Colors.red,
                            Colors.yellow,
                            Colors.green,
                            Colors.cyan,
                            Colors.blue,
                            Colors.purple,
                            Colors.pink,
                            Colors.red,
                          ],
                        ),
                  color: _showColorPicker ? widget.primary.withValues(alpha: 0.2) : null,
                ),
                child: Icon(
                  _showColorPicker ? Icons.close_rounded : Icons.colorize_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (_showColorPicker) ...[
          const Gap(14),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showColorPicker = false;
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                    Text(
                      "اختر لون التظليل",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<QuranSettingsCubit>().updateHighlightColor(_pickerColor);
                        setState(() {
                          _showColorPicker = false;
                        });
                      },
                      icon: Icon(Icons.check_rounded, color: widget.primary),
                    ),
                  ],
                ),
                const Gap(12),
                ColorPicker(
                  color: _pickerColor,
                  onColorChanged: (color) {
                    setState(() {
                      _pickerColor = color;
                    });
                  },
                  enableOpacity: false,
                  borderRadius: 16,
                  padding: EdgeInsets.zero,
                  showColorCode: true,
                  pickersEnabled: const {
                    ColorPickerType.both: false,
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: true,
                    ColorPickerType.bw: false,
                    ColorPickerType.custom: false,
                    ColorPickerType.wheel: true,
                  },
                ),
              ],
            ),
          ).animate().scale(duration: 300.ms, curve: Curves.easeOutCubic).fade(),
        ],
      ],
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

Future<Color?> showAlFurkanColorPicker(
  BuildContext context,
  Color currentColor, {
  bool allowOpacity = false,
  String heading = "اختر اللون",
}) async {
  Color newColor = currentColor;
  final confirmed = await ColorPicker(
    color: newColor,
    onColorChanged: (c) => newColor = c,
    enableOpacity: allowOpacity,
    borderRadius: 22,
    padding: const EdgeInsets.all(20),
    heading: Text(
      heading,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    wheelSubheading: const Text(
      "الاختيار الحر",
      textDirection: TextDirection.rtl,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    ),
    showColorCode: true,
    showMaterialName: true,
    actionButtons: const ColorPickerActionButtons(
      okButton: true,
      closeButton: true,
      dialogActionButtons: false,
    ),
    pickersEnabled: const {
      ColorPickerType.both: false,
      ColorPickerType.primary: true,
      ColorPickerType.accent: true,
      ColorPickerType.bw: false,
      ColorPickerType.custom: false,
      ColorPickerType.wheel: true,
    },
  ).showPickerDialog(
    context,
    constraints: const BoxConstraints(minHeight: 460, minWidth: 320, maxWidth: 320),
    barrierColor: Colors.black.withValues(alpha: 0.5),
  );
  return confirmed ? newColor : null;
}

class _LayoutModeSection extends StatelessWidget {
  final QuranSettingsState state;
  final Color primary;
  final bool isDark;

  const _LayoutModeSection({
    required this.state,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final modes = MushafLayoutMode.values;
    return Row(
      children: modes.map((mode) {
        final isSelected = state.layoutMode == mode;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: mode != modes.last ? 10 : 0,
            ),
            child: InkWell(
              onTap: () =>
                  context.read<QuranSettingsCubit>().updateLayoutMode(mode),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withValues(alpha: 0.15)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.035)
                          : Colors.black.withValues(alpha: 0.025)),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? primary.withValues(alpha: 0.6)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.04)),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      mode.icon,
                      size: 26,
                      color: isSelected ? primary : (isDark ? Colors.white60 : Colors.black45),
                    ),
                    const Gap(8),
                    Text(
                      mode.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? primary
                            : (isDark ? Colors.white70 : Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FontFamilySection extends StatelessWidget {
  final QuranSettingsState state;
  final Color primary;
  final bool isDark;

  const _FontFamilySection({
    required this.state,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final fonts = QuranFontFamily.values;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: fonts.map((font) {
        final isSelected = state.fontFamily == font;
        return InkWell(
          onTap: () =>
              context.read<QuranSettingsCubit>().updateFontFamily(font),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: 0.15)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.035)
                      : Colors.black.withValues(alpha: 0.025)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? primary.withValues(alpha: 0.6)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.04)),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "بِسْمِ اللَّهِ",
                  style: TextStyle(
                    fontFamily: font.flutterFontFamily,
                    fontSize: 18,
                    height: 1.6,
                    color: isSelected
                        ? primary
                        : (isDark ? Colors.white70 : Colors.black54),
                  ),
                ),
                const Gap(4),
                Text(
                  font.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? primary
                        : (isDark ? Colors.white60 : Colors.black45),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _UnifiedBackgroundsSection extends StatelessWidget {
  final QuranSettingsState state;
  final Color primary;
  final bool isDark;

  const _UnifiedBackgroundsSection({
    required this.state,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranSettingsCubit, QuranSettingsState>(
      builder: (context, currentState) {
        return _UnifiedBackgroundsSectionContent(
          state: currentState,
          primary: primary,
          isDark: isDark,
        );
      },
    );
  }
}

class _UnifiedBackgroundsSectionContent extends StatefulWidget {
  final QuranSettingsState state;
  final Color primary;
  final bool isDark;

  const _UnifiedBackgroundsSectionContent({
    required this.state,
    required this.primary,
    required this.isDark,
  });

  @override
  State<_UnifiedBackgroundsSectionContent> createState() => _UnifiedBackgroundsSectionContentState();
}

class _UnifiedBackgroundsSectionContentState extends State<_UnifiedBackgroundsSectionContent> {
  bool _showColorPicker = false;
  Color _pickerColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    // Get current system brightness
    final currentBrightness = Theme.of(context).brightness;
    final isCurrentlyDark = currentBrightness == Brightness.dark;

    
    // Filter themes based on CURRENT mode using the theme's isDark property
    final presetThemes = _themeOptions.where((entry) {
      final theme = entry.$1;
      if (theme == QuranTheme.custom) return false; // Skip custom from presets
      // Show dark themes in dark mode, light themes in light mode
      if (isCurrentlyDark) return theme.isDark;
      return !theme.isDark;
    }).toList();

    // Combine preset and custom backgrounds
    final allBackgrounds = <Widget>[];
    
    // Add preset themes
    for (final entry in presetThemes) {
      final theme = entry.$1;
      final bgColor = entry.$2;
      final textColor = entry.$3;
      final isSelected = widget.state.theme == theme;

      allBackgrounds.add(
        _BackgroundCard(
          label: theme.label,
          backgroundColor: bgColor,
          textColor: textColor,
          isSelected: isSelected,
          primary: widget.primary,
          isDark: widget.isDark,
          onTap: () {

            final cubit = context.read<QuranSettingsCubit>();
            cubit.updateTheme(theme);
          },
        ),
      );
    }
    
    // Add custom backgrounds
    for (var i = 0; i < widget.state.customBackgroundColors.length; i++) {
      final color = widget.state.customBackgroundColors[i];
      final textColor = color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
      final isSelected = widget.state.theme == QuranTheme.custom && 
                         widget.state.customBackgroundColor.toARGB32() == color.toARGB32();

      allBackgrounds.add(
        _BackgroundCard(
          label: "مخصصة ${i + 1}",
          backgroundColor: color,
          textColor: textColor,
          isSelected: isSelected,
          primary: widget.primary,
          isDark: widget.isDark,
          isCustom: true,
          onTap: () {
            context.read<QuranSettingsCubit>().applyCustomBackground(color, textColor);
          },
          onDelete: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  title: const Text("تأكيد الحذف"),
                  content: const Text("هل تريد حذف هذه الخلفية؟"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("إلغاء"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("حذف"),
                    ),
                  ],
                ),
              ),
            );
            if (confirmed == true && context.mounted) {
              context.read<QuranSettingsCubit>().removeCustomBackgroundColor(i);
            }
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            children: allBackgrounds.map((widget) {
              return Padding(
                padding: const EdgeInsets.only(left: 10),
                child: widget,
              );
            }).toList(),
          ),
        ),
        const Gap(14),
        if (_showColorPicker) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _showColorPicker = false;
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                    Text(
                      "اختر لون الخلفية",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        final cubit = context.read<QuranSettingsCubit>();
                        // Add to the list first
                        cubit.addCustomBackgroundColor(_pickerColor);
                        // Then switch to custom theme with this color (single atomic emit)
                        final textColor = _pickerColor.computeLuminance() > 0.5 
                            ? Colors.black87 
                            : Colors.white;
                        cubit.applyCustomBackground(_pickerColor, textColor);
                        setState(() {
                          _showColorPicker = false;
                        });
                      },
                      icon: Icon(Icons.check_rounded, color: widget.primary),
                    ),
                  ],
                ),
                const Gap(12),
                ColorPicker(
                  color: _pickerColor,
                  onColorChanged: (color) {
                    setState(() {
                      _pickerColor = color;
                    });
                  },
                  enableOpacity: false,
                  borderRadius: 16,
                  padding: EdgeInsets.zero,
                  showColorCode: true,
                  pickersEnabled: const {
                    ColorPickerType.both: false,
                    ColorPickerType.primary: true,
                    ColorPickerType.accent: true,
                    ColorPickerType.bw: false,
                    ColorPickerType.custom: false,
                    ColorPickerType.wheel: true,
                  },
                ),
              ],
            ),
          ).animate().scale(duration: 300.ms, curve: Curves.easeOutCubic).fade(),
          const Gap(14),
        ],
        InkWell(
          onTap: () {
            setState(() {
              _showColorPicker = !_showColorPicker;
              _pickerColor = widget.isDark 
                  ? const Color(0xFF1A1A1A) 
                  : const Color(0xFFFFF8E7);
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: widget.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showColorPicker ? Icons.close_rounded : Icons.add_rounded, 
                  size: 20, 
                  color: widget.primary,
                ),
                const Gap(8),
                Text(
                  _showColorPicker ? "إلغاء" : "إضافة خلفية مخصصة",
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: widget.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundCard extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool isSelected;
  final Color primary;
  final bool isDark;
  final bool isCustom;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const _BackgroundCard({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.isSelected,
    required this.primary,
    required this.isDark,
    this.isCustom = false,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 110,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary : textColor.withValues(alpha: 0.2),
            width: isSelected ? 2.5 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: backgroundColor.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isCustom && onDelete != null)
                  InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: Colors.red.shade400,
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 22),
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  size: 18,
                  color: isSelected ? primary : textColor.withValues(alpha: 0.4),
                ),
              ],
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: textColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: (isCustom ? 100 : 0).ms).scale(
      begin: const Offset(0.9, 0.9),
      duration: 300.ms,
      curve: Curves.easeOutCubic,
    ).fade(duration: 300.ms);
  }
}

extension on QuranTheme {
  String get label {
    switch (this) {
      case QuranTheme.oled:
        return "OLED";
      case QuranTheme.charcoal:
        return "فحمي";
      case QuranTheme.nightBlue:
        return "أزرق ليلي";
      case QuranTheme.custom:
        return "مخصص";
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
      case QuranTheme.ayah:
        return "آية";
      case QuranTheme.beige:
        return "بيج";
      case QuranTheme.darkBeige:
        return "بيج غامق";
      case QuranTheme.creamDark:
        return "كريمي غامق";
    }
  }

  bool get isDark {
    switch (this) {
      case QuranTheme.oled:
      case QuranTheme.charcoal:
      case QuranTheme.nightBlue:
      case QuranTheme.custom:
      case QuranTheme.graphite:
      case QuranTheme.midnightPurple:
        return true;
      case QuranTheme.sepia:
      case QuranTheme.cream:
      case QuranTheme.paperWhite:
      case QuranTheme.sand:
      case QuranTheme.ayah:
      case QuranTheme.beige:
      case QuranTheme.darkBeige:
      case QuranTheme.creamDark:
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
  // Dark themes
  (QuranTheme.charcoal, const Color(0xFF212529), Colors.white),
  (QuranTheme.oled, Colors.black, Colors.white),
  (QuranTheme.nightBlue, const Color(0xFF0F172A), Colors.white),
  (QuranTheme.custom, const Color(0xFF111318), Colors.white),
  (QuranTheme.graphite, const Color(0xFF121417), Colors.white),
  (QuranTheme.midnightPurple, const Color(0xFF140B2D), Colors.white),
  // Light themes — Ayah-inspired palette
  (QuranTheme.ayah, const Color(0xFFFAF8F5), const Color(0xFF1C1C28)),
  (QuranTheme.beige, const Color(0xFFF0EBE3), const Color(0xFF2A2A35)),
  (QuranTheme.darkBeige, const Color(0xFFE0D5C5), const Color(0xFF1A1A22)),
  (QuranTheme.creamDark, const Color(0xFFD4C4A8), const Color(0xFF151515)),
  (QuranTheme.sepia, const Color(0xFFF4ECD8), const Color(0xFF3E2723)),
  (QuranTheme.cream, const Color(0xFFFFFDD0), const Color(0xFF2F2417)),
  (QuranTheme.paperWhite, Colors.white, const Color(0xFF151515)),
  (QuranTheme.sand, const Color(0xFFF3E7D3), const Color(0xFF2E241B)),
];

extension on MushafLayoutMode {
  String get label {
    switch (this) {
      case MushafLayoutMode.singlePage:
        return "صفحة واحدة";
      case MushafLayoutMode.doublePage:
        return "صفحتان";
      case MushafLayoutMode.continuousScroll:
        return "سكرول متواصل";
    }
  }

  IconData get icon {
    switch (this) {
      case MushafLayoutMode.singlePage:
        return Icons.crop_portrait_rounded;
      case MushafLayoutMode.doublePage:
        return Icons.menu_book_rounded;
      case MushafLayoutMode.continuousScroll:
        return Icons.view_agenda_rounded;
    }
  }
}

