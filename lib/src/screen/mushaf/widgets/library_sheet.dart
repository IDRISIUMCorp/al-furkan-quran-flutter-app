import 'package:al_quran_v3/src/resources/quran_resources/quran_ayah_count.dart';
import 'package:al_quran_v3/src/resources/quran_resources/meaning_of_surah.dart';
import 'package:al_quran_v3/src/screen/quran_resources/quran_resources_view.dart';
import 'package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_cubit.dart';
import 'package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_state.dart';
import 'package:al_quran_v3/src/theme/controller/theme_cubit.dart';
import 'package:al_quran_v3/src/theme/controller/theme_state.dart' as theme;
import 'package:al_quran_v3/src/utils/quran_ayahs_function/get_page_number.dart';
import 'package:al_quran_v3/src/utils/quran_resources/quran_script_function.dart';
import 'package:al_quran_v3/src/utils/quran_resources/quran_tafsir_function.dart';
import 'package:al_quran_v3/src/utils/quran_resources/quran_translation_function.dart';
import 'package:al_quran_v3/src/utils/quran_resources/get_translation_with_word_by_word.dart';
import 'package:al_quran_v3/src/utils/quran_resources/word_info_models.dart';
import 'package:al_quran_v3/src/utils/quran_resources/word_info_repository.dart';
import 'package:al_quran_v3/src/screen/settings/cubit/quran_script_view_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:qcf_quran/qcf_quran.dart' as qcf hide getPageNumber;

class WahyLibrarySheet extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;

  const WahyLibrarySheet({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
  });

  static Future<void> show({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
  }) async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => WahyLibrarySheet(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
      ),
    );
  }

  @override
  State<WahyLibrarySheet> createState() => _WahyLibrarySheetState();
}

