import 'package:al_furkan/src/core/storage/app_boxes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBoxes', () {
    test('user box name is correct', () {
      expect(AppBoxes.user, 'user');
    });

    test('pinned box name is correct', () {
      expect(AppBoxes.pinned, 'pinned');
    });

    test('notes box name is correct', () {
      expect(AppBoxes.notes, 'notes');
    });

    test('readingStats box name is correct', () {
      expect(AppBoxes.readingStats, 'reading_stats');
    });

    test('all box names are non-empty strings', () {
      final names = [AppBoxes.user, AppBoxes.pinned, AppBoxes.notes, AppBoxes.readingStats];
      for (final name in names) {
        expect(name, isNotEmpty);
        expect(name, isA<String>());
      }
    });

    test('all box names are unique', () {
      final names = [AppBoxes.user, AppBoxes.pinned, AppBoxes.notes, AppBoxes.readingStats];
      expect(names.toSet().length, names.length);
    });
  });
}
