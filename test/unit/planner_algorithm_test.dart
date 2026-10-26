import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/core/constants/app_constants.dart';
import 'package:studymate_ai/features/planner/domain/planner_algorithm.dart';
import 'package:studymate_ai/features/subjects/domain/subject.dart';
import 'package:studymate_ai/features/tasks/domain/task.dart';

void main() {
  group('StudyPlannerAlgorithm Unit Tests', () {
    final now = DateTime(2026, 11, 24);

    final subjects = [
      Subject(
        id: 'sub_ds',
        name: 'Data Structures',
        difficulty: 4,
        examAt: now.add(const Duration(days: 5)), // Urgent
        createdAt: now,
        updatedAt: now,
      ),
      Subject(
        id: 'sub_cn',
        name: 'Computer Networks',
        difficulty: 2,
        examAt: now.add(const Duration(days: 40)), // Not urgent
        createdAt: now,
        updatedAt: now,
      ),
    ];

    final urgentTask = TaskItem(
      id: 'task_urgent',
      title: 'Revise Trees',
      subjectId: 'sub_ds',
      priority: AppConstants.priorityHigh,
      difficulty: 4,
      dueAt: now.add(const Duration(days: 2)),
      createdAt: now,
      updatedAt: now,
    );

    final lowPriorityTask = TaskItem(
      id: 'task_low',
      title: 'Read Network History',
      subjectId: 'sub_cn',
      priority: AppConstants.priorityLow,
      difficulty: 2,
      dueAt: now.add(const Duration(days: 30)),
      createdAt: now,
      updatedAt: now,
    );

    test('generateSchedule prioritizes urgent and high priority tasks', () {
      final sessions = StudyPlannerAlgorithm.generateSchedule(
        tasks: [lowPriorityTask, urgentTask],
        subjects: subjects,
        weekStartDate: now,
        dailyStudyMinutes: 180,
      );

      expect(sessions.isNotEmpty, isTrue);
      // First session scheduled should be the high priority/urgent task
      expect(sessions.first.taskId, equals('task_urgent'));
      expect(sessions.first.subjectName, equals('Data Structures'));
    });

    test('generateSchedule returns empty list when all tasks are completed', () {
      final completedTask = urgentTask.copyWith(status: AppConstants.statusCompleted);
      final sessions = StudyPlannerAlgorithm.generateSchedule(
        tasks: [completedTask],
        subjects: subjects,
        weekStartDate: now,
        dailyStudyMinutes: 180,
      );

      expect(sessions.isEmpty, isTrue);
    });

    test('generateSchedule respects daily allocated minutes limit', () {
      final sessions = StudyPlannerAlgorithm.generateSchedule(
        tasks: [urgentTask, lowPriorityTask],
        subjects: subjects,
        weekStartDate: now,
        dailyStudyMinutes: 150,
      );

      // Group sessions by day
      final daySessions = sessions.where((s) =>
          s.startTime.year == now.year &&
          s.startTime.month == now.month &&
          s.startTime.day == now.day);

      int totalMinutes = 0;
      for (var s in daySessions) {
        totalMinutes += s.endTime.difference(s.startTime).inMinutes;
      }

      // Slot 1 is 90 mins. Slot 2 is 90 mins (total 180 > 150), so only 1 session fits
      expect(daySessions.length, equals(1));
      expect(totalMinutes, equals(90));
    });
  });
}
