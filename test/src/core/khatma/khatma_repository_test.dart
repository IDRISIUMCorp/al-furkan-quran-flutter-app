import "dart:io";

import "package:al_quran_v3/src/core/khatma/khatma_models.dart";
import "package:al_quran_v3/src/core/khatma/khatma_repository.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

class _FakeReminderScheduler implements KhatmaReminderScheduler {
  int syncCalls = 0;
  int cancelCalls = 0;
  int testNotificationCalls = 0;

  @override
  Future<void> cancel() async {
    cancelCalls++;
  }

  @override
  Future<void> sendTestNotification() async {
    testNotificationCalls++;
  }

  @override
  Future<void> sync(KhatmaReminderSettings settings) async {
    syncCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Box<dynamic> userBox;
  late _FakeReminderScheduler scheduler;
  late LocalKhatmaRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp("khatma_repo_test");
    Hive.init(tempDir.path);
    userBox = await Hive.openBox<dynamic>("user");
    scheduler = _FakeReminderScheduler();
    repository = LocalKhatmaRepository(
      userBox: userBox,
      reminderScheduler: scheduler,
    );
  });

  tearDown(() async {
    await userBox.deleteFromDisk();
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test("migrates legacy khatma keys into a v2 active plan", () async {
    await userBox.put("smart_khatma_enabled", true);
    await userBox.put("smart_khatma_plan_days", 10);
    await userBox.put("smart_khatma_current_day_index", 3);
    await userBox.put("smart_khatma_started_at", "2026-01-01T08:00:00.000");
    await userBox.put("wahy_khatma_reminder_enabled", true);
    await userBox.put("wahy_khatma_reminder_time", "06:30");

    await repository.ensureMigrated();

    final active = repository.loadActivePlan();
    expect(active, isNotNull);
    expect(active!.isMigrated, isTrue);
    expect(active.totalDays, 10);
    expect(active.reminder.enabled, isTrue);
    expect(active.reminder.hour, 6);
    expect(active.reminder.minute, 30);
    expect(active.assignments.where((item) => item.isCompleted).length, 3);
    expect(scheduler.syncCalls, 1);
  });

  test("archives the plan automatically when all days are completed", () async {
    await repository.createPlan(
      days: 2,
      startPage: 1,
      title: "خطة قصيرة",
      reminder: const KhatmaReminderSettings.disabled(),
      startedAt: DateTime(2026, 1, 1),
    );

    await repository.markTodayCompleted(now: DateTime(2026, 1, 1, 9));
    final activeAfterFirstDay = repository.loadActivePlan();
    expect(activeAfterFirstDay, isNotNull);

    final stats = repository.buildStats(
      activeAfterFirstDay!,
      now: DateTime(2026, 1, 1, 9),
    );
    expect(stats.completedDays, 1);
    expect(stats.pagesRead, activeAfterFirstDay.assignments.first.pageCount);

    await repository.markTodayCompleted(now: DateTime(2026, 1, 2, 9));

    expect(repository.loadActivePlan(), isNull);
    final archive = repository.loadArchive();
    expect(archive, isNotEmpty);
    expect(archive.first.status, KhatmaArchiveStatus.completed);
  });

  test(
    "today snapshot reports backlog and make-up clears one overdue day",
    () async {
      await repository.createPlan(
        days: 3,
        startPage: 1,
        title: "خطة المتابعة",
        reminder: const KhatmaReminderSettings.disabled(),
        startedAt: DateTime(2026, 1, 1),
      );

      final initial = repository.loadActivePlan()!;
      final snapshotBefore = repository.buildTodaySnapshot(
        initial,
        now: DateTime(2026, 1, 3, 12),
      );

      expect(snapshotBefore.overdueAssignments.length, 2);
      expect(
        snapshotBefore.backlogPages,
        initial.assignments[0].pageCount + initial.assignments[1].pageCount,
      );

      await repository.completeNextOverdueDay(now: DateTime(2026, 1, 3, 12));

      final updated = repository.loadActivePlan()!;
      final snapshotAfter = repository.buildTodaySnapshot(
        updated,
        now: DateTime(2026, 1, 3, 12),
      );

      expect(snapshotAfter.overdueAssignments.length, 1);
      expect(snapshotAfter.backlogPages, initial.assignments[1].pageCount);
    },
  );
}
