import "package:al_quran_v3/src/core/constants/app_fonts.dart";
import "package:al_quran_v3/src/core/services/ayah_of_the_day_service.dart";
import "package:flex_color_picker/flex_color_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:qcf_quran/qcf_quran.dart";

import "ayah_widget_design.dart";

class AyahWidgetSettingsView extends StatefulWidget {
  const AyahWidgetSettingsView({super.key});

  @override
  State<AyahWidgetSettingsView> createState() => _AyahWidgetSettingsViewState();
}

class _AyahWidgetSettingsViewState extends State<AyahWidgetSettingsView> {
  late final Box _userBox;
  late final TextEditingController _surahController;
  late final TextEditingController _verseController;

  double _fontSize = 45;
  String _theme = AyahWidgetDesign.availableThemes.first.id;
  String _fontFamily = AppFonts.uthmanicHafs;
  bool _isGradientBg = false;
  bool _isLoading = true;

  Color? _customBgColor;
  Color? _customBgColor2;
  Color? _customTextColor;
  Color? _customSurahColor;

  static const Map<String, String> _fontLabels = {
    AppFonts.uthmanicHafs: "عثماني حفصي",
    AppFonts.qpcHafs: "القرآن الكريم",
    AppFonts.alQuranNeo: "أحمد حسني",
    AppFonts.indopakNastaleeq: "روح الدوحة",
    "AmiriQuran-Regular": "أميري قرآن",
    "Aref Ruqaa Bold": "رقعة",
  };

  static const Map<String, String> _fontSubtitles = {
    AppFonts.uthmanicHafs: "عثماني حفصي",
    AppFonts.qpcHafs: "QPC Hafs",
    AppFonts.alQuranNeo: "AlQuran Neo",
    AppFonts.indopakNastaleeq: "Indopak",
    "AmiriQuran-Regular": "Amiri Quran",
    "Aref Ruqaa Bold": "Aref Ruqaa",
  };

  static const List<String> _fontOptions = [
    AppFonts.uthmanicHafs,
    AppFonts.qpcHafs,
    AppFonts.alQuranNeo,
    AppFonts.indopakNastaleeq,
    "AmiriQuran-Regular",
    "Aref Ruqaa Bold",
  ];

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
    _fontSize = _userBox.get("widget_font_size", defaultValue: 45.0) as double;
    _theme =
        _userBox.get(
              "widget_theme",
              defaultValue: AyahWidgetDesign.availableThemes.first.id,
            )
            as String;
    _fontFamily =
        _userBox.get("widget_font_family", defaultValue: AppFonts.uthmanicHafs)
            as String;
    _isGradientBg =
        _userBox.get("widget_is_gradient_bg", defaultValue: false) as bool;

    final customSurah = _userBox.get("widget_custom_surah") as int?;
    final customVerse = _userBox.get("widget_custom_verse") as int?;
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

    setState(() => _isLoading = false);
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

  int get _previewSurah => _parseSurah(_surahController.text) ?? 51;
  int get _previewVerse =>
      _parseVerse(_verseController.text, _previewSurah) ?? 14;

  String get _previewAyahText => AyahOfTheDayService.formatAyahTextForWidget(
    getVerse(_previewSurah, _previewVerse, verseEndSymbol: false),
  );

  String get _previewSurahName =>
      AyahOfTheDayService.buildWidgetSurahName(_previewSurah, _previewVerse);

  String get _selectedAyahLabel {
    final surah = _parseSurah(_surahController.text);
    final verse = _parseVerse(_verseController.text, surah);
    if (surah == null || verse == null) {
      return "اضغط لاختيار سورة وآية محددة بدلًا من العشوائية";
    }
    return "سورة ${getSurahNameArabic(surah)} - آية $verse";
  }

  Future<void> _putOrDelete(String key, Object? value) async {
    if (value == null) {
      await _userBox.delete(key);
    } else {
      await _userBox.put(key, value);
    }
  }

  Future<void> _persistSettings({bool refreshWidget = true}) async {
    final surah = _parseSurah(_surahController.text);
    final verse = _parseVerse(_verseController.text, surah);

    await _userBox.put("widget_font_size", _fontSize);
    await _userBox.put("widget_theme", _theme);
    await _userBox.put("widget_font_family", _fontFamily);
    await _userBox.put("widget_is_gradient_bg", _isGradientBg);
    await _userBox.put("widget_update_frequency_minutes", 1440);
    await _userBox.put("widget_ayah_category", "random");
    await _putOrDelete("widget_custom_surah", surah);
    await _putOrDelete("widget_custom_verse", verse);
    await _putOrDelete("widget_custom_bg_color", _customBgColor?.value);
    await _putOrDelete("widget_custom_bg_color2", _customBgColor2?.value);
    await _putOrDelete("widget_custom_text_color", _customTextColor?.value);
    await _putOrDelete("widget_custom_surah_color", _customSurahColor?.value);

    if (refreshWidget) {
      await AyahOfTheDayService.updateWidget(forceRefresh: true);
    }
  }

