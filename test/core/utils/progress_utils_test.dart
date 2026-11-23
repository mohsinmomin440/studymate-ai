// Unit tests for progress utilities
// Tests: dailyStatsKey, todayOnly, calculateLevel, xpForLevel, etc.

import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/core/utils/progress_utils.dart';

void main() {
  group('dailyStatsKey', () {
    test('returns correct format for given date', () {
      final date = DateTime(2024, 6, 15);
      expect(dailyStatsKey(date), equals('2024-06-15'));
    });

    test('pads single digit month and day', () {
      final date = DateTime(2024, 1, 5);
      expect(dailyStatsKey(date), equals('2024-01-05'));
    });

    test('pads single digit day', () {
      final date = DateTime(2024, 12, 3);
      expect(dailyStatsKey(date), equals('2024-12-03'));
    });

    test('pads single digit month', () {
      final date = DateTime(2024, 3, 15);
      expect(dailyStatsKey(date), equals('2024-03-15'));
    });

    test('handles year boundary correctly', () {
      final date = DateTime(2025, 1, 1);
      expect(dailyStatsKey(date), equals('2025-01-01'));
    });

    test('handles leap year date', () {
      final date = DateTime(2024, 2, 29);
      expect(dailyStatsKey(date), equals('2024-02-29'));
    });
  });

  group('todayOnly', () {
    test('strips time component to midnight', () {
      final date = DateTime(2024, 6, 15, 14, 30, 45);
      final result = todayOnly(date);
      expect(result, equals(DateTime(2024, 6, 15, 0, 0, 0)));
    });

    test('keeps midnight as is', () {
      final date = DateTime(2024, 6, 15, 0, 0, 0);
      final result = todayOnly(date);
      expect(result, equals(DateTime(2024, 6, 15, 0, 0, 0)));
    });

    test('handles year boundary', () {
      final date = DateTime(2025, 1, 1, 23, 59, 59);
      final result = todayOnly(date);
      expect(result, equals(DateTime(2025, 1, 1, 0, 0, 0)));
    });
  });

  group('xpForLevel', () {
    test('level 1 returns 0', () {
      expect(xpForLevel(1), equals(0));
    });

    test('level 2 returns 100', () {
      expect(xpForLevel(2), equals(100));
    });

    test('level 3 returns 250', () {
      expect(xpForLevel(3), equals(250));
    });
  });

  group('calculateLevel', () {
    test('0 XP returns level 1', () {
      expect(calculateLevel(0), equals(1));
    });

    test('99 XP returns level 1', () {
      expect(calculateLevel(99), equals(1));
    });

    test('100 XP returns level 2', () {
      expect(calculateLevel(100), equals(2));
    });

    test('250 XP returns level 3', () {
      expect(calculateLevel(250), equals(3));
    });
  });

  group('calculateXpProgress', () {
    test('returns 0.0 for 0 XP', () {
      expect(calculateXpProgress(0), equals(0.0));
    });

    test('returns 0.5 for halfway through level 2', () {
      // Level 2: 100-249 XP, halfway = 175 XP
      // (175 - 100) / (250 - 100) = 75 / 150 = 0.5
      expect(calculateXpProgress(175), closeTo(0.5, 0.01));
    });

    test('returns 0.0 at level boundary (start of next level)', () {
      // At exactly 250 XP, you're at the start of level 3, progress = 0.0
      expect(calculateXpProgress(250), equals(0.0));
    });

    test('returns close to 1.0 just before level boundary', () {
      // Just before level 3: 249 XP
      // (249 - 100) / (250 - 100) = 149 / 150 ≈ 0.993
      expect(calculateXpProgress(249), closeTo(0.993, 0.01));
    });
  });
}
