import '../../subjects/domain/subject.dart';
import '../../tasks/domain/task.dart';

class ScheduledSession {
  final String id;
  final String taskId;
  final String taskTitle;
  final String subjectId;
  final String subjectName;
  final String colorHex;
  final String priority;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCompleted;

  const ScheduledSession({
    required this.id,
    required this.taskId,
    required this.taskTitle,
    required this.subjectId,
    required this.subjectName,
    required this.colorHex,
    required this.priority,
    required this.startTime,
    required this.endTime,
    this.isCompleted = false,
  });

  ScheduledSession copyWith({bool? isCompleted}) {
    return ScheduledSession(
      id: id,
      taskId: taskId,
      taskTitle: taskTitle,
      subjectId: subjectId,
      subjectName: subjectName,
      colorHex: colorHex,
      priority: priority,
      startTime: startTime,
      endTime: endTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class StudyPlannerAlgorithm {
  StudyPlannerAlgorithm._();

  /// Generates a prioritized weekly schedule based on:
  /// - Pending tasks
  /// - Subjects and upcoming exam dates
  /// - Urgency, priority weight, and difficulty weight
  /// - Daily study time limits
  static List<ScheduledSession> generateSchedule({
    required List<TaskItem> tasks,
    required List<Subject> subjects,
    required DateTime weekStartDate,
    int dailyStudyMinutes = 180,
  }) {
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    if (pendingTasks.isEmpty) return [];

    final subjectMap = {for (var s in subjects) s.id: s};

    // Calculate priority score for each task:
    // Score = (Urgency * 0.45) + (Priority * 0.35) + (Difficulty * 0.20)
    final scoredTasks = pendingTasks.map((task) {
      final subject = subjectMap[task.subjectId];
      final urgency = _calculateUrgency(task, subject);
      final priorityScore = _priorityValue(task.priority);
      final difficultyScore = task.difficulty.toDouble();

      final totalScore = (urgency * 0.45) + (priorityScore * 0.35) + (difficultyScore * 0.20);
      return MapEntry(task, totalScore);
    }).toList();

    // Sort descending by score
    scoredTasks.sort((a, b) => b.value.compareTo(a.value));

    final List<ScheduledSession> sessions = [];

    // Schedule across 7 days starting from weekStartDate
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final currentDay = weekStartDate.add(Duration(days: dayOffset));
      int allocatedMinutesToday = 0;

      // Available slots per day:
      // Slot 1: 09:00 - 10:30 (90 min)
      // Slot 2: 11:00 - 12:30 (90 min)
      // Slot 3: 14:00 - 15:30 (90 min)
      // Slot 4: 16:00 - 17:00 (60 min)
      final slotTemplates = [
        {'startH': 9, 'startM': 0, 'duration': 90},
        {'startH': 11, 'startM': 0, 'duration': 90},
        {'startH': 14, 'startM': 0, 'duration': 90},
        {'startH': 16, 'startM': 0, 'duration': 60},
      ];

      for (int slotIndex = 0; slotIndex < slotTemplates.length; slotIndex++) {
        final template = slotTemplates[slotIndex];
        final duration = template['duration'] as int;

        if (allocatedMinutesToday + duration > dailyStudyMinutes) break;

        final taskIndex = (dayOffset * 2 + slotIndex) % scoredTasks.length;
        final task = scoredTasks[taskIndex].key;
        final subject = subjectMap[task.subjectId];

        final startH = template['startH'] as int;
        final startM = template['startM'] as int;

        final sessionStart = DateTime(
          currentDay.year,
          currentDay.month,
          currentDay.day,
          startH,
          startM,
        );
        final sessionEnd = sessionStart.add(Duration(minutes: duration));

        sessions.add(
          ScheduledSession(
            id: 'session_${dayOffset}_$slotIndex',
            taskId: task.id,
            taskTitle: task.title,
            subjectId: task.subjectId,
            subjectName: subject?.name ?? 'General Revision',
            colorHex: subject?.colorHex ?? '#6750A4',
            priority: task.priority,
            startTime: sessionStart,
            endTime: sessionEnd,
            isCompleted: dayOffset == 0 && slotIndex == 0, // Mock completed for demonstration
          ),
        );

        allocatedMinutesToday += duration;
      }
    }

    return sessions;
  }

  static double _calculateUrgency(TaskItem task, Subject? subject) {
    final now = DateTime.now();

    // Check task due date
    if (task.dueAt != null) {
      final days = task.dueAt!.difference(now).inDays;
      if (days <= 1) return 10.0;
      if (days <= 3) return 8.0;
      if (days <= 7) return 6.0;
      if (days <= 14) return 4.0;
      return 2.0;
    }

    // Check subject exam date
    if (subject?.examAt != null) {
      final days = subject!.examAt!.difference(now).inDays;
      if (days <= 3) return 10.0;
      if (days <= 7) return 8.0;
      if (days <= 14) return 6.0;
      if (days <= 30) return 4.0;
      return 2.0;
    }

    return 3.0;
  }

  static double _priorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 10.0;
      case 'medium':
        return 6.0;
      case 'low':
      default:
        return 3.0;
    }
  }
}
