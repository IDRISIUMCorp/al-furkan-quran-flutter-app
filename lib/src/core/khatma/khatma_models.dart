enum KhatmaDayStatus { pending, deferred, completed }

enum KhatmaArchiveStatus { completed, cancelled }

class KhatmaReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const KhatmaReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

  const KhatmaReminderSettings.disabled()
    : enabled = false,
      hour = 7,
      minute = 0;

  KhatmaReminderSettings copyWith({bool? enabled, int? hour, int? minute}) {
    return KhatmaReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "enabled": enabled,
      "hour": hour,
      "minute": minute,
    };
  }

  factory KhatmaReminderSettings.fromMap(Map<String, dynamic> map) {
    return KhatmaReminderSettings(
      enabled: map["enabled"] == true,
      hour: map["hour"] as int? ?? 7,
      minute: map["minute"] as int? ?? 0,
    );
  }
}

class KhatmaDayAssignment {
  final int dayNumber;
  final int startPage;
  final int endPage;
  final DateTime scheduledDate;
  final KhatmaDayStatus status;
  final DateTime? completedAt;

  const KhatmaDayAssignment({
    required this.dayNumber,
    required this.startPage,
    required this.endPage,
    required this.scheduledDate,
    required this.status,
    this.completedAt,
  });

  int get pageCount => (endPage - startPage) + 1;

  bool get isCompleted => status == KhatmaDayStatus.completed;

  KhatmaDayAssignment copyWith({
    int? dayNumber,
    int? startPage,
    int? endPage,
    DateTime? scheduledDate,
    KhatmaDayStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return KhatmaDayAssignment(
      dayNumber: dayNumber ?? this.dayNumber,
      startPage: startPage ?? this.startPage,
      endPage: endPage ?? this.endPage,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "dayNumber": dayNumber,
      "startPage": startPage,
      "endPage": endPage,
      "scheduledDate": scheduledDate.toIso8601String(),
      "status": status.name,
      "completedAt": completedAt?.toIso8601String(),
    };
  }

  factory KhatmaDayAssignment.fromMap(Map<String, dynamic> map) {
    return KhatmaDayAssignment(
      dayNumber: map["dayNumber"] as int? ?? 1,
      startPage: map["startPage"] as int? ?? 1,
      endPage: map["endPage"] as int? ?? 1,
      scheduledDate:
          DateTime.tryParse(map["scheduledDate"] as String? ?? "") ??
          DateTime.now(),
      status: KhatmaDayStatus.values.firstWhere(
        (value) => value.name == map["status"],
        orElse: () => KhatmaDayStatus.pending,
      ),
      completedAt: DateTime.tryParse(map["completedAt"] as String? ?? ""),
    );
  }
}

class KhatmaPlanRecord {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime startedAt;
  final int startPage;
  final int totalDays;
  final bool isMigrated;
  final KhatmaReminderSettings reminder;
  final List<KhatmaDayAssignment> assignments;

  const KhatmaPlanRecord({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.startedAt,
    required this.startPage,
    required this.totalDays,
    required this.isMigrated,
    required this.reminder,
    required this.assignments,
  });

  int get totalPages =>
      assignments.fold<int>(0, (sum, item) => sum + item.pageCount);

