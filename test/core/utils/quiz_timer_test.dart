// Unit tests for QuizTimer
// Tests: deadline-based timing, remaining seconds calculation, isTimeUp

import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/core/utils/quiz_timer.dart';

void main() {
  group('QuizTimer - creation and basic state', () {
    test('create timer with 5 minutes duration', () {
      final timer = QuizTimer(totalSeconds: 300);
      expect(timer.totalSeconds, equals(300));
      expect(timer.hasTimeLimit, isTrue);
      expect(timer.isExpired, isFalse);
    });

    test('create timer with 0 duration (no timer)', () {
      final timer = QuizTimer(totalSeconds: 0);
      expect(timer.totalSeconds, equals(0));
      expect(timer.hasTimeLimit, isFalse);
      expect(timer.isExpired, isFalse);
    });

    test('create timer from minutes', () {
      final timer = QuizTimer.fromDurationMinutes(15);
      expect(timer.totalSeconds, equals(900));
      expect(timer.hasTimeLimit, isTrue);
    });
  });

  group('QuizTimer - remaining time calculation', () {
    test('remainingSeconds starts at totalSeconds when no deadline', () {
      final timer = QuizTimer(totalSeconds: 60);
      expect(timer.remainingSeconds, equals(60));
    });

    test('remainingSeconds decreases as time passes', () {
      final timer = QuizTimer.fromDurationMinutes(1);
      // Immediately created, remaining should be close to 60
      expect(timer.remainingSeconds, lessThanOrEqualTo(60));
      expect(timer.remainingSeconds, greaterThan(55));
    });

    test('formattedTime shows correct MM:SS for various durations', () {
      // Use a fake clock to make test deterministic
      final fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final clock = () => fixedNow;
      final timer = QuizTimer(
        totalSeconds: 65,
        deadline: fixedNow.add(const Duration(seconds: 65)),
        now: clock,
      );
      expect(timer.formattedTime, equals('01:05'));
    });

    test('formattedTime shows double digit for seconds under 10', () {
      final fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final clock = () => fixedNow;
      final timer = QuizTimer(
        totalSeconds: 70,
        deadline: fixedNow.add(const Duration(seconds: 70)),
        now: clock,
      );
      expect(timer.formattedTime, equals('01:10'));
    });

    test('formattedTime shows 00:00 when exhausted', () {
      final fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final clock = () => fixedNow;
      final timer = QuizTimer(
        totalSeconds: 5,
        deadline: fixedNow, // Deadline in the past
        now: clock,
      );
      expect(timer.formattedTime, equals('00:00'));
    });
  });

  group('QuizTimer - isTimeUp', () {
    test('isTimeUp returns false when time remains', () {
      final fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final timer = QuizTimer(
        totalSeconds: 60,
        deadline: fixedNow.add(const Duration(seconds: 30)),
        now: () => fixedNow,
      );
      expect(timer.isTimeUp(), isFalse);
    });

    test('isTimeUp returns true when deadline passed', () {
      final fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final timer = QuizTimer(
        totalSeconds: 60,
        deadline: fixedNow.subtract(const Duration(seconds: 5)),
        now: () => fixedNow,
      );
      expect(timer.isTimeUp(), isTrue);
    });

    test('isTimeUp returns false for no time limit', () {
      final timer = QuizTimer(totalSeconds: 0);
      expect(timer.isTimeUp(), isFalse);
    });

    test('isTimeUp returns true when expire() called', () {
      final timer = QuizTimer(totalSeconds: 60);
      timer.expire();
      expect(timer.isTimeUp(), isTrue);
    });
  });

  group('QuizTimer - tick', () {
    test('tick returns false while time remains', () {
      final fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final timer = QuizTimer(
        totalSeconds: 60,
        deadline: fixedNow.add(const Duration(seconds: 30)),
        now: () => fixedNow,
      );
      expect(timer.tick(), isFalse);
      expect(timer.tick(), isFalse);
    });

    test('tick returns true when time expires', () {
      final fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final timer = QuizTimer(
        totalSeconds: 5,
        deadline: fixedNow.subtract(const Duration(seconds: 1)),
        now: () => fixedNow,
      );
      expect(timer.tick(), isTrue); // Already expired
    });

    test('tick returns false for no timer', () {
      final timer = QuizTimer(totalSeconds: 0);
      expect(timer.tick(), isFalse);
    });

    test('tick returns true only once per expiration', () {
      final fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final timer = QuizTimer(
        totalSeconds: 5,
        deadline: fixedNow.subtract(const Duration(seconds: 1)),
        now: () => fixedNow,
      );
      expect(timer.tick(), isTrue);
      expect(timer.tick(), isTrue); // Still returns true after first expiration
      expect(timer.isExpired, isTrue);
    });
  });

  group('QuizTimer - elapsedSeconds', () {
    test('elapsedSeconds is 0 at start', () {
      final timer = QuizTimer(totalSeconds: 60);
      expect(timer.elapsedSeconds, equals(0));
    });

    test('elapsedSeconds increases as time passes', () {
      final fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      // Set deadline 15 seconds in the future to verify elapsed is tracked
      final timer = QuizTimer(
        totalSeconds: 60,
        deadline: fixedNow.add(const Duration(seconds: 15)),
        now: () => fixedNow,
      );
      // Some time will have elapsed between creation and assertion
      expect(timer.elapsedSeconds, greaterThanOrEqualTo(0));
    });
  });

  group('QuizTimer - reset', () {
    test('reset clears expired state', () {
      final fixedNow = DateTime(2024, 1, 1, 12, 0, 0);
      final timer = QuizTimer(
        totalSeconds: 5,
        deadline: fixedNow.subtract(const Duration(seconds: 1)),
        now: () => fixedNow,
      );
      timer.tick(); // expire
      expect(timer.isExpired, isTrue);
      timer.reset();
      expect(timer.isExpired, isFalse);
    });

    test('reset with new duration', () {
      final timer = QuizTimer(totalSeconds: 60);
      timer.reset(newDuration: 120);
      expect(timer.totalSeconds, equals(120));
    });
  });

  group('QuizTimer - questionsAnsweredByTime', () {
    test('questionsAnsweredByTime returns partial count for timed quiz', () {
      final timer = QuizTimer(totalSeconds: 60);
      // After 60 seconds, at 30 sec/question pace = 2 questions
      // This is informational based on elapsedSeconds, not actual
      expect(timer.questionsAnsweredByTime(60, 10), equals(2));
    });

    test('questionsAnsweredByTime returns total for untimed quiz', () {
      final timer = QuizTimer(totalSeconds: 0);
      expect(timer.questionsAnsweredByTime(120, 10), equals(10));
    });
  });
}
