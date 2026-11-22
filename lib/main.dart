import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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

      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
      );

      _initialized = true;
    } catch (e) {
      // Firebase failed to initialize - will show setup screen
    }
  }
}