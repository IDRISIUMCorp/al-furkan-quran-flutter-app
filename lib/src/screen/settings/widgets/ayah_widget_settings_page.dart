import "package:al_quran_v3/src/core/constants/app_fonts.dart";
import "package:al_quran_v3/src/core/services/ayah_of_the_day_service.dart";
import "package:flex_color_picker/flex_color_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:qcf_quran/qcf_quran.dart";

import "ayah_widget_design.dart";

/// Ayah Widget Settings Page
/// إعدادات ويدجت آية اليوم
class AyahWidgetSettingsPage extends StatefulWidget {
  const AyahWidgetSettingsPage({super.key});

  @override
  State<AyahWidgetSettingsPage> createState() => _AyahWidgetSettingsPageState();
}

class _AyahWidgetSettingsPageState extends State<AyahWidgetSettingsPage> {
  late final Box _userBox;
  late final TextEditingController _surahController;
  late final TextEditingController _verseController;

  double _fontSize = 28.0;
  String _theme = AyahWidgetDesign.availableThemes.first.id;
  int _updateFrequency = 1440;
  String _fontFamily = AppFonts.uthmanicHafs;
  String _category = "random";
  bool _isGradientBg = false;
  bool _isLoading = true;

  Color? _customBgColor;
  Color? _customBgColor2;
  Color? _customTextColor;
  Color? _customSurahColor;

  static const List<int> _frequencies = [60, 360, 720, 1440, 10080];
  static const Map<int, String> _frequencyLabels = {
    60: "كل ساعة",
    360: "كل 6 ساعات",
    720: "كل 12 ساعة",
    1440: "كل يوم",
    10080: "كل أسبوع",
  };

  static const Map<String, String> _fontLabels = {
    AppFonts.uthmanicHafs: "عثماني",
    AppFonts.qpcHafs: "QPC Hafs",
    AppFonts.alQuranNeo: "Neo",
    AppFonts.indopakNastaleeq: "Indopak",
  };

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box("user");
    _surahController = TextEditingController();
    _verseController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    _surahController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    _fontSize = _userBox.get("widget_font_size", defaultValue: 28.0) as double;
    _theme =
        _userBox.get(
              "widget_theme",
              defaultValue: AyahWidgetDesign.availableThemes.first.id,
            )
            as String;
    _updateFrequency =
        _userBox.get("widget_update_frequency_minutes", defaultValue: 1440)
            as int;
    final customSurah = _userBox.get("widget_custom_surah") as int?;
    final customVerse = _userBox.get("widget_custom_verse") as int?;
    _fontFamily =
        _userBox.get("widget_font_family", defaultValue: AppFonts.uthmanicHafs)
            as String;
    _category =
        _userBox.get("widget_ayah_category", defaultValue: "random") as String;
    _isGradientBg =
        _userBox.get("widget_is_gradient_bg", defaultValue: false) as bool;

    final bg1 = _userBox.get("widget_custom_bg_color") as int?;
    final bg2 = _userBox.get("widget_custom_bg_color2") as int?;
    final text = _userBox.get("widget_custom_text_color") as int?;
    final surah = _userBox.get("widget_custom_surah_color") as int?;

    _customBgColor = bg1 == null ? null : Color(bg1);
    _customBgColor2 = bg2 == null ? null : Color(bg2);
    _customTextColor = text == null ? null : Color(text);
    _customSurahColor = surah == null ? null : Color(surah);

    _surahController.text = customSurah?.toString() ?? "";
    _verseController.text = customVerse?.toString() ?? "";

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickColor({
    required Color current,
    required ValueChanged<Color?> onChanged,
  }) async {
    final picked = await showColorPickerDialog(context, current);
    onChanged(picked);
  }

  Future<void> _putOrDelete(String key, Object? value) async {
    if (value == null) {
      await _userBox.delete(key);
    } else {
      await _userBox.put(key, value);
    }
  }