class _WahyLibrarySheetState extends State<WahyLibrarySheet>
    with SingleTickerProviderStateMixin {
  late int _currentVerse;
  int? _selectedWordNumber;
  late TabController _tabController;
  final WordInfoRepository _wordInfoRepo = WordInfoRepository();

  @override
  void initState() {
    super.initState();
    _currentVerse = widget.verseNumber;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _toArabicDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  List<String> _splitAyahWordsForChips(String qcfAyah) {
    return qcfAyah
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  String _stripHtml(String? htmlText) {
    if (htmlText == null) return "";
    final RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(exp, '').trim();
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

  String _getApproxSize(WordInfoKind kind) {
    switch (kind) {
      case WordInfoKind.eerab:
        return "1.2 MB";
      case WordInfoKind.tasreef:
        return "0.8 MB";
      case WordInfoKind.recitations:
        return "1.5 MB";
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalVerses = quranAyahCount[widget.surahNumber - 1];

    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFFDF8F0);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    final String ayahKey = "${widget.surahNumber}:$_currentVerse";
    final int page = getPageNumber(ayahKey) ?? 1;
    final String pageFont = "QCF_P${page.toString().padLeft(3, '0')}";
    final String qcfAyah = qcf.getVerseQCF(
      widget.surahNumber,
      _currentVerse,
      verseEndSymbol: false,
    );
    final words = _splitAyahWordsForChips(qcfAyah);

    return Container(
      height: 0.9.sh,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          _buildHeader(context, isDark, themeState),
          const Divider(height: 1, thickness: 0.5),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                SizedBox(height: 4.h),
                _buildHorizontalAyahSlider(words, pageFont, isDark, themeState),
                if (_selectedWordNumber != null) ...[
                  _buildMinimalistTabBar(isDark, themeState),
                  _buildTabContent(
                    ayahKey: ayahKey,
                    surahNumber: widget.surahNumber,
                    verseNumber: _currentVerse,
                    selectedWord: _selectedWordNumber!,
                    isDark: isDark,
                    cardColor: cardColor,
                    themeState: themeState,
                  ),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
                    child: Text(
                      "اختار كلمة تظهرلك المكتبة",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ),
                ],
                const Divider(indent: 30, endIndent: 30, thickness: 0.3, height: 1),
                _buildTafsirSection(
                  ayahKey: ayahKey,
                  surahNumber: widget.surahNumber,
                  isDark: isDark,
                  cardColor: cardColor,
                  themeState: themeState,
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
          _buildNavigation(totalVerses, isDark, themeState),
        ],
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDark, theme.ThemeState themeState) {
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
                  builder: (_) => const QuranResourcesView(initTab: 1),
                ),
              );
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

  Widget _buildHorizontalAyahSlider(
      List<String> words, String pageFont, bool isDark, theme.ThemeState themeState) {
    // Standard RTL ordering: [W1, W2, ..., WN]
    // Ayah Number should be at the end (left side in RTL view)
    final ayahNumberWord = qcf.getVerseNumberQCF(widget.surahNumber, _currentVerse);

    return Container(
      height: 72.h,
      margin: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // Start from the right (item 0 is right)
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Words from 1 to N
            for (int i = 0; i < words.length; i++)
              _buildWordItem(i + 1, words[i], pageFont, isDark, themeState),
            
            SizedBox(width: 8.w),
            // Ayah Number (End of Ayah)
            Text(
              ayahNumberWord,
              style: TextStyle(
                fontFamily: pageFont,
                package: 'qcf_quran',
                fontSize: 22.sp,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordItem(int wordNumber, String word, String font, bool isDark, theme.ThemeState themeState) {
    final isSelected = _selectedWordNumber == wordNumber;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedWordNumber = isSelected ? null : wordNumber;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(horizontal: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? themeState.primary.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? themeState.primary.withValues(alpha: 0.4) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          word,
          style: TextStyle(
            fontFamily: font,
            package: 'qcf_quran',
            fontSize: 24.sp,
            height: 1.1,
            color: isSelected 
                ? themeState.primary 
                : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalistTabBar(bool isDark, theme.ThemeState themeState) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 6.h),
      height: 38.h,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: themeState.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeState.primary.withValues(alpha: 0.2), width: 1),
        ),
        labelColor: themeState.primary,
        unselectedLabelColor: isDark ? Colors.white54 : Colors.black54,
        labelStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
        tabs: const [
          Tab(text: "ترجمة"),
          Tab(text: "إعراب"),
          Tab(text: "صرف"),
          Tab(text: "قراءات"),
        ],
      ),
    );
  }

  Widget _buildTabContent({
    required String ayahKey,
    required int surahNumber,
    required int verseNumber,
    required int selectedWord,
    required bool isDark,
    required Color cardColor,
    required theme.ThemeState themeState,
  }) {
    final ref = WordRef(
      surahNumber: surahNumber,
      ayahNumber: verseNumber,
      wordNumber: selectedWord,
    );

    return SizedBox(
      height: 200.h, // Reduced height as requested
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildTranslationTab(ayahKey, isDark, cardColor, themeState),
          _buildInfoTab(WordInfoKind.eerab, ref, isDark, cardColor, themeState),
          _buildInfoTab(WordInfoKind.tasreef, ref, isDark, cardColor, themeState),
          _buildInfoTab(WordInfoKind.recitations, ref, isDark, cardColor, themeState),
        ],
      ),
    );
  }

  Widget _buildTranslationTab(
      String ayahKey, bool isDark, Color cardColor, theme.ThemeState themeState) {
    return FutureBuilder<List<TranslationOfAyah>>(
      future: QuranTranslationFunction.getDownloadedTranslations(ayahKey),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final list = snap.data ?? [];
        if (list.isEmpty) return _buildEmptyState(isDark, "لم يتم تحميل أي تراجم بعد");

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final text = list[i].translation?['t']?.toString() ?? "";
            final bookName = list[i].bookInfo?.name ?? "ترجمة";

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: themeState.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          bookName,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: themeState.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    text,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInfoTab(WordInfoKind kind, WordRef ref, bool isDark,
      Color cardColor, theme.ThemeState themeState) {
    return FutureBuilder<bool>(
      future: Future.value(_wordInfoRepo.isKindDownloaded(kind)),
      builder: (context, downSnap) {
        final isDownloaded = downSnap.data ?? false;

        if (!isDownloaded) {
          return _buildDownloadPrompt(kind, themeState, isDark);
        }

        return FutureBuilder<QiraatWordInfo?>(
          future: _wordInfoRepo.getWordInfo(kind: kind, ref: ref),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final info = snap.data?.content ?? "";
            if (info.isEmpty) return _buildEmptyState(isDark, "لا توجد بيانات متاحة");

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                ),
                child: Text(
                  _stripHtml(info),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.6,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.1),
            );
          },
        );
      },
    );
  }

  Widget _buildDownloadPrompt(
      WordInfoKind kind, theme.ThemeState themeState, bool isDark) {
    final name = kind == WordInfoKind.eerab
        ? "الإعراب"
        : kind == WordInfoKind.tasreef
            ? "التصريف (الصرف)"
            : "القراءات";
    final size = _getApproxSize(kind);

    return BlocBuilder<ResourcesProgressCubit, ResourcesProgressCubitState>(
      builder: (context, state) {
        final bool onProcess = (state.onProcess ?? false) &&
            ((state.processName?.contains(name) ?? false) ||
                (state.processName?.contains("Word Info") ?? false));

        if (onProcess) {
          return _buildDownloadProgress(state.percentage ?? 0.0, isDark, themeState);
        }

        return Center(
          child: GestureDetector(
            onTap: () async {
              context.read<ResourcesProgressCubit>().onProcess();
              await _wordInfoRepo.downloadKind(
                kind: kind,
                onProgress: (p) {
                  context.read<ResourcesProgressCubit>().updateProgress(
                        p / 100,
                        "تحميل بيانات $name",
                      );
                },
              );
              setState(() {});
            },
            child: Container(
              margin: EdgeInsets.all(20.w),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
              decoration: BoxDecoration(
                color: themeState.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: themeState.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.download_rounded,
                      color: themeState.primary, size: 32.sp),
                  SizedBox(height: 12.h),
                  Text(
                    "تحميل بيانات $name (~$size)",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: themeState.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDownloadProgress(double progress, bool isDark, theme.ThemeState themeState) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearPercentIndicator(
              lineHeight: 8.h,
              percent: progress.clamp(0.0, 1.0),
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              progressColor: themeState.primary,
              barRadius: const Radius.circular(10),
              isRTL: true,
            ),
            SizedBox(height: 12.h),
            Text(
              "جاري التحميل... ${(progress * 100).toInt()}%",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
            color: isDark ? Colors.white38 : Colors.black38,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTafsirSection({
    required String ayahKey,
    required int surahNumber,
    required bool isDark,
    required Color cardColor,
    required theme.ThemeState themeState,
  }) {
    return FutureBuilder<List<TafsirOfAyah>>(
      future: QuranTafsirFunction.getDownloadedTafsirs(ayahKey),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        final list = snap.data ?? [];
        if (list.isEmpty) return _buildEmptyState(isDark, "لم يتم تحميل أي تفاسير بعد");

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
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
                      final text = _getAyahText(context, surahNumber, _currentVerse);
                      Share.share(_formatAyahTextForSharing(ayahKey: ayahKey, ayahText: text));
                    },
                    icon: Icon(Icons.share_rounded, size: 20.sp),
                    color: themeState.primary,
                  ),
                ],
              ),
            ),
            ...list.map((tafsir) => _buildTafsirCard(tafsir, isDark, cardColor, themeState)),
          ],
        );
      },
    );
  }

  Widget _buildTafsirCard(TafsirOfAyah tafsir, bool isDark, Color cardColor, theme.ThemeState themeState) {
    final bookName = tafsir.bookInfo.name;
    final text = _stripHtml(tafsir.tafsir['t']?.toString() ?? "لا يوجد تفسير متاح.");

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: themeState.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  bookName,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: themeState.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.7,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(int total, bool isDark, theme.ThemeState themeState) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _currentVerse < total
                  ? () => setState(() {
                        _currentVerse++;
                        _selectedWordNumber = null;
                      })
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
                  ? () => setState(() {
                        _currentVerse--;
                        _selectedWordNumber = null;
                      })
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
