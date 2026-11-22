// Planner repository - Firestore operations for study plans

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../domain/planner_models.dart';

final plannerRepositoryProvider =
    Provider<PlannerRepository>((ref) => PlannerRepository());

class PlannerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();
  final NotificationService _notificationService = NotificationService();

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _plansCollection => _firestore
      .collection(AppConstants.firestoreUsersCollection)
      .doc(_uid)
      .collection(AppConstants.firestorePlansCollection);

  /// Generate a deterministic 32-bit notification ID for a plan day
  /// Format: hash(planId + date + reminderHour) fits in 32-bit int range
  /// Using a stable hashing algorithm that produces consistent results
  int _generateNotificationId(
      String planId, DateTime dayDate, int reminderHour) {
    final dateStr = dayDate.toIso8601String().split('T')[0];
    final key = '$planId|$dateStr|$reminderHour';

    // Simple deterministic hash that fits in 32-bit integer
    int hash = 0;
    for (int i = 0; i < key.length; i++) {
      hash = (hash * 31 + key.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return hash;
  }

  /// Cancel all scheduled notifications for a plan
  /// Called when plan is deleted or all tasks are marked done
  Future<void> _cancelPlanNotifications(String planId, DateTime examDate,
      {List<StudyDay>? days}) async {
    final notificationService = NotificationService();

    // Default reminder time: 8:00 AM
    const reminderHour = 8;
    const reminderMinute = 0;

    // If days provided, use them; otherwise we just cancel all for this plan
    if (days != null) {
      for (final day in days) {
        final notificationId =
            _generateNotificationId(planId, day.date, reminderHour);
        await notificationService.cancelNotification(notificationId);
      }
    } else {
      // Fallback: try to cancel notifications for next 30 days
      // Since we can't iterate all days, we cancel a reasonable range
      final now = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final dayDate =
            DateTime(now.year, now.month, now.day).add(Duration(days: i));
        if (!dayDate.isBefore(now)) {
          final notificationId =
              _generateNotificationId(planId, dayDate, reminderHour);
          await notificationService.cancelNotification(notificationId);
        }
      }
    }
  }

  /// Create a new study plan from AI-generated data
  Future<String> createPlan({
    required String title,
    required DateTime examDate,
    required List<String> subjects,
    required int hoursPerDay,
    required List<String> weakTopics,
    required List<StudyDay> days,
  }) async {
    final plan = StudyPlan(
      id: _uuid.v4(),
      title: title,
      examDate: examDate,
      subjects: subjects,
      hoursPerDay: hoursPerDay,
      weakTopics: weakTopics,
      createdAt: DateTime.now(),
      days: days,
    );

    await _plansCollection.doc(plan.id).set(plan.toJson());
    return plan.id;
  }

  /// Get all study plans for current user (stream)
  Stream<List<StudyPlan>> getPlans() {
    return _plansCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => StudyPlan.fromFirestore(doc)).toList());
  }

  /// Get a single study plan by ID
  Future<StudyPlan?> getPlan(String planId) async {
    final doc = await _plansCollection.doc(planId).get();
    if (!doc.exists) return null;
    return StudyPlan.fromFirestore(doc);
  }

  /// Delete a study plan and cancel its notifications
  Future<void> deletePlan(String planId) async {
    // First get the plan to cancel its notifications
    final plan = await getPlan(planId);
    if (plan != null) {
      await _cancelPlanNotifications(planId, plan.examDate, days: plan.days);
    }

    await _plansCollection.doc(planId).delete();
  }

  /// Update a task as done/undone, and reschedule notifications if needed
  Future<void> toggleTask({
    required String planId,
    required int dayIndex,
    required int taskIndex,
  }) async {
    final plan = await getPlan(planId);
    if (plan == null) return;

    final day = plan.days[dayIndex];
    if (day.tasks.isEmpty || taskIndex >= day.tasks.length) return;

    final updatedTask =
        day.tasks[taskIndex].copyWith(done: !day.tasks[taskIndex].done);
    final updatedDay = StudyDay(
      date: day.date,
      tasks: [
        ...day.tasks.take(taskIndex),
        updatedTask,
        ...day.tasks.skip(taskIndex + 1)
      ],
    );

    // Cancel old notification for this day, will be rescheduled when needed
    final notificationId = _generateNotificationId(planId, day.date, 8);
    await _notificationService.cancelNotification(notificationId);

    await _plansCollection.doc(planId).update({
      'days': plan.days
          .asMap()
          .map((i, d) => MapEntry(i, d.toJson()))
          .values
          .toList(),
    });

    // Update the specific day
    await _updateDay(planId, dayIndex, updatedDay);
  }

  /// Update task in a day
  Future<void> updateTask({
    required String planId,
    required int dayIndex,
    required int taskIndex,
    required StudyTask updatedTask,
  }) async {
    final plan = await getPlan(planId);
    if (plan == null) return;

    final day = plan.days[dayIndex];
    if (day.tasks.isEmpty || taskIndex >= day.tasks.length) return;

    final updatedDay = StudyDay(
      date: day.date,
      tasks: [
        ...day.tasks.take(taskIndex),
        updatedTask,
        ...day.tasks.skip(taskIndex + 1)
      ],
    );

    await _updateDay(planId, dayIndex, updatedDay);
  }

  /// Update a day in the plan
  Future<void> _updateDay(
      String planId, int dayIndex, StudyDay updatedDay) async {
    final plan = await getPlan(planId);
    if (plan == null) return;

    final updatedDays = [
      for (int i = 0; i < plan.days.length; i++)
        if (i == dayIndex) updatedDay else plan.days[i],
    ];

    await _plansCollection.doc(planId).update({
      'days': updatedDays.map((d) => d.toJson()).toList(),
    });
  }

  /// Reschedule missed tasks to the next available days
  Future<void> rescheduleMissedTasks(String planId) async {
    final plan = await getPlan(planId);
    if (plan == null) return;

    // Find all missed tasks and their original scheduled days
    final missedItems = <Map<String, dynamic>>[];

    for (int dayIndex = 0; dayIndex < plan.days.length; dayIndex++) {
      final day = plan.days[dayIndex];
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

    if (missedItems.isEmpty) return;

    // Find today's date for comparison (start of day for proper comparison)
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayDate = DateTime.parse(today);

    // Build a map of available days (today and future days only)
    final availableDays = <int, StudyDay>{};
    for (int i = 0; i < plan.days.length; i++) {
      final day = plan.days[i];
      // Only include today and future days
      if (!day.date.isBefore(todayDate)) {
        availableDays[i] = day;
      }
    }

    if (availableDays.isEmpty) return;

    // Distribute missed tasks across available days
    final updatedDays = Map<int, List<StudyTask>>.from(
      Map.fromEntries(availableDays.entries
          .map((e) => MapEntry(e.key, e.value.tasks.toList()))),
    );

    // Add missed tasks to available days (spread across them)
    final availableDayIndices = availableDays.keys.toList()..sort();
    for (int i = 0; i < missedItems.length; i++) {
      final item = missedItems[i];
      final task = item['task'] as StudyTask;
      final targetDayIndex =
          availableDayIndices[i % availableDayIndices.length];

      // Add task to the target day (keeping it as not done)
      updatedDays[targetDayIndex]!.add(task);
    }

    // Apply updates to all days
    final allDays = List<StudyDay>.from(plan.days);

    for (int i = 0; i < availableDayIndices.length; i++) {
      final dayIndex = availableDayIndices[i];
      final day = plan.days[dayIndex];
      final tasks = updatedDays[dayIndex];
      allDays[dayIndex] = StudyDay(date: day.date, tasks: tasks ?? day.tasks);
    }

    await _plansCollection.doc(planId).update({
      'days': allDays.map((d) => d.toJson()).toList(),
    });
  }

  /// Get statistics for a plan
  Future<PlanStats> getStats(String planId) async {
    final plan = await getPlan(planId);
    if (plan == null) throw Exception('Plan not found');
    return PlanStats.fromPlan(plan);
  }
}
