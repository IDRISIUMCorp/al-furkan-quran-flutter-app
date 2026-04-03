import "dart:math" as math;

import "package:qcf_quran/qcf_quran.dart" as qcf;

enum SearchMatchType { exact, normalized, prefix, fuzzy }

class SearchMatchSpan {
  final int start;
  final int end;

  const SearchMatchSpan({required this.start, required this.end});
}

class AyahSearchResult {
  final int surahNumber;
  final int verseNumber;
  final String ayahKey;
  final String surahName;
  final String content;
  final String snippet;
  final double score;
  final SearchMatchType matchType;
  final String reasonLabel;
  final List<SearchMatchSpan> highlightSpans;

  const AyahSearchResult({
    required this.surahNumber,
    required this.verseNumber,
    required this.ayahKey,
    required this.surahName,
    required this.content,
    required this.snippet,
    required this.score,
    required this.matchType,
    required this.reasonLabel,
    required this.highlightSpans,
  });
}

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

class _NormalizedMappedText {
  final String normalized;
  final List<int> originalIndexByNormalizedOffset;

  const _NormalizedMappedText({
    required this.normalized,
    required this.originalIndexByNormalizedOffset,
  });
}

class _OriginalMatchRange {
  final int start;
  final int end;

  const _OriginalMatchRange({required this.start, required this.end});
}

class _WordMatchCandidate {
  final _OriginalMatchRange range;
  final double score;
  final bool isPrefixLike;
  final int wordIndex;

  const _WordMatchCandidate({
    required this.range,
    required this.score,
    required this.isPrefixLike,
    required this.wordIndex,
  });
}

class _SearchPresentation {
  final String snippet;
  final SearchMatchType matchType;
  final String reasonLabel;
  final List<SearchMatchSpan> highlightSpans;

  const _SearchPresentation({
    required this.snippet,
    required this.matchType,
    required this.reasonLabel,
    required this.highlightSpans,
  });
}

final Map<String, List<AyahSearchResult>> _quranSearchCache =
    <String, List<AyahSearchResult>>{};

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

_NormalizedMappedText _normalizeWithOriginalOffsets(String input) {
  final offsets = <int>[];
  var previous = "";

  for (var index = 0; index < input.length; index++) {
    final current = normalizeQuranSearchQuery(input.substring(0, index + 1));
    final appendedLength = math.max(0, current.length - previous.length);
    for (var partIndex = 0; partIndex < appendedLength; partIndex++) {
      offsets.add(index);
    }
    previous = current;
  }

  return _NormalizedMappedText(
    normalized: previous,
    originalIndexByNormalizedOffset: offsets,
  );
}

_OriginalMatchRange? _findLiteralRange(String content, String rawQuery) {
  final query = rawQuery.trim();
  if (query.isEmpty) return null;

  final start = content.indexOf(query);
  if (start == -1) return null;

  return _OriginalMatchRange(start: start, end: start + query.length);
}

_OriginalMatchRange? _findNormalizedRange(
  String content,
  String normalizedQuery,
) {
  if (normalizedQuery.isEmpty) return null;

  final mapped = _normalizeWithOriginalOffsets(content);
  if (mapped.normalized.isEmpty) return null;

  final start = mapped.normalized.indexOf(normalizedQuery);
  if (start == -1) return null;

  final originalStart = mapped.originalIndexByNormalizedOffset[start];
  final originalEnd =
      mapped.originalIndexByNormalizedOffset[start +
          normalizedQuery.length -
          1] +
      1;
  return _OriginalMatchRange(start: originalStart, end: originalEnd);
}

