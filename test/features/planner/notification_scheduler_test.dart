// Unit tests for notification scheduler logic
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'package:studymate_ai/core/services/notification_utils.dart';
import 'package:studymate_ai/features/planner/data/notification_planner.dart';

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
  });

  group('NotificationScheduler', () {
    late NotificationScheduler scheduler;
    late List<int> cancelledIds;
    late List<int> scheduledIds;

    setUp(() {
      cancelledIds = [];
      scheduledIds = [];

      scheduler = NotificationScheduler(
        now: () => DateTime(2025, 12, 15, 10, 0), // 10:00 AM on Dec 15, 2025
        cancelNotification: (id) => cancelledIds.add(id),
        scheduleNotification: ({
          required int id,
          required String title,
          required String body,
          required tz.TZDateTime scheduledDate,
        }) async {
          scheduledIds.add(id);
        },
      );
    });

    group('schedulePlanReminders', () {
      test('schedules reminders for future days only', () async {
        final days = [
          DayWithTasks(date: DateTime(2025, 12, 15), tasks: [
            TaskInfo(
                title: 'Task 1',
                subject: 'Math',
                estimatedMinutes: 30,
                type: 'study',
                done: false),
          ]),
          DayWithTasks(date: DateTime(2025, 12, 16), tasks: [
            TaskInfo(
                title: 'Task 2',
                subject: 'Science',
                estimatedMinutes: 30,
                type: 'study',
                done: false),
          ]),
        ];

        final ids = await scheduler.schedulePlanReminders(
          planId: 'plan_1',
          days: days,
          generateNotificationId: generateNotificationId,
        );

        // At 10:00 AM, 8:00 AM reminder has passed, so today is NOT included
        // Only tomorrow (12/16) is scheduled
        expect(ids.length, 1);
      });

      test('includes today if time has not passed (morning)', () async {
        scheduler = NotificationScheduler(
          now: () =>
              DateTime(2025, 12, 15, 7, 0), // 7:00 AM - before 8:00 reminder
          cancelNotification: (id) => cancelledIds.add(id),
          scheduleNotification: ({
            required int id,
            required String title,
            required String body,
            required tz.TZDateTime scheduledDate,
          }) async {
            scheduledIds.add(id);
          },
        );

        final days = [
          DayWithTasks(date: DateTime(2025, 12, 15), tasks: [
            TaskInfo(
                title: 'Task 1',
                subject: 'Math',
                estimatedMinutes: 30,
                type: 'study',
                done: false),
          ]),
        ];

        final ids = await scheduler.schedulePlanReminders(
          planId: 'plan_1',
          days: days,
          generateNotificationId: generateNotificationId,
        );

        expect(ids.length, 1); // Should include today since 7:00 < 8:00
      });

      test('excludes today if time has passed (afternoon)', () async {
        scheduler = NotificationScheduler(
          now: () =>
              DateTime(2025, 12, 15, 10, 0), // 10:00 AM - after 8:00 reminder
          cancelNotification: (id) => cancelledIds.add(id),
          scheduleNotification: ({
            required int id,
            required String title,
            required String body,
            required tz.TZDateTime scheduledDate,
          }) async {
            scheduledIds.add(id);
          },
        );

        final days = [
          DayWithTasks(date: DateTime(2025, 12, 15), tasks: [
            TaskInfo(
                title: 'Task 1',
                subject: 'Math',
                estimatedMinutes: 30,
                type: 'study',
                done: false),
          ]),
        ];

        final ids = await scheduler.schedulePlanReminders(
          planId: 'plan_1',
          days: days,
          generateNotificationId: generateNotificationId,
        );

        // Should not include today since 10:00 > 8:00 (reminder time passed)
        expect(ids.length, 0);
      });
    });

    group('cancelPlanReminders', () {
      test('cancels all notifications for plan days', () async {
        final days = [
          DayWithTasks(date: DateTime(2025, 12, 15), tasks: []),
          DayWithTasks(date: DateTime(2025, 12, 16), tasks: []),
          DayWithTasks(date: DateTime(2025, 12, 17), tasks: []),
        ];

        final ids = await scheduler.cancelPlanReminders(
          planId: 'plan_1',
          days: days,
          generateNotificationId: generateNotificationId,
        );

        // Should cancel for today and future days
        expect(ids.length, 3);
        expect(cancelledIds.length, 3);
      });

      test('does not cancel past days', () async {
        scheduler = NotificationScheduler(
          now: () => DateTime(2025, 12, 15, 10, 0),
          cancelNotification: (id) => cancelledIds.add(id),
          scheduleNotification: ({
            required int id,
            required String title,
            required String body,
            required tz.TZDateTime scheduledDate,
          }) async {
            scheduledIds.add(id);
          },
        );

        final days = [
          DayWithTasks(date: DateTime(2025, 12, 10), tasks: []), // Past day
          DayWithTasks(date: DateTime(2025, 12, 15), tasks: []), // Today
          DayWithTasks(date: DateTime(2025, 12, 16), tasks: []), // Tomorrow
        ];

        final ids = await scheduler.cancelPlanReminders(
          planId: 'plan_1',
          days: days,
          generateNotificationId: generateNotificationId,
        );

        // Should only cancel for today and tomorrow (not past)
        expect(ids.length, 2);
      });
    });

    group('updateDayNotification', () {
      test('cancels and reschedules when undone tasks remain', () async {
        final notificationId = await scheduler.updateDayNotification(
          planId: 'plan_1',
          dayDate: DateTime(2025, 12, 15),
          undoneCount: 3,
          generateNotificationId: generateNotificationId,
        );

        expect(cancelledIds.length, 1);
        expect(scheduledIds.length, 1);
        expect(notificationId, cancelledIds.first);
      });

      test('cancels notification when all tasks are done', () async {
        final notificationId = await scheduler.updateDayNotification(
          planId: 'plan_1',
          dayDate: DateTime(2025, 12, 15),
          undoneCount: 0,
          generateNotificationId: generateNotificationId,
        );

        expect(cancelledIds.length, 1);
        expect(scheduledIds.length, 0); // Not scheduled
      });

      test('uses deterministic notification ID', () async {
        final id1 = await scheduler.updateDayNotification(
          planId: 'plan_1',
          dayDate: DateTime(2025, 12, 15),
          undoneCount: 2,
          generateNotificationId: generateNotificationId,
        );

        cancelledIds.clear();
        scheduledIds.clear();

        final id2 = await scheduler.updateDayNotification(
          planId: 'plan_1',
          dayDate: DateTime(2025, 12, 15),
          undoneCount: 1,
          generateNotificationId: generateNotificationId,
        );

        expect(id1, id2); // Same ID for same plan+date
      });
    });

    group('rescheduleMissedTasks', () {
      test('schedules missed tasks to available days', () async {
        final days = [
          DayWithTasks(date: DateTime(2025, 12, 15), tasks: [
            TaskInfo(
                title: 'Task 1',
                subject: 'Math',
                estimatedMinutes: 30,
                type: 'study',
                done: false),
          ]),
          DayWithTasks(date: DateTime(2025, 12, 16), tasks: [
            TaskInfo(
                title: 'Task 2',
                subject: 'Science',
                estimatedMinutes: 30,
                type: 'study',
                done: false),
          ]),
        ];

        final ids = await scheduler.rescheduleMissedTasks(
          planId: 'plan_1',
          originalDays: days,
          generateNotificationId: generateNotificationId,
        );

        // Should schedule for both days with the missed tasks
        expect(scheduledIds.length, 2);
        expect(cancelledIds.length, 2); // Cancelled old notifications
      });

      test('handles no missed tasks gracefully', () async {
        final days = [
          DayWithTasks(date: DateTime(2025, 12, 15), tasks: [
            TaskInfo(
                title: 'Task 1',
                subject: 'Math',
                estimatedMinutes: 30,
                type: 'study',
                done: true),
          ]),
        ];

        final ids = await scheduler.rescheduleMissedTasks(
          planId: 'plan_1',
          originalDays: days,
          generateNotificationId: generateNotificationId,
        );

        expect(ids.length, 0);
      });
    });

    group('Notification ID generation integration', () {
      test('IDs are consistent across scheduler calls', () async {
        final day = DateTime(2025, 12, 15);

        final testScheduler = NotificationScheduler(
          now: () => DateTime(2025, 12, 15, 10, 0),
          cancelNotification: (id) {},
          scheduleNotification: ({
            required int id,
            required String title,
            required String body,
            required tz.TZDateTime scheduledDate,
          }) async {},
        );

        final id1 = await testScheduler.updateDayNotification(
          planId: 'plan_1',
          dayDate: day,
          undoneCount: 2,
          generateNotificationId: generateNotificationId,
        );

        final id2 = generateNotificationId('plan_1', day, 8);

        expect(id1, id2);
      });
    });
  });
}
