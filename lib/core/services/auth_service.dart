import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signInWithEmail(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    await _ensureUserDocument();
  }

  Future<void> createUserWithEmail(String email, String password) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    await _ensureUserDocument();
  }

  Future<void> signInWithGoogle() async {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();

    await _auth.signInWithProvider(googleProvider);
    await _ensureUserDocument();
  }

  Future<void> signInAsGuest() async {
    await _auth.signInAnonymously();
  }

  Future<void> linkAnonymousToGoogle() async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) return;

    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.linkWithCredential(credential);
  }

  Future<void> linkAnonymousToEmail(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) return;

    final credential =
        EmailAuthProvider.credential(email: email, password: password);
    await user.linkWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await user.delete();
    await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .delete();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateProfileName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name);
  }

  Future<void> _ensureUserDocument() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid);
    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      await docRef.set({
        'name': user.displayName ?? 'User',
        'photoUrl': user.photoURL,
        'email': user.email,
        'grade': '',
        'language': AppConstants.defaultLocale,
        'dailyGoalMin': 60,
        'xp': 0,
        'level': 1,
        'streak': 0,
        'lastStudyDate': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'settings': {
          'theme': 'system',
          'notificationsEnabled': true,
          'aiResponseLanguage': 'en',
          'reminderTime': '08:00',
        },
      });
    } else {
      // Merge settings if they don't exist (for existing users)
      final data = docSnap.data() ?? {};
      final settings = data['settings'] as Map<String, dynamic>? ?? {};
      if (!settings.containsKey('reminderTime')) {
        await docRef.update({
          'settings.reminderTime': '08:00',
        });
      }
    }
  }
}

/// Forgot password service
class ForgotPasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendResetLink(String email, BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password reset email sent. Check your inbox.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending reset email: ${e.toString()}')),
      );
    }
  }
}
