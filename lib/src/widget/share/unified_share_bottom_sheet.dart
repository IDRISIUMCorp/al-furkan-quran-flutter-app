import 'dart:io';

import 'package:al_quran_v3/src/model/ayah_image_settings.dart';
import 'package:al_quran_v3/src/resources/quran_resources/quran_pages_info.dart';
import 'package:al_quran_v3/src/theme/controller/theme_cubit.dart';
import 'package:al_quran_v3/src/utils/basic_functions.dart';
import 'package:al_quran_v3/src/utils/quran_ayahs_function/get_page_number.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gap/gap.dart';
import 'package:qcf_quran/qcf_quran.dart' hide getPageNumber;
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:al_quran_v3/src/resources/quran_resources/models/tafsir_book_model.dart';
import 'package:al_quran_v3/src/utils/quran_resources/quran_tafsir_function.dart';
import 'package:al_quran_v3/src/core/constants/app_fonts.dart';
import 'package:google_fonts/google_fonts.dart';

class UnifiedShareBottomSheet extends StatefulWidget {
  final int initialSurahNumber;
  final int initialVerseNumber;
  final String Function(int surah, int verse) getAyahText;

  const UnifiedShareBottomSheet({
    super.key,
    required this.initialSurahNumber,
    required this.initialVerseNumber,
    required this.getAyahText,
  });

