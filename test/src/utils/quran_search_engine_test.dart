import "package:al_quran_v3/src/utils/quran_search_engine.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test(
    "normalizeQuranSearchQuery strips punctuation and keeps Arabic letters searchable",
    () {
      final normalized = normalizeQuranSearchQuery("ٱلْحَمْدُ!!");

      expect(normalized, isNotEmpty);
      expect(normalized.contains("!"), isFalse);
      expect(normalized.contains(" "), isFalse);
    },
  );

  test(
    "searchQuranAyahs returns highlighted spans for common matches",
    () async {
      final results = await searchQuranAyahs("الحمد", limit: 20);

      expect(results, isNotEmpty);
      final highlighted = results.firstWhere(
        (result) => result.highlightSpans.isNotEmpty,
        orElse: () => results.first,
      );

      expect(highlighted.snippet, isNotEmpty);
      expect(highlighted.reasonLabel, isNotEmpty);
      expect(highlighted.highlightSpans, isNotEmpty);
    },
  );

  test(
    "searchQuranAyahs classifies approximate matches as fuzzy when needed",
    () async {
      final results = await searchQuranAyahs("الحمذ", limit: 20);

      expect(results, isNotEmpty);
      expect(results.first.matchType, SearchMatchType.fuzzy);
      expect(results.first.reasonLabel, "مطابقة تقريبية");
    },
  );
}
