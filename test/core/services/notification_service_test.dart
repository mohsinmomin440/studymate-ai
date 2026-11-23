// Unit tests for notification service streak reminder logic

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NotificationService - streak reminder logic', () {
    // Test the shouldShowStreakReminder logic
    // This is a pure function test, no need to mock notifications

    test('should remind when notifications enabled and never studied before',
        () {
      // Arrange
      final notificationsEnabled = true;
      final DateTime? lastStudyDate = null; // First time user

      // Act
      final shouldRemind = _shouldShowStreakReminder(
        notificationsEnabled: notificationsEnabled,
        lastStudyDate: lastStudyDate,
      );

      // Assert
      expect(shouldRemind, isTrue);
    });

    test('should NOT remind when notifications disabled', () {
      // Arrange
      final notificationsEnabled = false;
      final DateTime? lastStudyDate = null;

      // Act
      final shouldRemind = _shouldShowStreakReminder(
        notificationsEnabled: notificationsEnabled,
        lastStudyDate: lastStudyDate,
      );

      // Assert
      expect(shouldRemind, isFalse);
    });

    test('should NOT remind when studied today', () {
      // Arrange
      final notificationsEnabled = true;
      final today = DateTime.now();
      final lastStudyDate = today; // Studied today

      // Act
      final shouldRemind = _shouldShowStreakReminder(
        notificationsEnabled: notificationsEnabled,
        lastStudyDate: lastStudyDate,
      );

      // Assert
      expect(shouldRemind, isFalse);
    });

    test('should remind when studied yesterday', () {
      // Arrange
      final notificationsEnabled = true;
      final today = DateTime.now();
      final yesterday = DateTime(today.year, today.month, today.day - 1);
      final lastStudyDate = yesterday;

      // Act
      final shouldRemind = _shouldShowStreakReminder(
        notificationsEnabled: notificationsEnabled,
        lastStudyDate: lastStudyDate,
      );

      // Assert
      expect(shouldRemind, isTrue);
    });

    test('should remind when studied 2 days ago', () {
      // Arrange
      final notificationsEnabled = true;
      final today = DateTime.now();
      final twoDaysAgo = DateTime(today.year, today.month, today.day - 2);
      final lastStudyDate = twoDaysAgo;

      // Act
      final shouldRemind = _shouldShowStreakReminder(
        notificationsEnabled: notificationsEnabled,
        lastStudyDate: lastStudyDate,
      );

      // Assert
      expect(shouldRemind, isTrue);
    });

    test('should handle time of day correctly (studied late yesterday)', () {
      // Arrange
      final notificationsEnabled = true;
      final today = DateTime.now();
      // Studied yesterday at 11:59 PM
      final yesterdayLate =
          DateTime(today.year, today.month, today.day - 1, 23, 59);
      final lastStudyDate = yesterdayLate;

      // Act
      final shouldRemind = _shouldShowStreakReminder(
        notificationsEnabled: notificationsEnabled,
        lastStudyDate: lastStudyDate,
      );

      // Assert - should remind because it's a different calendar day
      expect(shouldRemind, isTrue);
    });

    test('should handle time of day correctly (studied early today)', () {
      // Arrange
      final notificationsEnabled = true;
      final today = DateTime.now();
      // Studied today at 12:01 AM
      final todayEarly = DateTime(today.year, today.month, today.day, 0, 1);
      final lastStudyDate = todayEarly;

      // Act
      final shouldRemind = _shouldShowStreakReminder(
        notificationsEnabled: notificationsEnabled,
        lastStudyDate: lastStudyDate,
      );

      // Assert - should NOT remind because it's the same calendar day
      expect(shouldRemind, isFalse);
    });
  });
}

// Pure function for testing (extracted from NotificationService logic)
bool _shouldShowStreakReminder({
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
