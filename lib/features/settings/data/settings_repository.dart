// Settings repository - Firestore operations for user settings

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studymate_ai/core/constants/app_constants.dart';
import '../domain/settings_models.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

/// Stream provider for user settings
final userSettingsStreamProvider = StreamProvider<UserSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).settingsStream();
});

/// Single fetch provider for user settings
final userSettingsProvider = FutureProvider<UserSettings>((ref) {
  return ref.watch(settingsRepositoryProvider).getSettings();
});

class SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's settings as a stream
  Stream<UserSettings> settingsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value(UserSettings.defaultSettings());
    }

    return _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection('settings')
        .doc('user')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserSettings.fromFirestore(snapshot);
      }
      return UserSettings.defaultSettings();
    });
  }

  /// Get current user's settings (single fetch)
  Future<UserSettings> getSettings() async {
    final user = _auth.currentUser;
    if (user == null) return UserSettings.defaultSettings();

    final doc = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection('settings')
        .doc('user')
        .get();

    if (doc.exists && doc.data() != null) {
      return UserSettings.fromFirestore(doc);
    }
    return UserSettings.defaultSettings();
  }

  /// Save settings to Firestore
  Future<void> saveSettings(UserSettings settings) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection('settings')
        .doc('user')
        .set(settings.toJson());
  }

  /// Update specific settings fields
  Future<void> updateSettings(Map<String, dynamic> updates) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection('settings')
        .doc('user')
        .set(updates, SetOptions(merge: true));
  }

  /// Update a single setting field
  Future<void> updateSettingField(String field, dynamic value) async {
    await updateSettings({field: value});
  }

  /// Initialize settings document if it doesn't exist
  Future<void> ensureSettingsExists() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection('settings')
        .doc('user');

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set(UserSettings.defaultSettings().toJson());
    }
  }
}
