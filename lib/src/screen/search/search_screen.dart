import "dart:async";
import "dart:ui";

import "package:al_quran_v3/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_quran_v3/src/screen/quran_script_view/cubit/ayah_to_highlight.dart";
import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:al_quran_v3/src/theme/controller/theme_state.dart";
import "package:al_quran_v3/src/utils/number_localization.dart";
import "package:al_quran_v3/src/utils/quran_search_engine.dart";
import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:qcf_quran/qcf_quran.dart" as qcf;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final ValueNotifier<List<Map<String, dynamic>>> _resultsVN =
      ValueNotifier<List<Map<String, dynamic>>>(const []);
  final ValueNotifier<bool> _hasSearchedVN = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isSearchingVN = ValueNotifier<bool>(false);

  Timer? _debounce;
  List<String> _searchHistory = <String>[];

  static const String _kHistoryKey = "search_history";
  static const int _maxHistory = 8;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _pageBg =>
      _isDark ? const Color(0xFF121212) : const Color(0xFFF7F1E6);
  Color get _cardBg =>
      _isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFFFBF5);
  Color get _cardBorder => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.06);
  Color get _textPrimary => _isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get _textMuted =>
      _isDark ? Colors.white.withValues(alpha: 0.58) : const Color(0xFF7E7B74);

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _resultsVN.dispose();
    _hasSearchedVN.dispose();
    _isSearchingVN.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final rawQuery = query.trim();
    final normalizedQuery = normalizeQuranSearchQuery(rawQuery);

    if (rawQuery.isEmpty || normalizedQuery.length < 2) {
      if (!mounted) return;
      _resultsVN.value = const <Map<String, dynamic>>[];
      _hasSearchedVN.value = false;
      _isSearchingVN.value = false;
      return;
    }

    _isSearchingVN.value = true;
    final results = await searchQuranAyahs(rawQuery, limit: 150);
    if (!mounted) return;

    _resultsVN.value = results;
    _hasSearchedVN.value = true;
    _isSearchingVN.value = false;

    if (results.isNotEmpty) {
      _saveToHistory(rawQuery);
    }
  }

  void _queueSearch(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 180),
      () => _performSearch(value),
    );
  }

  void _loadHistory() {
    final box = Hive.box("user");
    final raw = box.get(_kHistoryKey);
    if (raw is List) {
      _searchHistory = raw.cast<String>().toList();
    }
  }

  void _saveToHistory(String query) {
    _searchHistory.remove(query);
    _searchHistory.insert(0, query);
    if (_searchHistory.length > _maxHistory) {
      _searchHistory = _searchHistory.sublist(0, _maxHistory);
    }
    Hive.box("user").put(_kHistoryKey, _searchHistory);
    if (mounted) {
      setState(() {});
    }
  }

  void _clearHistory() {
    _searchHistory.clear();
    Hive.box("user").delete(_kHistoryKey);
    if (mounted) {
      setState(() {});
    }
  }

  void _applySuggestion(String value) {
    _searchController.text = value;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
    _performSearch(value);
  }

  void _navigateToAyah(BuildContext context, int surah, int ayah) {
    HapticFeedback.lightImpact();
    final key = "$surah:$ayah";
    final page = qcf.getPageNumber(surah, ayah);

    context.read<AyahKeyCubit>().changeLastScrolledPage(page);
    context.read<AyahKeyCubit>().changeCurrentAyahKey(key);
    context.read<AyahToHighlight>().changeAyah(key);

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      if (context.read<AyahToHighlight>().state == key) {
        context.read<AyahToHighlight>().changeAyah(null);
      }
    });

    Navigator.of(context).pop(<String, dynamic>{"page": page, "key": key});
  }

  @override
  Widget build(BuildContext context) {
    final ThemeState themeState = context.watch<ThemeCubit>().state;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _pageBg,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      themeState.primary.withValues(
                        alpha: _isDark ? 0.06 : 0.08,
                      ),
                      _pageBg,
                      _pageBg,
                    ],
                  ),
                ),
              ),
            ),
            _buildBody(themeState),
            _buildTopBar(themeState),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ThemeState themeState) {
    return ValueListenableBuilder<bool>(
      valueListenable: _hasSearchedVN,
      builder: (context, hasSearched, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isSearchingVN,
          builder: (context, isSearching, __) {
            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _resultsVN,
              builder: (context, results, ___) {
                final topPadding = MediaQuery.of(context).padding.top + 112;
                final bottomPadding =
                    MediaQuery.of(context).padding.bottom + 24;
                final query = _searchController.text.trim();

                late final Widget child;

                if (query.isNotEmpty &&
                    normalizeQuranSearchQuery(query).length < 2) {
                  child = _buildShortQueryState();
                } else if (!hasSearched) {
                  child = _buildIdleState(themeState);
                } else if (isSearching) {
                  child = _buildLoadingState(themeState);
                } else if (results.isEmpty) {
                  child = _buildEmptyState();
                } else {
                  child = _buildResultsState(themeState, results);
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: Padding(
                    key: ValueKey<String>(
                      "${query}_${hasSearched}_${isSearching}_${results.length}",
                    ),
                    padding: EdgeInsets.only(
                      top: topPadding,
                      bottom: bottomPadding,
                    ),
                    child: child,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTopBar(ThemeState themeState) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 14,
            ),
            color: _pageBg.withValues(alpha: 0.88),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: themeState.primary,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        "البحث في الآيات",
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                Container(
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: _isDark ? 0.16 : 0.05,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    textDirection: TextDirection.rtl,
                    textInputAction: TextInputAction.search,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: TextStyle(
                      color: _textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: "ابحث بكلمة أو مقطع من الآية",
                      hintStyle: TextStyle(color: _textMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      prefixIcon: Icon(
                        FluentIcons.search_24_regular,
                        color: themeState.primary,
                        size: 22,
                      ),
                      suffixIcon: ValueListenableBuilder<bool>(
                        valueListenable: _isSearchingVN,
                        builder: (context, isSearching, _) {
                          if (isSearching) {
                            return Padding(
                              padding: const EdgeInsets.all(14),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: themeState.primary,
                                ),
                              ),
                            );
                          }

                          return ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchController,
                            builder: (context, value, __) {
                              final hasText = value.text.trim().isNotEmpty;
                              return IconButton(
                                onPressed: () {
                                  if (hasText) {
                                    _searchController.clear();
                                    _performSearch("");
                                  } else {
                                    _performSearch(_searchController.text);
                                  }
                                },
                                icon: Icon(
                                  hasText
                                      ? FluentIcons.dismiss_24_filled
                                      : FluentIcons.search_24_filled,
                                  color: themeState.primary,
                                  size: 20,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    onChanged: _queueSearch,
                    onSubmitted: _performSearch,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdleState(ThemeState themeState) {
    final suggestions = _searchHistory.isNotEmpty
        ? _searchHistory
        : const <String>["الرحمن", "الصبر", "الجنة", "المغفرة", "النور"];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: _cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: themeState.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  FluentIcons.search_24_regular,
                  color: themeState.primary,
                ),
              ),
              const Gap(16),
              Text(
                "ابحث بسرعة داخل القرآن الكريم",
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Gap(8),
              Text(
                "اكتب كلمتين أو أكثر، وسنعرض لك أفضل النتائج مباشرة مع السورة والآية.",
                style: TextStyle(color: _textMuted, fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.05, end: 0),
        const Gap(18),
        Row(
          children: [
            Text(
              _searchHistory.isNotEmpty ? "آخر عمليات البحث" : "اقتراحات سريعة",
              style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            if (_searchHistory.isNotEmpty)
              TextButton(
                onPressed: _clearHistory,
                child: Text(
                  "مسح",
                  style: TextStyle(
                    color: themeState.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
        const Gap(10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: suggestions
              .map(
                (value) => _SuggestionChip(
                  text: value,
                  primary: themeState.primary,
                  onTap: () => _applySuggestion(value),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildShortQueryState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.short_text_rounded, color: _textMuted, size: 34),
            const Gap(12),
            Text(
              "اكتب حرفين أو أكثر لبدء البحث",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(ThemeState themeState) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: themeState.primary,
              ),
            ),
            const Gap(12),
            Text(
              "جارٍ البحث في الآيات...",
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cardBg,
                border: Border.all(color: _cardBorder),
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 34,
                color: _textMuted,
              ),
            ),
            const Gap(18),
            Text(
              "لا توجد نتائج مطابقة",
              style: TextStyle(
                color: _textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Gap(8),
            Text(
              "جرّب صياغة أقصر، أو اكتب الكلمات من غير تشكيل للوصول لنتائج أدق.",
              textAlign: TextAlign.center,
              style: TextStyle(color: _textMuted, fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 260.ms);
  }

  Widget _buildResultsState(
    ThemeState themeState,
    List<Map<String, dynamic>> results,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: themeState.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: themeState.primary.withValues(alpha: 0.14),
              ),
            ),
            child: Text(
              "تم العثور على ${localizedNumber(context, results.length)} نتيجة مرتبة حسب الأقرب",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeState.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            itemCount: results.length,
            separatorBuilder: (_, __) => const Gap(10),
            itemBuilder: (context, index) {
              final result = results[index];
              final surahNumber = (result["surah_number"] as num?)?.toInt();
              final ayahNumber = (result["verse_number"] as num?)?.toInt();
              if (surahNumber == null || ayahNumber == null) {
                return const SizedBox.shrink();
              }

              final surahName =
                  (result["surah_name"] as String?) ??
                  qcf.getSurahNameArabic(surahNumber);
              final content =
                  (result["snippet"] as String?) ??
                  (result["content"] as String?) ??
                  "";
              final pageNumber = qcf.getPageNumber(surahNumber, ayahNumber);

              return _SearchResultCard(
                    surahName: surahName,
                    ayahNumber: ayahNumber,
                    pageNumber: pageNumber,
                    content: content,
                    primary: themeState.primary,
                    surface: _cardBg,
                    border: _cardBorder,
                    textColor: _textPrimary,
                    mutedColor: _textMuted,
                    onTap: () =>
                        _navigateToAyah(context, surahNumber, ayahNumber),
                  )
                  .animate()
                  .fadeIn(duration: 260.ms, delay: (index.clamp(0, 6) * 40).ms)
                  .slideY(begin: 0.05, end: 0);
            },
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final Color primary;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.text,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: primary.withValues(alpha: 0.12)),
          ),
          child: Text(
            text,
            style: TextStyle(color: primary, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final String surahName;
  final int ayahNumber;
  final int pageNumber;
  final String content;
  final Color primary;
  final Color surface;
  final Color border;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.surahName,
    required this.ayahNumber,
    required this.pageNumber,
    required this.content,
    required this.primary,
    required this.surface,
    required this.border,
    required this.textColor,
    required this.mutedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      surahName,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaChip(
                        label: "الآية ${localizedNumber(context, ayahNumber)}",
                        color: mutedColor,
                      ),
                      _MetaChip(
                        label: "الصفحة ${localizedNumber(context, pageNumber)}",
                        color: mutedColor,
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(14),
              Text(
                content,
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "QPC_Hafs",
                  fontSize: 23,
                  height: 1.65,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MetaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
