// Notification planner - testable logic for notification scheduling
// This class contains pure business logic that can be tested without Firebase

import 'package:timezone/timezone.dart' as tz;

/// A notification scheduler that can be tested offline
class NotificationScheduler {
  final DateTime Function() now;
  final void Function(int id) cancelNotification;
  final Future<void> Function({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) scheduleNotification;

  NotificationScheduler({
    required this.now,
    required this.cancelNotification,
    required this.scheduleNotification,
  });

  /// Schedule reminders for a plan's days
  /// Returns list of scheduled notification IDs
  Future<List<int>> schedulePlanReminders({
    required String planId,
    required List<DayWithTasks> days,
    int reminderHour = 8,
    int reminderMinute = 0,
    required int Function(String planId, DateTime dayDate, int hour)
        generateNotificationId,
  }) async {
    final List<int> scheduledIds = [];
    final currentNow = now();

    // Normalize currentNow to just the date for comparison
    final todayOnly =
        DateTime(currentNow.year, currentNow.month, currentNow.day);
    final reminderDateTime = DateTime(currentNow.year, currentNow.month,
        currentNow.day, reminderHour, reminderMinute);

    for (final day in days) {
      final dayOnly = DateTime(day.date.year, day.date.month, day.date.day);

      // Include today if reminder time hasn't passed yet
      // OR include future days
      bool shouldSchedule;
      if (dayOnly.isBefore(todayOnly)) {
        shouldSchedule = false; // Past day
      } else if (dayOnly.isAfter(todayOnly)) {
        shouldSchedule = true; // Future day
      } else {
        // Today - check if reminder time has passed
        shouldSchedule = !reminderDateTime.isBefore(currentNow);
      }

      if (shouldSchedule) {
        final notificationId =
            generateNotificationId(planId, day.date, reminderHour);
        final scheduledDate = tz.TZDateTime(
          tz.local,
          day.date.year,
          day.date.month,
          day.date.day,
          reminderHour,
          reminderMinute,
        );

        await scheduleNotification(
          id: notificationId,
          title: 'Study Session Today',
          body: '${day.undoneCount} tasks waiting. Let\'s get started!',
          scheduledDate: scheduledDate,
        );

        scheduledIds.add(notificationId);
      }
    }

    return scheduledIds;
  }

  /// Cancel all notifications for a plan
  /// Returns list of canceled notification IDs
  Future<List<int>> cancelPlanReminders({
    required String planId,
    required List<DayWithTasks> days,
    int reminderHour = 8,
    required int Function(String planId, DateTime dayDate, int hour)
        generateNotificationId,
  }) async {
    final List<int> canceledIds = [];
    final currentNow = now();

    // Normalize currentNow to just the date for comparison
    final todayOnly =
        DateTime(currentNow.year, currentNow.month, currentNow.day);

    for (final day in days) {
      final dayOnly = DateTime(day.date.year, day.date.month, day.date.day);

      // Include today OR future days
      if (!dayOnly.isBefore(todayOnly)) {
        final notificationId =
            generateNotificationId(planId, day.date, reminderHour);
        cancelNotification(notificationId);
        canceledIds.add(notificationId);
      }
    }

    return canceledIds;
  }

  /// Update notification for a single day after task toggle
  /// Returns the notification ID
  Future<int> updateDayNotification({
    required String planId,
    required DateTime dayDate,
    required int undoneCount,
    int reminderHour = 8,
    required int Function(String planId, DateTime dayDate, int hour)
        generateNotificationId,
  }) async {
    final notificationId =
        generateNotificationId(planId, dayDate, reminderHour);

    cancelNotification(notificationId);

    if (undoneCount > 0) {
      final scheduledDate = tz.TZDateTime(
        tz.local,
        dayDate.year,
        dayDate.month,
        dayDate.day,
        reminderHour,
        0,
      );

      await scheduleNotification(
        id: notificationId,
        title: 'Study Session Today',
        body: '$undoneCount tasks waiting. Let\'s get started!',
        scheduledDate: scheduledDate,
      );
    }

    return notificationId;
  }

  /// Reschedule missed tasks to available days
  /// Returns list of newly scheduled notification IDs
  Future<List<int>> rescheduleMissedTasks({
    required String planId,
    required List<DayWithTasks> originalDays,
    int reminderHour = 8,
    required int Function(String planId, DateTime dayDate, int hour)
        generateNotificationId,
  }) async {
    final List<int> scheduledIds = [];
    final currentNow = now();
    final todayOnly =
        DateTime(currentNow.year, currentNow.month, currentNow.day);

    // Cancel all existing notifications first
    await cancelPlanReminders(
      planId: planId,
      days: originalDays,
      reminderHour: reminderHour,
      generateNotificationId: generateNotificationId,
    );

    // Find all missed tasks and their original scheduled days
    final missedItems = <Map<String, dynamic>>[];

    for (int dayIndex = 0; dayIndex < originalDays.length; dayIndex++) {
      final day = originalDays[dayIndex];
      final dayOnly = DateTime(day.date.year, day.date.month, day.date.day);
      if (!dayOnly.isBefore(todayOnly)) {
        for (int taskIndex = 0; taskIndex < day.tasks.length; taskIndex++) {
          final task = day.tasks[taskIndex];
          if (!task.done) {
            missedItems.add({
              'task': task,
              'originalDayIndex': dayIndex,
              'taskIndex': taskIndex,
            });
          }
        }
      }
    }

    if (missedItems.isEmpty) return scheduledIds;

    // Build a map of available days (today and future days only)
    final availableDays = <int, DayWithTasks>{};
    for (int i = 0; i < originalDays.length; i++) {
      final day = originalDays[i];
      final dayOnly = DateTime(day.date.year, day.date.month, day.date.day);
      if (!dayOnly.isBefore(todayOnly)) {
        availableDays[i] = day;
      }
    }

    if (availableDays.isEmpty) return scheduledIds;

    // Distribute missed tasks across available days
    final updatedDays = Map<int, List<TaskInfo>>.from(
      Map.fromEntries(availableDays.entries
          .map((e) => MapEntry(e.key, e.value.tasks.toList()))),
    );

    final availableDayIndices = availableDays.keys.toList()..sort();

    for (int i = 0; i < missedItems.length; i++) {
      final item = missedItems[i];
      final task = item['task'] as TaskInfo;
      final targetDayIndex =
          availableDayIndices[i % availableDayIndices.length];

      updatedDays[targetDayIndex]!.add(task);
    }

    // Schedule new notifications for rescheduled days
    for (int i = 0; i < availableDayIndices.length; i++) {
      final dayIndex = availableDayIndices[i];
      final day = originalDays[dayIndex];
      final tasks = updatedDays[dayIndex]!;

      final notificationId =
          generateNotificationId(planId, day.date, reminderHour);
      final scheduledDate = tz.TZDateTime(
        tz.local,
        day.date.year,
        day.date.month,
        day.date.day,
        reminderHour,
        0,
      );

      final undoneCount = tasks.where((t) => !t.done).length;

      await scheduleNotification(
        id: notificationId,
        title: 'Study Session Today',
        body: undoneCount > 0
            ? '$undoneCount tasks waiting. Let\'s get started!'
            : 'All tasks done for today!',
        scheduledDate: scheduledDate,
      );

      scheduledIds.add(notificationId);
    }

    return scheduledIds;
  }
}

/// Helper class for day with tasks info
class DayWithTasks {
  final DateTime date;
  final List<TaskInfo> tasks;
  final int undoneCount;

  DayWithTasks({
    required this.date,
    required this.tasks,
  }) : undoneCount = tasks.where((t) => !t.done).length;
}

/// Helper class for task info
class TaskInfo {
  final String title;
  final String subject;
  final int estimatedMinutes;
  final String type;
  final bool done;

  TaskInfo({
    required this.title,
    required this.subject,
    required this.estimatedMinutes,
    required this.type,
    required this.done,
  });

  TaskInfo copyWith({bool? done}) {
    return TaskInfo(
      title: title,
      subject: subject,
      estimatedMinutes: estimatedMinutes,
      type: type,
      done: done ?? this.done,
    );
  }
}
