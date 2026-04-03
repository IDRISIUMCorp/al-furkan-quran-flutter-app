import "package:al_quran_v3/src/core/khatma/khatma_models.dart";
import "package:al_quran_v3/src/core/notifications/khatma_notification_service.dart";
import "package:flutter/material.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

abstract class KhatmaReminderScheduler {
  Future<void> sync(KhatmaReminderSettings settings);
  Future<void> cancel();
  Future<void> sendTestNotification();
}

class LocalKhatmaReminderScheduler implements KhatmaReminderScheduler {
  @override
  Future<void> cancel() {
    return KhatmaNotificationService.instance.cancelDailyReminder();
  }

  @override
  Future<void> sendTestNotification() {
    return KhatmaNotificationService.instance.sendTestNotification();
  }

  @override
  Future<void> sync(KhatmaReminderSettings settings) async {
    if (!settings.enabled) {
      await cancel();
      return;
    }
    final granted = await KhatmaNotificationService.instance
        .requestPermissionIfNeeded();
    if (!granted) return;
    await KhatmaNotificationService.instance.scheduleDailyReminder(
      time: TimeOfDay(hour: settings.hour, minute: settings.minute),
    );
  }
}

abstract class KhatmaRepository {
  Future<void> ensureMigrated();
  KhatmaPlanRecord? loadActivePlan();
  List<KhatmaArchiveRecord> loadArchive();
  Future<void> createPlan({
    required int days,
    required int startPage,
    required String title,
    required KhatmaReminderSettings reminder,
    DateTime? startedAt,
  });
  Future<void> updateReminder(KhatmaReminderSettings reminder);
  Future<void> markTodayCompleted({DateTime? now});
  Future<void> completeNextOverdueDay({DateTime? now});
  Future<void> deferToday({DateTime? now});
  Future<void> cancelActivePlan({DateTime? now});
  KhatmaTodaySnapshot buildTodaySnapshot(
    KhatmaPlanRecord plan, {
    DateTime? now,
  });
  KhatmaStatsSnapshot buildStats(KhatmaPlanRecord plan, {DateTime? now});
  Future<void> sendTestNotification();
}

class LocalKhatmaRepository implements KhatmaRepository {
  LocalKhatmaRepository({
    Box<dynamic>? userBox,
    KhatmaReminderScheduler? reminderScheduler,
  }) : _box = userBox ?? Hive.box<dynamic>("user"),
       _reminderScheduler = reminderScheduler ?? LocalKhatmaReminderScheduler();

  static const int _lastPage = 604;

  static const String _activePlanKey = "khatma_v2_active_plan";
  static const String _archiveKey = "khatma_v2_archive";
  static const String _migratedKey = "khatma_v2_migrated";

  static const String _legacyEnabledKey = "smart_khatma_enabled";
  static const String _legacyPlanDaysKey = "smart_khatma_plan_days";
  static const String _legacyCurrentDayIndexKey =
      "smart_khatma_current_day_index";
  static const String _legacyStartedAtKey = "smart_khatma_started_at";
  static const String _legacyReminderEnabledKey =
      "wahy_khatma_reminder_enabled";
  static const String _legacyReminderTimeKey = "wahy_khatma_reminder_time";

  final Box<dynamic> _box;
  final KhatmaReminderScheduler _reminderScheduler;

  @override
  Future<void> ensureMigrated() async {
    if (_box.get(_migratedKey, defaultValue: false) == true) {
      return;
    }

    if (_box.get(_activePlanKey) != null || _box.get(_archiveKey) != null) {
      await _box.put(_migratedKey, true);
      return;
    }

    final legacyEnabled =
        _box.get(_legacyEnabledKey, defaultValue: false) == true;
    if (!legacyEnabled) {
      await _box.put(_migratedKey, true);
      return;
    }

    final days = (_box.get(_legacyPlanDaysKey, defaultValue: 30) as int?) ?? 30;
    final completedCount =
        (_box.get(_legacyCurrentDayIndexKey, defaultValue: 0) as int?) ?? 0;
    final startedAt =
        DateTime.tryParse(_box.get(_legacyStartedAtKey) as String? ?? "") ??
        DateTime.now();
    final reminder = _readLegacyReminder();

    final assignments = _buildAssignments(
      days: days,
      startPage: 1,
      startedAt: _dateOnly(startedAt),
    );
    final migratedAssignments = assignments.asMap().entries.map((entry) {
      if (entry.key >= completedCount) return entry.value;
      return entry.value.copyWith(
        status: KhatmaDayStatus.completed,
        completedAt: _dateOnly(startedAt).add(Duration(days: entry.key)),
      );
    }).toList();

    final plan = KhatmaPlanRecord(
      id: "khatma_${startedAt.millisecondsSinceEpoch}",
      title: "الختمة السابقة",
      createdAt: startedAt,
      startedAt: _dateOnly(startedAt),
      startPage: 1,
      totalDays: days,
      isMigrated: true,
      reminder: reminder,
      assignments: migratedAssignments,
    );

    if (migratedAssignments.every((item) => item.isCompleted)) {
      await _archivePlan(plan, KhatmaArchiveStatus.completed, now: startedAt);
    } else {
      await _saveActivePlan(plan);
      await _syncReminderSettings(plan.reminder);
    }

    await _box.put(_migratedKey, true);
  }

