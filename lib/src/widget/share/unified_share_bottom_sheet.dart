import 'dart:io';

import 'package:al_furkan/src/model/ayah_image_settings.dart';
import 'package:al_furkan/src/resources/quran_resources/quran_pages_info.dart';
import 'package:al_furkan/src/theme/controller/theme_cubit.dart';
import 'package:al_furkan/src/utils/basic_functions.dart';
import 'package:al_furkan/src/utils/quran_ayahs_function/get_page_number.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gap/gap.dart';
import 'package:qcf_quran/qcf_quran.dart' hide getPageNumber;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:al_furkan/src/resources/quran_resources/models/tafsir_book_model.dart';
import 'package:al_furkan/src/utils/quran_resources/quran_tafsir_function.dart';
import 'package:al_furkan/src/core/constants/app_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class UnifiedShareBottomSheet extends StatefulWidget {
  final int initialSurahNumber;
  final int initialVerseNumber;
  final String Function(int surah, int verse) getAyahText;
  final int initialShareMode;
  final TafsirBookModel? initialTafsirBook;

  const UnifiedShareBottomSheet({
    super.key,
    required this.initialSurahNumber,
    required this.initialVerseNumber,
    required this.getAyahText,
    this.initialShareMode = 0,
    this.initialTafsirBook,
  });

  static Future<void> show({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
    required String Function(int surah, int verse) getAyahText,
    int initialShareMode = 0,
    TafsirBookModel? initialTafsirBook,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.95,
          minChildSize: 0.80,
          maxChildSize: 1.0,
          snap: true,
          snapSizes: const [0.80, 0.95, 1.0],
          builder: (context, scrollController) => UnifiedShareBottomSheet(
            initialSurahNumber: surahNumber,
            initialVerseNumber: verseNumber,
            getAyahText: getAyahText,
            initialShareMode: initialShareMode,
            initialTafsirBook: initialTafsirBook,
          ),
        ),
      ),
    );
  }

  @override
  State<UnifiedShareBottomSheet> createState() =>
      _UnifiedShareBottomSheetState();
}

