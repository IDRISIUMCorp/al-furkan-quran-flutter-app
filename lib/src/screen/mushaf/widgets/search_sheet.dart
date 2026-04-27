import "dart:async";
import "dart:math" as math;

import "package:al_furkan/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_furkan/src/utils/number_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:qcf_quran/qcf_quran.dart";

class AyahSearchResult {
  final int surah;
  final int verse;
  final String ayahKey;
  final String snippet;

  const AyahSearchResult({
    required this.surah,
    required this.verse,
    required this.ayahKey,
    required this.snippet,
  });
}

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
      _isDark ? Theme.of(context).colorScheme.surface : const Color(0xFFEDE4D4);
  Color get _cardColor =>
      _isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5EBE0);
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: _isDark ? 0.16 : 0.05,
                          ),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
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
                              "ابحث باسم كلمة أو بجزء من النص، وستظهر لك أقرب النتائج فورًا.",
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
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final result = results[index];
                                    return Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () => widget.onResultTap(
                                              result.ayahKey,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              22,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(14),
                                              decoration: BoxDecoration(
                                                color: _cardColor,
                                                borderRadius:
                                                    BorderRadius.circular(22),
                                                border: Border.all(
                                                  color: _borderColor,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    alignment: WrapAlignment
                                                        .spaceBetween,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: widget.primary
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          getSurahNameArabic(
                                                            result.surah,
                                                          ),
                                                          style: TextStyle(
                                                            color:
                                                                widget.primary,
                                                            fontWeight:
                                                                FontWeight.w800,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 5,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: _mutedColor
                                                              .withValues(
                                                                alpha: 0.08,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          "الآية ${localizedNumber(context, result.verse)}",
                                                          style: TextStyle(
                                                            color: _mutedColor,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 11.5,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    result.snippet,
                                                    maxLines: 3,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: context.watch<QuranSettingsCubit>().state.fontFamily.flutterFontFamily,
                                                      fontSize: 22,
                                                      height: 1.65,
                                                      color: _textColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(
                                          duration: 250.ms,
                                          delay: (math.min(index, 6) * 35).ms,
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
