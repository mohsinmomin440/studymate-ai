// Badges repository - Firestore operations for user badges

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/badge.dart';

final badgesRepositoryProvider =
    Provider<BadgesRepository>((ref) => BadgesRepository());

class BadgesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String get _uid => _auth.currentUser?.uid ?? '';

  /// Get badges collection reference
  CollectionReference<Map<String, dynamic>> get _badgesCollection => _firestore
      .collection(AppConstants.firestoreUsersCollection)
      .doc(_uid)
      .collection(AppConstants.firestoreBadgesCollection);

  /// Get all unlocked badges for current user
  Stream<List<UserBadge>> getBadges() {
    return _badgesCollection.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserBadge.fromFirestore(doc)).toList());
  }

  /// Unlock a badge for the user
  Future<void> unlockBadge(String badgeId) async {
    final badge = allBadges.firstWhere((b) => b.id == badgeId,
        orElse: () => throw Exception('Badge not found: $badgeId'));

    await _badgesCollection.doc(badgeId).set({
      'id': badge.id,
      'name': badge.name,
      'description': badge.description,
      'iconName': badge.iconName,
      'unlockedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Check and unlock badges based on user stats
  Future<List<String>> checkAndUnlockBadges({
    required int totalQuizzes,
    required int streak,
    required int totalCards,
    required int totalNotes,
    required int level,
    required int focusMinutes,
  }) async {
    final unlocked = <String>[];
    final newUnlocks = checkBadgeUnlocks(
      totalQuizzes: totalQuizzes,
      streak: streak,
      totalCards: totalCards,
      totalNotes: totalNotes,
      level: level,
      focusMinutes: focusMinutes,
    );

    for (final badgeId in newUnlocks) {
      try {
        await unlockBadge(badgeId);
        unlocked.add(badgeId);
      } catch (e) {
        // Badge already unlocked or other error
      }
    }

    return unlocked;
  }

  /// Delete all user badges (for account deletion)
  Future<void> deleteAllBadges() async {
    if (_uid.isEmpty) return;

    final batch = _firestore.batch();
    final snapshot = await _badgesCollection.get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

/// Check which badges should be unlocked based on user stats
List<String> checkBadgeUnlocks({
  required int totalQuizzes,
  required int streak,
  required int totalCards,
  required int totalNotes,
  required int level,
  required int focusMinutes,
}) {
  final List<String> unlocked = [];

  if (totalQuizzes >= 1) unlocked.add('first_quiz');
  if (streak >= 7) unlocked.add('streak_7');
  if (streak >= 30) unlocked.add('streak_30');
  if (totalCards >= 100) unlocked.add('cards_100');
  if (totalNotes >= 50) unlocked.add('notes_50');
  if (level >= 10) unlocked.add('level_10');
  if (focusMinutes >= 1000) unlocked.add('focus_1000');

  return unlocked;
}