  Future<void> _saveSettings() async {
    final int? validatedSurah = _parseSurah(_surahController.text);
    final int? validatedVerse = _parseVerse(
      _verseController.text,
      validatedSurah,
    );

    await _userBox.put("widget_font_size", _fontSize);
    await _userBox.put("widget_theme", _theme);
    await _userBox.put("widget_update_frequency_minutes", _updateFrequency);
    await _userBox.put("widget_font_family", _fontFamily);
    await _userBox.put("widget_ayah_category", _category);
    await _userBox.put("widget_is_gradient_bg", _isGradientBg);
    await _putOrDelete("widget_custom_surah", validatedSurah);
    await _putOrDelete("widget_custom_verse", validatedVerse);
    await _putOrDelete("widget_custom_bg_color", _customBgColor?.value);
    await _putOrDelete("widget_custom_bg_color2", _customBgColor2?.value);
    await _putOrDelete("widget_custom_text_color", _customTextColor?.value);
    await _putOrDelete("widget_custom_surah_color", _customSurahColor?.value);

    await AyahOfTheDayService.setupBackgroundUpdates();
    await AyahOfTheDayService.updateWidget(forceRefresh: true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم حفظ إعدادات الويدجيت وتحديثها"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshNow() async {
    await AyahOfTheDayService.updateWidget(forceRefresh: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم تحديث الويدجيت الآن"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _resetDefaults() {
    setState(() {
      _fontSize = 28.0;
      _theme = AyahWidgetDesign.availableThemes.first.id;
      _updateFrequency = 1440;
      _fontFamily = AppFonts.uthmanicHafs;
      _category = "random";
      _isGradientBg = false;
      _customBgColor = null;
      _customBgColor2 = null;
      _customTextColor = null;
      _customSurahColor = null;
      _surahController.clear();
      _verseController.clear();
    });
  }

  int? _parseSurah(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 1 || parsed > 114) return null;
    return parsed;
  }

  int? _parseVerse(String value, int? surah) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || surah == null) return null;
    final maxVerse = getVerseCount(surah);
    if (parsed < 1 || parsed > maxVerse) return null;
    return parsed;
  }

  int get _previewSurah => _parseSurah(_surahController.text) ?? 55;
  int get _previewVerse =>
      _parseVerse(_verseController.text, _previewSurah) ?? 13;

  String get _previewAyahText => AyahOfTheDayService.formatAyahTextForWidget(
    getVerse(_previewSurah, _previewVerse, verseEndSymbol: false),
  );

  String get _previewSurahName =>
      AyahOfTheDayService.buildWidgetSurahName(_previewSurah, _previewVerse);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;
    final previewPrimary = AyahOfTheDayService.resolveWidgetPrimaryColor(
      _userBox,
    );
    final bg = isDark ? const Color(0xFF0C0C0C) : const Color(0xFFF7F1E7);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: const Text("إعدادات ويدجيت آية اليوم"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 30.h),
                children: [
                  _buildPreviewCard(previewPrimary, isDark),
                  SizedBox(height: 18.h),
                  _buildSectionCard(
                    title: "الثيم",
                    icon: Icons.palette_rounded,
                    primary: primary,
                    isDark: isDark,
                    child: SizedBox(
                      height: 112.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AyahWidgetDesign.availableThemes.length,
                        separatorBuilder: (_, __) => SizedBox(width: 12.w),
                        itemBuilder: (context, index) {
                          final preset =
                              AyahWidgetDesign.availableThemes[index];
                          final selected = preset.id == _theme;
                          return _ThemeCard(
                            preset: preset,
                            selected: selected,
                            onTap: () => setState(() => _theme = preset.id),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _buildSectionCard(
                    title: "الخط والمعايرة",
                    icon: Icons.text_fields_rounded,
                    primary: primary,
                    isDark: isDark,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "حجم الخط",
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              "${_fontSize.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _fontSize,
                          min: 18,
                          max: 48,
                          divisions: 15,
                          onChanged: (value) =>
                              setState(() => _fontSize = value),
                        ),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: AppFonts.quranFonts.map((font) {
                            final selected = _fontFamily == font;
                            return ChoiceChip(
                              label: Text(_fontLabels[font] ?? font),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _fontFamily = font),
                              selectedColor: primary.withValues(alpha: 0.18),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _buildSectionCard(
                    title: "مصدر الآيات",
                    icon: Icons.auto_awesome_rounded,
                    primary: primary,
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "فئة الآيات عند التحديث التلقائي",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: AyahOfTheDayService.categoryLabels.entries
                              .map((entry) {
                                final selected = _category == entry.key;
                                return ChoiceChip(
                                  label: Text(entry.value),
                                  selected: selected,
                                  onSelected: (_) =>
                                      setState(() => _category = entry.key),
                                  selectedColor: primary.withValues(
                                    alpha: 0.18,
                                  ),
                                );
                              })
                              .toList(),
                        ),
                        SizedBox(height: 14.h),
                        Text(
                          "آية محددة بدل التحديث العشوائي",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _surahController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: "رقم السورة",
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: TextField(
                                controller: _verseController,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: "رقم الآية",
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _surahController.clear();
                              _verseController.clear();
                            });
                          },
                          icon: const Icon(Icons.clear_rounded),
                          label: const Text("إلغاء الآية المحددة"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _buildSectionCard(
                    title: "الألوان والخلفية",
                    icon: Icons.gradient_rounded,
                    primary: primary,
                    isDark: isDark,
                    child: Column(
                      children: [
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: _isGradientBg,
                          onChanged: (value) =>
                              setState(() => _isGradientBg = value),
                          title: const Text("استخدام تدرج لوني"),
                          subtitle: const Text("بين اللون الأساسي والثانوي"),
                        ),
                        _ColorTile(
                          title: "الخلفية الأساسية",
                          color:
                              _customBgColor ??
                              AyahWidgetDesign.themeById(
                                _theme,
                              ).primaryBackground,
                          onTap: () => _pickColor(
                            current:
                                _customBgColor ??
                                AyahWidgetDesign.themeById(
                                  _theme,
                                ).primaryBackground,
                            onChanged: (value) =>
                                setState(() => _customBgColor = value),
                          ),
                          onReset: _customBgColor == null
                              ? null
                              : () => setState(() => _customBgColor = null),
                        ),
                        _ColorTile(
                          title: "الخلفية الثانوية",
                          color:
                              _customBgColor2 ??
                              AyahWidgetDesign.themeById(
                                _theme,
                              ).secondaryBackground,
                          onTap: () => _pickColor(
                            current:
                                _customBgColor2 ??
                                AyahWidgetDesign.themeById(
                                  _theme,
                                ).secondaryBackground,
                            onChanged: (value) =>
                                setState(() => _customBgColor2 = value),
                          ),
                          onReset: _customBgColor2 == null
                              ? null
                              : () => setState(() => _customBgColor2 = null),
                        ),
                        _ColorTile(
                          title: "لون النص",
                          color:
                              _customTextColor ??
                              AyahWidgetDesign.themeById(_theme).textColor,
                          onTap: () => _pickColor(
                            current:
                                _customTextColor ??
                                AyahWidgetDesign.themeById(_theme).textColor,
                            onChanged: (value) =>
                                setState(() => _customTextColor = value),
                          ),
                          onReset: _customTextColor == null
                              ? null
                              : () => setState(() => _customTextColor = null),
                        ),
                        _ColorTile(
                          title: "لون اسم السورة",
                          color:
                              _customSurahColor ??
                              AyahWidgetDesign.themeById(_theme).surahColor,
                          onTap: () => _pickColor(
                            current:
                                _customSurahColor ??
                                AyahWidgetDesign.themeById(_theme).surahColor,
                            onChanged: (value) =>
                                setState(() => _customSurahColor = value),
                          ),
                          onReset: _customSurahColor == null
                              ? null
                              : () => setState(() => _customSurahColor = null),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _buildSectionCard(
                    title: "معدل التحديث",
                    icon: Icons.update_rounded,
                    primary: primary,
                    isDark: isDark,
                    child: Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _frequencies.map((frequency) {
                        final selected = _updateFrequency == frequency;
                        return ChoiceChip(
                          label: Text(
                            _frequencyLabels[frequency] ?? "$frequency",
                          ),
                          selected: selected,
                          onSelected: (_) =>
                              setState(() => _updateFrequency = frequency),
                          selectedColor: primary.withValues(alpha: 0.18),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _resetDefaults,
                          icon: const Icon(Icons.restart_alt_rounded),
                          label: const Text("إعادة الضبط"),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _refreshNow,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text("تحديث الآن"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text("حفظ إعدادات الويدجيت"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPreviewCard(Color primary, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171717) : Colors.white,
        borderRadius: BorderRadius.circular(28),
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
            "المعاينة الحية",
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 8.h),
          Text(
            "أي تعديل هنا ينعكس مباشرة على شكل الويدجيت قبل الحفظ.",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.7,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          SizedBox(height: 14.h),
          FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox(
              width: 800,
              height: 400,
              child: AyahWidgetDesign(
                ayahText: _previewAyahText,
                surahName: _previewSurahName,
                primaryColor: primary,
                fontSize: _fontSize,
                themeId: _theme,
                fontFamily: _fontFamily,
                ayahNumber: _previewVerse,
                customBgColor: _customBgColor,
                customBgColor2: _customBgColor2,
                isGradientBg: _isGradientBg,
                customTextColor: _customTextColor,
                customSurahColor: _customSurahColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color primary,
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171717) : Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primary),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AyahWidgetThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 120.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [preset.primaryBackground, preset.secondaryBackground],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? preset.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: preset.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const Spacer(),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: preset.accent,
                    size: 18,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              preset.name,
              style: TextStyle(
                color: preset.textColor,
                fontWeight: FontWeight.w800,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onReset;

  const _ColorTile({
    required this.title,
    required this.color,
    required this.onTap,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: onReset == null
          ? null
          : IconButton(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
            ),
      title: Text(title, textAlign: TextAlign.right),
      trailing: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        ),
      ),
    );
  }
}
