import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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

  /// Result of delete account operation
  /// [needsReauth] - true if re-authentication is required before retrying
  /// [dataDeleted] - true if Firestore data was successfully deleted
  Future<DeleteAccountResult> deleteAccount({
    AuthCredential? reauthCredential,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      return DeleteAccountResult(
        success: false,
        error: 'No user signed in',
        needsReauth: false,
        dataDeleted: false,
      );
    }

    final uid = user.uid;

    // Step 1: Re-authenticate if needed (non-anonymous users)
    if (!user.isAnonymous) {
      if (reauthCredential == null) {
        return DeleteAccountResult(
          success: false,
          error: 'Re-authentication required',
          needsReauth: true,
          dataDeleted: false,
        );
      }
      try {
        await user.reauthenticateWithCredential(reauthCredential);
      } on FirebaseAuthException catch (e) {
        return DeleteAccountResult(
          success: false,
          error: 'Re-authentication failed: ${e.message}',
          needsReauth: true,
          dataDeleted: false,
        );
      }
    }

    // Step 2: Delete all Firestore subcollections
    try {
      await _deleteAllUserData(uid);
    } catch (e) {
      return DeleteAccountResult(
        success: false,
        error: 'Failed to delete user data: $e',
        needsReauth: !user.isAnonymous,
        dataDeleted: false,
      );
    }

    // Step 3: Delete the user document
    try {
      await _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(uid)
          .delete();
    } catch (e) {
      return DeleteAccountResult(
        success: false,
        error: 'Failed to delete user profile: $e',
        needsReauth: !user.isAnonymous,
        dataDeleted: true, // Subcollections were deleted
      );
    }

    // Step 4: Delete the auth account (only after all data is gone)
    try {
      await user.delete();
    } on FirebaseAuthException catch (e) {
      // If auth deletion fails, data is already deleted - this is a critical state
      return DeleteAccountResult(
        success: false,
        error: 'Data deleted but failed to delete auth account: ${e.message}',
        needsReauth: true,
        dataDeleted: true,
      );
    }

    return DeleteAccountResult(
      success: true,
      error: null,
      needsReauth: false,
      dataDeleted: true,
    );
  }

  /// Delete all user data from Firestore subcollections
  /// Throws on any failure - caller should handle and show retry
  Future<void> _deleteAllUserData(String uid) async {
    final firestore = _firestore;

    // Collections in order (nested first, then parents)
    final List<Object> collectionsToDelete = [
      // Nested: messages under chats
      () => _deleteNestedCollection(firestore, uid, 'chats', 'messages'),
      // Nested: cards under decks
      () => _deleteNestedCollection(firestore, uid, 'decks', 'cards'),
      // Main collections
      'chats',
      'doubts',
      'notes',
      'decks',
      'quizzes',
      'quizAttempts',
      'plans',
      'dailyStats',
      'badges',
      'settings',
    ];

    for (final item in collectionsToDelete) {
      if (item is String) {
        await _deleteCollection(firestore, uid, item);
      } else if (item is Future<void> Function()) {
        await item();
      }
    }
  }

  /// Delete a top-level collection under users/{uid}
  Future<void> _deleteCollection(
    FirebaseFirestore firestore,
    String uid,
    String collectionName,
  ) async {
    const int batchSize = 400; // Firestore batch limit
    final collectionRef =
        firestore.collection('users').doc(uid).collection(collectionName);

    QuerySnapshot snapshot;
    do {
      snapshot = await collectionRef.limit(batchSize).get();
      if (snapshot.docs.isEmpty) break;

      final batch = firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } while (snapshot.docs.length == batchSize);
  }

  /// Delete nested collection: parentCollection/{parentId}/nestedCollection
  Future<void> _deleteNestedCollection(
    FirebaseFirestore firestore,
    String uid,
    String parentCollection,
    String nestedCollection,
  ) async {
    final parentRef =
        firestore.collection('users').doc(uid).collection(parentCollection);
    const int batchSize = 400;

    final parentsSnapshot = await parentRef.get();
    for (final parentDoc in parentsSnapshot.docs) {
      final nestedRef = parentDoc.reference.collection(nestedCollection);

      QuerySnapshot nestedSnapshot;
      do {
        nestedSnapshot = await nestedRef.limit(batchSize).get();
        if (nestedSnapshot.docs.isEmpty) break;

        final batch = firestore.batch();
        for (final doc in nestedSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } while (nestedSnapshot.docs.length == batchSize);
    }
  }

  /// Get re-authentication credential for the current user
  /// Returns null if user is anonymous (guests don't need re-auth)
  Future<AuthCredential?> getReauthCredential() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    if (user.isAnonymous) return null; // Guests skip re-auth

    // Try Google sign-in first
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        return GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }
    } catch (e) {
      // Google sign-in failed or cancelled
    }

    // For email/password, the UI should prompt for credentials
    // This method returns null to signal that email/password re-auth is needed
    return null;
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

/// Result of a delete account operation
class DeleteAccountResult {
  final bool success;
  final String? error;
  final bool needsReauth;
  final bool dataDeleted;

  const DeleteAccountResult({
    required this.success,
    this.error,
    required this.needsReauth,
    required this.dataDeleted,
  });
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
