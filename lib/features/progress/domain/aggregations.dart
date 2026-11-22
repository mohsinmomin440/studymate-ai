// Pure Dart aggregation functions for Home dashboard and ProgressScreen
// No Firebase, no Flutter imports

import 'package:studymate_ai/features/progress/data/progress_repository.dart';
import 'package:studymate_ai/features/planner/domain/planner_models.dart';

/// Aggregated data for Home dashboard
class HomeDashboardData {
  final int streak;
  final int xp;
  final int level;
  final double xpProgress;
  final int dailyGoalMin;
  final int todayStudyMinutes;
  final int todayXpEarned;
  final int cardsDueToday;
  final List<PlannedTask> todayTasks;
  final String greeting;

  HomeDashboardData({
    required this.streak,
    required this.xp,
    required this.level,
    required this.xpProgress,
    required this.dailyGoalMin,
    required this.todayStudyMinutes,
    required this.todayXpEarned,
    required this.cardsDueToday,
    required this.todayTasks,
    required this.greeting,
  });

  factory HomeDashboardData.empty() {
    return HomeDashboardData(
      streak: 0,
      xp: 0,
      level: 1,
      xpProgress: 0.0,
      dailyGoalMin: 60,
      todayStudyMinutes: 0,
      todayXpEarned: 0,
      cardsDueToday: 0,
      todayTasks: [],
      greeting: '',
    );
  }
}

/// A planned task for today
class PlannedTask {
  final String id;
  final String title;
  final bool done;
  final String planId;

  const PlannedTask({
    required this.id,
    required this.title,
    required this.done,
    required this.planId,
  });
}

/// Weekly aggregated stats for charts
class AggregatedWeeklyStats {
  final List<WeeklyStat> dailyStats;
  final int totalStudyMinutes;
  final int totalXpEarned;
  final double avgQuizScore;

  AggregatedWeeklyStats({
    required this.dailyStats,
    required this.totalStudyMinutes,
    required this.totalXpEarned,
    required this.avgQuizScore,
  });

  factory AggregatedWeeklyStats.empty() {
    return AggregatedWeeklyStats(
      dailyStats: [],
      totalStudyMinutes: 0,
      totalXpEarned: 0,
      avgQuizScore: 0.0,
    );
  }
}

/// Subject-wise strength from quiz attempts
class SubjectStrength {
  final String subject;
  final int totalQuestions;
  final int correctAnswers;
  final double accuracy;

  SubjectStrength({
    required this.subject,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.accuracy,
  });
}

/// Weekly summary card data
class WeeklySummary {
  final int studyDays;
  final int totalMinutes;
  final int quizzesTaken;
  final int cardsReviewed;
  final int xpEarned;
  final int currentStreak;
  final String message;

  WeeklySummary({
    required this.studyDays,
    required this.totalMinutes,
    required this.quizzesTaken,
    required this.cardsReviewed,
    required this.xpEarned,
    required this.currentStreak,
    required this.message,
  });

  factory WeeklySummary.empty() {
    return WeeklySummary(
      studyDays: 0,
      totalMinutes: 0,
      quizzesTaken: 0,
      cardsReviewed: 0,
      xpEarned: 0,
      currentStreak: 0,
      message: 'Start studying to see your weekly summary!',
    );
  }
}

/// Time-of-day greeting
String getTimeOfDayGreeting(String name) {
  final hour = DateTime.now().hour;
  String timeGreeting;
  if (hour < 12) {
    timeGreeting = 'Good morning';
  } else if (hour < 17) {
    timeGreeting = 'Good afternoon';
  } else {
    timeGreeting = 'Good evening';
  }
  return name.isNotEmpty ? '$timeGreeting, $name!' : '$timeGreeting!';
}

