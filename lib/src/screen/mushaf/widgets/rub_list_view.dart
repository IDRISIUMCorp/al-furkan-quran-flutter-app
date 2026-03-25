import "dart:convert";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:al_quran_v3/src/utils/number_localization.dart";
import "package:al_quran_v3/src/resources/quran_resources/meaning_of_surah.dart";
import "package:al_quran_v3/src/utils/quran_ayahs_function/get_page_number.dart";

class RubListView extends StatelessWidget {
  final ValueChanged<int> onOpenPage;
  final String query;
  const RubListView({super.key, required this.onOpenPage, required this.query});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onBg = isDark ? Colors.white : Colors.black;
    final bg = isDark ? Colors.black : Colors.white;
    final cardBg = isDark ? const Color(0xFF1B1B1F) : const Color(0xFFFFF9F2);

    final q = query.trim().toLowerCase();
    return FutureBuilder<String>(
      future: rootBundle.loadString("assets/meta_data/Rub.json"),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done || !snap.hasData) {
          return const SizedBox.shrink();
        }

        final Map data = jsonDecode(snap.data!);
        final items = data.values.toList();

        bool matchesQuery({
          required int rubNumber,
          required int surah,
          required int verse,
          required int page,
        }) {
          if (q.isEmpty) return true;
          final surahName = getSurahNameArabic(surah);
          final key = "$rubNumber $surahName $surah:$verse $page".toLowerCase();
          return key.contains(q);
        }

        final filtered = <Map<String, dynamic>>[];
        for (var i = 0; i < items.length; i++) {
          final m = Map<String, dynamic>.from(items[i]);
          final String firstKey = (m["fvk"] as String?) ?? "1:1";
          final int rubNumber = (m["rn"] as int?) ?? (i + 1);
          final surah = int.tryParse(firstKey.split(":").first) ?? 1;
          final verse = int.tryParse(firstKey.split(":").last) ?? 1;
          final page = _getPageNumber(firstKey) ?? 1;
          if (matchesQuery(
            rubNumber: rubNumber,
            surah: surah,
            verse: verse,
            page: page,
          )) {
            filtered.add({
              ...m,
              "_firstKey": firstKey,
              "_rubNumber": rubNumber,
              "_surah": surah,
              "_verse": verse,
              "_page": page,
            });
          }
        }

        if (filtered.isEmpty) {
          return const Center(
            child: Text(
              "مفيش نتائج",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF9C9C9C),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
          itemCount: filtered.length,
          separatorBuilder: (_, __) =>
              Divider(height: 10, color: Colors.black.withValues(alpha: 0.06)),
          itemBuilder: (context, index) {
            final m = filtered[index];
            final int rubNumber = (m["_rubNumber"] as int?) ?? (index + 1);
            final surah = (m["_surah"] as int?) ?? 1;
            final verse = (m["_verse"] as int?) ?? 1;
            final page = (m["_page"] as int?) ?? 1;

            return InkWell(
              onTap: () => onOpenPage(page),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Text(
                        localizedNumber(context, rubNumber),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: onBg,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ربع ${localizedNumber(context, rubNumber)}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: onBg,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${getSurahNameArabic(surah)}: ${localizedNumber(context, verse)} · الصفحة ${localizedNumber(context, page)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF8F8F8F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF8F8F8F),
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

  int? _getPageNumber(String firstKey) {
    if (firstKey.isEmpty) return null;
    final surah = int.tryParse(firstKey.split(":").first) ?? 1;
    final verse = int.tryParse(firstKey.split(":").last) ?? 1;
    return getPageNumber("$surah:$verse");
  }
}