  Future<void> _refreshNow() async {
    await _persistSettings();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("تم تحديث الويدجت الآن"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickColor({
    required Color current,
    required ValueChanged<Color?> onChanged,
  }) async {
    final picked = await showColorPickerDialog(context, current);
    onChanged(picked);
    await _persistSettings();
  }

  Future<void> _showCustomAyahSheet() async {
    final surahController = TextEditingController(text: _surahController.text);
    final verseController = TextEditingController(text: _verseController.text);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final bottom = MediaQuery.of(context).viewInsets.bottom;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, bottom + 16.h),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                final parsedSurah = _parseSurah(surahController.text);
                final parsedVerse = _parseVerse(
                  verseController.text,
                  parsedSurah,
                );
                return Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F4EC),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 30,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "تخصيص آية معينة",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF251E18),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "اختر سورة وآية محددة، أو اتركها فارغة ليبقى التحديث عشوائيًا.",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13.sp,
                          height: 1.7,
                          color: const Color(0xFF6E6258),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: surahController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setModalState(() {}),
                              decoration: const InputDecoration(
                                labelText: "رقم السورة",
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextField(
                              controller: verseController,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setModalState(() {}),
                              decoration: const InputDecoration(
                                labelText: "رقم الآية",
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1E8D8),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE1D5C1)),
                        ),
                        child: Text(
                          parsedSurah != null && parsedVerse != null
                              ? "المحدد الآن: ${getSurahNameArabic(parsedSurah)} - آية $parsedVerse"
                              : "سيتم استخدام آية عشوائية إذا لم تُكمل الإدخال.",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4B4036),
                          ),
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _surahController.clear();
                                _verseController.clear();
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.restart_alt_rounded),
                              label: const Text("إلغاء التخصيص"),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                if (surahController.text.trim().isNotEmpty &&
                                    (parsedSurah == null ||
                                        parsedVerse == null)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "الرجاء إدخال سورة وآية صحيحتين",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                _surahController.text =
                                    parsedSurah?.toString() ?? "";
                                _verseController.text =
                                    parsedVerse?.toString() ?? "";
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.check_rounded),
                              label: const Text("تطبيق"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {});
    await _persistSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0C0D10) : const Color(0xFFF6F2EA);
    final divider = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFE4DBCE);
    final textColor = isDark ? Colors.white : const Color(0xFF1D1A17);
    final themePreset = AyahWidgetDesign.themeById(_theme);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 4.w,
          title: Text(
            "ويدجت آية اليوم",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 20.sp,
              color: textColor,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 36.h),
                children: [
                  Text(
                    "المعاينة الحية للويدجت",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor.withValues(alpha: 0.72),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  _PreviewSurface(
                    child: _LivePreviewShell(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: SizedBox(
                          key: ValueKey(
                            [
                              _theme,
                              _fontFamily,
                              _fontSize.round(),
                              _isGradientBg,
                              _customBgColor?.value,
                              _customBgColor2?.value,
                              _customTextColor?.value,
                              _customSurahColor?.value,
                              _previewSurah,
                              _previewVerse,
                            ].join("_"),
                          ),
                          width: AyahWidgetDesign.canvasSize.width,
                          height: AyahWidgetDesign.canvasSize.height,
                          child: AyahWidgetDesign(
                            ayahText: _previewAyahText,
                            surahName: _previewSurahName,
                            primaryColor: themePreset.accent,
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
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _ActionRow(
                    title: "تحديث الآية الآن",
                    subtitle: "اضغط لتغيير الآية في الويدجت فورًا",
                    icon: Icons.refresh_rounded,
                    onTap: _refreshNow,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    "حجم خط الآية: ${_fontSize.toStringAsFixed(0)}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: const Color(0xFF5E483B),
                      inactiveTrackColor: const Color(0xFFD9D1C7),
                      thumbColor: const Color(0xFF5E483B),
                      overlayColor: const Color(0x335E483B),
                      trackHeight: 4.5,
                    ),
                    child: Slider(
                      value: _fontSize,
                      min: 28,
                      max: 58,
                      divisions: 15,
                      onChanged: (value) => setState(() => _fontSize = value),
                      onChangeEnd: (_) => _persistSettings(),
                    ),
                  ),
                  Divider(height: 34.h, color: divider),
                  _SectionHeader(
                    title: "نوع خط الآية",
                    subtitle: "اسحب واختر الخط الأنسب لعرض النص داخل الويدجت",
                    icon: Icons.text_fields_rounded,
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 122.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _fontOptions.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (context, index) {
                        final font = _fontOptions[index];
                        return _FontPreviewCard(
                          label: _fontLabels[font] ?? font,
                          subtitle: _fontSubtitles[font] ?? font,
                          sample: "القرآن الكريم",
                          fontFamily: font,
                          selected: _fontFamily == font,
                          onTap: () async {
                            setState(() => _fontFamily = font);
                            await _persistSettings();
                          },
                        );
                      },
                    ),
                  ),
                  Divider(height: 34.h, color: divider),
                  _ActionRow(
                    title: "تخصيص آية معينة",
                    subtitle: _selectedAyahLabel,
                    icon: Icons.tune_rounded,
                    onTap: _showCustomAyahSheet,
                  ),
                  Divider(height: 34.h, color: divider),
                  _SectionHeader(
                    title: "شكل الويدجت",
                    subtitle: "اختر التصميم الذي يناسب خلفية هاتفك",
                    icon: Icons.style_rounded,
                  ),
                  SizedBox(height: 14.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: AyahWidgetDesign.availableThemes
                          .map(
                            (preset) => Padding(
                              padding: EdgeInsets.only(left: 10.w),
                              child: _ThemePill(
                                preset: preset,
                                selected: preset.id == _theme,
                                onTap: () async {
                                  setState(() => _theme = preset.id);
                                  await _persistSettings();
                                },
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Divider(height: 34.h, color: divider),
                  Text(
                    "أو صمم الويدجت الخاص بك بحرية مطلقة:",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Switch.adaptive(
                        value: _isGradientBg,
                        onChanged: (value) async {
                          setState(() => _isGradientBg = value);
                          await _persistSettings();
                        },
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          "استخدام خلفية متدرجة (Gradient)",
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: textColor.withValues(alpha: 0.90),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 22.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ColorSelector(
                        label: "الخلفية",
                        color: _customBgColor ?? themePreset.primaryBackground,
                        onTap: () => _pickColor(
                          current:
                              _customBgColor ?? themePreset.primaryBackground,
                          onChanged: (value) =>
                              setState(() => _customBgColor = value),
                        ),
                      ),
                      _ColorSelector(
                        label: "النص",
                        color: _customTextColor ?? themePreset.textColor,
                        onTap: () => _pickColor(
                          current: _customTextColor ?? themePreset.textColor,
                          onChanged: (value) =>
                              setState(() => _customTextColor = value),
                        ),
                      ),
                      _ColorSelector(
                        label: "السورة",
                        color: _customSurahColor ?? themePreset.surahColor,
                        onTap: () => _pickColor(
                          current: _customSurahColor ?? themePreset.surahColor,
                          onChanged: (value) =>
                              setState(() => _customSurahColor = value),
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

class _PreviewSurface extends StatelessWidget {
  final Widget child;

  const _PreviewSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LivePreviewShell extends StatelessWidget {
  final Widget child;

  const _LivePreviewShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 245.h,
      padding: EdgeInsets.fromLTRB(12.w, 14.h, 12.w, 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8E3DA), Color(0xFFF7F3EC)],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1E24), Color(0xFF45433E)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 10,
                left: 18,
                right: 18,
                child: Row(
                  children: [
                    Text(
                      "12:30",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.network_wifi_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                    SizedBox(width: 6.w),
                    Icon(
                      Icons.signal_cellular_alt_rounded,
                      size: 12,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: -24.w,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 46.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -24.w,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 46.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.white.withValues(alpha: 0.22),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(6.w, 28.h, 6.w, 36.h),
                  child: FittedBox(fit: BoxFit.fitWidth, child: child),
                ),
              ),
              Positioned(
                left: 18.w,
                right: 18.w,
                bottom: 14.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _PreviewAppDot(color: Color(0xFF5339F0)),
                    _PreviewAppDot(color: Color(0xFFB87A16)),
                    _PreviewAppDot(color: Color(0xFF0071B8)),
                    _PreviewAppDot(color: Color(0xFF26853F)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewAppDot extends StatelessWidget {
  final Color color;

  const _PreviewAppDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF241E19);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : const Color(0xFF6E6258);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w900,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 13.sp,
                  height: 1.6,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: const Color(0xFFEEE6D9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF5B483A), size: 18),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF241E19);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.65)
        : const Color(0xFF6E6258);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.5,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Icon(icon, color: const Color(0xFF5A4638), size: 26),
          ],
        ),
      ),
    );
  }
}

class _FontPreviewCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final String sample;
  final String fontFamily;
  final bool selected;
  final VoidCallback onTap;

  const _FontPreviewCard({
    required this.label,
    required this.subtitle,
    required this.sample,
    required this.fontFamily,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 126.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF5E483B) : const Color(0xFFE4DBCE),
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  sample,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontFamilyFallback: const [
                      "AmiriQuran-Regular",
                      "KFGQPC-Uthmanic-HAFS-Regular",
                    ],
                    fontSize: 21.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF181411),
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF221B16),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 10.sp, color: const Color(0xFF8B7C71)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePill extends StatelessWidget {
  final AyahWidgetThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  const _ThemePill({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE5DFDA) : const Color(0xFFF8F5EF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFF5E483B) : const Color(0xFFD9D1C7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(
                Icons.check_rounded,
                size: 16,
                color: const Color(0xFF5E483B),
              ),
              SizedBox(width: 6.w),
            ],
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    preset.primaryBackground,
                    preset.secondaryBackground,
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              preset.name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF241D18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSelector extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ColorSelector({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Column(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD0C8BC), width: 1.5),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF261F19),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
