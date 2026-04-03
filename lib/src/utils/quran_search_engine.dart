import "dart:math" as math;

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
  return qcf
      .normalise(input)
      .replaceAll(RegExp(r"[^\u0621-\u064A0-9\s]"), " ")
      .replaceAll(RegExp(r"\s+"), " ")
      .trim()
      .toLowerCase();
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

double _tokenSimilarity(String queryToken, String verseToken) {
  if (queryToken == verseToken) return 1.0;
  if (verseToken.startsWith(queryToken) || queryToken.startsWith(verseToken)) {
    return 0.94;
  }
  if (verseToken.contains(queryToken) || queryToken.contains(verseToken)) {
    return 0.88;
  }

  final minLength = math.min(queryToken.length, verseToken.length);
  int sharedPrefix = 0;
  while (sharedPrefix < minLength &&
      queryToken.codeUnitAt(sharedPrefix) ==
          verseToken.codeUnitAt(sharedPrefix)) {
    sharedPrefix++;
  }

  final prefixRatio =
      sharedPrefix / math.max(queryToken.length, verseToken.length);
  if (sharedPrefix >= 2 && prefixRatio >= 0.55) {
    return prefixRatio;
  }

  return 0.0;
}

double _scoreAyahMatch(
  String query,
  List<String> queryTokens,
  _IndexedAyah ayah,
) {
  final text = ayah.normalizedText;
  if (text.isEmpty) return 0;

  final exactIndex = text.indexOf(query);
  if (exactIndex >= 0) {
    return 4000.0 - exactIndex;
  }

  if (queryTokens.isEmpty) return 0;

  double score = 0;
  int stronglyMatchedTokens = 0;
  for (final queryToken in queryTokens) {
    double best = 0;
    for (final verseToken in ayah.tokens) {
      final similarity = _tokenSimilarity(queryToken, verseToken);
      if (similarity > best) {
        best = similarity;
      }
      if (best >= 1.0) break;
    }

    if (best < 0.62) {
      return 0;
    }

    if (best >= 0.88) {
      stronglyMatchedTokens++;
    }

    score += best * queryToken.length * 100;
  }

  final coverage = stronglyMatchedTokens / queryTokens.length;
  if (coverage < 0.34) return 0;

  final startsWithBoost = ayah.tokens.any(
    (token) => queryTokens.any((queryToken) => token.startsWith(queryToken)),
  );

  if (startsWithBoost) {
    score += 90;
  }

  score += math.min(ayah.content.length.toDouble(), 180) * 0.1;
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
}) async {
  final query = normalizeQuranSearchQuery(rawQuery);
  if (query.length < 2) return const <Map<String, dynamic>>[];

  final cacheKey = "$limit::$query";
  final cached = _quranSearchCache[cacheKey];
  if (cached != null) return cached;

  final queryTokens = query
      .split(" ")
      .where((token) => token.trim().isNotEmpty)
      .toList(growable: false);

  final scored = <Map<String, dynamic>>[];
  for (final ayah in _indexedAyahs) {
    final score = _scoreAyahMatch(query, queryTokens, ayah);
    if (score <= 0) continue;

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
