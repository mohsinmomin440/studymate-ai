// Unit tests for pure progress calculation functions
// Tests: first activity, same day twice, next day, missed day, year boundary, level thresholds, XP to next level

import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/features/progress/domain/progress_calculations.dart';

void main() {
  group('xpForAction', () {
    test('returns correct XP for known actions', () {
      expect(xpForAction('chat'), equals(5));
      expect(xpForAction('note'), equals(10));
      expect(xpForAction('quiz'), equals(25));
      expect(xpForAction('flashcard_review'), equals(2));
      expect(xpForAction('focus_minute'), equals(1));
    });

    test('returns 0 for unknown actions', () {
      expect(xpForAction('unknown'), equals(0));
      expect(xpForAction(''), equals(0));
    });
  });

  group('xpForLevel', () {
    test('level 1 returns 0', () {
      expect(xpForLevel(1), equals(0));
    });

    test('level 2 returns 100', () {
      expect(xpForLevel(2), equals(100));
    });

    test('level 3 returns 250 (100 + 150)', () {
      expect(xpForLevel(3), equals(250));
    });

    test('level 4 returns 475 (100 + 150 + 225)', () {
      expect(xpForLevel(4), equals(475));
    });

    test('level 5 returns 812 (100 + 150 + 225 + 337)', () {
      expect(xpForLevel(5), equals(812));
    });
  });

  group('levelFromXp', () {
    test('0 XP returns level 1', () {
      expect(levelFromXp(0), equals(1));
    });

    test('99 XP returns level 1', () {
      expect(levelFromXp(99), equals(1));
    });

    test('100 XP returns level 2', () {
      expect(levelFromXp(100), equals(2));
    });

    test('249 XP returns level 2', () {
      expect(levelFromXp(249), equals(2));
    });

    test('250 XP returns level 3', () {
      expect(levelFromXp(250), equals(3));
    });

    test('474 XP returns level 3', () {
      expect(levelFromXp(474), equals(3));
    });

    test('475 XP returns level 4', () {
      expect(levelFromXp(475), equals(4));
    });

    test('811 XP returns level 4', () {
      expect(levelFromXp(811), equals(4));
    });

    test('812 XP returns level 5', () {
      expect(levelFromXp(812), equals(5));
    });

    test('large XP works correctly', () {
      expect(levelFromXp(10000), greaterThan(1));
    });

    test('negative XP returns level 1', () {
      expect(levelFromXp(-100), equals(1));
    });
  });

  group('xpToNextLevel', () {
    test('0 XP needs 100 for next level', () {
      expect(xpToNextLevel(0), equals(100));
    });

    test('99 XP needs 1 for next level', () {
      expect(xpToNextLevel(99), equals(1));
    });

    test('100 XP (level 2) needs 150 for level 3', () {
      expect(xpToNextLevel(100), equals(150));
    });

    test('249 XP needs 1 for level 3', () {
      expect(xpToNextLevel(249), equals(1));
    });

    test('250 XP (level 3) needs 225 for level 4', () {
      expect(xpToNextLevel(250), equals(225));
    });

    test('474 XP needs 1 for level 4', () {
      expect(xpToNextLevel(474), equals(1));
    });

    test('475 XP (level 4) needs 337 for level 5', () {
      expect(xpToNextLevel(475), equals(337));
    });
  });

  group('shouldContinueStreak - calendar day comparison', () {
    test('same day returns true', () {
      final today = DateTime(2024, 6, 15);
      final lastStudy =
          DateTime(2024, 6, 15, 10, 30); // same day, different time
      expect(shouldContinueStreak(lastStudy, today), isTrue);
    });

    test('yesterday returns true', () {
      final today = DateTime(2024, 6, 15);
      final lastStudy = DateTime(2024, 6, 14, 20, 0); // yesterday
      expect(shouldContinueStreak(lastStudy, today), isTrue);
    });

    test('two days ago returns false', () {
      final today = DateTime(2024, 6, 15);
      final lastStudy = DateTime(2024, 6, 13);
      expect(shouldContinueStreak(lastStudy, today), isFalse);
    });

    test('three days ago returns false', () {
      final today = DateTime(2024, 6, 15);
      final lastStudy = DateTime(2024, 6, 12);
      expect(shouldContinueStreak(lastStudy, today), isFalse);
    });

    test('year boundary - Dec 31 to Jan 1 works', () {
      final today = DateTime(2025, 1, 1);
      final lastStudy =
          DateTime(2024, 12, 31); // yesterday across year boundary
      expect(shouldContinueStreak(lastStudy, today), isTrue);
    });

    test('year boundary - Dec 30 to Jan 1 fails', () {
      final today = DateTime(2025, 1, 1);
      final lastStudy = DateTime(2024, 12, 30); // two days ago
      expect(shouldContinueStreak(lastStudy, today), isFalse);
    });

    test('month boundary - Jan 31 to Feb 1 works', () {
      final today = DateTime(2024, 2, 1);
      final lastStudy = DateTime(2024, 1, 31); // yesterday
      expect(shouldContinueStreak(lastStudy, today), isTrue);
    });

    test('leap year - Feb 28 to Feb 29 works', () {
      final today = DateTime(2024, 2, 29);
      final lastStudy = DateTime(2024, 2, 28); // yesterday
      expect(shouldContinueStreak(lastStudy, today), isTrue);
    });

    test('different times on same day still continues streak', () {
      final today = DateTime(2024, 6, 15, 23, 59);
      final lastStudy = DateTime(2024, 6, 15, 0, 1); // early morning same day
      expect(shouldContinueStreak(lastStudy, today), isTrue);
    });
  });

  group('calculateStreak', () {
    test(
        'first ever activity (streak 0, no last study) - assumes first day = streak 1',
        () {
      // When there's no previous study, currentStreak=0 and we're adding today
      // The function will be called with currentStreak=0, and since lastStudyDate would be
      // a sentinel or we'd need a separate first-time check. Let's test with a very old date
      // that's treated as "no previous study" - but actually we should handle this differently.
      // The function as written needs a valid lastStudyDate. For first activity, we pass today.
      final today = DateTime(2024, 6, 15);
      expect(
          calculateStreak(currentStreak: 0, lastStudyDate: today, today: today),
          equals(1));
    });

    test('same day twice - streak unchanged', () {
      final today = DateTime(2024, 6, 15);
      // Already studied today (currentStreak = 5)
      expect(
          calculateStreak(currentStreak: 5, lastStudyDate: today, today: today),
          equals(5));
    });

    test('next day - streak increments by 1', () {
      final yesterday = DateTime(2024, 6, 14);
      final today = DateTime(2024, 6, 15);
      expect(
          calculateStreak(
              currentStreak: 5, lastStudyDate: yesterday, today: today),
          equals(6));
    });

    test('missed one day - resets to 1', () {
      final twoDaysAgo = DateTime(2024, 6, 13);
      final today = DateTime(2024, 6, 15);
      expect(
          calculateStreak(
              currentStreak: 10, lastStudyDate: twoDaysAgo, today: today),
          equals(1));
    });

    test('missed multiple days - resets to 1', () {
      final fiveDaysAgo = DateTime(2024, 6, 10);
      final today = DateTime(2024, 6, 15);
      expect(
          calculateStreak(
              currentStreak: 100, lastStudyDate: fiveDaysAgo, today: today),
          equals(1));
    });

    test('year boundary - Dec 31 to Jan 1 increments', () {
      final yesterday = DateTime(2024, 12, 31);
      final today = DateTime(2025, 1, 1);
      expect(
          calculateStreak(
              currentStreak: 30, lastStudyDate: yesterday, today: today),
          equals(31));
    });

    test('year boundary - Dec 30 to Jan 1 resets to 1', () {
      final twoDaysAgo = DateTime(2024, 12, 30);
      final today = DateTime(2025, 1, 1);
      expect(
          calculateStreak(
              currentStreak: 30, lastStudyDate: twoDaysAgo, today: today),
          equals(1));
    });

    test('leap year - Feb 28 to Feb 29 increments', () {
      final yesterday = DateTime(2024, 2, 28);
      final today = DateTime(2024, 2, 29);
      expect(
          calculateStreak(
              currentStreak: 5, lastStudyDate: yesterday, today: today),
          equals(6));
    });

    test('time of day does not matter - only calendar day', () {
      final yesterdayLate = DateTime(2024, 6, 14, 23, 59);
      final todayEarly = DateTime(2024, 6, 15, 0, 1);
      expect(
          calculateStreak(
              currentStreak: 3,
              lastStudyDate: yesterdayLate,
              today: todayEarly),
          equals(4));
    });

    test('streak of 1 yesterday becomes 2 today', () {
      final yesterday = DateTime(2024, 6, 14);
      final today = DateTime(2024, 6, 15);
      expect(
          calculateStreak(
              currentStreak: 1, lastStudyDate: yesterday, today: today),
          equals(2));
    });

    test('long streak continues correctly', () {
      final yesterday = DateTime(2024, 6, 14);
      final today = DateTime(2024, 6, 15);
      expect(
          calculateStreak(
              currentStreak: 365, lastStudyDate: yesterday, today: today),
          equals(366));
    });
  });
}
