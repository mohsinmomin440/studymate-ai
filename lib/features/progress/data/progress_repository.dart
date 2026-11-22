// Progress repository - Firestore operations for user progress

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/progress_utils.dart';

final progressRepositoryProvider =
    Provider<ProgressRepository>((ref) => ProgressRepository());

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's complete progress stream
  Stream<UserProgressData> getUserProgressStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(UserProgressData.empty());

    final profileStream = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .snapshots();

    return profileStream.asyncMap((snapshot) async {
      if (!snapshot.exists || snapshot.data() == null) {
        return UserProgressData.empty();
      }

      final profileData = snapshot.data() as Map<String, dynamic>;

      // Get badges count
      final badgeSnapshot = await _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(user.uid)
          .collection(AppConstants.firestoreBadgesCollection)
          .get();
      final badgeCount = badgeSnapshot.docs.length;

      // Get due cards count
      final cardsDue = await getDueFlashcardsCount();

      return UserProgressData.fromJson(profileData,
          cardsDue: cardsDue, badgeCount: badgeCount);
    });
  }

  /// Get user's weekly stats for charts
  Future<List<WeeklyStat>> getWeeklyStats() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final now = DateTime.now();
    final List<WeeklyStat> stats = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final doc = await _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(user.uid)
          .collection(AppConstants.firestoreDailyStatsCollection)
          .doc(dateStr)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        stats.add(WeeklyStat(
          date: date,
          studyMinutes: data['studyMinutes'] as int? ?? 0,
          xpEarned: data['xpEarned'] as int? ?? 0,
          quizScore: data['quizScore'] as int? ?? 0,
        ));
      } else {
        stats.add(
            WeeklyStat(date: date, studyMinutes: 0, xpEarned: 0, quizScore: 0));
      }
    }

    return stats;
  }

  /// Update user XP and level
  Future<void> updateXp(int xpToAdd) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid);

    // Get current XP and calculate level up
    final doc = await userRef.get();
    final currentXp = doc.data()?['xp'] as int? ?? 0;
    final newXp = currentXp + xpToAdd;

    // Calculate new level
    final newLevel = calculateLevel(newXp);

    await userRef.update({
      'xp': newXp,
      'level': newLevel,
    });

    // Check for badge unlocks
    checkBadgeUnlocksFromStats(xpEarned: xpToAdd);
  }

  /// Add study minutes for today
  Future<void> addStudyMinutes(int minutes, [int xp = 0]) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final docRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreDailyStatsCollection)
        .doc(dateStr);

    await docRef.set({
      'date': Timestamp.fromDate(now),
      'studyMinutes': FieldValue.increment(minutes),
      'xpEarned': FieldValue.increment(xp),
      'quizzesTaken': FieldValue.increment(0),
      'cardsReviewed': FieldValue.increment(0),
    }, SetOptions(merge: true));
  }

  /// Record quiz completion
  Future<void> recordQuizCompletion({
    required String quizId,
    required String title,
    required String subject,
    required int score,
    required int total,
    required List<QuizAnswer> answers,
    int durationSec = 0,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Record quiz attempt
    await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreQuizAttemptsCollection)
        .add({
      'quizId': quizId,
      'title': title,
      'subject': subject,
      'score': score,
      'total': total,
      'answers': answers.map((a) => a.toJson()).toList(),
      'durationSec': durationSec,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update daily stats
    final docRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreDailyStatsCollection)
        .doc(dateStr);

    await docRef.set({
      'date': Timestamp.fromDate(now),
      'studyMinutes': FieldValue.increment(0),
      'xpEarned': FieldValue.increment(AppConstants.xpPerQuizCompleted),
      'quizzesTaken': FieldValue.increment(1),
      'cardsReviewed': FieldValue.increment(0),
    }, SetOptions(merge: true));

    // Update user stats
    final userRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid);
    final userDoc = await userRef.get();
    final currentXp = userDoc.data()?['xp'] as int? ?? 0;
    final newXp = currentXp + AppConstants.xpPerQuizCompleted;

    await userRef.update({
      'xp': newXp,
      'level': calculateLevel(newXp),
    });
  }

  /// Record flashcard review
  Future<void> recordFlashcardReview({
    required String deckId,
    required int cardsReviewed,
    required int correct,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final docRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreDailyStatsCollection)
        .doc(dateStr);

    await docRef.set({
      'date': Timestamp.fromDate(now),
      'studyMinutes': FieldValue.increment(cardsReviewed * 2),
      'xpEarned': FieldValue.increment(
          cardsReviewed * AppConstants.xpPerFlashcardReview),
      'quizzesTaken': FieldValue.increment(0),
      'cardsReviewed': FieldValue.increment(cardsReviewed),
    }, SetOptions(merge: true));
  }

  /// Check and unlock badges based on user stats
  void checkBadgeUnlocksFromStats({int xpEarned = 0}) {
    // This is called from updateXp - badges are managed separately
    // Real badge checking would need full stats fetch
  }

  /// Get due flashcards count (cards with dueAt <= now)
  Future<int> getDueFlashcardsCount() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final now = Timestamp.now();

    final snapshot = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreDecksCollection)
        .get();

    int totalDue = 0;

    for (final deckDoc in snapshot.docs) {
      final cardsSnapshot = await _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(user.uid)
          .collection(AppConstants.firestoreDecksCollection)
          .doc(deckDoc.id)
          .collection(AppConstants.firestoreCardsCollection)
          .where('dueAt', isLessThanOrEqualTo: now)
          .get();

      totalDue += cardsSnapshot.docs.length;
    }

    return totalDue;
  }
}

/// User progress data model
class UserProgressData {
  final String name;
  final String? photoUrl;
  final int xp;
  final int level;
  final int streak;
  final int dailyGoalMin;
  final int cardsDueToday;
  final int badgesCount;
  final double xpProgress;

  UserProgressData({
    required this.name,
    this.photoUrl,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.dailyGoalMin = 60,
    this.cardsDueToday = 0,
    this.badgesCount = 0,
    double? xpProgress,
  }) : xpProgress = xpProgress ?? 0.0;

  UserProgressData.empty()
      : name = '',
        photoUrl = null,
        xp = 0,
        level = 1,
        streak = 0,
        dailyGoalMin = 60,
        cardsDueToday = 0,
        badgesCount = 0,
        xpProgress = 0.0;

  factory UserProgressData.fromJson(Map<String, dynamic> json,
      {int cardsDue = 0, int badgeCount = 0}) {
    final xp = json['xp'] as int? ?? 0;
    final level = json['level'] as int? ?? 1;

    return UserProgressData(
      name: json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      xp: xp,
      level: level,
      streak: json['streak'] as int? ?? 0,
      dailyGoalMin: json['dailyGoalMin'] as int? ?? 60,
      cardsDueToday: cardsDue,
      badgesCount: badgeCount,
      xpProgress: calculateXpProgress(xp),
    );
  }
}

/// Weekly stat for charts
class WeeklyStat {
  final DateTime date;
  final int studyMinutes;
  final int xpEarned;
  final int quizScore;

  WeeklyStat({
    required this.date,
    required this.studyMinutes,
    required this.xpEarned,
    required this.quizScore,
  });
}

/// Quiz answer model for recording
class QuizAnswer {
  final String question;
  final String subject;
  final bool correct;
  final String? explanation;

  QuizAnswer({
    required this.question,
    required this.subject,
    required this.correct,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'subject': subject,
        'correct': correct,
        'explanation': explanation,
      };
}
