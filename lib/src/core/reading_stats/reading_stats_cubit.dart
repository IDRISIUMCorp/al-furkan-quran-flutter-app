import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:al_furkan/src/core/storage/app_boxes.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Reading Stats — إحصائيات القراءة
// ═══════════════════════════════════════════════════════════════════

class ReadingStatsState {
  /// Pages read today
  final int pagesToday;
  /// Ayahs read today
  final int ayahsToday;
  /// Reading time today in seconds
  final int secondsToday;
  /// Current streak (consecutive days with reading)
  final int streak;
  /// Daily goal in pages (0 = no goal)
  final int dailyGoalPages;
  /// Daily goal in ayahs (0 = no goal)
  final int dailyGoalAyahs;
  /// Date of last reading activity (yyyy-MM-dd)
  final String? lastActiveDate;
  /// Total pages read all time
  final int totalPagesAllTime;
  /// Total ayahs read all time
  final int totalAyahsAllTime;

  const ReadingStatsState({
    this.pagesToday = 0,
    this.ayahsToday = 0,
    this.secondsToday = 0,
    this.streak = 0,
    this.dailyGoalPages = 0,
    this.dailyGoalAyahs = 0,
    this.lastActiveDate,
    this.totalPagesAllTime = 0,
    this.totalAyahsAllTime = 0,
  });

  ReadingStatsState copyWith({
    int? pagesToday,
    int? ayahsToday,
    int? secondsToday,
    int? streak,
    int? dailyGoalPages,
    int? dailyGoalAyahs,
    String? lastActiveDate,
    int? totalPagesAllTime,
    int? totalAyahsAllTime,
  }) =>
      ReadingStatsState(
        pagesToday: pagesToday ?? this.pagesToday,
        ayahsToday: ayahsToday ?? this.ayahsToday,
        secondsToday: secondsToday ?? this.secondsToday,
        streak: streak ?? this.streak,
        dailyGoalPages: dailyGoalPages ?? this.dailyGoalPages,
        dailyGoalAyahs: dailyGoalAyahs ?? this.dailyGoalAyahs,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
        totalPagesAllTime: totalPagesAllTime ?? this.totalPagesAllTime,
        totalAyahsAllTime: totalAyahsAllTime ?? this.totalAyahsAllTime,
      );

  /// Progress toward daily goal (0.0 - 1.0)
  double get goalProgress {
    if (dailyGoalPages > 0) return (pagesToday / dailyGoalPages).clamp(0.0, 1.0);
    if (dailyGoalAyahs > 0) return (ayahsToday / dailyGoalAyahs).clamp(0.0, 1.0);
    return 0.0;
  }

  bool get hasGoal => dailyGoalPages > 0 || dailyGoalAyahs > 0;
  bool get goalReached => goalProgress >= 1.0;

  String get formattedTimeToday {
    final mins = secondsToday ~/ 60;
    final hrs = mins ~/ 60;
    final remMins = mins % 60;
    if (hrs > 0) return "$hrs ساعة $remMins دقيقة";
    if (mins > 0) return "$mins دقيقة";
    return "$secondsToday ثانية";
  }
}

class ReadingStatsCubit extends Cubit<ReadingStatsState> {
  static const _kBox = AppBoxes.readingStats;
  static const _kPagesToday = "pages_today";
  static const _kAyahsToday = "ayahs_today";
  static const _kSecondsToday = "seconds_today";
  static const _kStreak = "streak";
  static const _kDailyGoalPages = "daily_goal_pages";
  static const _kDailyGoalAyahs = "daily_goal_ayahs";
  static const _kLastActiveDate = "last_active_date";
  static const _kTotalPages = "total_pages";
  static const _kTotalAyahs = "total_ayahs";

  ReadingStatsCubit() : super(const ReadingStatsState()) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final box = Hive.box(_kBox);
    final today = _todayString();
    final lastDate = box.get(_kLastActiveDate) as String?;

