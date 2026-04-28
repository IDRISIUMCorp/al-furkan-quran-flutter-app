/// Al-Furkan String Extensions — Utility methods for string manipulation
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Check if string is a valid ayah key format (e.g., "1:1")
  bool get isAyahKey {
    final parts = split(':');
    if (parts.length != 2) return false;
    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    return surah != null && ayah != null && surah > 0 && surah <= 114 && ayah > 0;
  }

  /// Extract surah number from ayah key
  int? get surahNumber {
    if (!isAyahKey) return null;
    return int.tryParse(split(':')[0]);
  }

  /// Extract ayah number from ayah key
  int? get ayahNumber {
    if (!isAyahKey) return null;
    return int.tryParse(split(':')[1]);
  }

  /// Truncate string to max length with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  /// Remove diacritics (tashkeel) from Arabic text
  String get removeDiacritics {
    const diacritics = [
      '\u0618', '\u0619', '\u061A', '\u064B', '\u064C',
      '\u064D', '\u064E', '\u064F', '\u0650', '\u0651',
      '\u0652', '\u0653', '\u0654', '\u0655', '\u0656',
      '\u0657', '\u0658', '\u0659', '\u065A', '\u065B',
      '\u065C', '\u065D', '\u065E', '\u065F', '\u0670',
    ];
    var result = this;
    for (final d in diacritics) {
      result = result.replaceAll(d, '');
    }
    return result;
  }
}