  @override
  KhatmaPlanRecord? loadActivePlan() {
    final raw = _box.get(_activePlanKey);
    if (raw is! Map) return null;
    return KhatmaPlanRecord.fromMap(Map<String, dynamic>.from(raw));
  }

  @override
  List<KhatmaArchiveRecord> loadArchive() {
    final raw = _box.get(_archiveKey, defaultValue: const <dynamic>[]) as List?;
    return (raw ?? const <dynamic>[])
        .map(
          (item) => KhatmaArchiveRecord.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList()
      ..sort((a, b) => b.archivedAt.compareTo(a.archivedAt));
  }

  @override
  Future<void> createPlan({
    required int days,
    required int startPage,
    required String title,
    required KhatmaReminderSettings reminder,
    DateTime? startedAt,
  }) async {
    final current = loadActivePlan();
    if (current != null) {
      await _archivePlan(
        current,
        KhatmaArchiveStatus.cancelled,
        now: startedAt ?? DateTime.now(),
      );
    }

    final normalizedStartPage = startPage.clamp(1, _lastPage);
    final totalReadablePages = (_lastPage - normalizedStartPage) + 1;
    final normalizedDays = days.clamp(1, totalReadablePages);
    final startDate = _dateOnly(startedAt ?? DateTime.now());

    final plan = KhatmaPlanRecord(
      id: "khatma_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      createdAt: DateTime.now(),
      startedAt: startDate,
      startPage: normalizedStartPage,
      totalDays: normalizedDays,
      isMigrated: false,
      reminder: reminder,
      assignments: _buildAssignments(
        days: normalizedDays,
        startPage: normalizedStartPage,
        startedAt: startDate,
      ),
    );

    await _saveActivePlan(plan);
    await _syncReminderSettings(reminder);
    await _box.put(_migratedKey, true);
  }

  @override
  Future<void> updateReminder(KhatmaReminderSettings reminder) async {
    final active = loadActivePlan();
    if (active == null) return;
    final updated = active.copyWith(reminder: reminder);
    await _saveActivePlan(updated);
    await _syncReminderSettings(reminder);
  }

  @override
  Future<void> markTodayCompleted({DateTime? now}) async {
    final active = loadActivePlan();
    if (active == null) return;
    final today = buildTodaySnapshot(active, now: now);
    final scheduled = today.scheduledAssignment;
    if (scheduled == null || scheduled.isCompleted) return;
    await _updateAssignment(
      active,
      scheduled.dayNumber,
      status: KhatmaDayStatus.completed,
      completedAt: now ?? DateTime.now(),
    );
  }

  @override
  Future<void> completeNextOverdueDay({DateTime? now}) async {
    final active = loadActivePlan();
    if (active == null) return;
    final today = buildTodaySnapshot(active, now: now);
    if (today.overdueAssignments.isEmpty) return;
    final target = today.overdueAssignments.first;
    await _updateAssignment(
      active,
      target.dayNumber,
      status: KhatmaDayStatus.completed,
      completedAt: now ?? DateTime.now(),
    );
  }

  @override
  Future<void> deferToday({DateTime? now}) async {
    final active = loadActivePlan();
    if (active == null) return;
    final today = buildTodaySnapshot(active, now: now);
    final scheduled = today.scheduledAssignment;
    if (scheduled == null || scheduled.isCompleted) return;
    await _updateAssignment(
      active,
      scheduled.dayNumber,
      status: KhatmaDayStatus.deferred,
      clearCompletedAt: true,
    );
  }

  @override
  Future<void> cancelActivePlan({DateTime? now}) async {
    final active = loadActivePlan();
    if (active == null) return;
    await _archivePlan(
      active,
      KhatmaArchiveStatus.cancelled,
      now: now ?? DateTime.now(),
    );
  }

  @override
  KhatmaTodaySnapshot buildTodaySnapshot(
    KhatmaPlanRecord plan, {
    DateTime? now,
  }) {
    final currentDate = _dateOnly(now ?? DateTime.now());
    final scheduled = _scheduledAssignment(plan, currentDate);
    final overdue = plan.assignments
        .where(
          (assignment) =>
              _dateOnly(assignment.scheduledDate).isBefore(currentDate) &&
              !assignment.isCompleted,
        )
        .toList();
    final todayPages = scheduled != null && !scheduled.isCompleted
        ? scheduled.pageCount
        : 0;

    return KhatmaTodaySnapshot(
      scheduledAssignment: scheduled,
      overdueAssignments: overdue,
      completedToday: scheduled?.isCompleted ?? false,
      backlogPages: overdue.fold<int>(0, (sum, item) => sum + item.pageCount),
      todayPages: todayPages,
    );
  }

  @override
  KhatmaStatsSnapshot buildStats(KhatmaPlanRecord plan, {DateTime? now}) {
    final currentDate = _dateOnly(now ?? DateTime.now());
    final pagesRead = plan.assignments
        .where((item) => item.isCompleted)
        .fold<int>(0, (sum, item) => sum + item.pageCount);
    final completedDays = plan.assignments
        .where((item) => item.isCompleted)
        .length;
    final remainingDays = plan.totalDays - completedDays;
    final pagesRemaining = plan.totalPages - pagesRead;
    final elapsedDays = _elapsedDays(plan, currentDate);
    final averagePagesPerDay = completedDays == 0
        ? 0.0
        : pagesRead / completedDays;
    final progressPercent = plan.totalPages == 0
        ? 0.0
        : (pagesRead / plan.totalPages) * 100;
    final adherencePercent = elapsedDays == 0
        ? 0.0
        : (completedDays / elapsedDays).clamp(0, 1).toDouble() * 100;

    return KhatmaStatsSnapshot(
      capturedAt: currentDate,
      completedDays: completedDays,
      remainingDays: remainingDays,
      pagesRead: pagesRead,
      pagesRemaining: pagesRemaining,
      progressPercent: progressPercent,
      adherencePercent: adherencePercent,
      averagePagesPerDay: averagePagesPerDay,
      streak: _currentStreak(plan, currentDate),
      bestStreak: _bestStreak(plan),
      expectedCompletionDate: _expectedCompletionDate(
        plan: plan,
        currentDate: currentDate,
        pagesRead: pagesRead,
        completedDays: completedDays,
      ),
    );
  }

  @override
  Future<void> sendTestNotification() {
    return _reminderScheduler.sendTestNotification();
  }

  Future<void> _updateAssignment(
    KhatmaPlanRecord plan,
    int dayNumber, {
    required KhatmaDayStatus status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) async {
    final updatedAssignments = plan.assignments.map((assignment) {
      if (assignment.dayNumber != dayNumber) return assignment;
      return assignment.copyWith(
        status: status,
        completedAt: completedAt,
        clearCompletedAt: clearCompletedAt,
      );
    }).toList();
    final updatedPlan = plan.copyWith(assignments: updatedAssignments);
    if (updatedAssignments.every((item) => item.isCompleted)) {
      await _archivePlan(
        updatedPlan,
        KhatmaArchiveStatus.completed,
        now: completedAt ?? DateTime.now(),
      );
      return;
    }
    await _saveActivePlan(updatedPlan);
  }

  Future<void> _archivePlan(
    KhatmaPlanRecord plan,
    KhatmaArchiveStatus status, {
    required DateTime now,
  }) async {
    final archive = loadArchive();
    final stats = buildStats(plan, now: now);
    archive.insert(
      0,
      KhatmaArchiveRecord(
        id: "archive_${now.millisecondsSinceEpoch}",
        archivedAt: now,
        status: status,
        plan: plan,
        stats: stats,
      ),
    );
    await _box.put(_archiveKey, archive.map((item) => item.toMap()).toList());
    await _box.delete(_activePlanKey);
    await _syncReminderSettings(const KhatmaReminderSettings.disabled());
  }

  Future<void> _saveActivePlan(KhatmaPlanRecord plan) {
    return _box.put(_activePlanKey, plan.toMap());
  }

  List<KhatmaDayAssignment> _buildAssignments({
    required int days,
    required int startPage,
    required DateTime startedAt,
  }) {
    final totalPages = (_lastPage - startPage) + 1;
    final normalizedDays = days.clamp(1, totalPages);
    final basePages = totalPages ~/ normalizedDays;
    final remainder = totalPages % normalizedDays;
    var currentStart = startPage;
    final assignments = <KhatmaDayAssignment>[];

    for (var index = 0; index < normalizedDays; index++) {
      final pagesThisDay = basePages + (index < remainder ? 1 : 0);
      final currentEnd = currentStart + pagesThisDay - 1;
      assignments.add(
        KhatmaDayAssignment(
          dayNumber: index + 1,
          startPage: currentStart,
          endPage: currentEnd,
          scheduledDate: startedAt.add(Duration(days: index)),
          status: KhatmaDayStatus.pending,
        ),
      );
      currentStart = currentEnd + 1;
    }

    return assignments;
  }

  KhatmaReminderSettings _readLegacyReminder() {
    final enabled =
        _box.get(_legacyReminderEnabledKey, defaultValue: false) == true;
    final rawTime = _box.get(_legacyReminderTimeKey) as String?;
    final parts = rawTime?.split(":") ?? const <String>[];
    return KhatmaReminderSettings(
      enabled: enabled,
      hour: int.tryParse(parts.isNotEmpty ? parts[0] : "") ?? 7,
      minute: int.tryParse(parts.length > 1 ? parts[1] : "") ?? 0,
    );
  }

  Future<void> _syncReminderSettings(KhatmaReminderSettings settings) async {
    await _box.put(_legacyReminderEnabledKey, settings.enabled);
    await _box.put(
      _legacyReminderTimeKey,
      "${settings.hour.toString().padLeft(2, "0")}:${settings.minute.toString().padLeft(2, "0")}",
    );
    if (!settings.enabled) {
      await _reminderScheduler.cancel();
      return;
    }
    await _reminderScheduler.sync(settings);
  }

  KhatmaDayAssignment? _scheduledAssignment(
    KhatmaPlanRecord plan,
    DateTime currentDate,
  ) {
    final rawIndex = currentDate.difference(_dateOnly(plan.startedAt)).inDays;
    if (rawIndex < 0) return plan.assignments.first;
    final clampedIndex = rawIndex.clamp(0, plan.assignments.length - 1);
    return plan.assignments[clampedIndex];
  }

  int _elapsedDays(KhatmaPlanRecord plan, DateTime currentDate) {
    final raw = currentDate.difference(_dateOnly(plan.startedAt)).inDays + 1;
    return raw.clamp(0, plan.totalDays);
  }

  int _currentStreak(KhatmaPlanRecord plan, DateTime currentDate) {
    final scheduled = _scheduledAssignment(plan, currentDate);
    if (scheduled == null || !scheduled.isCompleted) return 0;
    var streak = 0;
    for (var index = scheduled.dayNumber - 1; index >= 0; index--) {
      if (plan.assignments[index].isCompleted) {
        streak++;
        continue;
      }
      break;
    }
    return streak;
  }

  int _bestStreak(KhatmaPlanRecord plan) {
    var best = 0;
    var current = 0;
    for (final assignment in plan.assignments) {
      if (assignment.isCompleted) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  DateTime _expectedCompletionDate({
    required KhatmaPlanRecord plan,
    required DateTime currentDate,
    required int pagesRead,
    required int completedDays,
  }) {
    final pagesRemaining = plan.totalPages - pagesRead;
    if (pagesRemaining <= 0) return currentDate;
    if (completedDays == 0 || pagesRead == 0) {
      return _dateOnly(plan.startedAt).add(Duration(days: plan.totalDays - 1));
    }
    final avg = pagesRead / completedDays;
    final daysNeeded = (pagesRemaining / avg).ceil();
    return currentDate.add(Duration(days: daysNeeded - 1));
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
