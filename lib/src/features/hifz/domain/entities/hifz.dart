/// Hifz Progress Entity — Pure Dart, ZERO Flutter imports
class HifzProgress {
  final int surahId;
  final int ayahStart;
  final int ayahEnd;
  final int totalAyahs;
  final DateTime lastReviewed;
  final HifzMasteryLevel mastery;
  final int reviewCount;
  final int correctCount;
  final int mistakeCount;

  const HifzProgress({
    required this.surahId,
    required this.ayahStart,
    required this.ayahEnd,
    required this.totalAyahs,
    required this.lastReviewed,
    required this.mastery,
    required this.reviewCount,
    required this.correctCount,
    required this.mistakeCount,
  });

  /// Calculate mastery percentage
  double get masteryPercentage {
    if (reviewCount == 0) return 0;
    return (correctCount / reviewCount) * 100;
  }

  /// Calculate progress percentage (ayahs memorized / total)
  double get progressPercentage {
    return ((ayahEnd - ayahStart + 1) / totalAyahs) * 100;
  }
}

enum HifzMasteryLevel {
  notStarted,
  learning,    // 0-30% accuracy
  familiar,    // 30-60% accuracy
  confident,   // 60-85% accuracy
  mastered,    // 85-100% accuracy
}

/// Hifz Session Entity — a single review session
class HifzSession {
  final int id;
  final int surahId;
  final int ayahStart;
  final int ayahEnd;
  final DateTime date;
  final int durationSeconds;
  final int mistakes;
  final int hints;
  final HifzSessionType type;

  const HifzSession({
    required this.id,
    required this.surahId,
    required this.ayahStart,
    required this.ayahEnd,
    required this.date,
    required this.durationSeconds,
    required this.mistakes,
    required this.hints,
    required this.type,
  });
}

enum HifzSessionType {
  review,      // Review previously memorized
  newMemorize, // New memorization session
  test,        // Self-test mode
}