/// Aggregate weekly stats from dailyStats list
AggregatedWeeklyStats aggregateWeeklyStats(List<WeeklyStat> dailyStats) {
  if (dailyStats.isEmpty) return AggregatedWeeklyStats.empty();

  int totalMinutes = 0;
  int totalXp = 0;
  int quizScoreSum = 0;
  int quizDays = 0;

  for (final stat in dailyStats) {
    totalMinutes += stat.studyMinutes;
    totalXp += stat.xpEarned;
    if (stat.quizScore > 0) {
      quizScoreSum += stat.quizScore;
      quizDays++;
    }
  }

  return AggregatedWeeklyStats(
    dailyStats: dailyStats,
    totalStudyMinutes: totalMinutes,
    totalXpEarned: totalXp,
    avgQuizScore: quizDays > 0 ? quizScoreSum / quizDays : 0.0,
  );
}

/// Calculate subject-wise strength from quiz attempts
List<SubjectStrength> calculateSubjectStrength(List<QuizAttempt> attempts) {
  if (attempts.isEmpty) return [];

  final Map<String, _SubjectAccumulator> acc = {};

  for (final attempt in attempts) {
    final subject = attempt.subject;
    acc.putIfAbsent(subject, () => _SubjectAccumulator());

    for (final answer in attempt.answers) {
      acc[subject]!.total++;
      if (answer.correct) {
        acc[subject]!.correct++;
      }
    }
  }

  return acc.entries.map((e) {
    final a = e.value;
    return SubjectStrength(
      subject: e.key,
      totalQuestions: a.total,
      correctAnswers: a.correct,
      accuracy: a.total > 0 ? a.correct / a.total : 0.0,
    );
  }).toList()
    ..sort((a, b) => b.accuracy.compareTo(a.accuracy));
}

class _SubjectAccumulator {
  int total = 0;
  int correct = 0;
}

/// Calculate weekly summary from daily stats
WeeklySummary calculateWeeklySummary(
    List<WeeklyStat> dailyStats, int currentStreak) {
  if (dailyStats.isEmpty) return WeeklySummary.empty();

  int studyDays = 0;
  int totalMinutes = 0;
  int quizzesTaken = 0;
  int cardsReviewed = 0;
  int xpEarned = 0;

  for (final stat in dailyStats) {
    if (stat.studyMinutes > 0) studyDays++;
    totalMinutes += stat.studyMinutes;
    // Note: quiz and card counts need to come from dailyStats if we add those fields
    xpEarned += stat.xpEarned;
  }

  String message;
  if (studyDays == 7) {
    message = 'Perfect week! You studied every day! 🎉';
  } else if (studyDays >= 5) {
    message = 'Great consistency! $studyDays out of 7 days!';
  } else if (studyDays >= 3) {
    message = 'Good start! $studyDays days this week.';
  } else if (studyDays > 0) {
    message =
        'Keep going! $studyDays day${studyDays == 1 ? '' : 's'} this week.';
  } else {
    message = 'Start your study streak today!';
  }

  return WeeklySummary(
    studyDays: studyDays,
    totalMinutes: totalMinutes,
    quizzesTaken: quizzesTaken,
    cardsReviewed: cardsReviewed,
    xpEarned: xpEarned,
    currentStreak: currentStreak,
    message: message,
  );
}

/// Get today's tasks from active plans
List<PlannedTask> getTodaysTasks(List<StudyPlan> plans) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final tasks = <PlannedTask>[];

  for (final plan in plans) {
    try {
      final dayIndex = plan.days.indexWhere((d) {
        final dayDate = DateTime(d.date.year, d.date.month, d.date.day);
        return dayDate == today;
      });
      if (dayIndex != -1) {
        final day = plan.days[dayIndex];
        for (int i = 0; i < day.tasks.length; i++) {
          final task = day.tasks[i];
          tasks.add(PlannedTask(
            id: '${plan.id}_$dayIndex\\_$i',
            title: task.title,
            done: task.done,
            planId: plan.id,
          ));
        }
      }
    } catch (_) {
      // Skip malformed plans
    }
  }

  return tasks;
}