  static Future<void> show({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
    required String Function(int surah, int verse) getAyahText,
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
          initialChildSize: 0.90,
          minChildSize: 0.60,
          maxChildSize: 0.95,
          builder: (context, scrollController) => UnifiedShareBottomSheet(
            initialSurahNumber: surahNumber,
            initialVerseNumber: verseNumber,
            getAyahText: getAyahText,
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
  String _shareFontFamily = 'default'; // 'default' = use QCF page fonts
  bool _isShareFontGoogle = false;
  String _tafsirFontFamily = 'default';
  bool _isTafsirFontGoogle = false;

  // Settings
  AyahImageSettings _settings = const AyahImageSettings(
    background: AyahImageBackground.light,
    ayahTextAlign: AyahImageTextAlign.center,
  );

  double _customFontSize = 75.0; // Matches AyahImageGenerator default
  double _surahNameScale = 1.0; // Default scale for Surah name text
  double _bannerScale = 1.0; // Default scale for Surah banner frame
  double _tafsirFontSize = 48.0; // Default scale for Tafsir text
  bool _showBranding = true; // Identity Branding Toggle
  bool _didInitDarkMode = false;

  @override
  void initState() {
    super.initState();
    _selectedSurah = widget.initialSurahNumber;
    _fromVerse = widget.initialVerseNumber;
    _toVerse = widget.initialVerseNumber;
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
    _pageMinVerse = surahAyahs.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    _pageMaxVerse = surahAyahs.map((e) => e.value).reduce((a, b) => a > b ? a : b);
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
    final int estimatedHeight = (verseCount * 180) + (totalTextLength ~/ 3) + 400;

    if (estimatedHeight > 2800) {
      if (mounted) {
        setState(() {
          _selectedTafsirBook = null;
          _resolvedTafsirText = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("╪º┘ä┘å╪╡ ╪╖┘ê┘è┘ä ╪¼╪»╪º┘ï ┘ä╪Ñ╪╢╪º┘ü╪⌐ ╪¬┘ü╪│┘è╪▒ ΓÇö ╪º┘ä╪╡┘ê╪▒╪⌐ ┘ç╪¬┘â┘ê┘å ╪ú┘â╪¿╪▒ ┘à┘å ╪º┘ä┘à╪│┘à┘ê╪¡", textDirection: TextDirection.rtl),
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
        _resolvedTafsirText = buffer.toString().trim().isEmpty ? null : buffer.toString().trim();
        _isLoadingTafsir = false;
      });
    }
  }

  int _calculateRawTextLength() {
    int len = 0;
    for (int v = _fromVerse; v <= _toVerse; v++) {
      len += widget.getAyahText(_selectedSurah, v).length;
    }
    return len;
  }

  String _toArabicDigits(String number) {
    const arabics = ['┘á', '┘í', '┘ó', '┘ú', '┘ñ', '┘Ñ', '┘ª', '┘º', '┘¿', '┘⌐'];
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
    t = t.replaceAll(RegExp(r"[\s\u06DD█¥]+$"), "");
    t = t.replaceAll(RegExp(r"[\s0-9┘á-┘⌐█░-█╣]+$"), "");
    
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
        var t = _cleanAyahText(widget.getAyahText(_selectedSurah, v));
        buffer.writeln("$t ∩┤┐${_toArabicDigits(v.toString())}∩┤╛");
      }

      if (_resolvedTafsirText != null) {
        final tafsirName = _selectedTafsirBook?.name ?? "╪º┘ä╪¬┘ü╪│┘è╪▒";
        buffer.writeln();
        buffer.writeln("ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ");
        buffer.writeln("$tafsirName:");
        buffer.writeln(_resolvedTafsirText);
      }

      if (_showBranding) {
        buffer.writeln();
        buffer.writeln("╪¬┘à╪¬ ╪º┘ä┘à╪┤╪º╪▒┘â╪⌐ ┘à┘å ╪¬╪╖╪¿┘è┘é ╪º┘ä┘ü╪▒┘é╪º┘å");
        buffer.writeln("github.com/IDRISIUMCorp/al-furkan-quran-flutter-app");
      }

      await SharePlus.instance.share(ShareParams(text: buffer.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = context.read<ThemeCubit>().state;
    final bgColor = isDark ? const Color(0xFF0B0B0C) : const Color(0xFFF7F1E6);
    final cardColor = isDark ? const Color(0xFF1B1B1B) : const Color(0xFFFFF9F2);
    final primary = themeState.primary;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "┘à╪┤╪º╪▒┘â╪⌐",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balance
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Segmented Control (Tabs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    _buildTab(1, "┘å╪╡", Icons.text_snippet_rounded, primary, cardColor, isDark),
                    _buildTab(0, "╪╡┘ê╪▒╪⌐", Icons.image_rounded, primary, cardColor, isDark),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Range Selectors (Surah, From, To) ΓÇö animated hide when full page is on
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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: cardColor,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("╪│┘ê╪▒╪⌐", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(10),
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
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                                  overflow: TextOverflow.ellipsis,
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("┘à┘å", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(10),
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
                                                  _toArabicDigits((_pageMinVerse + i).toString()),
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                                ),
                                              ),
                                            ),
                                            onChanged: (v) {
                                              if (v != null) {
                                                setState(() {
                                                  _fromVerse = v;
                                                  if (_toVerse < _fromVerse) _toVerse = _fromVerse;
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
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("╪Ñ┘ä┘ë", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          borderRadius: BorderRadius.circular(10),
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
                                                  _toArabicDigits((_fromVerse + i).toString()),
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
            ),
            const SizedBox(height: 8),

            // Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: cardColor,
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
                              _shareFullPage ? FluentIcons.document_page_bottom_center_24_filled : FluentIcons.document_page_bottom_center_24_regular,
                              color: _shareFullPage ? primary : null,
                            ),
                            tooltip: '┘à╪┤╪º╪▒┘â╪⌐ ╪º┘ä╪╡┘ü╪¡╪⌐ ┘â╪º┘à┘ä╪⌐',
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
                              _forceDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: _forceDarkMode ? primary : null,
                            ),
                            onPressed: () => setState(() => _forceDarkMode = !_forceDarkMode),
                          ),

                        IconButton(
                          icon: Icon(
                            _showBranding ? FluentIcons.person_board_24_filled : FluentIcons.person_board_24_regular,
                            color: _showBranding ? primary : null,
                          ),
                          tooltip: '╪Ñ╪╕┘ç╪º╪▒ ╪º┘ä┘ç┘ê┘è╪⌐',
                          onPressed: () => setState(() => _showBranding = !_showBranding),
                        ),

                        // Alignment Toggle
                        if (_shareMode == 0)
                          IconButton(
                            icon: Icon(
                              _settings.ayahTextAlign == AyahImageTextAlign.center
                                  ? Icons.format_align_center_rounded
                                  : _settings.ayahTextAlign == AyahImageTextAlign.right
                                      ? Icons.format_align_right_rounded
                                      : Icons.format_align_justify_rounded,
                            ),
                            onPressed: () {
                              setState(() {
                                final current = _settings.ayahTextAlign;
                                final next = current == AyahImageTextAlign.center
                                    ? AyahImageTextAlign.right
                                    : current == AyahImageTextAlign.right
                                        ? AyahImageTextAlign.justify
                                        : AyahImageTextAlign.center;
                                _settings = _settings.copyWith(ayahTextAlign: next);
                              });
                            },
                          ),

                        // Font Gallery Button
                        if (_shareMode == 0)
                          IconButton(
                            icon: Icon(
                              Icons.font_download_rounded,
                              color: _shareFontFamily != 'default' ? primary : null,
                            ),
                            tooltip: '╪º╪«╪¬┘è╪º╪▒ ╪º┘ä╪«╪╖',
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
                            foregroundColor: _selectedTafsirBook != null ? primary : (isDark ? Colors.white : Colors.black),
                          ),
                          onPressed: _showTafsirSelector,
                          icon: const Icon(FluentIcons.book_open_24_regular),
                          label: Text(
                            _selectedTafsirBook != null ? _selectedTafsirBook!.name : "╪¬┘ü╪│┘è╪▒",
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
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
            ),
            const SizedBox(height: 16),

            // Live Preview Area
            Expanded(
              child: Container(
                width: double.infinity,
                color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: _shareMode == 0
                        ? Screenshot(
                            controller: _screenshotController,
                            child: _buildImagePreview(),
                          )
                        : _buildTextPreview(cardColor, primary),
                  ),
                ),
              ),
            ),

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
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.share_rounded),
                  label: Text(
                    _isSharing ? "╪¼╪º╪▒┘è ╪º┘ä╪¬╪¼┘ç┘è╪▓..." : "┘à╪┤╪º╪▒┘â╪⌐",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int mode, String label, IconData icon, Color primary, Color cardColor, bool isDark) {
    final isSelected = _shareMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _shareMode = mode),
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
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
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
    final List<String> googleFonts = ['Amiri', 'Cairo', 'Tajawal', 'Lalezar', 'Almarai', 'Changa', 'El Messiri'];
    
    // Get preview text from actual content
    final String ayahPreview = _cleanAyahText(widget.getAyahText(_selectedSurah, _fromVerse));
    final String shortAyah = ayahPreview.length > 60 ? '${ayahPreview.substring(0, 60)}...' : ayahPreview;
    final String tafsirPreview = _resolvedTafsirText != null 
        ? (_resolvedTafsirText!.length > 80 ? '${_resolvedTafsirText!.substring(0, 80)}...' : _resolvedTafsirText!)
        : '┘à╪╣╪º┘è┘å╪⌐ ┘å╪╡ ╪º┘ä╪¬┘ü╪│┘è╪▒';
    
    // Auto-select Tafsir tab if tafsir is active
    final int initialTab = _resolvedTafsirText != null ? 1 : 0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: bgColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
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
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.font_download_rounded, color: primary),
                          const SizedBox(width: 8),
                          const Text("╪º╪«╪¬╪▒ ┘å┘ê╪╣ ╪º┘ä╪«╪╖", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    TabBar(
                      labelColor: primary,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: primary,
                      tabs: [
                        const Tab(text: "╪«╪╖ ╪º┘ä╪ó┘è╪⌐", icon: Icon(Icons.menu_book_rounded, size: 18)),
                        Tab(
                          text: "╪«╪╖ ╪º┘ä╪¬┘ü╪│┘è╪▒",
                          icon: Icon(Icons.auto_stories_rounded, size: 18, color: _resolvedTafsirText == null ? Colors.grey.withValues(alpha: 0.3) : null),
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
                            defaultLabel: '╪«╪╖ ╪º┘ä┘à╪╡╪¡┘ü (QCF)',
                            onSelect: (fontId, isGoogle) {
                              setState(() { _shareFontFamily = fontId; _isShareFontGoogle = isGoogle; });
                              Navigator.pop(ctx);
                            },
                            onReset: () {
                              setState(() { _shareFontFamily = 'default'; _isShareFontGoogle = false; });
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
                            defaultLabel: '╪º┘ä╪«╪╖ ╪º┘ä╪º┘ü╪¬╪▒╪º╪╢┘è',
                            onSelect: (fontId, isGoogle) {
                              setState(() { _tafsirFontFamily = fontId; _isTafsirFontGoogle = isGoogle; });
                              Navigator.pop(ctx);
                            },
                            onReset: () {
                              setState(() { _tafsirFontFamily = 'default'; _isTafsirFontGoogle = false; });
                              Navigator.pop(ctx);
                            },
                          )
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.auto_stories_rounded, size: 48, color: Colors.grey.withValues(alpha: 0.3)),
                                      const SizedBox(height: 16),
                                      Text(
                                        "\u0627\u062e\u062a\u0631 \u062a\u0641\u0633\u064a\u0631 \u0623\u0648\u0644\u0627\u064b \u0645\u0646 \u0627\u0644\u0623\u062f\u0648\u0627\u062a",
                                        style: TextStyle(color: Colors.grey.withValues(alpha: 0.5), fontSize: 16),
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
              label: Text("╪Ñ╪╣╪º╪»╪⌐ ╪º┘ä╪¬╪╣┘è┘è┘å ╪Ñ┘ä┘ë ╪º┘ä╪º┘ü╪¬╪▒╪º╪╢┘è", style: TextStyle(color: primary)),
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
              final bool isGoogle = !isDefault && index > AppFonts.customFonts.length;
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
              
              final isSelected = selectedFont == fontId && isSelectedGoogle == (isGoogle && !isDefault);
              
              return GestureDetector(
                onTap: () => onSelect(fontId, isGoogle && !isDefault),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? primary.withValues(alpha: 0.1) : cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? primary : Colors.grey.withValues(alpha: 0.12),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [BoxShadow(color: primary.withValues(alpha: 0.1), blurRadius: 8)] : null,
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
                              ? TextStyle(fontSize: 16, color: isSelected ? primary : null, fontWeight: FontWeight.bold)
                              : (isGoogle 
                                  ? GoogleFonts.getFont(fontId, fontSize: 16, color: isSelected ? primary : null, height: 1.6) 
                                  : TextStyle(fontFamily: fontId, fontSize: 16, color: isSelected ? primary : null, height: 1.6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: isSelected ? primary : Colors.grey.withValues(alpha: 0.6), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
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
    final books = QuranTafsirFunction.getDownloadedTafsirBooks();
    if (!mounted) return;
    
    if (books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("┘ä╪º ╪¬┘ê╪¼╪» ╪¬┘ü╪º╪│┘è╪▒ ┘à╪¡┘à┘ä╪⌐.", textDirection: TextDirection.rtl)),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: ListView(
              shrinkWrap: true,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("╪º╪«╪¬╪▒ ╪º┘ä╪¬┘ü╪│┘è╪▒", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                ListTile(
                  title: const Text("╪¿╪»┘ê┘å ╪¬┘ü╪│┘è╪▒"),
                  trailing: _selectedTafsirBook == null ? const Icon(Icons.check_circle, color: Colors.green) : null,
                  onTap: () {
                    setState(() => _selectedTafsirBook = null);
                    _fetchTafsirIfSelected();
                    Navigator.pop(ctx);
                  },
                ),
                ...books.map((b) => ListTile(
                  title: Text(b.name),
                  trailing: _selectedTafsirBook?.fullPath == b.fullPath ? const Icon(Icons.check_circle, color: Colors.green) : null,
                  onTap: () {
                    setState(() => _selectedTafsirBook = b);
                    _fetchTafsirIfSelected();
                    Navigator.pop(ctx);
                  },
                )),
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
                      TextSpan(text: "${_cleanAyahText(widget.getAyahText(_selectedSurah, v))} "),
                      TextSpan(
                        text: "∩┤┐${_toArabicDigits(v.toString())}∩┤╛",
                        style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  style: const TextStyle(fontSize: 20, height: 1.7),
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
                style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 13),
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
                "╪º┘ä╪¬┘ü╪│┘è╪▒:",
                style: TextStyle(color: primary, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                _resolvedTafsirText!,
                style: const TextStyle(fontSize: 16, height: 1.6),
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
            headerFontSizeLarge: 85,
            headerFontSizeSmall: 85,
            headerTextColor: Colors.white,
            verseTextColor: Colors.white,
            verseNumberColor: Colors.white,
          )
        : QcfThemeData.sepia().copyWith(
            pageBackgroundColor: const Color(0xFFF7F1E6),
            headerBackgroundColor: const Color(0xFFEFE3D2),
            headerWidthLarge: bannerWidth * 1.25,
            headerWidthSmall: bannerWidth * 1.25,
            headerFontSizeLarge: 85,
            headerFontSizeSmall: 85,
            headerTextColor: const Color(0xFF1B1B1B),
            verseTextColor: const Color(0xFF1B1B1B),
            verseNumberColor: const Color(0xFF1B1B1B),
          );

    final Color cardBgColor = isDark ? Colors.black : const Color(0xFFF7F1E6);
    final Color tafsirBgColor = isDark ? const Color(0xFF111111) : const Color(0xFFEFE3D2);
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
            surahGroups.add(_SurahVerseGroup(currentSurah, List.of(currentVerses)));
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
      surahGroups.add(_SurahVerseGroup(
        _selectedSurah,
        List.generate(_toVerse - _fromVerse + 1, (i) => _fromVerse + i),
      ));
    }

    // Fallback: single surah group if page detection didn't work
    if (surahGroups.isEmpty) {
      surahGroups.add(_SurahVerseGroup(
        _selectedSurah,
        List.generate(_toVerse - _fromVerse + 1, (i) => _fromVerse + i),
      ));
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
            child: HeaderWidget(
              suraNumber: group.surahNumber,
              theme: qcfTheme,
            ),
          ),
        ),
      );
      surahWidgets.add(const SizedBox(height: 50));

      // Build verseSpans exactly like QcfPage does it:
      // All verses ΓåÆ one flat list of TextSpans ΓåÆ single Text.rich
      final List<InlineSpan> verseSpans = [];
      for (final v in group.verses) {
        final int pageNumber = getPageNumber("${group.surahNumber}:$v") ?? 1;
        final String pageFont = "QCF_P${pageNumber.toString().padLeft(3, '0')}";
        
        // Use custom font if user selected one, otherwise use QCF page font
        final bool useCustomFont = _shareFontFamily != 'default';
        final String? customFontPackage = useCustomFont ? null : 'qcf_quran';
        final String effectiveFont = useCustomFont ? _shareFontFamily : pageFont;
        final String? effectiveText = useCustomFont 
            ? getVerse(group.surahNumber, v, verseEndSymbol: false)
            : getVerseQCF(group.surahNumber, v, verseEndSymbol: false);
        final String? effectiveNumber = useCustomFont
            ? ' \u06DD${v.toString()} '
            : getVerseNumberQCF(group.surahNumber, v);

        verseSpans.add(
          TextSpan(
            text: effectiveText,
            style: useCustomFont
                ? (_isShareFontGoogle
                    ? GoogleFonts.getFont(effectiveFont, fontSize: _customFontSize, color: qcfTheme.verseTextColor, height: 2.1)
                    : TextStyle(
                        fontFamily: effectiveFont,
                        fontSize: _customFontSize,
                        color: qcfTheme.verseTextColor,
                        height: 2.1,
                        fontFamilyFallback: const ['Amiri-Regular', 'KFGQPC-Uthmanic-HAFS-Regular'],
                      ))
                : TextStyle(
                    fontFamily: effectiveFont,
                    package: customFontPackage,
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
                    package: 'qcf_quran',
                    fontSize: _customFontSize,
                    color: qcfTheme.verseNumberColor,
                    height: qcfTheme.verseNumberHeight,
                  ),
          ),
        );
      }

      surahWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text.rich(
            TextSpan(children: verseSpans),
            locale: const Locale("ar"),
            textScaler: const TextScaler.linear(1),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
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
    final String tafsirTitle = _selectedTafsirBook?.name ?? "╪º┘ä╪¬┘ü╪│┘è╪▒";
    final double titleFontSize = (44 - (tafsirTitle.length * 0.35)).clamp(36, 44);

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
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              height: 1.2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              color: textColor.withValues(alpha: 0.12),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  tafsirTitle,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w800,
                    color: textColor.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
              decoration: BoxDecoration(
                color: tafsirBgColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _resolvedTafsirText!,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: _tafsirFontFamily != 'default' && _isTafsirFontGoogle
                      ? GoogleFonts.getFont(_tafsirFontFamily, fontSize: _tafsirFontSize, height: 2.2, fontWeight: FontWeight.w600, color: textColor)
                      : TextStyle(
                          fontSize: _tafsirFontSize,
                          height: 2.2,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                          fontFamily: _tafsirFontFamily != 'default' ? _tafsirFontFamily : null,
                        ),
                ),
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
                        "╪¬╪╖╪¿┘è┘é ╪º┘ä┘ü╪▒┘é╪º┘å",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFFC09B5A) : const Color(0xFF33B18E),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      "assets/img/Quran_Logo_v3.png",
                      width: 90,
                      height: 90,
                    ),
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
    return FittedBox(
      fit: BoxFit.fitWidth,
      child: card,
    );
  }

  Widget _buildFontSizeButton(BuildContext context, Color primary) {
     return IconButton(
       icon: const Icon(Icons.format_size_rounded),
       onPressed: () {
         showDialog(
           context: context,
           builder: (context) => StatefulBuilder(
             builder: (context, setDialogState) => AlertDialog(
               title: const Text("╪¡╪¼┘à ╪º┘ä╪«╪╖", textAlign: TextAlign.right),
               content: Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   const Gap(16),
                   const Text("╪¡╪¼┘à ╪º╪│┘à ╪º┘ä╪│┘ê╪▒╪⌐", textAlign: TextAlign.right),
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
                   const Text("╪¡╪¼┘à ╪º┘ä╪¿╪º┘å╪▒", textAlign: TextAlign.right),
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
                     const Text("╪¡╪¼┘à ╪º┘ä╪¬┘ü╪│┘è╪▒", textAlign: TextAlign.right),
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
}

/// Helper class to group verses by surah for multi-surah rendering
class _SurahVerseGroup {
  final int surahNumber;
  final List<int> verses;
  const _SurahVerseGroup(this.surahNumber, this.verses);
}
