import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

class FirebaseService {
  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;
      debugPrint('Firebase successfully initialized with DefaultFirebaseOptions.');
    } catch (e, stack) {
      _isInitialized = false;
      debugPrint('Firebase initialization notice: $e');
      debugPrint('To connect to your own Firebase Project, run:\n'
          '  1. firebase login\n'
          '  2. dart pub global activate flutterfire_cli\n'
          '  3. flutterfire configure\n'
          'The application will run in safe mode with full UI and local storage capability.');
      if (kDebugMode) {
        debugPrint(stack.toString());
      }
    }
  }
}
