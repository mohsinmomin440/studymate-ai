// Settings models - pure Dart, no Firebase imports

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// User settings stored in Firestore under users/{uid}/settings
class UserSettings {
  final String theme; // system, light, dark
  final String language; // en, gu, hi
  final int dailyGoalMin;
  final int? reminderTimeHour;
  final int? reminderTimeMinute;
  final bool notificationsEnabled;
  final String aiResponseLanguage; // en, gu, hi, en-hinglish
  final String aiResponseStyle; // friendly, formal, simple, detailed

  const UserSettings({
    required this.theme,
    required this.language,
    required this.dailyGoalMin,
    this.reminderTimeHour,
    this.reminderTimeMinute,
    required this.notificationsEnabled,
    required this.aiResponseLanguage,
    required this.aiResponseStyle,
  });

  /// Default settings for new users
  factory UserSettings.defaultSettings() {
    return const UserSettings(
      theme: 'system',
      language: 'en',
      dailyGoalMin: 60,
      notificationsEnabled: true,
      aiResponseLanguage: 'en',
      aiResponseStyle: 'friendly',
    );
  }

  /// Theme mode enum
  ThemeMode get themeMode {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Get reminder time as DateTime (placeholder - actual time zone handling needed)
  DateTime? get reminderTime {
    final hour = reminderTimeHour;
    final minute = reminderTimeMinute;
    if (hour == null || minute == null) return null;
    return DateTime(0, 0, 0, hour, minute);
  }

  /// Check if reminders are enabled and have a time set
  bool get hasScheduledReminder =>
      notificationsEnabled && reminderTimeHour != null;

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        theme: json['theme'] as String? ?? 'system',
        language: json['language'] as String? ?? 'en',
        dailyGoalMin: json['dailyGoalMin'] as int? ?? 60,
        reminderTimeHour: json['reminderTimeHour'] as int?,
        reminderTimeMinute: json['reminderTimeMinute'] as int?,
        notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
        aiResponseLanguage: json['aiResponseLanguage'] as String? ?? 'en',
        aiResponseStyle: json['aiResponseStyle'] as String? ?? 'friendly',
      );

  factory UserSettings.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserSettings.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'theme': theme,
        'language': language,
        'dailyGoalMin': dailyGoalMin,
        'reminderTimeHour': reminderTimeHour,
        'reminderTimeMinute': reminderTimeMinute,
        'notificationsEnabled': notificationsEnabled,
        'aiResponseLanguage': aiResponseLanguage,
        'aiResponseStyle': aiResponseStyle,
      };

  UserSettings copyWith({
    String? theme,
    String? language,
    int? dailyGoalMin,
    int? reminderTimeHour,
    int? reminderTimeMinute,
    bool? notificationsEnabled,
    String? aiResponseLanguage,
    String? aiResponseStyle,
  }) {
    return UserSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      dailyGoalMin: dailyGoalMin ?? this.dailyGoalMin,
      reminderTimeHour: reminderTimeHour ?? this.reminderTimeHour,
      reminderTimeMinute: reminderTimeMinute ?? this.reminderTimeMinute,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      aiResponseLanguage: aiResponseLanguage ?? this.aiResponseLanguage,
      aiResponseStyle: aiResponseStyle ?? this.aiResponseStyle,
    );
  }
}

/// Theme mode extension
extension ThemeModeExtension on ThemeMode {
  String get label {
    switch (this) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      default:
        return 'System';
    }
  }
}

/// Available AI response styles
class AiStyles {
  static const List<String> styles = [
    'friendly',
    'formal',
    'simple',
    'detailed',
  ];

  static const Map<String, String> styleLabels = {
    'friendly': 'Friendly',
    'formal': 'Formal',
    'simple': 'Simple',
    'detailed': 'Detailed',
  };

  static const Map<String, String> styleDescriptions = {
    'friendly': 'Casual, conversational tone',
    'formal': 'Professional, academic tone',
    'simple': 'Easy to understand, minimal jargon',
    'detailed': 'In-depth explanations with examples',
  };
}

/// Available AI response languages
class AiLanguages {
  static const List<String> languages = [
    'en',
    'gu',
    'hi',
    'en-hinglish',
  ];

  static const Map<String, String> languageLabels = {
    'en': 'English',
    'gu': 'ગુજરાતી',
    'hi': 'हिंदी',
    'en-hinglish': 'Hinglish (English+Hindi)',
  };
}
