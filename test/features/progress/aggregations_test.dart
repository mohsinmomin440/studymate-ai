// Unit tests for aggregation functions

import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/features/progress/domain/aggregations.dart';
import 'package:studymate_ai/features/progress/data/progress_repository.dart';
import 'package:studymate_ai/features/planner/domain/planner_models.dart';

void main() {
  group('getTimeOfDayGreeting', () {
    test('returns morning greeting before 12', () {
      // We can't easily test time-dependent function without mocking clock
      // This is a basic smoke test
      final result = getTimeOfDayGreeting('Alice');
      expect(result, isNotEmpty);
      expect(result, contains('Alice'));
    });

    test('returns greeting without name when empty', () {
      final result = getTimeOfDayGreeting('');
      expect(result, isNotEmpty);
      expect(result, isNot(contains(',')));
    });
  });

  group('aggregateWeeklyStats', () {
    test('empty list returns empty aggregation', () {
      final result = aggregateWeeklyStats([]);
      expect(result.dailyStats, isEmpty);
      expect(result.totalStudyMinutes, equals(0));
      expect(result.totalXpEarned, equals(0));
      expect(result.avgQuizScore, equals(0.0));
    });

    test('aggregates study minutes and XP correctly', () {
      final stats = [
        WeeklyStat(
            date: DateTime(2024, 1, 1),
            studyMinutes: 30,
            xpEarned: 50,
            quizScore: 0),
        WeeklyStat(
            date: DateTime(2024, 1, 2),
            studyMinutes: 45,
            xpEarned: 75,
            quizScore: 80),
        WeeklyStat(
            date: DateTime(2024, 1, 3),
            studyMinutes: 0,
            xpEarned: 0,
            quizScore: 0),
        WeeklyStat(
            date: DateTime(2024, 1, 4),
            studyMinutes: 60,
            xpEarned: 100,
            quizScore: 90),
      ];

      final result = aggregateWeeklyStats(stats);
      expect(result.totalStudyMinutes, equals(135));
      expect(result.totalXpEarned, equals(225));
      expect(result.avgQuizScore, equals(85.0)); // (80 + 90) / 2
    });

    test('ignores zero quiz scores in average', () {
      final stats = [
        WeeklyStat(
            date: DateTime(2024, 1, 1),
            studyMinutes: 30,
            xpEarned: 50,
            quizScore: 0),
        WeeklyStat(
            date: DateTime(2024, 1, 2),
            studyMinutes: 45,
            xpEarned: 75,
            quizScore: 100),
      ];

      final result = aggregateWeeklyStats(stats);
      expect(result.avgQuizScore, equals(100.0));
    });
  });

  group('calculateSubjectStrength', () {
    test('empty attempts returns empty list', () {
      final result = calculateSubjectStrength([]);
      expect(result, isEmpty);
    });

    test('calculates accuracy per subject', () {
      final attempts = [
        QuizAttempt(
          id: '1',
          quizId: 'q1',
          title: 'Math Quiz',
          subject: 'Math',
          score: 8,
          total: 10,
          answers: [
            QuizAnswerData(question: '1+1', subject: 'Math', correct: true),
            QuizAnswerData(question: '2+2', subject: 'Math', correct: true),
            QuizAnswerData(question: '3+3', subject: 'Math', correct: false),
          ],
          durationSec: 60,
          createdAt: DateTime.now(),
        ),
        QuizAttempt(
          id: '2',
          quizId: 'q2',
          title: 'Science Quiz',
          subject: 'Science',
          score: 5,
          total: 10,
          answers: [
            QuizAnswerData(question: 'H2O', subject: 'Science', correct: true),
            QuizAnswerData(question: 'CO2', subject: 'Science', correct: false),
          ],
          durationSec: 60,
          createdAt: DateTime.now(),
        ),
      ];

      final result = calculateSubjectStrength(attempts);
      expect(result.length, equals(2));

      // Math: 2/3 = 0.667
      // Science: 1/2 = 0.5
      expect(result[0].subject, equals('Math'));
      expect(result[0].accuracy, closeTo(0.667, 0.001));
      expect(result[1].subject, equals('Science'));
      expect(result[1].accuracy, closeTo(0.5, 0.001));
    });

    test('sorts by accuracy descending', () {
      final attempts = [
        QuizAttempt(
          id: '1',
          quizId: 'q1',
          title: 'Low Score',
          subject: 'Low',
          score: 1,
          total: 10,
          answers: [
            QuizAnswerData(question: 'q1', subject: 'Low', correct: true),
            QuizAnswerData(question: 'q2', subject: 'Low', correct: false),
          ],
          durationSec: 60,
          createdAt: DateTime.now(),
        ),
        QuizAttempt(
          id: '2',
          quizId: 'q2',
          title: 'High Score',
          subject: 'High',
          score: 10,
          total: 10,
          answers: [
            QuizAnswerData(question: 'q1', subject: 'High', correct: true),
            QuizAnswerData(question: 'q2', subject: 'High', correct: true),
          ],
          durationSec: 60,
          createdAt: DateTime.now(),
        ),
      ];

      final result = calculateSubjectStrength(attempts);
      expect(result[0].subject, equals('High'));
      expect(result[1].subject, equals('Low'));
    });
  });

  group('calculateWeeklySummary', () {
    test('empty stats returns empty summary', () {
      final result = calculateWeeklySummary([], 0);
      expect(result.studyDays, equals(0));
      expect(result.totalMinutes, equals(0));
      expect(result.xpEarned, equals(0));
      expect(result.message, contains('Start studying'));
    });

    test('counts study days correctly', () {
      final stats = [
        WeeklyStat(
            date: DateTime(2024, 1, 1),
            studyMinutes: 30,
            xpEarned: 50,
            quizScore: 0),
        WeeklyStat(
            date: DateTime(2024, 1, 2),
            studyMinutes: 0,
            xpEarned: 0,
            quizScore: 0),
        WeeklyStat(
            date: DateTime(2024, 1, 3),
            studyMinutes: 45,
            xpEarned: 75,
            quizScore: 0),
        WeeklyStat(
            date: DateTime(2024, 1, 4),
            studyMinutes: 0,
            xpEarned: 0,
            quizScore: 0),
        WeeklyStat(
            date: DateTime(2024, 1, 5),
            studyMinutes: 60,
            xpEarned: 100,
            quizScore: 0),
        WeeklyStat(
            date: DateTime(2024, 1, 6),
            studyMinutes: 0,
            xpEarned: 0,
            quizScore: 0),
        WeeklyStat(
            date: DateTime(2024, 1, 7),
            studyMinutes: 0,
            xpEarned: 0,
            quizScore: 0),
      ];

      final result = calculateWeeklySummary(stats, 3);
      expect(result.studyDays, equals(3));
      expect(result.totalMinutes, equals(135));
      expect(result.xpEarned, equals(225));
      expect(result.currentStreak, equals(3));
    });

    test('message for perfect week (7 days)', () {
      final stats = List.generate(
          7,
          (i) => WeeklyStat(
                date: DateTime(2024, 1, i + 1),
                studyMinutes: 30,
                xpEarned: 50,
                quizScore: 0,
              ));

      final result = calculateWeeklySummary(stats, 7);
      expect(result.message, contains('Perfect week'));
    });

    test('message for 5-6 days', () {
      final stats = List.generate(
          5,
          (i) => WeeklyStat(
                date: DateTime(2024, 1, i + 1),
                studyMinutes: 30,
                xpEarned: 50,
                quizScore: 0,
              ));
      stats.addAll([
        WeeklyStat(
            date: DateTime(2024, 1, 6),
            studyMinutes: 0,
            xpEarned: 0,
            quizScore: 0),
        WeeklyStat(
            date: DateTime(2024, 1, 7),
            studyMinutes: 0,
            xpEarned: 0,
            quizScore: 0),
      ]);

      final result = calculateWeeklySummary(stats, 5);
      expect(result.message, contains('consistency'));
    });
  });

  group('getTodaysTasks', () {
    test('returns empty for empty plans', () {
      final result = getTodaysTasks([]);
      expect(result, isEmpty);
    });

    test('filters tasks for today', () {
      final today = DateTime.now();

      final plans = [
        StudyPlan(
          id: 'plan1',
          title: 'Test Plan',
          examDate: today.add(const Duration(days: 30)),
          subjects: ['Math'],
          hoursPerDay: 2,
          weakTopics: [],
          createdAt: DateTime.now(),
          days: [
            StudyDay(
              date: today,
              tasks: [
                StudyTask(
                  title: 'Task 1',
                  subject: 'Math',
                  estimatedMinutes: 30,
                  type: 'study',
                  done: false,
                ),
                StudyTask(
                  title: 'Task 2',
                  subject: 'Math',
                  estimatedMinutes: 45,
                  type: 'review',
                  done: true,
                ),
              ],
            ),
            StudyDay(
              date: DateTime(today.year, today.month, today.day + 1),
              tasks: [
                StudyTask(
                  title: 'Tomorrow Task',
                  subject: 'Science',
                  estimatedMinutes: 20,
                  type: 'practice',
                  done: false,
                ),
              ],
            ),
          ],
        ),
      ];

      final result = getTodaysTasks(plans);
      expect(result.length, equals(2));
      expect(result[0].title, equals('Task 1'));
      expect(result[0].done, isFalse);
      expect(result[1].title, equals('Task 2'));
      expect(result[1].done, isTrue);
    });
  });
}
