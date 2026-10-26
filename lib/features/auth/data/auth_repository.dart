import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/app_user.dart';

/// Exception thrown when the user cancels an auth flow (e.g. closing Google dialog).
class AuthCancelledException implements Exception {
  final String message;
  const AuthCancelledException([this.message = 'Authentication cancelled by user.']);
  @override
  String toString() => message;
}

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

  Future<AppUser?> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> signOut();

  Future<void> updateStudyPreferences({required int dailyMinutes});
}

class AuthRepositoryImpl implements AuthRepository {
  final SharedPreferences _prefs;
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AppUser? _cachedUser;

  AuthRepositoryImpl(
    this._prefs, {
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn() {
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
    final u = _firebaseAuth.currentUser;
    if (u != null) {
      final email = u.email ?? '';
      final name = u.displayName?.isNotEmpty == true
          ? u.displayName!
          : (email.contains('@') ? email.split('@').first : 'Student');
      return AppUser(
        uid: u.uid,
        email: email,
        displayName: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    return _cachedUser;
  }

  @override
  Stream<AppUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((u) {
      if (u == null) {
        _cachedUser = null;
        return null;
      }
      final email = u.email ?? '';
      final name = u.displayName?.isNotEmpty == true
          ? u.displayName!
          : (email.contains('@') ? email.split('@').first : 'Student');
      final appUser = AppUser(
        uid: u.uid,
        email: email,
        displayName: name,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _cachedUser = appUser;
      return appUser;
    });
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Registration failed: User could not be created.');
    }

    if (displayName.trim().isNotEmpty) {
      try {
        await user.updateDisplayName(displayName.trim());
      } catch (e) {
        debugPrint('Failed to update displayName on user: $e');
      }
    }

    final appUser = await _getOrCreateUserDoc(
      firebaseUser: user,
      overrideDisplayName: displayName.trim(),
    );

    await _prefs.setString(AppConstants.userAuthKey, appUser.email);
    _cachedUser = appUser;
    return appUser;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Sign in failed: No user returned.');
    }

    final appUser = await _getOrCreateUserDoc(firebaseUser: user);
    await _prefs.setString(AppConstants.userAuthKey, appUser.email);
    _cachedUser = appUser;
    return appUser;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    // 1. Trigger Google Sign-In sheet
    final GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();
    if (googleAccount == null) {
      // User cancelled account selection
      return null;
    }

    // 2. Obtain Google auth tokens
    final GoogleSignInAuthentication googleAuth = await googleAccount.authentication;

    // 3. Create Firebase credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 4. Sign in to Firebase Auth
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw Exception('Google Sign-In failed: No user returned from Firebase.');
    }

    // 5. Create or sync Firestore user profile
    final appUser = await _getOrCreateUserDoc(
      firebaseUser: user,
      overrideDisplayName: googleAccount.displayName,
    );

    await _prefs.setString(AppConstants.userAuthKey, appUser.email);
    _cachedUser = appUser;
    return appUser;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('FirebaseAuth signOut error: $e');
    }

    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('GoogleSignIn signOut error: $e');
    }

    await _prefs.remove(AppConstants.userAuthKey);
    _cachedUser = null;
  }

  @override
  Future<void> updateStudyPreferences({required int dailyMinutes}) async {
    if (_cachedUser == null) return;
    _cachedUser = _cachedUser!.copyWith(dailyStudyMinutes: dailyMinutes);

    final user = _firebaseAuth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .update({
          'dailyStudyMinutes': dailyMinutes,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } catch (e) {
        debugPrint('Failed to update study preferences: $e');
      }
    }
  }

  Future<AppUser> _getOrCreateUserDoc({
    required User firebaseUser,
    String? overrideDisplayName,
  }) async {
    final uid = firebaseUser.uid;
    final email = firebaseUser.email ?? '';
    final docRef = _firestore.collection(AppConstants.usersCollection).doc(uid);

    try {
      final snapshot = await docRef.get();
      if (snapshot.exists && snapshot.data() != null) {
        return AppUser.fromMap(snapshot.data()!, uid);
      }
    } catch (e) {
      debugPrint('Firestore user doc read error: $e');
    }

    final resolvedName = (overrideDisplayName != null && overrideDisplayName.trim().isNotEmpty)
        ? overrideDisplayName.trim()
        : (firebaseUser.displayName?.isNotEmpty == true
            ? firebaseUser.displayName!
            : (email.contains('@') ? email.split('@').first : 'Student'));

    final newUser = AppUser(
      uid: uid,
      email: email,
      displayName: resolvedName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await docRef.set(newUser.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore user doc create error: $e');
    }

    return newUser;
  }
}
