import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/firebase_service.dart';
import '../domain/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  });
  Future<AppUser> signIn({
    required String email,
    required String password,
  });
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<void> updateStudyPreferences({required int dailyMinutes});
}

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences _prefs;
  FirebaseAuth? _firebaseAuth;
  FirebaseFirestore? _firestore;

  AppUser? _cachedUser;

  AuthRepositoryImpl(this._prefs) {
    if (FirebaseService.isInitialized) {
      try {
        _firebaseAuth = FirebaseAuth.instance;
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        debugPrint('Firebase Auth not available locally: $e');
      }
    }
    _restoreCachedSession();
  }

  void _restoreCachedSession() {
    final cachedEmail = _prefs.getString(AppConstants.userAuthKey);
    if (cachedEmail != null && cachedEmail.isNotEmpty) {
      final name = cachedEmail.contains('@') ? cachedEmail.split('@').first : 'Student';
      _cachedUser = AppUser(
        uid: 'user_${cachedEmail.hashCode.abs()}',
        email: cachedEmail,
        displayName: name.isNotEmpty ? name[0].toUpperCase() + name.substring(1) : 'Student',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  @override
  AppUser? get currentUser {
    if (_firebaseAuth?.currentUser != null) {
      final u = _firebaseAuth!.currentUser!;
      return AppUser(
        uid: u.uid,
        email: u.email ?? '',
        displayName: u.displayName ?? 'Student',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    return _cachedUser;
  }

  @override
  Stream<AppUser?> get authStateChanges {
    if (_firebaseAuth != null) {
      return _firebaseAuth!.authStateChanges().map((u) {
        if (u == null) return null;
        return AppUser(
          uid: u.uid,
          email: u.email ?? '',
          displayName: u.displayName ?? 'Student',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    }
    return Stream.value(_cachedUser);
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (_firebaseAuth != null) {
      final credential = await _firebaseAuth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(displayName.trim());
        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? email.trim(),
          displayName: displayName.trim(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        if (_firestore != null) {
          try {
            await _firestore!
                .collection(AppConstants.usersCollection)
                .doc(user.uid)
                .set(appUser.toMap());
          } catch (e) {
            debugPrint('Failed to save user profile in Firestore: $e');
          }
        }

        await _prefs.setString(AppConstants.userAuthKey, email.trim());
        _cachedUser = appUser;
        return appUser;
      }
    }

    // Local / Offline fallback
    final localUser = AppUser(
      uid: 'user_${email.trim().hashCode.abs()}',
      email: email.trim(),
      displayName: displayName.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _prefs.setString(AppConstants.userAuthKey, email.trim());
    _cachedUser = localUser;
    return localUser;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    if (_firebaseAuth != null) {
      final credential = await _firebaseAuth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final appUser = AppUser(
          uid: user.uid,
          email: user.email ?? email.trim(),
          displayName: user.displayName ?? email.split('@').first,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _prefs.setString(AppConstants.userAuthKey, email.trim());
        _cachedUser = appUser;
        return appUser;
      }
    }

    // Local fallback
    final localUser = AppUser(
      uid: 'user_${email.trim().hashCode.abs()}',
      email: email.trim(),
      displayName: email.split('@').first,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _prefs.setString(AppConstants.userAuthKey, email.trim());
    _cachedUser = localUser;
    return localUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (_firebaseAuth != null) {
      await _firebaseAuth!.sendPasswordResetEmail(email: email.trim());
    }
  }

  @override
  Future<void> signOut() async {
    if (_firebaseAuth != null) {
      await _firebaseAuth!.signOut();
    }
    await _prefs.remove(AppConstants.userAuthKey);
    _cachedUser = null;
  }

  @override
  Future<void> updateStudyPreferences({required int dailyMinutes}) async {
    if (_cachedUser == null) return;
    _cachedUser = _cachedUser!.copyWith(dailyStudyMinutes: dailyMinutes);
    if (_firestore != null && _firebaseAuth?.currentUser != null) {
      try {
        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(_firebaseAuth!.currentUser!.uid)
            .update({
          'dailyStudyMinutes': dailyMinutes,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Failed to update study preferences: $e');
      }
    }
  }
}
