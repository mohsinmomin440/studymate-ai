import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data for notifications
  tz_data.initializeTimeZones();

  // Initialize Firebase and App Check
  await FirebaseInitializer.initialize();

  runApp(const ProviderScope(child: StudyMateApp()));
}

/// Provider to track Firebase initialization status
final firebaseStatusProvider =
    StateProvider<FirebaseStatus>((ref) => FirebaseStatus.unknown);

enum FirebaseStatus { unknown, initialized, error }

/// Firebase initialization service
class FirebaseInitializer {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Use playIntegrity for release, debug provider for debug
      await FirebaseAppCheck.instance.activate(
        androidProvider: kReleaseMode
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
      );

      // Set up Crashlytics error handlers (guarded against missing Firebase)
      _setupErrorHandling();

      _initialized = true;
    } catch (e) {
      // Firebase failed to initialize - will show setup screen
      developer.log('Firebase init failed: $e', name: 'FirebaseInitializer');
    }
  }

  /// Set up Crashlytics error handling - guarded so app never crashes
  /// when Firebase is missing
  static void _setupErrorHandling() {
    try {
      // Handle Flutter errors
      FlutterError.onError = (FlutterErrorDetails details) {
        developer.log('Flutter error: ${details.exceptionAsString()}',
            name: 'FlutterError');
        FirebaseCrashlytics.instance.recordFlutterError(details);
      };

      // Handle uncaught Dart errors
      ui.PlatformDispatcher.instance.onError =
          (Object error, StackTrace stack) {
        FirebaseCrashlytics.instance.recordError(error, stack);
        return true;
      };
    } catch (e) {
      // If Crashlytics fails, just log - app continues to work
      developer.log('Error handler setup failed: $e', name: 'ErrorHandler');
    }
  }
}