class _UnifiedShareBottomSheetState extends State<UnifiedShareBottomSheet> {
  // ── SearchSheet-style color tokens ──
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _surfaceColor =>
      _isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFF7F1E6);
  Color get _cardColor =>
      _isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFFFBF5);
  Color get _borderColor => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.06);
  Color get _textColor => _isDark ? Colors.white : const Color(0xFF1B1B1B);
  Color get _mutedColor => _isDark ? Colors.white54 : const Color(0xFF8F8F8F);

  // 0 = Image, 1 = Text
  int _shareMode = 0;

  late int _selectedSurah;
  late int _fromVerse;
  late int _toVerse;
  int _totalVerses = 0;

  // Page-based limits: min/max verse numbers for the current page
  int _pageMinVerse = 1;
  int _pageMaxVerse = 999;

  TafsirBookModel? _selectedTafsirBook;
  String? _resolvedTafsirText;
  bool _isLoadingTafsir = false;

  bool _isSharing = false;
  bool _forceDarkMode = false; // Independent dark mode toggle for the image
  bool _shareFullPage = false; // Share all surahs on the same page
  final ScreenshotController _screenshotController = ScreenshotController();
  String _shareFontFamily = 'default'; // Use 'default' to render the authentic Mushaf font (QCF page fonts)
  bool _isShareFontGoogle = false;
  String _tafsirFontFamily = 'default';
  bool _isTafsirFontGoogle = false;

  // Settings
  AyahImageSettings _settings = const AyahImageSettings(
    background: AyahImageBackground.light,
    ayahTextAlign: AyahImageTextAlign.center,
  );

  double _customFontSize = 75.0; // Matches AyahImageGenerator default
  double _surahNameScale = 1.1; // Default scale for Surah name text
  double _bannerScale = 1.2; // Changed to 1.1 as requested
  double _tafsirFontSize = 48.0; // Default scale for Tafsir text
  bool _showBranding = false; // Identity Branding Toggle
  bool _didInitDarkMode = false;

  @override
  void initState() {
    super.initState();
    _shareMode = widget.initialShareMode;
    _selectedSurah = widget.initialSurahNumber;
    _fromVerse = widget.initialVerseNumber;
    _toVerse = widget.initialVerseNumber;

    if (widget.initialTafsirBook != null) {
      _selectedTafsirBook = widget.initialTafsirBook;
    } else {
      // Auto-select Default Tafsir Built-in
      final books = _getUniqueTafsirBooks();
      if (books.isNotEmpty) {
        final sadi = books.where((b) => b.name.contains("سعدي")).toList();
        final muyassar = books.where((b) => b.name.contains("ميسر")).toList();
        if (muyassar.isNotEmpty) {
          _selectedTafsirBook = muyassar.first;
        } else if (sadi.isNotEmpty) {
          _selectedTafsirBook = sadi.first;
        }
      }
    }

    _updateTotalVerses();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitDarkMode) {
      _didInitDarkMode = true;
      _forceDarkMode = Theme.of(context).brightness == Brightness.dark;
    }
  }

  /// Returns the page info entry for the given surah:verse
  Map<String, int>? _getPageInfo(int surah, int verse) {
    final ayahId = convertKeyToAyahNumber("$surah:$verse");
    if (ayahId == null) return null;
    for (final info in quranPagesInfo) {
      if (info["s"]! <= ayahId && info["e"]! >= ayahId) return info;
    }
    return null;
  }

  /// Returns all (surah, verse) pairs on the same page as the given ayah
  List<MapEntry<int, int>> _getAyahsOnPage(Map<String, int> pageInfo) {
    final List<MapEntry<int, int>> result = [];
    for (int id = pageInfo["s"]!; id <= pageInfo["e"]!; id++) {
      final key = convertAyahNumberToKey(id);
      if (key == null) continue;
      final parts = key.split(":");
      result.add(MapEntry(int.parse(parts[0]), int.parse(parts[1])));
    }
    return result;
  }

  /// Computes min/max verse for the selected surah on the same page
  void _computePageLimits() {
    final pageInfo = _getPageInfo(_selectedSurah, _fromVerse);
    if (pageInfo == null) {
      _pageMinVerse = 1;
      _pageMaxVerse = _totalVerses;
      return;
    }
    final ayahs = _getAyahsOnPage(pageInfo);
    final surahAyahs = ayahs.where((e) => e.key == _selectedSurah).toList();
    if (surahAyahs.isEmpty) {
      _pageMinVerse = 1;
      _pageMaxVerse = _totalVerses;
      return;
    }
    _pageMinVerse = surahAyahs
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b);
    _pageMaxVerse = surahAyahs
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
  }

  void _updateTotalVerses() {
    _totalVerses = getVerseCount(_selectedSurah);
    if (_fromVerse > _totalVerses) _fromVerse = 1;
    if (_toVerse > _totalVerses) _toVerse = _totalVerses;
    if (_toVerse < _fromVerse) _toVerse = _fromVerse;
    _computePageLimits();
    // Clamp to page limits
    if (_fromVerse < _pageMinVerse) _fromVerse = _pageMinVerse;
    if (_fromVerse > _pageMaxVerse) _fromVerse = _pageMaxVerse;
    if (_toVerse < _fromVerse) _toVerse = _fromVerse;
    if (_toVerse > _pageMaxVerse) _toVerse = _pageMaxVerse;
    _fetchTafsirIfSelected();
  }

  Future<void> _fetchTafsirIfSelected() async {
    if (_selectedTafsirBook == null) {
      if (mounted) setState(() => _resolvedTafsirText = null);
      return;
    }

    // Smart height estimation: block tafsir if image would exceed 2x canvas width (2800px)
    final int totalTextLength = _calculateRawTextLength();
    final int verseCount = _toVerse - _fromVerse + 1;
    final int estimatedHeight =
        (verseCount * 180) + (totalTextLength ~/ 3) + 400;

    if (estimatedHeight > 2800) {
      if (mounted) {
        setState(() {
          _selectedTafsirBook = null;
          _resolvedTafsirText = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "النص طويل جداً لإضافة تفسير — الصورة هتكون أكبر من المسموح",
              textDirection: TextDirection.rtl,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _isLoadingTafsir = true);

    final buffer = StringBuffer();
    for (int v = _fromVerse; v <= _toVerse; v++) {
      final String? t = await QuranTafsirFunction.getResolvedTafsirTextForBook(
        _selectedTafsirBook!,
        "$_selectedSurah:$v",
      );
      if (t != null) {
        var clean = t.replaceAll(RegExp(r"<[^>]+>"), " ");
        clean = clean.replaceAll(RegExp(r"\s{2,}"), " ").trim();
        buffer.writeln(clean);
        if (v != _toVerse) buffer.writeln();
      }
    }

    if (mounted) {
      setState(() {
        _resolvedTafsirText = buffer.toString().trim().isEmpty
            ? null
            : buffer.toString().trim();
        _isLoadingTafsir = false;
      });
    }
  }

  List<TafsirBookModel> _getUniqueTafsirBooks() {
    final books = QuranTafsirFunction.getDownloadedTafsirBooks();
    final Map<String, TafsirBookModel> unique = {};
    for (var b in books) {
      unique[b.name.trim()] = b;
    }
    return unique.values.toList();
  }

  int _calculateRawTextLength() {
    int len = 0;
    for (int v = _fromVerse; v <= _toVerse; v++) {
      len += getVerse(_selectedSurah, v, verseEndSymbol: false).length;
    }
    return len;
  }

  String _toArabicDigits(String number) {
    const arabics = [
      '٠',
      '١',
      '٢',
      '٣',
      '٤',
      '٥',
      '٦',
      '٧',
      '٨',
      '٩',
    ];
    final buffer = StringBuffer();
    for (final ch in number.split('')) {
      final digit = int.tryParse(ch);
      if (digit == null) {
        buffer.write(ch);
      } else {
        buffer.write(arabics[digit]);
      }
    }
    return buffer.toString();
  }

  String _cleanAyahText(String originalText) {
    if (originalText.contains(":") && !originalText.contains(" ")) {
      // Likely a reference key like "2:10" that survived the fallback
      return "";
    }
    var t = originalText.trimRight();
    t = t.replaceAll(RegExp(r"[\s\u06DD۝]+$"), "");
    t = t.replaceAll(RegExp(r"[\s0-9\u0660-\u0669]+$"), "");

    // If we stripped too much, return original
    if (t.trim().isEmpty && originalText.isNotEmpty) return originalText;

    return t.trimRight();
  }

  Future<void> _share() async {
    if (_shareMode == 0) {
      setState(() => _isSharing = true);
      try {
        final image = await _screenshotController.capture(
          delay: const Duration(milliseconds: 100),
          pixelRatio: 4.0, // High quality PNG
        );
        if (image == null) return;
        final dir = await getTemporaryDirectory();
        final file = File("${dir.path}/shared_ayah.png");
        await file.writeAsBytes(image, flush: true);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            fileNameOverrides: ["quran_share.png"],
          ),
        );
      } finally {
        if (mounted) setState(() => _isSharing = false);
      }
    } else {
      final buffer = StringBuffer();
      buffer.writeln(getSurahNameArabic(_selectedSurah));
      buffer.writeln();

      for (int v = _fromVerse; v <= _toVerse; v++) {
        final t = getVerse(_selectedSurah, v, verseEndSymbol: false);
        buffer.writeln("$t ﴿${_toArabicDigits(v.toString())}﴾");
      }

      if (_resolvedTafsirText != null) {
        final tafsirName = _selectedTafsirBook?.name ?? "التفسير";
        buffer.writeln();
        buffer.writeln("──────");
        buffer.writeln("$tafsirName:");
        buffer.writeln(_resolvedTafsirText);
      }

      if (_showBranding) {
        buffer.writeln();
        buffer.writeln(
          "تمت المشاركة من تطبيق الفرقان",
        );
        buffer.writeln("github.com/IDRISIUMCorp/al-furkan-quran-flutter-app");
      }

      await SharePlus.instance.share(ShareParams(text: buffer.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    final themeState = context.read<ThemeCubit>().state;
    final primary = themeState.primary;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // ── Drag Handle (like SearchSheet) ──
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            // ── Header: Close + Title + Subtitle ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "مشاركة",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _textColor,
                          ),
                        ),
                        Text(
                          "شارك الآيات كصورة أو نص",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: _mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.05, end: 0),
            const SizedBox(height: 14),

            // Segmented Control (Tabs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTab(
                      1,
                      "نص",
                      Icons.text_snippet_rounded,
                      primary,
                      _cardColor,
                      isDark,
                    ),
                    _buildTab(
                      0,
                      "صورة",
                      Icons.image_rounded,
                      primary,
                      _cardColor,
                      isDark,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 250.ms, delay: 50.ms).slideY(begin: 0.03, end: 0),
            const SizedBox(height: 16),

            // Range Selectors (Surah, From, To) — animated hide when full page is on
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedOpacity(
                opacity: _shareFullPage ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: _shareFullPage
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: _cardColor,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Row(
                              children: [
                                // Surah
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "سورة",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _surfaceColor,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            isExpanded: true,
                                            value: _selectedSurah,
                                            items: List.generate(
                                              114,
                                              (i) => DropdownMenuItem(
                                                value: i + 1,
                                                child: Text(
                                                  "${i + 1}. ${getSurahNameArabic(i + 1)}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() {
                                                  _selectedSurah = v;
                                                  _fromVerse = 1;
                                                  _toVerse = 1;
                                                  _updateTotalVerses();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // From
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "من",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _surfaceColor,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            isExpanded: true,
                                            value: _fromVerse,
                                            items: List.generate(
                                              _pageMaxVerse - _pageMinVerse + 1,
                                              (i) => DropdownMenuItem(
                                                value: _pageMinVerse + i,
                                                child: Text(
                                                  _toArabicDigits(
                                                    (_pageMinVerse + i)
                                                        .toString(),
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() {
                                                  _fromVerse = v;
                                                  if (_toVerse < _fromVerse) {
                                                    _toVerse = _fromVerse;
                                                  }
                                                  _updateTotalVerses();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // To
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "إلى",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _surfaceColor,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<int>(
                                            isExpanded: true,
                                            value: _toVerse,
                                            items: List.generate(
                                              _pageMaxVerse - _fromVerse + 1,
                                              (i) => DropdownMenuItem(
                                                value: _fromVerse + i,
                                                child: Text(
                                                  _toArabicDigits(
                                                    (_fromVerse + i).toString(),
                                                  ),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() {
                                                  _toVerse = v;
                                                  _updateTotalVerses();
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ).animate().fadeIn(duration: 250.ms, delay: 100.ms).slideY(begin: 0.03, end: 0),
            const SizedBox(height: 8),

            // Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Full Page Toggle (share all surahs on this page)
                        if (_shareMode == 0)
                          IconButton(
                            icon: Icon(
                              _shareFullPage
                                  ? FluentIcons
                                        .document_page_bottom_center_24_filled
                                  : FluentIcons
                                        .document_page_bottom_center_24_regular,
                              color: _shareFullPage ? primary : null,
                            ),
                            tooltip: 'مشاركة الصفحة كاملة',
                            onPressed: () {
                              setState(() {
                                _shareFullPage = !_shareFullPage;
                                if (_shareFullPage) {
                                  _fromVerse = _pageMinVerse;
                                  _toVerse = _pageMaxVerse;
                                }
                              });
                            },
                          ),
                        // Dark/Light Mode Toggle for image
                        if (_shareMode == 0)
                          IconButton(
                            icon: Icon(
                              _forceDarkMode
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: _forceDarkMode ? primary : null,
                            ),
                            onPressed: () => setState(
                              () => _forceDarkMode = !_forceDarkMode,
                            ),
                          ),

                        IconButton(
                          icon: Icon(
                            _showBranding
                                ? FluentIcons.person_board_24_filled
                                : FluentIcons.person_board_24_regular,
                            color: _showBranding ? primary : null,
                          ),
                          tooltip: 'إظهار الهوية',
                          onPressed: () =>
                              setState(() => _showBranding = !_showBranding),
                        ),

                        // Alignment Toggle
                        if (_shareMode == 0)
                          IconButton(
                            icon: Icon(
                              _settings.ayahTextAlign ==
                                      AyahImageTextAlign.center
                                  ? Icons.format_align_center_rounded
                                  : _settings.ayahTextAlign ==
                                        AyahImageTextAlign.right
                                  ? Icons.format_align_right_rounded
                                  : Icons.format_align_justify_rounded,
                            ),
                            onPressed: () {
                              setState(() {
                                final current = _settings.ayahTextAlign;
                                final next =
                                    current == AyahImageTextAlign.center
                                    ? AyahImageTextAlign.right
                                    : current == AyahImageTextAlign.right
                                    ? AyahImageTextAlign.justify
                                    : AyahImageTextAlign.center;
                                _settings = _settings.copyWith(
                                  ayahTextAlign: next,
                                );
                              });
                            },
                          ),

                        // Font Gallery Button
                        if (_shareMode == 0)
                          IconButton(
                            icon: Icon(
                              Icons.font_download_rounded,
                              color: _shareFontFamily != 'default'
                                  ? primary
                                  : null,
                            ),
                            tooltip: 'اختيار الخط',
                            onPressed: _showFontGalleryModal,
                          ),

                        // Font size decrease
                        if (_shareMode == 0)
                          IconButton(
                            icon: const Icon(Icons.text_decrease_rounded),
                            onPressed: _customFontSize > 16
                                ? () => setState(() => _customFontSize -= 2)
                                : null,
                          ),
                        // Font size increase
                        if (_shareMode == 0)
                          IconButton(
                            icon: const Icon(Icons.text_increase_rounded),
                            onPressed: _customFontSize < 80
                                ? () => setState(() => _customFontSize += 2)
                                : null,
                          ),

                        // Tafsir Selector
                        const SizedBox(width: 4),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: _selectedTafsirBook != null
                                ? primary
                                : (isDark ? Colors.white : Colors.black),
                          ),
                          onPressed: _showTafsirSelector,
                          icon: const Icon(FluentIcons.book_open_24_regular),
                          label: Text(
                            _selectedTafsirBook != null
                                ? _selectedTafsirBook!.name
                                : "تفسير",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Font Size Slider (Inline popup or just button)
                        if (_shareMode == 0)
                          _buildFontSizeButton(context, primary),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 250.ms, delay: 150.ms).slideY(begin: 0.03, end: 0),
            const SizedBox(height: 16),

            // Live Preview Area
            Expanded(
              child: Container(
                width: double.infinity,
                color: isDark
                    ? Colors.black.withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.03),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 16,
                    ),
                    child: _shareMode == 0
                        ? Screenshot(
                            controller: _screenshotController,
                            child: _buildImagePreview(),
                          )
                        : _buildTextPreview(_cardColor, primary),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

            // Bottom Action
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _isSharing ? null : _share,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.share_rounded),
                  label: Text(
                    _isSharing ? "جاري التجهيز..." : "مشاركة",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 250.ms, delay: 250.ms).slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    int mode,
    String label,
    IconData icon,
    Color primary,
    Color cardColor,
    bool isDark,
  ) {
    final isSelected = _shareMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _shareMode = mode;
            if (_shareMode == 0 && _selectedTafsirBook != null) {
              final isSadi = _selectedTafsirBook!.name.contains("سعدي");
              final isMuyassar = _selectedTafsirBook!.name.contains("ميسر");
              
              if (!isSadi && !isMuyassar) {
                final books = _getUniqueTafsirBooks();
                final valid = books.where((b) => b.name.contains("ميسر") || b.name.contains("سعدي")).toList();
                _selectedTafsirBook = valid.isNotEmpty ? valid.first : null;
              } else if (isSadi && _fromVerse != _toVerse) {
                final books = _getUniqueTafsirBooks();
                final valid = books.where((b) => b.name.contains("ميسر")).toList();
                _selectedTafsirBook = valid.isNotEmpty ? valid.first : null;
              }
            }
          });
          _fetchTafsirIfSelected();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontGalleryModal() {
    final primary = context.read<ThemeCubit>().state.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B0B0C) : const Color(0xFFF7F1E6);
    final cardColor = isDark ? const Color(0xFF1B1B1B) : Colors.white;
    final List<String> googleFonts = [
      'Amiri',
      'Cairo',
      'Tajawal',
      'Lalezar',
      'Almarai',
      'Changa',
      'El Messiri',
    ];

    // Get preview text from actual content
    final String ayahPreview = getVerse(_selectedSurah, _fromVerse, verseEndSymbol: false);
    final String shortAyah = ayahPreview.length > 60
        ? '${ayahPreview.substring(0, 60)}...'
        : ayahPreview;
    final String tafsirPreview = _resolvedTafsirText != null
        ? (_resolvedTafsirText!.length > 80
              ? '${_resolvedTafsirText!.substring(0, 80)}...'
              : _resolvedTafsirText!)
        : 'معاينة نص التفسير';

    // Auto-select Tafsir tab if tafsir is active
    final int initialTab = _resolvedTafsirText != null ? 1 : 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx2, scrollController) {
            return DefaultTabController(
              length: 2,
              initialIndex: initialTab,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.font_download_rounded, color: primary),
                          const SizedBox(width: 8),
                          const Text(
                            "اختر نوع الخط",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      labelColor: primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: primary,
                      tabs: [
                        const Tab(
                          text: "خط الآية",
                          icon: Icon(Icons.menu_book_rounded, size: 18),
                        ),
                        Tab(
                          text: "خط التفسير",
                          icon: Icon(
                            Icons.auto_stories_rounded,
                            size: 18,
                            color: _resolvedTafsirText == null
                                ? Colors.grey.withValues(alpha: 0.3)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Tab 1: Ayah Font
                          _buildFontGrid(
                            scrollController: scrollController,
                            cardColor: cardColor,
                            primary: primary,
                            googleFonts: googleFonts,
                            previewText: shortAyah,
                            selectedFont: _shareFontFamily,
                            isSelectedGoogle: _isShareFontGoogle,
                            defaultLabel: 'خط المصحف (QCF)',
                            onSelect: (fontId, isGoogle) {
                              setState(() {
                                _shareFontFamily = fontId;
                                _isShareFontGoogle = isGoogle;
                              });
                              Navigator.pop(ctx);
                            },
                            onReset: () {
                              setState(() {
                                _shareFontFamily = 'default';
                                _isShareFontGoogle = false;
                              });
                              Navigator.pop(ctx);
                            },
                          ),
                          // Tab 2: Tafsir Font (only active if tafsir is selected)
                          _resolvedTafsirText != null
                              ? _buildFontGrid(
                                  scrollController: scrollController,
                                  cardColor: cardColor,
                                  primary: primary,
                                  googleFonts: googleFonts,
                                  previewText: tafsirPreview,
                                  selectedFont: _tafsirFontFamily,
                                  isSelectedGoogle: _isTafsirFontGoogle,
                                  defaultLabel: 'الخط الافتراضي',
                                  onSelect: (fontId, isGoogle) {
                                    setState(() {
                                      _tafsirFontFamily = fontId;
                                      _isTafsirFontGoogle = isGoogle;
                                    });
                                    Navigator.pop(ctx);
                                  },
                                  onReset: () {
                                    setState(() {
                                      _tafsirFontFamily = 'default';
                                      _isTafsirFontGoogle = false;
                                    });
                                    Navigator.pop(ctx);
                                  },
                                )
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.auto_stories_rounded,
                                          size: 48,
                                          color: Colors.grey.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "\u0627\u062e\u062a\u0631 \u062a\u0641\u0633\u064a\u0631 \u0623\u0648\u0644\u0627\u064b \u0645\u0646 \u0627\u0644\u0623\u062f\u0648\u0627\u062a",
                                          style: TextStyle(
                                            color: Colors.grey.withValues(
                                              alpha: 0.5,
                                            ),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
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
          },
        );
      },
    );
  }

  Widget _buildFontGrid({
    required ScrollController scrollController,
    required Color cardColor,
    required Color primary,
    required List<String> googleFonts,
    required String previewText,
    required String selectedFont,
    required bool isSelectedGoogle,
    required String defaultLabel,
    required Function(String fontId, bool isGoogle) onSelect,
    required VoidCallback onReset,
  }) {
    return Column(
      children: [
        if (selectedFont != 'default')
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton.icon(
              onPressed: onReset,
              icon: Icon(Icons.restart_alt_rounded, color: primary, size: 18),
              label: Text(
                "إعادة التعيين إلى الافتراضي",
                style: TextStyle(color: primary),
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 1 + AppFonts.customFonts.length + googleFonts.length,
            itemBuilder: (ctx, index) {
              final bool isDefault = index == 0;
              final bool isGoogle =
                  !isDefault && index > AppFonts.customFonts.length;
              final String fontId;
              final String displayName;

              if (isDefault) {
                fontId = 'default';
                displayName = defaultLabel;
              } else if (isGoogle) {
                fontId = googleFonts[index - AppFonts.customFonts.length - 1];
                displayName = fontId;
              } else {
                fontId = AppFonts.customFonts[index - 1];
                displayName = fontId.replaceAll('-', ' ');
              }

              final isSelected =
                  selectedFont == fontId &&
                  isSelectedGoogle == (isGoogle && !isDefault);

              return GestureDetector(
                onTap: () => onSelect(fontId, isGoogle && !isDefault),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primary.withValues(alpha: 0.1)
                        : cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? primary
                          : Colors.grey.withValues(alpha: 0.12),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.1),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            previewText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: isDefault
                                ? TextStyle(
                                    fontSize: 16,
                                    color: isSelected ? primary : null,
                                    fontWeight: FontWeight.bold,
                                  )
                                : (isGoogle
                                      ? GoogleFonts.getFont(
                                          fontId,
                                          fontSize: 16,
                                          color: isSelected ? primary : null,
                                          height: 1.6,
                                        )
                                      : TextStyle(
                                          fontFamily: fontId,
                                          fontSize: 16,
                                          color: isSelected ? primary : null,
                                          height: 1.6,
                                        )),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? primary
                              : Colors.grey.withValues(alpha: 0.6),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTafsirSelector() {
    List<TafsirBookModel> books = _getUniqueTafsirBooks();
    if (!mounted) return;

    if (_shareMode == 0) {
      books = books.where((b) => b.name.contains("ميسر") || b.name.contains("سعدي")).toList();
    }

    if (books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "لا توجد تفاسير محملة.",
            textDirection: TextDirection.rtl,
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "اختر التفسير",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                ListTile(
                  title: const Text("بدون تفسير"),
                  trailing: _selectedTafsirBook == null
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedTafsirBook = null;
                    });
                    _fetchTafsirIfSelected();
                    Navigator.pop(ctx);
                  },
                ),
                ...books.map(
                  (b) {
                    final bool disabledSadi = _shareMode == 0 && _fromVerse != _toVerse && b.name.contains("سعدي");
                    return ListTile(
                      title: Text(
                        b.name,
                        style: TextStyle(
                          color: disabledSadi ? Colors.grey : null,
                        ),
                      ),
                      subtitle: disabledSadi
                          ? const Text(
                              "مسموح لآية واحدة فقط (للمزيد، يرجى اختيار التفسير الميسر أو المشاركة كنص)",
                              style: TextStyle(color: Colors.redAccent, fontSize: 11),
                            )
                          : null,
                      trailing: _selectedTafsirBook?.fullPath == b.fullPath
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        if (disabledSadi) return;
                        setState(() => _selectedTafsirBook = b);
                        _fetchTafsirIfSelected();
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============== PREVIEW GENERATORS ==============

  Widget _buildTextPreview(Color cardColor, Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int v = _fromVerse; v <= _toVerse; v++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "${getVerse(_selectedSurah, v, verseEndSymbol: false)} ",
                      ),
                      TextSpan(
                        text: "﴿${_toArabicDigits(v.toString())}﴾",
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontFamily: 'KFGQPC-Uthmanic-HAFS-Regular',
                    fontSize: 22,
                    height: 1.65,
                    color: _textColor,
                  ),
                ),
              ),

            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "${getSurahNameArabic(_selectedSurah)} : ${_fromVerse == _toVerse ? _toArabicDigits(_fromVerse.toString()) : "${_toArabicDigits(_fromVerse.toString())} - ${_toArabicDigits(_toVerse.toString())}"}",
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),

            if (_isLoadingTafsir) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],

            if (_resolvedTafsirText != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                "التفسير:",
                style: TextStyle(color: primary, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _resolvedTafsirText!,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ],

            if (_showBranding) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _textColor.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _textColor.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "تطبيق الفرقان",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _isDark
                                  ? const Color(0xFFC09B5A)
                                  : const Color(0xFF33B18E),
                            ),
                          ),
                          Text(
                            "github.com/IDRISIUM",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    // Exactly matches AyahImageGenerator.shareLibraryAsImage at 1400px canvas,
    // wrapped in FittedBox for live preview scaling.
    final isDark = _forceDarkMode;

    const double canvasWidth = 1400;
    const double paddingH = 40;
    final double headerWidth = canvasWidth - (paddingH * 2);
    final double bannerWidth = headerWidth * 0.82;

    final qcfTheme = isDark
        ? QcfThemeData.dark().copyWith(
            pageBackgroundColor: Colors.black,
            headerBackgroundColor: const Color(0xFF111111),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,
            headerFontSizeLarge: 85 * _surahNameScale,
            headerFontSizeSmall: 85 * _surahNameScale,
            headerTextColor: Colors.white,
            verseTextColor: Colors.white,
            verseNumberColor: Colors.white,
          )
        : QcfThemeData.sepia().copyWith(
            pageBackgroundColor: const Color(0xFFF7F1E6),
            headerBackgroundColor: const Color(0xFFEFE3D2),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,
            headerFontSizeLarge: 85 * _surahNameScale,
            headerFontSizeSmall: 85 * _surahNameScale,
            headerTextColor: const Color(0xFF1B1B1B),
            verseTextColor: const Color(0xFF1B1B1B),
            verseNumberColor: const Color(0xFF1B1B1B),
          );

    final Color cardBgColor = isDark ? Colors.black : const Color(0xFFF7F1E6);
    final Color tafsirBgColor = isDark
        ? const Color(0xFF111111)
        : const Color(0xFFEFE3D2);
    final Color textColor = isDark ? Colors.white : const Color(0xFF1B1B1B);

    // Build multi-surah-aware content: group verses by surah for individual banners
    // This enables sharing e.g. Al-Ikhlas + Al-Falaq + Al-Nas together with separate banners
    final pageInfo = _getPageInfo(_selectedSurah, _fromVerse);
    final List<_SurahVerseGroup> surahGroups = [];

    if (_shareFullPage && pageInfo != null) {
      // Full page mode: include ALL ayahs on this page (multi-surah)
      final allAyahs = _getAyahsOnPage(pageInfo);
      int? currentSurah;
      List<int> currentVerses = [];
      for (final a in allAyahs) {
        if (a.key != currentSurah) {
          if (currentSurah != null && currentVerses.isNotEmpty) {
            surahGroups.add(
              _SurahVerseGroup(currentSurah, List.of(currentVerses)),
            );
          }
          currentSurah = a.key;
          currentVerses = [a.value];
        } else {
          currentVerses.add(a.value);
        }
      }
      if (currentSurah != null && currentVerses.isNotEmpty) {
        surahGroups.add(_SurahVerseGroup(currentSurah, currentVerses));
      }
    } else if (pageInfo != null) {
      // Normal mode: only selected range within single surah
      surahGroups.add(
        _SurahVerseGroup(
          _selectedSurah,
          List.generate(_toVerse - _fromVerse + 1, (i) => _fromVerse + i),
        ),
      );
    }

    // Fallback: single surah group if page detection didn't work
    if (surahGroups.isEmpty) {
      surahGroups.add(
        _SurahVerseGroup(
          _selectedSurah,
          List.generate(_toVerse - _fromVerse + 1, (i) => _fromVerse + i),
        ),
      );
    }

    // Build the content widgets for each surah group
    final List<Widget> surahWidgets = [];
    for (final group in surahGroups) {
      // Banner for this surah
      surahWidgets.add(const SizedBox(height: 30));
      surahWidgets.add(
        Center(
          child: SizedBox(
            width: bannerWidth,
            child: Transform.scale(
              scale: _bannerScale,
              child: HeaderWidget(
                suraNumber: group.surahNumber,
                theme: qcfTheme,
              ),
            ),
          ),
        ),
      );
      // Removed the SizedBox completely to eliminate the gap before Ayah 9

      // Build verseSpans exactly like QcfPage does it:
      // All verses → one flat list of TextSpans → single Text.rich
      final List<InlineSpan> verseSpans = [];
      for (final v in group.verses) {
        final int pageNumber = getPageNumber("${group.surahNumber}:$v") ?? 1;
        final String pageFont = "QCF_P${pageNumber.toString().padLeft(3, '0')}";

        // Use custom font if user selected one, otherwise use QCF page font
        final bool useCustomFont = _shareFontFamily != 'default';
        final String effectiveFont = useCustomFont
            ? _shareFontFamily
            : pageFont;
        final String effectiveText = useCustomFont
            ? getVerse(group.surahNumber, v, verseEndSymbol: false)
            : getVerseQCF(group.surahNumber, v, verseEndSymbol: false);
        final String effectiveNumber = useCustomFont
            ? ' \u06DD${v.toString()} '
            : getVerseNumberQCF(group.surahNumber, v);

        verseSpans.add(
          TextSpan(
            text: effectiveText,
            style: useCustomFont
                ? (_isShareFontGoogle
                      ? GoogleFonts.getFont(
                          effectiveFont,
                          fontSize: _customFontSize,
                          color: qcfTheme.verseTextColor,
                          height: 2.1,
                        )
                      : TextStyle(
                          fontFamily: effectiveFont,
                          fontSize: _customFontSize,
                          color: qcfTheme.verseTextColor,
                          height: 2.1,
                          fontFamilyFallback: const [
                            'Amiri-Regular',
                            'KFGQPC-Uthmanic-HAFS-Regular',
                          ],
                        ))
                : TextStyle(
                    fontFamily: effectiveFont,
                    fontSize: _customFontSize,
                    color: qcfTheme.verseTextColor,
                    height: 2.1,
                  ),
          ),
        );
        verseSpans.add(
          TextSpan(
            text: effectiveNumber,
            style: useCustomFont
                ? TextStyle(
                    fontSize: _customFontSize * 0.7,
                    color: qcfTheme.verseNumberColor,
                    fontWeight: FontWeight.bold,
                    fontFamilyFallback: const ['Amiri-Regular'],
                  )
                : TextStyle(
                    fontFamily: pageFont,
                    fontSize: _customFontSize,
                    color: qcfTheme.verseNumberColor,
                    height: qcfTheme.verseNumberHeight,
                  ),
          ),
        );
      }

      surahWidgets.add(const SizedBox(height: 16));

      surahWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text.rich(
            TextSpan(children: verseSpans),
            locale: const Locale("ar"),
            textScaler: const TextScaler.linear(1),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
            style: TextStyle(
              fontSize: _customFontSize,
              color: qcfTheme.verseTextColor,
              height: 2.1,
            ),
          ),
        ),
      );
    }

    // Tafsir title styling (matches AyahImageGenerator)
    final String tafsirTitle = _selectedTafsirBook?.name ?? "التفسير";
    final double titleFontSize = (44 - (tafsirTitle.length * 0.35)).clamp(
      36,
      44,
    );

    final Widget contentColumn = Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Multi-surah banners + verses
          ...surahWidgets,

          if (_isLoadingTafsir) ...[
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],

          if (_resolvedTafsirText != null) ...[
            const SizedBox(height: 38),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              decoration: BoxDecoration(
                color: tafsirBgColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: textColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tafsirTitle,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFC09B5A),
                    ),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 20),
                  _buildRichTafsirText(
                    _resolvedTafsirText!,
                    TextStyle(
                      fontSize: _tafsirFontSize,
                      height: 2.0,
                      color: textColor,
                    ),
                    const Color(0xFFC09B5A),
                  ),
                ],
              ),
            ),
          ],
          if (_showBranding) ...[
            const SizedBox(height: 38),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: textColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "تطبيق الفرقان",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? const Color(0xFFC09B5A)
                              : const Color(0xFF33B18E),
                        ),
                      ),
                      Text(
                        "github.com/IDRISIUMCorp/al-furkan-quran-flutter-app",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );

    // Classic only
    final Widget card = Container(
      width: canvasWidth,
      padding: const EdgeInsets.symmetric(horizontal: paddingH, vertical: 22),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: contentColumn,
    );

    // FittedBox scales the 1400px card down to fit the preview area
    return FittedBox(fit: BoxFit.fitWidth, child: card);
  }

  Widget _buildFontSizeButton(BuildContext context, Color primary) {
    return IconButton(
      icon: const Icon(Icons.format_size_rounded),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: const Text("حجم الخط", textAlign: TextAlign.right),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Gap(16),
                  const Text(
                    "حجم اسم السورة",
                    textAlign: TextAlign.right,
                  ),
                  Slider(
                    value: _surahNameScale,
                    min: 0.5,
                    max: 2.5,
                    divisions: 20,
                    label: _surahNameScale.toStringAsFixed(1),
                    onChanged: (v) {
                      setDialogState(() => _surahNameScale = v);
                      setState(() => _surahNameScale = v);
                    },
                  ),
                  const Gap(16),
                  const Text("حجم البانر", textAlign: TextAlign.right),
                  Slider(
                    value: _bannerScale,
                    min: 0.5,
                    max: 2.5,
                    divisions: 20,
                    label: _bannerScale.toStringAsFixed(1),
                    onChanged: (v) {
                      setDialogState(() => _bannerScale = v);
                      setState(() => _bannerScale = v);
                    },
                  ),
                  if (_selectedTafsirBook != null) ...[
                    const Gap(16),
                    const Text(
                      "حجم التفسير",
                      textAlign: TextAlign.right,
                    ),
                    Slider(
                      value: _tafsirFontSize,
                      min: 24,
                      max: 100,
                      divisions: 38,
                      label: _tafsirFontSize.round().toString(),
                      onChanged: (v) {
                        setDialogState(() => _tafsirFontSize = v);
                        setState(() => _tafsirFontSize = v);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildRichTafsirText(
    String text,
    TextStyle baseStyle,
    Color primaryColor,
  ) {
    if (text.isEmpty) {
      return Text(text, style: baseStyle);
    }

    // Match text inside { } or ( ) or [ ] to highlight ayahs
    final regex = RegExp(r'\{[^\}]+\}|\([^\)]+\)|\[[^\]]+\]|«[^»]+»');
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return Text(
        text,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        style: baseStyle,
      );
    }

    final spans = <TextSpan>[];
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(text: text.substring(currentIndex, match.start)),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: baseStyle.copyWith(
            color: primaryColor,
          ),
        ),
      );
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
    );
  }
}

/// Helper class to group verses by surah for multi-surah rendering
class _SurahVerseGroup {
  final int surahNumber;
  final List<int> verses;
  const _SurahVerseGroup(this.surahNumber, this.verses);
}
