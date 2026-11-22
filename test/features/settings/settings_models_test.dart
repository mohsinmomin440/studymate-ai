// Unit tests for settings models

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/features/settings/domain/settings_models.dart';

void main() {
  group('UserSettings.fromJson defaults', () {
    test('handles empty map with all defaults', () {
      final settings = UserSettings.fromJson({});
      expect(settings.theme, 'system');
      expect(settings.language, 'en');
      expect(settings.dailyGoalMin, 60);
      expect(settings.notificationsEnabled, true);
      expect(settings.aiResponseLanguage, 'en');
      expect(settings.aiResponseStyle, 'friendly');
      expect(settings.reminderTimeHour, isNull);
      expect(settings.reminderTimeMinute, isNull);
    });

    test('handles null values with defaults', () {
      final settings = UserSettings.fromJson({
        'theme': null,
        'language': null,
        'dailyGoalMin': null,
        'notificationsEnabled': null,
        'aiResponseLanguage': null,
        'aiResponseStyle': null,
        'reminderTimeHour': null,
        'reminderTimeMinute': null,
      });
      expect(settings.theme, 'system');
      expect(settings.language, 'en');
      expect(settings.dailyGoalMin, 60);
      expect(settings.notificationsEnabled, true);
      expect(settings.aiResponseLanguage, 'en');
      expect(settings.aiResponseStyle, 'friendly');
    });

    test('preserves valid values', () {
      final settings = UserSettings.fromJson({
        'theme': 'dark',
        'language': 'hi',
        'dailyGoalMin': 90,
        'notificationsEnabled': false,
        'aiResponseLanguage': 'gu',
        'aiResponseStyle': 'detailed',
        'reminderTimeHour': 16,
        'reminderTimeMinute': 30,
      });
      expect(settings.theme, 'dark');
      expect(settings.language, 'hi');
      expect(settings.dailyGoalMin, 90);
      expect(settings.notificationsEnabled, false);
      expect(settings.aiResponseLanguage, 'gu');
      expect(settings.aiResponseStyle, 'detailed');
      expect(settings.reminderTimeHour, 16);
      expect(settings.reminderTimeMinute, 30);
    });

    test('handles partial data', () {
      final settings = UserSettings.fromJson({
        'theme': 'light',
        'dailyGoalMin': 120,
      });
      expect(settings.theme, 'light');
      expect(settings.dailyGoalMin, 120);
      expect(settings.language, 'en'); // default
      expect(settings.notificationsEnabled, true); // default
    });
  });

  group('UserSettings.reminderTime parsing', () {
    test('returns null when hour is null', () {
      final settings = UserSettings(
        theme: 'system',
        language: 'en',
        dailyGoalMin: 60,
        reminderTimeHour: null,
        reminderTimeMinute: 30,
        notificationsEnabled: true,
        aiResponseLanguage: 'en',
        aiResponseStyle: 'friendly',
      );
      expect(settings.reminderTime, isNull);
    });

    test('returns null when minute is null', () {
      final settings = UserSettings(
        theme: 'system',
        language: 'en',
        dailyGoalMin: 60,
        reminderTimeHour: 16,
        reminderTimeMinute: null,
        notificationsEnabled: true,
        aiResponseLanguage: 'en',
        aiResponseStyle: 'friendly',
      );
      expect(settings.reminderTime, isNull);
    });

    test('returns correct DateTime when both set', () {
      final settings = UserSettings(
        theme: 'system',
        language: 'en',
        dailyGoalMin: 60,
        reminderTimeHour: 16,
        reminderTimeMinute: 30,
        notificationsEnabled: true,
        aiResponseLanguage: 'en',
        aiResponseStyle: 'friendly',
      );
      final reminderTime = settings.reminderTime;
      expect(reminderTime, isNotNull);
      expect(reminderTime?.hour, 16);
      expect(reminderTime?.minute, 30);
    });

    test(
        'hasScheduledReminder returns true when notifications enabled with time',
        () {
      final settings = UserSettings(
        theme: 'system',
        language: 'en',
        dailyGoalMin: 60,
        reminderTimeHour: 8,
        reminderTimeMinute: 0,
        notificationsEnabled: true,
        aiResponseLanguage: 'en',
        aiResponseStyle: 'friendly',
      );
      expect(settings.hasScheduledReminder, isTrue);
    });

    test('hasScheduledReminder returns false when notifications disabled', () {
      final settings = UserSettings(
        theme: 'system',
        language: 'en',
        dailyGoalMin: 60,
        reminderTimeHour: 8,
        reminderTimeMinute: 0,
        notificationsEnabled: false,
        aiResponseLanguage: 'en',
        aiResponseStyle: 'friendly',
      );
      expect(settings.hasScheduledReminder, isFalse);
    });

    test('hasScheduledReminder returns false when no time set', () {
      final settings = UserSettings(
        theme: 'system',
        language: 'en',
        dailyGoalMin: 60,
        reminderTimeHour: null,
        reminderTimeMinute: null,
        notificationsEnabled: true,
        aiResponseLanguage: 'en',
        aiResponseStyle: 'friendly',
      );
      expect(settings.hasScheduledReminder, isFalse);
    });
  });

  group('UserSettings.themeMode getter', () {
    test('returns ThemeMode.light for light', () {
      final settings = UserSettings.defaultSettings().copyWith(theme: 'light');
      expect(settings.themeMode, ThemeMode.light);
    });

    test('returns ThemeMode.dark for dark', () {
      final settings = UserSettings.defaultSettings().copyWith(theme: 'dark');
      expect(settings.themeMode, ThemeMode.dark);
    });

    test('returns ThemeMode.system for system or unknown', () {
      final settings = UserSettings.defaultSettings().copyWith(theme: 'system');
      expect(settings.themeMode, ThemeMode.system);

      final unknownSettings =
          UserSettings.defaultSettings().copyWith(theme: 'unknown');
      expect(unknownSettings.themeMode, ThemeMode.system);
    });
  });

  group('UserSettings.toJson/fromJson round-trip', () {
    test('preserves all values after round-trip', () {
      final original = UserSettings(
        theme: 'dark',
        language: 'hi',
        dailyGoalMin: 90,
        reminderTimeHour: 14,
        reminderTimeMinute: 45,
        notificationsEnabled: false,
        aiResponseLanguage: 'gu',
        aiResponseStyle: 'detailed',
      );

      final json = original.toJson();
      final restored = UserSettings.fromJson(json);

      expect(restored.theme, original.theme);
      expect(restored.language, original.language);
      expect(restored.dailyGoalMin, original.dailyGoalMin);
      expect(restored.reminderTimeHour, original.reminderTimeHour);
      expect(restored.reminderTimeMinute, original.reminderTimeMinute);
      expect(restored.notificationsEnabled, original.notificationsEnabled);
      expect(restored.aiResponseLanguage, original.aiResponseLanguage);
      expect(restored.aiResponseStyle, original.aiResponseStyle);
    });
  });
}

void chunkListTest<T>(List<T> list, int chunkSize) {
  // This function is defined in settings_screen.dart
}
