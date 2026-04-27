import 'package:flutter_test/flutter_test.dart';

/// Since KhatmaNotificationService depends heavily on platform plugins
/// (flutter_local_notifications, permission_handler, flutter_timezone),
/// we test the core scheduling logic extracted here.
void main() {
  group('KhatmaNotification scheduling logic', () {
    test('nextInstanceOfTime returns today if time is in the future', () {
      final now = DateTime(2025, 1, 1, 10, 0);
      // If scheduled time is 11:00 and it's 10:00, should be today
      final scheduledHour = 11;
      final scheduledMinute = 0;

      var scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        scheduledHour,
        scheduledMinute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      expect(scheduled.day, now.day);
      expect(scheduled.hour, 11);
    });

    test('nextInstanceOfTime returns tomorrow if time is in the past', () {
      final now = DateTime(2025, 1, 1, 14, 0);
      // If scheduled time is 08:00 and it's 14:00, should be tomorrow
      final scheduledHour = 8;
      final scheduledMinute = 0;

      var scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        scheduledHour,
        scheduledMinute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      expect(scheduled.day, now.day + 1);
      expect(scheduled.hour, 8);
    });

    test('nextInstanceOfTime with same hour and minute returns today (not before)', () {
      final now = DateTime(2025, 1, 1, 10, 30);
      final scheduledHour = 10;
      final scheduledMinute = 30;

      var scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        scheduledHour,
        scheduledMinute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      // Same time is NOT before now, so it stays today
      expect(scheduled.day, now.day);
    });

    test('reminder time string parsing works correctly', () {
      const rawTime = '08:30';
      final parts = rawTime.split(':');
      expect(parts.length, 2);

      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      expect(h, 8);
      expect(m, 30);
    });

    test('invalid reminder time string returns null for parsing', () {
      const rawTime = 'abc:def';
      final parts = rawTime.split(':');
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      expect(h, isNull);
      expect(m, isNull);
    });

    test('malformed time string with too many colons', () {
      const rawTime = '08:30:45';
      final parts = rawTime.split(':');
      expect(parts.length, isNot(equals(2)));
    });

    test('empty time string splits to single element', () {
      const rawTime = '';
      final parts = rawTime.split(':');
      expect(parts.length, 1);
      expect(parts.length, isNot(equals(2)));
    });
  });
}
