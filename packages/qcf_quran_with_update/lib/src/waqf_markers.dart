import 'package:flutter/material.dart';

/// Quranic Waqf (stop) sign types and their visual representation.
///
/// These signs appear in the margins of the Mushaf to guide the reader
/// on where to stop, pause, or continue during recitation.
///
/// Reference: Most standard Hafs Mushafs use these symbols.

/// Enum representing the 10 standard Quranic Waqf (stop) signs.
enum WaqfType {
  /// م — Waqf Lazim (Mandatory stop).
  /// Failing to stop may change the meaning.
  mandatory('م', 'وقف لازم', Color(0xFFD32F2F)),

  /// ط — Waqf Mutlaq (Absolute stop).
  /// Preferred to stop, but continuing is acceptable.
  preferred('ط', 'وقف مطلق', Color(0xFFE65100)),

  /// ج — Waqf Ja'iz (Permissible stop).
  /// May stop or continue, both are acceptable.
  permissible('ج', 'وقف جائز', Color(0xFFF9A825)),

  /// ز — Waqf Mujawwaz (Allowed stop).
  /// Better to continue, but stopping is allowed.
  allowed('ز', 'وقف مجوز', Color(0xFF7CB342)),

  /// ص — Waqf Murakhkhas (Licensed stop).
  /// Continuation is preferred; stopping only for necessity.
  licensed('ص', 'وقف مرخص', Color(0xFF26A69A)),

  /// ق — Qat' (Cut/Discontinuation).
  /// Stop and start from the next verse; not a pause.
  cut('ق', 'قطع', Color(0xFF5C6BC0)),

  /// صلے — Al-Wasl Awla (Continuation preferred).
  /// Better to continue; stopping is discouraged.
  continuePreferred('صلے', 'الوصل أولى', Color(0xFF42A5F5)),

  /// قف — Qif (Pause/Stop here).
  /// Indicates a pause point that might be overlooked.
  pause('قف', 'قف', Color(0xFFAB47BC)),

  /// لا — La (No stop).
  /// Must NOT stop here; meaning would be corrupted.
  noStop('لا', 'لا تقف', Color(0xFFE53935)),

  /// ك — Kadhalik (Similarly).
  /// Stop here like the previous marked position.
  similarly('ك', 'كذلك', Color(0xFF78909C));

  const WaqfType(this.symbol, this.description, this.color);

  /// The Arabic symbol displayed in the Mushaf margin.
  final String symbol;

  /// Arabic description of the waqf type.
  final String description;

  /// Suggested color for rendering the marker.
  final Color color;
}

/// A data model representing a Waqf marker at a specific verse position.
class WaqfMarker {
  /// The surah number (1..114).
  final int surah;

  /// The verse number.
  final int verse;

  /// The type of waqf sign.
  final WaqfType type;

  const WaqfMarker({
    required this.surah,
    required this.verse,
    required this.type,
  });

  /// Returns the ayah key string (e.g. "2:255").
  String get ayahKey => '$surah:$verse';

  @override
  String toString() => 'WaqfMarker($ayahKey, ${type.symbol})';
}

/// Predefined waqf markers for commonly known positions.
///
/// NOTE: A complete waqf dataset requires the specific Mushaf edition's
/// stop sign data. This list contains the most well-known positions
/// that are consistent across standard Hafs editions.
const List<WaqfMarker> commonWaqfMarkers = [
  // Al-Baqarah - famous stop signs
  WaqfMarker(surah: 2, verse: 2, type: WaqfType.mandatory),
  WaqfMarker(surah: 2, verse: 22, type: WaqfType.noStop),
  WaqfMarker(surah: 2, verse: 255, type: WaqfType.mandatory),
  WaqfMarker(surah: 2, verse: 256, type: WaqfType.noStop),

  // Al-Kahf - stop at verse 1 and 110
  WaqfMarker(surah: 18, verse: 1, type: WaqfType.mandatory),
  WaqfMarker(surah: 18, verse: 110, type: WaqfType.mandatory),

  // Ya-Sin
  WaqfMarker(surah: 36, verse: 1, type: WaqfType.mandatory),
  WaqfMarker(surah: 36, verse: 60, type: WaqfType.noStop),

  // Ar-Rahman
  WaqfMarker(surah: 55, verse: 13, type: WaqfType.mandatory),

  // Al-Mulk
  WaqfMarker(surah: 67, verse: 1, type: WaqfType.mandatory),

  // Al-Alaq
  WaqfMarker(surah: 96, verse: 19, type: WaqfType.mandatory),
];

/// Returns the [WaqfType] for a given surah/verse, or `null` if no marker.
WaqfType? getWaqfType(int surah, int verse) {
  for (final m in commonWaqfMarkers) {
    if (m.surah == surah && m.verse == verse) {
      return m.type;
    }
  }
  return null;
}

/// Returns all waqf markers for a given surah.
List<WaqfMarker> getWaqfMarkersBySurah(int surah) {
  return commonWaqfMarkers.where((m) => m.surah == surah).toList();
}
