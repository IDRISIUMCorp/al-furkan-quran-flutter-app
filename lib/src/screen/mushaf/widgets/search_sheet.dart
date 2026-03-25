import 'package:flutter/material.dart';
import 'package:al_quran_v3/src/theme/controller/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qcf_quran/qcf_quran.dart';

import 'package:al_quran_v3/src/utils/number_localization.dart';
import 'package:al_quran_v3/src/utils/quran_resources/quran_script_function.dart';

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

  void _updateSearch() {
    final q = widget.controller.text;
    if (q == _lastQuery) return;
    _lastQuery = q;
    setState(() {
      _future = widget.search(q);
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateSearch);
    _future = widget.search(widget.controller.text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateSearch);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.controller.text.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF141414) : const Color(0xFFF7F1E6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      Expanded(
                        child: Text(
                          "بحث في الآيات",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9F2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.06),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
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
                            decoration: const InputDecoration(
                              hintText: "اكتب كلمة من الآية…",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (q.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              widget.controller.clear();
                            },
                            icon: const Icon(Icons.close_rounded),
                            color: const Color(0xFF8F8F8F),
                            splashRadius: 18,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (q.length < 2)
                    const Padding(
                      padding: EdgeInsets.only(top: 26),
                      child: Text(
                        "اكتب حرفين أو أكثر",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF9C9C9C),
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
                            return const Padding(
                              padding: EdgeInsets.only(top: 26),
                              child: Center(
                                child: Text(
                                  "مفيش نتائج",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF9C9C9C),
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(bottom: 10),
                            itemCount: results.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 10,
                              color: Colors.black.withValues(alpha: 0.06),
                            ),
                            itemBuilder: (context, index) {
                              final r = results[index];
                              return ListTile(
                                onTap: () => widget.onResultTap(r.ayahKey),
                                title: Text(
                                  "${getSurahNameArabic(r.surah)}: ${localizedNumber(context, r.verse)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF1B1B1B),
                                  ),
                                ),
                                subtitle: Text(
                                  r.snippet,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    height: 1.55,
                                    color: Color(0xFF8F8F8F),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_left_rounded,
                                  color: widget.primary,
                                ),
                              );
                            },
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
