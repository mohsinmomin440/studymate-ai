import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studymate_ai/core/constants/app_constants.dart';
import 'package:studymate_ai/core/theme/theme_provider.dart';

void main() {
  group('ThemeProvider Unit Tests', () {
    test('ThemeNotifier initializes with system default when no preference saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      expect(container.read(themeProvider), equals(ThemeMode.system));
    });

    test('ThemeNotifier loads saved light mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.themeModeKey: 'light',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      expect(container.read(themeProvider), equals(ThemeMode.light));
    });

    test('ThemeNotifier loads saved dark mode from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.themeModeKey: 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      expect(container.read(themeProvider), equals(ThemeMode.dark));
    });

    test('setThemeMode updates state and persists to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      await container.read(themeProvider.notifier).setThemeMode(ThemeMode.dark);
      expect(container.read(themeProvider), equals(ThemeMode.dark));
      expect(prefs.getString(AppConstants.themeModeKey), equals('dark'));

      await container.read(themeProvider.notifier).setThemeMode(ThemeMode.light);
      expect(container.read(themeProvider), equals(ThemeMode.light));
      expect(prefs.getString(AppConstants.themeModeKey), equals('light'));

      await container.read(themeProvider.notifier).setThemeMode(ThemeMode.system);
      expect(container.read(themeProvider), equals(ThemeMode.system));
      expect(prefs.getString(AppConstants.themeModeKey), equals('system'));
    });
  });
}
