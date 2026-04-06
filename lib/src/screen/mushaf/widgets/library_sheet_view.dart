import "package:al_quran_v3/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:al_quran_v3/src/resources/quran_resources/quran_ayah_count.dart";
import "package:al_quran_v3/src/resources/quran_resources/meaning_of_surah.dart";
import "package:al_quran_v3/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_quran_v3/src/core/unified_quran_settings/quran_settings_bottom_sheet.dart";
import "package:al_quran_v3/src/screen/quran_resources/quran_resources_view.dart";
import "package:al_quran_v3/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:al_quran_v3/src/theme/controller/theme_state.dart" as theme;
import "package:al_quran_v3/src/utils/quran_ayahs_function/get_page_number.dart";
import "package:al_quran_v3/src/utils/quran_resources/get_translation_with_word_by_word.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_script_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_tafsir_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/word_info_models.dart";
import "package:al_quran_v3/src/utils/quran_resources/word_info_repository.dart";
import "package:al_quran_v3/src/widget/add_collection_popup/add_note_popup.dart";
import "package:al_quran_v3/src/widget/add_collection_popup/add_to_pinned_popup.dart";
import "package:al_quran_v3/src/widget/share/unified_share_bottom_sheet.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:flutter/services.dart";
import "package:qcf_quran/qcf_quran.dart" as qcf hide getPageNumber;

enum _LibraryWordTab { translation, eerab, tasreef, recitations }

extension on _LibraryWordTab {
  String get label {
    switch (this) {
      case _LibraryWordTab.translation:
        return "الترجمة";
      case _LibraryWordTab.eerab:
        return "الإعراب";
      case _LibraryWordTab.tasreef:
        return "الصرف";
      case _LibraryWordTab.recitations:
        return "القراءات";
    }
  }

  WordInfoKind? get infoKind {
    switch (this) {
      case _LibraryWordTab.translation:
        return null;
      case _LibraryWordTab.eerab:
        return WordInfoKind.eerab;
      case _LibraryWordTab.tasreef:
        return WordInfoKind.tasreef;
      case _LibraryWordTab.recitations:
        return WordInfoKind.recitations;
    }
  }
}

class WahyLibrarySheetView extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;

  const WahyLibrarySheetView({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
  });

  @override
  State<WahyLibrarySheetView> createState() => _WahyLibrarySheetViewState();
}

class _WahyLibrarySheetViewState extends State<WahyLibrarySheetView> {
  late int _currentVerse;
  int? _selectedWordNumber;
  _LibraryWordTab _activeTab = _LibraryWordTab.translation;

  final WordInfoRepository _wordInfoRepo = WordInfoRepository();
  final Map<WordInfoKind, Future<int?>> _wordInfoSizeFutures = {};
  final Map<WordInfoKind, int?> _resolvedWordInfoSizes = {};
  final Map<String, Future<List<_ResolvedTafsirCard>>> _tafsirFutureCache = {};
  final Map<WordInfoKind, double> _downloadProgressByKind = {};

  WordInfoKind? _downloadingKind;

  @override
  void initState() {
    super.initState();
    _currentVerse = widget.verseNumber;
  }

  String _toArabicDigits(String input) {
    const english = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];
    const arabic = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  List<String> _getQcfWords(int surah, int verse) {
    return qcf.getVerseQCFWords(surah, verse, verseEndSymbol: false);
  }

