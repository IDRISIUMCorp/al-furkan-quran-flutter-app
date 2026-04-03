import "dart:async";

import "package:al_quran_v3/src/utils/number_localization.dart";
import "package:al_quran_v3/src/utils/quran_search_engine.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:qcf_quran/qcf_quran.dart";

class SearchSheet extends StatefulWidget {
  final TextEditingController controller;
  final Color primary;
  final Future<List<AyahSearchResult>> Function(String query) search;
  final void Function(String ayahKey) onResultTap;

  const SearchSheet({
    super.key,
    required this.controller,
    required this.primary,
    required this.search,
    required this.onResultTap,
  });

  @override
  State<SearchSheet> createState() => SearchSheetState();
}

class SearchSheetState extends State<SearchSheet> {
  String _lastQuery = "";
  Future<List<AyahSearchResult>>? _future;
  Timer? _debounce;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _surfaceColor =>
      _isDark ? const Color(0xFF141414) : const Color(0xFFF7F1E6);
  Color get _cardColor =>
      _isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFFFFBF5);
  Color get _borderColor => _isDark
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.black.withValues(alpha: 0.06);
  Color get _textColor => _isDark ? Colors.white : const Color(0xFF1B1B1B);
  Color get _mutedColor => _isDark ? Colors.white54 : const Color(0xFF8F8F8F);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateSearch);
    _future = widget.search(widget.controller.text);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_updateSearch);
    super.dispose();
  }

  void _updateSearch() {
    final query = widget.controller.text;
    if (query == _lastQuery) return;
    _lastQuery = query;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 160), () {
      if (!mounted) return;
      setState(() {
        _future = widget.search(query);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.controller.text.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        color: _isDark ? Colors.white70 : Colors.black87,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "بحث داخل المصحف",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: _textColor,
                              ),
                            ),
                            Text(
                              "ابحث عن أي مقطع ثم انتقل مباشرة إلى الآية",
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
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _cardColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: widget.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: widget.controller,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: _textColor,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: "اكتب كلمة أو جزءًا من الآية...",
                              hintStyle: TextStyle(color: _mutedColor),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (query.isNotEmpty)
                          IconButton(
                            onPressed: widget.controller.clear,
                            icon: const Icon(Icons.close_rounded),
                            color: _mutedColor,
                            splashRadius: 18,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (query.isNotEmpty && query.length < 2)
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 16),
                      child: Text(
                        "اكتب حرفين أو أكثر لعرض النتائج",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _mutedColor,
                        ),
                      ),
                    )
                  else if (query.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: widget.primary,
                              size: 28,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "اكتب جزءًا من الآية، وستظهر لك النتائج مع تظليل المطابقة داخل النص.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _textColor,
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: FutureBuilder<List<AyahSearchResult>>(
                        future: _future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          }

                          final results =
                              snapshot.data ?? const <AyahSearchResult>[];
                          if (results.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 26),
                              child: Center(
                                child: Text(
                                  "لا توجد نتائج مطابقة الآن",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: _mutedColor,
                                  ),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: widget.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: widget.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  "تم العثور على ${localizedNumber(context, results.length)} نتيجة",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: widget.primary,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView.separated(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  itemCount: results.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final result = results[index];
                                    return _SearchSheetResultTile(
                                          result: result,
                                          primary: widget.primary,
                                          cardColor: _cardColor,
                                          borderColor: _borderColor,
                                          textColor: _textColor,
                                          mutedColor: _mutedColor,
                                          onTap: () => widget.onResultTap(
                                            result.ayahKey,
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(
                                          duration: 220.ms,
                                          delay: (index.clamp(0, 6) * 30).ms,
                                        )
                                        .slideY(begin: 0.05, end: 0);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchSheetResultTile extends StatelessWidget {
  final AyahSearchResult result;
  final Color primary;
  final Color cardColor;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;
  final VoidCallback onTap;

  const _SearchSheetResultTile({
    required this.result,
    required this.primary,
    required this.cardColor,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reasonColor = switch (result.matchType) {
      SearchMatchType.exact => primary,
      SearchMatchType.normalized => const Color(0xFF1D7AFC),
      SearchMatchType.prefix => const Color(0xFF0F9D58),
      SearchMatchType.fuzzy => const Color(0xFFD97706),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu_book_rounded, color: primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        getSurahNameArabic(result.surahNumber),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      _MiniChip(label: result.reasonLabel, color: reasonColor),
                      _MiniChip(
                        label:
                            "الآية ${localizedNumber(context, result.verseNumber)}",
                        color: mutedColor,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SheetHighlightedSnippet(
                text: result.snippet,
                highlightSpans: result.highlightSpans,
                textColor: textColor,
                primary: primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SheetHighlightedSnippet extends StatelessWidget {
  final String text;
  final List<SearchMatchSpan> highlightSpans;
  final Color textColor;
  final Color primary;

  const _SheetHighlightedSnippet({
    required this.text,
    required this.highlightSpans,
    required this.textColor,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      color: textColor,
      fontSize: 18,
      height: 1.65,
      fontFamily: "QPC_Hafs",
    );

    if (highlightSpans.isEmpty) {
      return Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final spans = <TextSpan>[];
    var cursor = 0;
    final sorted = highlightSpans.toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    for (final range in sorted) {
      final safeStart = range.start.clamp(0, text.length);
      final safeEnd = range.end.clamp(safeStart, text.length);
      if (safeStart > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, safeStart)));
      }
      if (safeEnd > safeStart) {
        spans.add(
          TextSpan(
            text: text.substring(safeStart, safeEnd),
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w800,
              backgroundColor: primary.withValues(alpha: 0.14),
            ),
          ),
        );
      }
      cursor = safeEnd;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    return RichText(
      textAlign: TextAlign.center,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(style: baseStyle, children: spans),
    );
  }
}
