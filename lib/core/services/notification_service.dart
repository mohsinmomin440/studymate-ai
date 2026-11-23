import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../constants/app_constants.dart';

/// Notification service for local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // Android initialization
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    _initialized = true;
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      AppConstants.channelId,
      AppConstants.channelName,
      description: AppConstants.channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap - navigate to relevant screen
    // Navigation handled elsewhere
  }

  /// Show instant notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.channelId,
          AppConstants.channelName,
          channelDescription: AppConstants.channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF6C5CE7),
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// Schedule notification for later (accepts TZDateTime for proper timezone handling)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
    bool allowWhileIdle = true,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.channelId,
          AppConstants.channelName,
          channelDescription: AppConstants.channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF6C5CE7),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: allowWhileIdle
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.exact,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    String? payload,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.channelId,
          AppConstants.channelName,
          channelDescription: AppConstants.channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFF6C5CE7),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  /// Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Show study reminder
  Future<void> showStudyReminder({String? subject}) async {
    final title = 'Time to Study! 📚';
    final body = subject != null
        ? 'Your $subject session is waiting. Let\'s make progress!'
        : 'Your daily study session is ready. Tap to start!';

    await showNotification(
      id: 1001,
      title: title,
      body: body,
      payload: 'study_reminder',
    );
  }

  /// Show streak reminder
  Future<void> showStreakReminder(int streak) async {
    await showNotification(
      id: 1002,
      title: 'Keep Your Streak Alive! 🔥',
      body: 'You\'re on a $streak day streak. Don\'t break it now!',
      payload: 'streak_reminder',
    );
  }

  /// Show flashcard review notification
  Future<void> showFlashcardReview(int count) async {
    await showNotification(
      id: 1003,
      title: 'Flashcards Ready for Review 📇',
      body: 'You have $count flashcards due today. Quick review?',
      payload: 'flashcard_review',
    );
  }

  /// Show focus timer completion
  Future<void> showFocusComplete(int minutes) async {
    await showNotification(
      id: 1004,
      title: 'Focus Session Complete! ✅',
      body: 'Great job! You focused for $minutes minutes. Take a break!',
      payload: 'focus_complete',
    );
  }

  /// Request permissions (iOS)
  Future<bool> requestPermissions() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? false;
  }

  /// Request Android 13+ notification permission
  Future<bool> requestAndroidPermission() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // Check if we need to request permission (Android 13+)
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return true;
  }

  /// Check if streak reminder should be shown today
  /// Returns true if user hasn't studied today and reminders are enabled
  bool shouldShowStreakReminder({
    required bool notificationsEnabled,
    required DateTime? lastStudyDate,
  }) {
    if (!notificationsEnabled) return false;
    if (lastStudyDate == null) return true; // First time user

    final today = DateTime.now();
    final lastStudyDay = DateTime(
      lastStudyDate.year,
      lastStudyDate.month,
      lastStudyDate.day,
    );
    final todayDay = DateTime(today.year, today.month, today.day);

    // Don't remind if already studied today
    return lastStudyDay.isBefore(todayDay);
  }

  /// Schedule daily streak reminder at user's preferred time
  /// Defaults to 8 PM (20:00) if no time is set
  Future<void> scheduleStreakReminder({
    required int hour,
    required int minute,
    required String locale,
  }) async {
    // Cancel any existing streak reminder
    await cancelNotification(1002);

    // Get localized strings
    String title, body;
    switch (locale) {
      case 'gu':
        title = 'તમારું સ્ટ્રીક જીવંત રાખો!';
        body = 'તમે {streak} દિવસનો સ્ટ્રીક રાખી શક્યા છો. હવે તોડો નહીં!';
        break;
      case 'hi':
        title = 'अपना स्ट्रीक जीवित रखें!';
        body = 'आप {streak} दिन का स्ट्रीक बनाए हुए हैं। अब इसे न तोड़ें!';
        break;
      default:
        title = 'Keep Your Streak Alive!';
        body = "You're on a {streak} day streak. Don't break it now!";
    }

    // Note: The actual streak count will be interpolated at runtime
    // We schedule a generic reminder; the body will be updated when fired
    await scheduleDailyNotification(
      id: 1002,
      title: title,
      body: body.replaceAll('{streak}', 'X'), // Placeholder
      hour: hour,
      minute: minute,
      payload: 'streak_reminder',
    );
  }

  /// Cancel streak reminder
  Future<void> cancelStreakReminder() async {
    await cancelNotification(1002);
  }

  /// Reschedule streak reminder when settings change
  Future<void> rescheduleStreakReminder({
    required bool notificationsEnabled,
    required int? reminderHour,
    required int? reminderMinute,
    required String locale,
  }) async {
    await cancelStreakReminder();

    if (!notificationsEnabled ||
        reminderHour == null ||
        reminderMinute == null) {
      return;
    }

    // Request Android 13+ permission if needed
    await requestAndroidPermission();

    await scheduleStreakReminder(
      hour: reminderHour,
      minute: reminderMinute,
      locale: locale,
    );
  }

  /// Update streak reminder body with actual streak count (called when notification fires)
  /// This is a workaround since we can't dynamically update scheduled notifications
  /// In production, you'd use a background isolate or WorkManager to update
  Future<void> updateStreakReminderBody(int streak, String locale) async {
    String body;
    switch (locale) {
      case 'gu':
        body = 'તમે $streak દિવસનો સ્ટ્રીક રાખી શક્યા છો. હવે તોડો નહીં!';
        break;
      case 'hi':
        body = 'आप $streak दिन का स्ट्रीक बनाए हुए हैं। अब इसे न तोड़ें!';
        break;
      default:
        body = "You're on a $streak day streak. Don't break it now!";
    }

    // Reschedule with updated body
    // Note: This will fire immediately if the time has passed today
    // Better approach: Use WorkManager for exact time scheduling
    await cancelNotification(1002);
    await showNotification(
      id: 1002,
      title: locale == 'gu'
          ? 'તમારું સ્ટ્રીક જીવંત રાખો!'
          : locale == 'hi'
              ? 'अपना स्ट्रीक जीवित रखें!'
              : 'Keep Your Streak Alive!',
      body: body,
      payload: 'streak_reminder',
    );
  }
}