List<_WordMatchCandidate> _findTokenMatches(
  String content,
  List<String> queryTokens,
) {
  final words = RegExp(r"\S+").allMatches(content).toList(growable: false);
  if (words.isEmpty || queryTokens.isEmpty) {
    return const <_WordMatchCandidate>[];
  }

  final matches = <_WordMatchCandidate>[];
  final usedWordIndexes = <int>{};

  for (final token in queryTokens) {
    _WordMatchCandidate? best;
    for (var wordIndex = 0; wordIndex < words.length; wordIndex++) {
      final wordMatch = words[wordIndex];
      final word = wordMatch.group(0) ?? "";
      final normalizedWord = normalizeQuranSearchQuery(word);
      if (normalizedWord.isEmpty) continue;

      final similarity = _tokenSimilarity(token, normalizedWord);
      if (similarity < 0.88) continue;

      final candidate = _WordMatchCandidate(
        range: _OriginalMatchRange(start: wordMatch.start, end: wordMatch.end),
        score: similarity,
        isPrefixLike:
            normalizedWord.startsWith(token) ||
            token.startsWith(normalizedWord),
        wordIndex: wordIndex,
      );

      if (best == null || candidate.score > best.score) {
        best = candidate;
      }
    }

    if (best != null && usedWordIndexes.add(best.wordIndex)) {
      matches.add(best);
    }
  }

  matches.sort((a, b) => a.range.start.compareTo(b.range.start));
  return matches;
}

List<_OriginalMatchRange> _mergeRanges(List<_OriginalMatchRange> ranges) {
  if (ranges.isEmpty) return const <_OriginalMatchRange>[];

  final sorted = ranges.toList()..sort((a, b) => a.start.compareTo(b.start));
  final merged = <_OriginalMatchRange>[sorted.first];

  for (final range in sorted.skip(1)) {
    final last = merged.last;
    if (range.start <= last.end) {
      merged[merged.length - 1] = _OriginalMatchRange(
        start: last.start,
        end: math.max(last.end, range.end),
      );
      continue;
    }
    merged.add(range);
  }

  return merged;
}

_SearchPresentation _buildPresentation({
  required String content,
  required SearchMatchType type,
  required List<_OriginalMatchRange> ranges,
  int maxLength = 170,
}) {
  final mergedRanges = _mergeRanges(ranges);

  if (content.length <= maxLength) {
    return _SearchPresentation(
      snippet: content,
      matchType: type,
      reasonLabel: _reasonLabel(type),
      highlightSpans: mergedRanges
          .map(
            (range) => SearchMatchSpan(
              start: range.start.clamp(0, content.length),
              end: range.end.clamp(0, content.length),
            ),
          )
          .toList(growable: false),
    );
  }

  if (mergedRanges.isEmpty) {
    final snippet = _trimSnippet(content.substring(0, maxLength));
    return _SearchPresentation(
      snippet: snippet,
      matchType: type,
      reasonLabel: _reasonLabel(type),
      highlightSpans: const <SearchMatchSpan>[],
    );
  }

  final anchor = mergedRanges.first;
  var windowStart = math.max(0, anchor.start - (maxLength ~/ 3));
  var windowEnd = math.min(content.length, windowStart + maxLength);
  if (windowEnd - windowStart < maxLength) {
    windowStart = math.max(0, windowEnd - maxLength);
  }

  while (windowStart < windowEnd && content[windowStart].trim().isEmpty) {
    windowStart++;
  }
  while (windowEnd > windowStart && content[windowEnd - 1].trim().isEmpty) {
    windowEnd--;
  }

  final prefix = windowStart > 0 ? "... " : "";
  final suffix = windowEnd < content.length ? " ..." : "";
  final core = content.substring(windowStart, windowEnd);

  final spans = <SearchMatchSpan>[];
  for (final range in mergedRanges) {
    final clippedStart = math.max(range.start, windowStart);
    final clippedEnd = math.min(range.end, windowEnd);
    if (clippedEnd <= clippedStart) continue;

    spans.add(
      SearchMatchSpan(
        start: prefix.length + (clippedStart - windowStart),
        end: prefix.length + (clippedEnd - windowStart),
      ),
    );
  }

  return _SearchPresentation(
    snippet: "$prefix$core$suffix",
    matchType: type,
    reasonLabel: _reasonLabel(type),
    highlightSpans: spans,
  );
}