  KhatmaPlanRecord copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? startedAt,
    int? startPage,
    int? totalDays,
    bool? isMigrated,
    KhatmaReminderSettings? reminder,
    List<KhatmaDayAssignment>? assignments,
  }) {
    return KhatmaPlanRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      startPage: startPage ?? this.startPage,
      totalDays: totalDays ?? this.totalDays,
      isMigrated: isMigrated ?? this.isMigrated,
      reminder: reminder ?? this.reminder,
      assignments: assignments ?? this.assignments,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "title": title,
      "createdAt": createdAt.toIso8601String(),
      "startedAt": startedAt.toIso8601String(),
      "startPage": startPage,
      "totalDays": totalDays,
      "isMigrated": isMigrated,
      "reminder": reminder.toMap(),
      "assignments": assignments.map((item) => item.toMap()).toList(),
    };
  }

  factory KhatmaPlanRecord.fromMap(Map<String, dynamic> map) {
    return KhatmaPlanRecord(
      id: map["id"] as String? ?? "khatma",
      title: map["title"] as String? ?? "ختمة",
      createdAt:
          DateTime.tryParse(map["createdAt"] as String? ?? "") ??
          DateTime.now(),
      startedAt:
          DateTime.tryParse(map["startedAt"] as String? ?? "") ??
          DateTime.now(),
      startPage: map["startPage"] as int? ?? 1,
      totalDays: map["totalDays"] as int? ?? 30,
      isMigrated: map["isMigrated"] == true,
      reminder: KhatmaReminderSettings.fromMap(
        Map<String, dynamic>.from(
          map["reminder"] as Map? ?? const <String, dynamic>{},
        ),
      ),
      assignments: (map["assignments"] as List? ?? const <dynamic>[])
          .map(
            (item) => KhatmaDayAssignment.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class KhatmaStatsSnapshot {
  final DateTime capturedAt;
  final int completedDays;
  final int remainingDays;
  final int pagesRead;
  final int pagesRemaining;
  final double progressPercent;
  final double adherencePercent;
  final double averagePagesPerDay;
  final int streak;
  final int bestStreak;
  final DateTime expectedCompletionDate;

  const KhatmaStatsSnapshot({
    required this.capturedAt,
    required this.completedDays,
    required this.remainingDays,
    required this.pagesRead,
    required this.pagesRemaining,
    required this.progressPercent,
    required this.adherencePercent,
    required this.averagePagesPerDay,
    required this.streak,
    required this.bestStreak,
    required this.expectedCompletionDate,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "capturedAt": capturedAt.toIso8601String(),
      "completedDays": completedDays,
      "remainingDays": remainingDays,
      "pagesRead": pagesRead,
      "pagesRemaining": pagesRemaining,
      "progressPercent": progressPercent,
      "adherencePercent": adherencePercent,
      "averagePagesPerDay": averagePagesPerDay,
      "streak": streak,
      "bestStreak": bestStreak,
      "expectedCompletionDate": expectedCompletionDate.toIso8601String(),
    };
  }

  factory KhatmaStatsSnapshot.fromMap(Map<String, dynamic> map) {
    return KhatmaStatsSnapshot(
      capturedAt:
          DateTime.tryParse(map["capturedAt"] as String? ?? "") ??
          DateTime.now(),
      completedDays: map["completedDays"] as int? ?? 0,
      remainingDays: map["remainingDays"] as int? ?? 0,
      pagesRead: map["pagesRead"] as int? ?? 0,
      pagesRemaining: map["pagesRemaining"] as int? ?? 0,
      progressPercent: (map["progressPercent"] as num? ?? 0).toDouble(),
      adherencePercent: (map["adherencePercent"] as num? ?? 0).toDouble(),
      averagePagesPerDay: (map["averagePagesPerDay"] as num? ?? 0).toDouble(),
      streak: map["streak"] as int? ?? 0,
      bestStreak: map["bestStreak"] as int? ?? 0,
      expectedCompletionDate:
          DateTime.tryParse(map["expectedCompletionDate"] as String? ?? "") ??
          DateTime.now(),
    );
  }
}

class KhatmaArchiveRecord {
  final String id;
  final DateTime archivedAt;
  final KhatmaArchiveStatus status;
  final KhatmaPlanRecord plan;
  final KhatmaStatsSnapshot stats;

  const KhatmaArchiveRecord({
    required this.id,
    required this.archivedAt,
    required this.status,
    required this.plan,
    required this.stats,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "id": id,
      "archivedAt": archivedAt.toIso8601String(),
      "status": status.name,
      "plan": plan.toMap(),
      "stats": stats.toMap(),
    };
  }

  factory KhatmaArchiveRecord.fromMap(Map<String, dynamic> map) {
    return KhatmaArchiveRecord(
      id: map["id"] as String? ?? "archive",
      archivedAt:
          DateTime.tryParse(map["archivedAt"] as String? ?? "") ??
          DateTime.now(),
      status: KhatmaArchiveStatus.values.firstWhere(
        (value) => value.name == map["status"],
        orElse: () => KhatmaArchiveStatus.cancelled,
      ),
      plan: KhatmaPlanRecord.fromMap(
        Map<String, dynamic>.from(
          map["plan"] as Map? ?? const <String, dynamic>{},
        ),
      ),
      stats: KhatmaStatsSnapshot.fromMap(
        Map<String, dynamic>.from(
          map["stats"] as Map? ?? const <String, dynamic>{},
        ),
      ),
    );
  }
}

class KhatmaTodaySnapshot {
  final KhatmaDayAssignment? scheduledAssignment;
  final List<KhatmaDayAssignment> overdueAssignments;
  final bool completedToday;
  final int backlogPages;
  final int todayPages;

  const KhatmaTodaySnapshot({
    required this.scheduledAssignment,
    required this.overdueAssignments,
    required this.completedToday,
    required this.backlogPages,
    required this.todayPages,
  });

  int get combinedTargetPages => backlogPages + todayPages;

  bool get hasOverdue => overdueAssignments.isNotEmpty;
}
