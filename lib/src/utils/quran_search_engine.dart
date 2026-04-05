

import "package:qcf_quran/qcf_quran.dart" as qcf;

class _IndexedAyah {
  final int surahNumber;
  final int verseNumber;
  final String content;
  final String normalizedText;
  final List<String> tokens;

  const _IndexedAyah({
    required this.surahNumber,
    required this.verseNumber,
    required this.content,
    required this.normalizedText,
    required this.tokens,
  });
}

final Map<String, List<Map<String, dynamic>>> _quranSearchCache =
    <String, List<Map<String, dynamic>>>{};

List<_IndexedAyah>? _quranSearchIndex;

String normalizeQuranSearchQuery(String input) {
  var text = qcf.normalise(input);

  // Normalize Uthmani and variant characters to standard Arabic letters
  text = text.replaceAll('\u0671', '\u0627'); // Alef Wasla (ٱ) -> Alef (ا)
  text = text.replaceAll('\u0670', '\u0627'); // Dagger Alef -> Alef (ا)
  text = text.replaceAll('\u0622', '\u0627'); // Alef Madda (آ) -> Alef (ا)
  text = text.replaceAll('\u0623', '\u0627'); // Alef Hamza Above (أ) -> Alef (ا)
  text = text.replaceAll('\u0625', '\u0627'); // Alef Hamza Below (إ) -> Alef (ا)
  text = text.replaceAll('\u0649', '\u064A'); // Alif Maksura (ى) -> Yaa (ي)
  text = text.replaceAll('\u0629', '\u0647'); // Taa Marbuta (ة) -> Haa (ه)
  text = text.replaceAll('\u0624', '\u0648'); // Waw Hamza (ؤ) -> Waw (و)
  text = text.replaceAll('\u0626', '\u064A'); // Yaa Hamza (ئ) -> Yaa (ي)
  text = text.replaceAll('\u0640', '');       // Tatweel (ـ) -> empty

  text = text.replaceAll(RegExp(r"[^\u0621-\u064A0-9\s]"), "");
  
  return text.replaceAll(RegExp(r"\s+"), " ").trim().toLowerCase();
}

List<_IndexedAyah> _buildQuranSearchIndex() {
  return qcf.quranText
      .map((entry) {
        final surahNumber = (entry["surah_number"] as num).toInt();
        final verseNumber = (entry["verse_number"] as num).toInt();
        final content = (entry["content"] as String?)?.trim() ?? "";
        final textNormal = normalizeQuranSearchQuery(
          (entry["text_normal"] as String?) ?? content,
        );

        return _IndexedAyah(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          content: content,
          normalizedText: textNormal,
          tokens: textNormal
              .split(" ")
              .where((token) => token.trim().isNotEmpty)
              .toList(growable: false),
        );
      })
      .toList(growable: false);
}

List<_IndexedAyah> get _indexedAyahs =>
    _quranSearchIndex ??= _buildQuranSearchIndex();

double _scoreAyahMatch(
  String query,
  List<String> queryTokens,
  _IndexedAyah ayah,
) {
  final text = ayah.normalizedText;
  if (text.isEmpty || queryTokens.isEmpty) return 0;

  double score = 0;
  for (final token in queryTokens) {
    if (!text.contains(token)) return 0;
    score += token.length * 100;
  }

  final exactIndex = text.indexOf(query);
  if (exactIndex >= 0) {
    score += 4000.0 - exactIndex;
  }

  score += ayah.content.length <= 180 ? ayah.content.length * 0.1 : 18.0;
  return score;
}

String _buildSnippet(String content, int maxLength) {
  final trimmed = content.replaceAll(RegExp(r"\s+"), " ").trim();
  if (trimmed.length <= maxLength) return trimmed;
  return "${trimmed.substring(0, maxLength).trim()}...";
}

Future<List<Map<String, dynamic>>> searchQuranAyahs(
  String rawQuery, {
  int limit = 120,
  bool exactPhrase = true,
  int? surahId,
}) async {
  final query = normalizeQuranSearchQuery(rawQuery);
  if (query.length < 2) return const <Map<String, dynamic>>[];

  final cacheKey = "$limit::$exactPhrase::$surahId::$query";
  final cached = _quranSearchCache[cacheKey];
  if (cached != null) return cached;

  final queryTokens = query
      .split(" ")
      .where((token) => token.trim().isNotEmpty)
      .toList(growable: false);

  RegExp? exactRegex;
  if (exactPhrase) {
    exactRegex = RegExp(r"(^|\s)" + RegExp.escape(query) + r"($|\s)");
  }

  final scored = <Map<String, dynamic>>[];
  for (final ayah in _indexedAyahs) {
    if (surahId != null && ayah.surahNumber != surahId) continue;

    double score = 0;

    if (exactPhrase) {
      if (!exactRegex!.hasMatch(ayah.normalizedText)) continue;
      score = 5000.0 - ayah.normalizedText.indexOf(query);
    } else {
      score = _scoreAyahMatch(query, queryTokens, ayah);
      if (score <= 0) continue;
    }

    scored.add({
      "surah_number": ayah.surahNumber,
      "verse_number": ayah.verseNumber,
      "ayah_key": "${ayah.surahNumber}:${ayah.verseNumber}",
      "surah_name": qcf.getSurahNameArabic(ayah.surahNumber),
      "content": ayah.content,
      "snippet": _buildSnippet(ayah.content, 170),
      "score": score,
    });
  }

  scored.sort((a, b) {
    final scoreCompare = ((b["score"] as num?) ?? 0).compareTo(
      (a["score"] as num?) ?? 0,
    );
    if (scoreCompare != 0) return scoreCompare;

    final surahCompare = ((a["surah_number"] as num?) ?? 0).compareTo(
      (b["surah_number"] as num?) ?? 0,
    );
    if (surahCompare != 0) return surahCompare;

    return ((a["verse_number"] as num?) ?? 0).compareTo(
      (b["verse_number"] as num?) ?? 0,
    );
  });

  final results = scored.take(limit).toList(growable: false);
  _quranSearchCache[cacheKey] = results;
  return results;
}