String _trimSnippet(String snippet) {
  return snippet.replaceAll(RegExp(r"\s+"), " ").trim();
}

String _reasonLabel(SearchMatchType type) {
  switch (type) {
    case SearchMatchType.exact:
      return "مطابقة مباشرة";
    case SearchMatchType.normalized:
      return "مطابقة بعد التطبيع";
    case SearchMatchType.prefix:
      return "مطابقة قريبة";
    case SearchMatchType.fuzzy:
      return "مطابقة تقريبية";
  }
}

_SearchPresentation _resolvePresentation(
  String rawQuery,
  String normalizedQuery,
  List<String> queryTokens,
  _IndexedAyah ayah,
) {
  final literalRange = _findLiteralRange(ayah.content, rawQuery);
  if (literalRange != null) {
    return _buildPresentation(
      content: ayah.content,
      type: SearchMatchType.exact,
      ranges: <_OriginalMatchRange>[literalRange],
    );
  }

  final normalizedRange = _findNormalizedRange(ayah.content, normalizedQuery);
  if (normalizedRange != null) {
    return _buildPresentation(
      content: ayah.content,
      type: SearchMatchType.normalized,
      ranges: <_OriginalMatchRange>[normalizedRange],
    );
  }

  final tokenMatches = _findTokenMatches(ayah.content, queryTokens);
  if (tokenMatches.isNotEmpty) {
    final isPrefixLike = tokenMatches.every((match) => match.isPrefixLike);
    return _buildPresentation(
      content: ayah.content,
      type: isPrefixLike ? SearchMatchType.prefix : SearchMatchType.fuzzy,
      ranges: tokenMatches.map((match) => match.range).toList(growable: false),
    );
  }

  return _buildPresentation(
    content: ayah.content,
    type: SearchMatchType.fuzzy,
    ranges: const <_OriginalMatchRange>[],
  );
}

Future<List<AyahSearchResult>> searchQuranAyahs(
  String rawQuery, {
  int limit = 120,
}) async {
  final query = normalizeQuranSearchQuery(rawQuery);
  if (query.length < 2) return const <AyahSearchResult>[];

  final cacheKey = "$limit::$query";
  final cached = _quranSearchCache[cacheKey];
  if (cached != null) return cached;

  final queryTokens = query
      .split(" ")
      .where((token) => token.trim().isNotEmpty)
      .toList(growable: false);

  final scored = <AyahSearchResult>[];
  for (final ayah in _indexedAyahs) {
    final score = _scoreAyahMatch(query, queryTokens, ayah);
    if (score <= 0) continue;

    final presentation = _resolvePresentation(
      rawQuery,
      query,
      queryTokens,
      ayah,
    );

    scored.add(
      AyahSearchResult(
        surahNumber: ayah.surahNumber,
        verseNumber: ayah.verseNumber,
        ayahKey: "${ayah.surahNumber}:${ayah.verseNumber}",
        surahName: qcf.getSurahNameArabic(ayah.surahNumber),
        content: ayah.content,
        snippet: presentation.snippet,
        score: score,
        matchType: presentation.matchType,
        reasonLabel: presentation.reasonLabel,
        highlightSpans: presentation.highlightSpans,
      ),
    );
  }

  scored.sort((a, b) {
    final scoreCompare = b.score.compareTo(a.score);
    if (scoreCompare != 0) return scoreCompare;

    final surahCompare = a.surahNumber.compareTo(b.surahNumber);
    if (surahCompare != 0) return surahCompare;

    return a.verseNumber.compareTo(b.verseNumber);
  });

  final results = scored.take(limit).toList(growable: false);
  _quranSearchCache[cacheKey] = results;
  return results;
}