  List<String> _getPlainWords(BuildContext context, int surah, int verse) {
    final scriptType = context.read<QuranViewCubit>().state.quranScriptType;
    final words = QuranScriptFunction.getWordListOfAyah(
      scriptType,
      surah.toString(),
      verse.toString(),
    );
    if (words.isNotEmpty) return words;
    return qcf
        .getVerse(surah, verse, verseEndSymbol: false)
        .split(RegExp(r"\s+"))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  String _selectedWordLabel(BuildContext context) {
    final selected = _selectedWordNumber;
    if (selected == null) return "";
    final words = _getPlainWords(context, widget.surahNumber, _currentVerse);
    final index = selected - 1;
    if (index < 0 || index >= words.length) return "";
    return _normalizeWhitespace(words[index]);
  }

  String _stripHtml(String? htmlText) {
    if (htmlText == null) return "";
    final exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(exp, "").replaceAll("&nbsp;", " ").trim();
  }

  String _normalizeWhitespace(String value) {
    return value.replaceAll(RegExp(r"\s+"), " ").trim();
  }

  String _getAyahText(BuildContext context, int surah, int verse) {
    final scriptType = context.read<QuranViewCubit>().state.quranScriptType;
    final words = QuranScriptFunction.getWordListOfAyah(
      scriptType,
      surah.toString(),
      verse.toString(),
    );
    return words.join(" ");
  }

  String _formatAyahTextForSharing({
    required String ayahKey,
    required String ayahText,
  }) {
    final parts = ayahKey.split(":");
    final surah = int.parse(parts[0]);
    final verse = int.parse(parts[1]);
    return "$ayahText\n\n[${getSurahNameArabic(surah)}: $verse]\nتمت المشاركة من تطبيق الفرقان";
  }

  String _fallbackSizeLabel(WordInfoKind kind) {
    switch (kind) {
      case WordInfoKind.eerab:
        return "1.2 MB";
      case WordInfoKind.tasreef:
        return "0.8 MB";
      case WordInfoKind.recitations:
        return "1.5 MB";
    }
  }

  String _formatFileSize(int? bytes, {required String fallback}) {
    if (bytes == null || bytes <= 0) return fallback;

    const units = ["B", "KB", "MB", "GB"];
    double size = bytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    final fixed = unitIndex == 0 ? 0 : (size >= 10 ? 1 : 2);
    return "${size.toStringAsFixed(fixed)} ${units[unitIndex]}";
  }

  String _wordInfoLabel(WordInfoKind kind) {
    switch (kind) {
      case WordInfoKind.eerab:
        return "الإعراب";
      case WordInfoKind.tasreef:
        return "الصرف";
      case WordInfoKind.recitations:
        return "القراءات";
    }
  }

  String _localizedRevelationPlace(int surahNumber) {
    final raw = qcf.getPlaceOfRevelation(surahNumber).trim().toLowerCase();
    if (raw.contains("makk")) return "مكية";
    if (raw.contains("mad")) return "مدنية";
    return qcf.getPlaceOfRevelation(surahNumber);
  }

  Future<int?> _getWordInfoSize(WordInfoKind kind) {
    return _wordInfoSizeFutures.putIfAbsent(kind, () async {
      final size = await _wordInfoRepo.getRemoteZipSizeBytes(kind);
      _resolvedWordInfoSizes[kind] = size;
      return size;
    });
  }

  Future<void> _downloadWordInfo(WordInfoKind kind) async {
    if (_downloadingKind != null) return;

    setState(() {
      _downloadingKind = kind;
      _downloadProgressByKind[kind] = 0;
    });

    try {
      await _wordInfoRepo.downloadKind(
        kind: kind,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _downloadProgressByKind[kind] = (progress / 100).clamp(0.0, 1.0);
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "تعذر تحميل ${_wordInfoLabel(kind)} الآن، حاول مرة أخرى.",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _downloadingKind = null;
        });
      }
    }
  }

  void _toggleWordSelection(int wordNumber) {
    setState(() {
      final isSameWord = _selectedWordNumber == wordNumber;
      _selectedWordNumber = isSameWord ? null : wordNumber;
      if (!isSameWord) {
        _activeTab = _LibraryWordTab.translation;
      }
    });
  }

  void _changeVerse(int verse) {
    setState(() {
      _currentVerse = verse;
      _selectedWordNumber = null;
      _activeTab = _LibraryWordTab.translation;
    });
  }

  Future<void> _copyText(String text, String message) async {
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _selectedWordShareText(BuildContext context) {
    final word = _selectedWordLabel(context);
    final ayahText = _getAyahText(context, widget.surahNumber, _currentVerse);
    if (word.isEmpty) return ayahText;
    return "الكلمة المختارة: $word\n\n$ayahText\n\n[${getSurahNameArabic(widget.surahNumber)}: $_currentVerse]\nتمت المشاركة من تطبيق الفرقان";
  }

  String _tafsirDedupKey(TafsirBookModel book) {
    final normalizedName = _normalizeWhitespace(book.name).toLowerCase();
    final normalizedLanguage = _normalizeWhitespace(
      book.language,
    ).toLowerCase();
    return "$normalizedLanguage::$normalizedName";
  }

  int _tafsirPriority(_ResolvedTafsirCard card) {
    int score = card.text.isEmpty ? 0 : 100000;
    if (!card.book.fullPath.startsWith("bundled/")) {
      score += 1000;
    }
    score += card.book.hasTafsir;
    score += card.book.score.round();
    return score;
  }

  String _formatTafsirTitle(TafsirBookModel book) {
    final language = _normalizeWhitespace(book.language);
    final displayLanguage = language.toLowerCase() == "arabic"
        ? "العربية"
        : language;
    return language.isEmpty ? book.name : "${book.name} ($displayLanguage)";
  }

  Future<List<_ResolvedTafsirCard>> _loadTafsirCards(String ayahKey) async {
    final loaded = await QuranTafsirFunction.getDownloadedTafsirs(ayahKey);
    final unique = <String, _ResolvedTafsirCard>{};

    for (final tafsir in loaded) {
      final resolved =
          await QuranTafsirFunction.getResolvedTafsirTextForBook(
            tafsir.bookInfo,
            ayahKey,
          ) ??
          _stripHtml(tafsir.tafsir["t"]?.toString());

      final text = _normalizeWhitespace(_stripHtml(resolved));
      if (text.isEmpty) continue;

      final card = _ResolvedTafsirCard(
        book: tafsir.bookInfo,
        title: _formatTafsirTitle(tafsir.bookInfo),
        text: text,
      );

      final key = _tafsirDedupKey(tafsir.bookInfo);
      final current = unique[key];
      if (current == null || _tafsirPriority(card) > _tafsirPriority(current)) {
        unique[key] = card;
      }
    }

    return unique.values.toList();
  }

  Future<List<_ResolvedTafsirCard>> _tafsirFuture(String ayahKey) {
    return _tafsirFutureCache.putIfAbsent(
      ayahKey,
      () => _loadTafsirCards(ayahKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final quranSettings = context.watch<QuranSettingsCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalVerses = quranAyahCount[widget.surahNumber - 1];

    final bg = isDark ? const Color(0xFF111111) : const Color(0xFFF9F4EA);
    final cardColor = isDark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFFFFCF6);
    final surfaceColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : const Color(0xFFF5EEDF);

    final ayahKey = "${widget.surahNumber}:$_currentVerse";
    final page = getPageNumber(ayahKey) ?? 1;
    final pageFont = "QCF_P${page.toString().padLeft(3, "0")}";
    final words = _getQcfWords(widget.surahNumber, _currentVerse);
    final plainWords = _getPlainWords(
      context,
      widget.surahNumber,
      _currentVerse,
    );

    return Container(
      height: 0.9.sh,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHeader(context, isDark, themeState),
          Divider(
            height: 1,
            thickness: 0.6,
            color: isDark
                ? Colors.white10
                : Colors.black.withValues(alpha: 0.06),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: 10.h),
                _buildAyahScroller(
                  words: words,
                  plainWords: plainWords,
                  selectedWordLabel: _selectedWordLabel(context),
                  pageFont: pageFont,
                  isDark: isDark,
                  themeState: themeState,
                  surfaceColor: surfaceColor,
                ),
                _buildMetaStrip(
                  isDark: isDark,
                  themeState: themeState,
                  page: page,
                  wordsCount: words.length,
                  totalVerses: totalVerses,
                ),
                SizedBox(height: 8.h),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final offset = Tween<Offset>(
                      begin: const Offset(0, -0.04),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: offset, child: child),
                    );
                  },
                  child: _selectedWordNumber == null
                      ? Container(
                          key: const ValueKey<String>("library-hint"),
                          child: _buildSelectionHint(
                            isDark,
                            page: page,
                            totalVerses: totalVerses,
                          ),
                        )
                      : Container(
                          key: ValueKey<String>(
                            "library-word-$_selectedWordNumber",
                          ),
                          child: Column(
                            children: [
                              _buildSelectionActions(
                                ayahKey: ayahKey,
                                isDark: isDark,
                                themeState: themeState,
                              ),
                              _buildMinimalTabs(
                                isDark: isDark,
                                themeState: themeState,
                                surfaceColor: surfaceColor,
                                quranSettings: quranSettings,
                              ),
                              _buildWordContent(
                                ayahKey: ayahKey,
                                surahNumber: widget.surahNumber,
                                verseNumber: _currentVerse,
                                selectedWord: _selectedWordNumber!,
                                isDark: isDark,
                                cardColor: cardColor,
                                themeState: themeState,
                                quranSettings: quranSettings,
                              ),
                            ],
                          ),
                        ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 8.h,
                  ),
                  child: Divider(
                    height: 1,
                    thickness: 0.6,
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                _buildTafsirSection(
                  ayahKey: ayahKey,
                  surahNumber: widget.surahNumber,
                  isDark: isDark,
                  cardColor: cardColor,
                  themeState: themeState,
                  quranSettings: quranSettings,
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
          _buildNavigation(totalVerses, isDark, themeState),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    theme.ThemeState themeState,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          Text(
            "المكتبة",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () async {
              await Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (_) => const QuranResourcesView(initTab: 0),
                ),
              );
              if (!mounted) return;
              setState(() {});
            },
            child: Text(
              "تحرير",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: themeState.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyahScroller({
    required List<String> words,
    required List<String> plainWords,
    required String selectedWordLabel,
    required String pageFont,
    required bool isDark,
    required theme.ThemeState themeState,
    required Color surfaceColor,
  }) {
    final ayahNumberWord = qcf.getVerseNumberQCF(
      widget.surahNumber,
      _currentVerse,
    );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  selectedWordLabel.isEmpty
                      ? "اسحب الآية أفقيًا ثم اضغط على الكلمة المطلوبة."
                      : "الكلمة المختارة: $selectedWordLabel",
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: selectedWordLabel.isEmpty
                        ? (isDark ? Colors.white54 : Colors.black54)
                        : themeState.primary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: themeState.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "اسحب",
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: themeState.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            physics: const BouncingScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < words.length; i++)
                  _buildWordItem(
                        wordNumber: i + 1,
                        word: words[i],
                        plainWord: i < plainWords.length ? plainWords[i] : null,
                        font: pageFont,
                        isDark: isDark,
                        themeState: themeState,
                      )
                      .animate(delay: Duration(milliseconds: 35 * i))
                      .fadeIn(duration: 220.ms)
                      .slideX(begin: 0.06, end: 0, duration: 220.ms),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    ayahNumberWord,
                    style: TextStyle(
                      fontFamily: pageFont,
                      fontSize: 22.sp,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordItem({
    required int wordNumber,
    required String word,
    String? plainWord,
    required String font,
    required bool isDark,
    required theme.ThemeState themeState,
  }) {
    final isSelected = _selectedWordNumber == wordNumber;

    return Tooltip(
      message: plainWord ?? "",
      waitDuration: const Duration(milliseconds: 250),
      child: GestureDetector(
        onTap: () => _toggleWordSelection(wordNumber),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? themeState.primary.withValues(alpha: 0.12)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.02)
                      : Colors.white.withValues(alpha: 0.55)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? themeState.primary.withValues(alpha: 0.35)
                  : Colors.transparent,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeState.primary.withValues(alpha: 0.12),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Text(
            word,
            style: TextStyle(
              fontFamily: font,
              fontSize: 25.5.sp,
              height: 1.1,
              color: isSelected
                  ? themeState.primary
                  : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionHint(
    bool isDark, {
    required int page,
    required int totalVerses,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 10.h),
      child: Text(
        "اضغط على أي كلمة من الآية لتظهر ترجمتها ومعلوماتها فقط، وستظهر التبويبات تلقائيًا.",
        textAlign: TextAlign.right,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white54 : Colors.black45,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildMetaStrip({
    required bool isDark,
    required theme.ThemeState themeState,
    required int page,
    required int wordsCount,
    required int totalVerses,
  }) {
    final meaning = getSurahMeaning(context, widget.surahNumber).trim();
    final items = <String>[
      "الصفحة: ${_toArabicDigits(page.toString())}",
      "الكلمات: ${_toArabicDigits(wordsCount.toString())}",
      _localizedRevelationPlace(widget.surahNumber),
      "آيات السورة: ${_toArabicDigits(totalVerses.toString())}",
      if (meaning.isNotEmpty) meaning,
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 2.h),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 8.w,
        runSpacing: 8.h,
        children: items
            .map(
              (item) => Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : themeState.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFeaturePrompt({
    required bool isDark,
    required theme.ThemeState themeState,
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: themeState.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: themeState.primary.withValues(alpha: 0.14)),
      ),
      child: Column(
        children: [
          Icon(icon, color: themeState.primary, size: 24.sp),
          SizedBox(height: 10.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.6,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          SizedBox(height: 12.h),
          FilledButton.tonal(
            onPressed: onAction,
            style: FilledButton.styleFrom(
              backgroundColor: themeState.primary.withValues(alpha: 0.12),
              foregroundColor: themeState.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            ),
            child: Text(
              actionLabel,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionActions({
    required String ayahKey,
    required bool isDark,
    required theme.ThemeState themeState,
  }) {
    final wordLabel = _selectedWordLabel(context);
    final ayahText = _getAyahText(context, widget.surahNumber, _currentVerse);

    Widget action({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.025),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: themeState.primary.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16.sp, color: themeState.primary),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          children: [
            action(
              icon: Icons.tune_rounded,
              label: "الإعدادات",
              onTap: () => QuranSettingsBottomSheet.show(context),
            ),
            SizedBox(width: 8.w),
            action(
              icon: Icons.copy_rounded,
              label: "نسخ الكلمة",
              onTap: () => _copyText(wordLabel, "تم نسخ الكلمة المختارة."),
            ),
            SizedBox(width: 8.w),
            action(
              icon: Icons.notes_rounded,
              label: "ملاحظة",
              onTap: () => showAddNotePopup(context, ayahKey),
            ),
            SizedBox(width: 8.w),
            action(
              icon: Icons.bookmark_add_rounded,
              label: "حفظ",
              onTap: () => addAyahToFavoritesPinned(context, ayahKey),
            ),
            SizedBox(width: 8.w),
            action(
              icon: Icons.share_rounded,
              label: "مشاركة",
              onTap: () {
                UnifiedShareBottomSheet.show(
                  context: context,
                  surahNumber: widget.surahNumber,
                  verseNumber: _currentVerse,
                  getAyahText: (surah, verse) =>
                      _getAyahText(context, surah, verse),
                );
              },
            ),
            SizedBox(width: 8.w),
            action(
              icon: Icons.short_text_rounded,
              label: "نسخ الآية",
              onTap: () => _copyText(ayahText, "تم نسخ نص الآية."),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinimalTabs({
    required bool isDark,
    required theme.ThemeState themeState,
    required Color surfaceColor,
    required QuranSettingsState quranSettings,
  }) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 6.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth =
              constraints.maxWidth / _LibraryWordTab.values.length;
          final activeIndex = _LibraryWordTab.values.indexOf(_activeTab);
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                right: segmentWidth * activeIndex,
                top: 0,
                bottom: 0,
                child: Container(
                  width: segmentWidth,
                  decoration: BoxDecoration(
                    color: themeState.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Row(
                children: _LibraryWordTab.values.map((tab) {
                  final isDisabled =
                      tab == _LibraryWordTab.eerab && !quranSettings.enableIrab;
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        if (isDisabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "فعّل الإعراب والتحليل أولًا من إعدادات المصحف.",
                              ),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _activeTab = tab;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 9.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isDisabled) ...[
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 13.sp,
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.45)
                                    : Colors.black38,
                              ),
                              SizedBox(width: 4.w),
                            ],
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: _activeTab == tab
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: isDisabled
                                    ? (isDark
                                          ? Colors.white.withValues(alpha: 0.45)
                                          : Colors.black38)
                                    : _activeTab == tab
                                    ? themeState.primary
                                    : (isDark
                                          ? Colors.white60
                                          : Colors.black54),
                              ),
                              child: Text(
                                tab.label,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWordContent({
    required String ayahKey,
    required int surahNumber,
    required int verseNumber,
    required int selectedWord,
    required bool isDark,
    required Color cardColor,
    required theme.ThemeState themeState,
    required QuranSettingsState quranSettings,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 4.h),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offset = Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offset, child: child),
          );
        },
        child: Container(
          key: ValueKey<String>(
            "${_activeTab.name}-$ayahKey-$selectedWord-${_downloadingKind?.name}",
          ),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.08)
                    : const Color(0xFFB8A88A).withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: _activeTab == _LibraryWordTab.translation
              ? _buildTranslationTab(
                  ayahKey: ayahKey,
                  selectedWord: selectedWord,
                  isDark: isDark,
                )
              : _activeTab == _LibraryWordTab.eerab && !quranSettings.enableIrab
              ? _buildFeaturePrompt(
                  isDark: isDark,
                  themeState: themeState,
                  icon: Icons.lock_outline_rounded,
                  title: "الإعراب غير مفعل",
                  message:
                      "فعّل تبويب الإعراب والتحليل من إعدادات المصحف ليظهر هذا المحتوى مباشرة داخل المكتبة.",
                  actionLabel: "تفعيل الآن",
                  onAction: () =>
                      context.read<QuranSettingsCubit>().toggleIrab(true),
                )
              : _buildWordInfoTab(
                  kind: _activeTab.infoKind!,
                  ref: WordRef(
                    surahNumber: surahNumber,
                    ayahNumber: verseNumber,
                    wordNumber: selectedWord,
                  ),
                  isDark: isDark,
                  themeState: themeState,
                ),
        ),
      ),
    );
  }

  Widget _buildTranslationTab({
    required String ayahKey,
    required int selectedWord,
    required bool isDark,
  }) {
    return FutureBuilder<TranslationWithWordByWord>(
      future: getTranslationWithWordByWord(ayahKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;
        final wordByWord = data?.wordByWord;
        final translations =
            data?.translationList ?? const <TranslationOfAyah>[];
        final selectedIndex = selectedWord - 1;
        final rawMeaning =
            wordByWord != null &&
                selectedIndex >= 0 &&
                selectedIndex < wordByWord.length
            ? wordByWord[selectedIndex]?.toString()
            : null;
        final meaning = _normalizeWhitespace(_stripHtml(rawMeaning));
        final selectedWordLabel = _selectedWordLabel(context);
        final translationCards = translations
            .map((translation) {
              final text = _normalizeWhitespace(
                _stripHtml(translation.translation?["t"]?.toString()),
              );
              if (text.isEmpty) return null;
              final title = translation.bookInfo == null
                  ? "ترجمة الآية"
                  : "${translation.bookInfo!.name} (${translation.bookInfo!.language})";
              return _TranslationCardData(title: title, text: text);
            })
            .whereType<_TranslationCardData>()
            .toList();

        if (meaning.isEmpty && translationCards.isEmpty) {
          return _buildInlineMessage(
            isDark: isDark,
            icon: Icons.translate_rounded,
            message:
                "لا توجد ترجمة كلمة بكلمة أو ترجمات آيات مفعلة للعنصر المختار حاليًا.",
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (meaning.isNotEmpty)
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.black.withValues(alpha: 0.025),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      selectedWordLabel.isEmpty
                          ? "ترجمة الكلمة المختارة"
                          : "ترجمة: $selectedWordLabel",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      meaning,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 17.sp,
                        height: 1.7,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            if (meaning.isNotEmpty && translationCards.isNotEmpty)
              SizedBox(height: 12.h),
            if (translationCards.isNotEmpty) ...[
              Text(
                "الترجمات المختارة للآية",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              SizedBox(height: 10.h),
              ...translationCards.map(
                (card) => Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.03)
                        : Colors.black.withValues(alpha: 0.025),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        card.title,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        card.text,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.8,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildWordInfoTab({
    required WordInfoKind kind,
    required WordRef ref,
    required bool isDark,
    required theme.ThemeState themeState,
  }) {
    if (!_wordInfoRepo.isKindDownloaded(kind)) {
      return _buildDownloadPrompt(
        kind: kind,
        isDark: isDark,
        themeState: themeState,
      );
    }

    return FutureBuilder<QiraatWordInfo?>(
      future: _wordInfoRepo.getWordInfo(kind: kind, ref: ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final info = snapshot.data;
        final content = _normalizeWhitespace(_stripHtml(info?.content));
        if (content.isEmpty) {
          return _buildInlineMessage(
            isDark: isDark,
            icon: Icons.info_outline_rounded,
            message: "لا توجد بيانات متاحة لهذه الكلمة في هذا التبويب.",
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if ((info?.word ?? "").trim().isNotEmpty) ...[
              Text(
                "الكلمة: ${info!.word}",
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              SizedBox(height: 10.h),
            ],
            Text(
              content,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 15.sp,
                height: 1.8,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDownloadPrompt({
    required WordInfoKind kind,
    required bool isDark,
    required theme.ThemeState themeState,
  }) {
    final isDownloading = _downloadingKind == kind;
    final progress = _downloadProgressByKind[kind] ?? 0;
    final totalBytes = _resolvedWordInfoSizes[kind];
    final transferredBytes = totalBytes == null
        ? null
        : (totalBytes * progress).round();
    final remainingBytes = totalBytes == null || transferredBytes == null
        ? null
        : (totalBytes - transferredBytes).clamp(0, totalBytes);

    if (isDownloading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "جاري تجهيز ${_wordInfoLabel(kind)}",
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 6.h,
              value: progress.clamp(0.0, 1.0),
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(themeState.primary),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "جاري التحميل... ${(progress * 100).toInt()}%",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (totalBytes != null && transferredBytes != null) ...[
            SizedBox(height: 8.h),
            Text(
              "تم تحميل ${_formatFileSize(transferredBytes, fallback: "0 MB")} من ${_formatFileSize(totalBytes, fallback: _fallbackSizeLabel(kind))}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            if (remainingBytes != null)
              Text(
                "المتبقي ${_formatFileSize(remainingBytes, fallback: _fallbackSizeLabel(kind))}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: themeState.primary,
                ),
              ),
          ],
        ],
      );
    }

    return FutureBuilder<int?>(
      future: _getWordInfoSize(kind),
      builder: (context, snapshot) {
        final size = _formatFileSize(
          snapshot.data,
          fallback: _fallbackSizeLabel(kind),
        );

        return GestureDetector(
          onTap: () => _downloadWordInfo(kind),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: themeState.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: themeState.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.download_rounded,
                  color: themeState.primary,
                  size: 28.sp,
                ),
                SizedBox(height: 10.h),
                Text(
                  "تحميل بيانات ${_wordInfoLabel(kind)}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  "حجم الملف: $size",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInlineMessage({
    required bool isDark,
    required IconData icon,
    required String message,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        children: [
          Icon(
            icon,
            color: isDark ? Colors.white38 : Colors.black38,
            size: 22.sp,
          ),
          SizedBox(height: 10.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTafsirSection({
    required String ayahKey,
    required int surahNumber,
    required bool isDark,
    required Color cardColor,
    required theme.ThemeState themeState,
    required QuranSettingsState quranSettings,
  }) {
    if (!quranSettings.enableTafsir) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: _buildFeaturePrompt(
          isDark: isDark,
          themeState: themeState,
          icon: Icons.menu_book_outlined,
          title: "التفسير متوقف",
          message:
              "فعّل عرض التفاسير من إعدادات المصحف ليظهر هذا القسم تلقائيًا في المكتبة.",
          actionLabel: "تفعيل التفسير",
          onAction: () => context.read<QuranSettingsCubit>().toggleTafsir(true),
        ),
      );
    }

    return FutureBuilder<List<_ResolvedTafsirCard>>(
      future: _tafsirFuture(ayahKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final list = snapshot.data ?? const <_ResolvedTafsirCard>[];
        if (list.isEmpty) {
          return _buildInlineMessage(
            isDark: isDark,
            icon: Icons.menu_book_outlined,
            message: "لا توجد تفاسير مفعلة أو محملة لهذه الآية حاليًا.",
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
              child: Row(
                children: [
                  Text(
                    "التفسير",
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      UnifiedShareBottomSheet.show(
                        context: context,
                        surahNumber: surahNumber,
                        verseNumber: _currentVerse,
                        getAyahText: (surah, verse) =>
                            _getAyahText(context, surah, verse),
                      );
                    },
                    icon: Icon(Icons.share_rounded, size: 20.sp),
                    color: themeState.primary,
                  ),
                ],
              ),
            ),
            ...list.map(
              (tafsir) => Container(
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.06)
                          : const Color(0xFFB8A88A).withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      tafsir.title,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      tafsir.text,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.9,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavigation(
    int totalVerses,
    bool isDark,
    theme.ThemeState themeState,
  ) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _currentVerse < totalVerses
                  ? () => _changeVerse(_currentVerse + 1)
                  : null,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: themeState.primary,
            ),
            Text(
              "${getSurahNameArabic(widget.surahNumber)}: ${_toArabicDigits(_currentVerse.toString())}",
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            IconButton(
              onPressed: _currentVerse > 1
                  ? () => _changeVerse(_currentVerse - 1)
                  : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              color: themeState.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolvedTafsirCard {
  final TafsirBookModel book;
  final String title;
  final String text;

  const _ResolvedTafsirCard({
    required this.book,
    required this.title,
    required this.text,
  });
}

class _TranslationCardData {
  final String title;
  final String text;

  const _TranslationCardData({required this.title, required this.text});
}