    // Reset daily counters if it's a new day
    final isSameDay = lastDate == today;

    final pagesToday = isSameDay ? (box.get(_kPagesToday, defaultValue: 0) as int) : 0;
    final ayahsToday = isSameDay ? (box.get(_kAyahsToday, defaultValue: 0) as int) : 0;
    final secondsToday = isSameDay ? (box.get(_kSecondsToday, defaultValue: 0) as int) : 0;

    // Calculate streak
    int streak = box.get(_kStreak, defaultValue: 0) as int;
    if (!isSameDay) {
      final yesterday = _yesterdayString();
      if (lastDate == yesterday) {
        // Continue streak
      } else if (lastDate != today) {
        // Streak broken
        streak = 0;
      }
    }
    if (pagesToday > 0 || ayahsToday > 0) {
      streak = streak > 0 ? streak : 1;
    }

    emit(ReadingStatsState(
      pagesToday: pagesToday,
      ayahsToday: ayahsToday,
      secondsToday: secondsToday,
      streak: streak,
      dailyGoalPages: box.get(_kDailyGoalPages, defaultValue: 0) as int,
      dailyGoalAyahs: box.get(_kDailyGoalAyahs, defaultValue: 0) as int,
      lastActiveDate: lastDate,
      totalPagesAllTime: box.get(_kTotalPages, defaultValue: 0) as int,
      totalAyahsAllTime: box.get(_kTotalAyahs, defaultValue: 0) as int,
    ));
  }

  /// Record pages read
  void recordPages(int pages) {
    if (pages <= 0) return;
    final box = Hive.box(_kBox);
    final today = _todayString();
    final newPages = state.pagesToday + pages;
    final newTotal = state.totalPagesAllTime + pages;

    box.put(_kPagesToday, newPages);
    box.put(_kTotalPages, newTotal);
    box.put(_kLastActiveDate, today);

    _updateStreak(box, today);
    emit(state.copyWith(
      pagesToday: newPages,
      totalPagesAllTime: newTotal,
      lastActiveDate: today,
    ));
  }

  /// Record ayahs read
  void recordAyahs(int ayahs) {
    if (ayahs <= 0) return;
    final box = Hive.box(_kBox);
    final today = _todayString();
    final newAyahs = state.ayahsToday + ayahs;
    final newTotal = state.totalAyahsAllTime + ayahs;

    box.put(_kAyahsToday, newAyahs);
    box.put(_kTotalAyahs, newTotal);
    box.put(_kLastActiveDate, today);

    _updateStreak(box, today);
    emit(state.copyWith(
      ayahsToday: newAyahs,
      totalAyahsAllTime: newTotal,
      lastActiveDate: today,
    ));
  }

  /// Record reading time (seconds)
  void recordTime(int seconds) {
    if (seconds <= 0) return;
    final box = Hive.box(_kBox);
    final newSeconds = state.secondsToday + seconds;
    box.put(_kSecondsToday, newSeconds);
    emit(state.copyWith(secondsToday: newSeconds));
  }

  /// Set daily goal
  void setDailyGoal({int pages = 0, int ayahs = 0}) {
    final box = Hive.box(_kBox);
    box.put(_kDailyGoalPages, pages);
    box.put(_kDailyGoalAyahs, ayahs);
    emit(state.copyWith(dailyGoalPages: pages, dailyGoalAyahs: ayahs));
  }

  void _updateStreak(Box box, String today) {
    int streak = state.streak;
    final lastDate = state.lastActiveDate;

    if (lastDate == today) {
      // Same day, streak unchanged
    } else if (lastDate == _yesterdayString()) {
      // Next day — increment streak
      streak++;
    } else {
      // Streak broken — start fresh
      streak = 1;
    }

    box.put(_kStreak, streak);
    emit(state.copyWith(streak: streak));
  }

  String _todayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  String _yesterdayString() {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return "${y.year}-${y.month.toString().padLeft(2, '0')}-${y.day.toString().padLeft(2, '0')}";
  }
}
