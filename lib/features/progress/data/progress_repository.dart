// Progress repository - Firestore operations for user progress

import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/progress_utils.dart';
import '../domain/progress_calculations.dart';
import '../domain/badges.dart';

final progressRepositoryProvider =
    Provider<ProgressRepository>((ref) => ProgressRepository());

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's complete progress once (non-streaming)
  Future<UserProgressData> getUserProgressOnce() async {
    final user = _auth.currentUser;
    if (user == null) return UserProgressData.empty();

    final profileSnapshot = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .get();

    if (!profileSnapshot.exists || profileSnapshot.data() == null) {
      return UserProgressData.empty();
    }

    final profileData = profileSnapshot.data() as Map<String, dynamic>;

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
  }

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

  /// Get unlocked badge IDs for current user
  Future<Set<String>> getUnlockedBadgeIds() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final snapshot = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreBadgesCollection)
        .get();

    return snapshot.docs.map((d) => d.id).toSet();
  }

  /// Get user stats needed for badge evaluation (uses counters on user doc)
  Future<BadgeStats> getBadgeStats() async {
    final user = _auth.currentUser;
    if (user == null) return BadgeStats.empty();

    final userRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid);

    final userDoc = await userRef.get();
    if (!userDoc.exists) return BadgeStats.empty();

    final data = userDoc.data() as Map<String, dynamic>;

    return BadgeStats(
      quizzesCompleted: data['totalQuizzes'] as int? ?? 0,
      notesCreated: data['totalNotes'] as int? ?? 0,
      chatsStarted: data['totalChats'] as int? ?? 0,
      currentStreak: data['streak'] as int? ?? 0,
      cardsReviewed: data['totalCardsReviewed'] as int? ?? 0,
      focusMinutes: data['totalFocusMinutes'] as int? ?? 0,
    );
  }

  /// Check and unlock badges based on current stats
  /// Returns list of newly unlocked badges
  Future<List<Badge>> checkAndUnlockBadges() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final alreadyUnlocked = await getUnlockedBadgeIds();
    final stats = await getBadgeStats();
    final newBadges = badgesToUnlock(stats, alreadyUnlocked);

    if (newBadges.isEmpty) return [];

    // Write new badges to Firestore
    final batch = _firestore.batch();
    final now = Timestamp.now();

    for (final badge in newBadges) {
      final badgeRef = _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(user.uid)
          .collection(AppConstants.firestoreBadgesCollection)
          .doc(badge.id);
      batch.set(badgeRef, {
        'unlockedAt': now,
        'title': badge.title,
        'description': badge.description,
      });
    }

    await batch.commit();

    return newBadges;
  }

  /// Get today's daily stats
  Future<Map<String, dynamic>> getTodayDailyStats() async {
    final user = _auth.currentUser;
    if (user == null) return {};

    final doc = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreDailyStatsCollection)
        .doc(dailyStatsKey())
        .get();

    if (doc.exists && doc.data() != null) {
      return doc.data() as Map<String, dynamic>;
    }
    return {};
  }

  /// Get user's weekly stats for charts
  Future<List<WeeklyStat>> getWeeklyStats() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final now = DateTime.now();
    final List<WeeklyStat> stats = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dateKey = dailyStatsKey(date);

      final doc = await _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(user.uid)
          .collection(AppConstants.firestoreDailyStatsCollection)
          .doc(dateKey)
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

    final todayKey = dailyStatsKey();

    final docRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreDailyStatsCollection)
        .doc(todayKey);

    await docRef.set({
      'date': Timestamp.fromDate(todayOnly()),
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

    final todayKey = dailyStatsKey();

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
        .doc(todayKey);

    await docRef.set({
      'date': Timestamp.fromDate(todayOnly()),
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
    final todayKey = dailyStatsKey();

    final docRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreDailyStatsCollection)
        .doc(todayKey);

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

  /// Record a user activity in a single Firestore transaction.
  /// Updates: xp, level, streak, lastStudyDate, today's dailyStats, and counter fields.
  /// Uses calendar-day comparison for streak calculation.
  /// Implements anti-farming: daily XP caps per action, quiz XP once per attempt.
  /// Returns newly unlocked badges.
  ///
  /// This method is fire-and-forget safe: it never throws to the caller.
  /// Errors are logged but the calling feature continues working.
  Future<List<Badge>> recordActivity(String action,
      {bool isRetry = false}) async {
    // Validate user
    final user = _auth.currentUser;
    if (user == null) return [];

    // Anti-farming: validate action and get base XP
    final baseXp = xpForAction(action);
    if (baseXp == 0) return [];

    // For quiz retries, don't award XP
    if (action == 'quiz' && isRetry) {
      // Still update streak but no XP or badge check for retry
      return _recordQuizRetry();
    }

    try {
      final now = DateTime.now();
      final todayKey = dailyStatsKey();
      final todayOnlyDate = todayOnly();

      final userRef = _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(user.uid);
      final dailyStatsRef = userRef
          .collection(AppConstants.firestoreDailyStatsCollection)
          .doc(todayKey);

      // Run transaction for atomic updates
      await _firestore.runTransaction((transaction) async {
        // Read current user data
        final userSnap = await transaction.get(userRef);
        if (!userSnap.exists) return <Badge>[];

        final userData = userSnap.data() as Map<String, dynamic>;
        final currentXp = userData['xp'] as int? ?? 0;
        final currentStreak = userData['streak'] as int? ?? 0;
        final lastStudyDateRaw = userData['lastStudyDate'];

        // Read today's daily stats for anti-farming check
        final statsSnap = await transaction.get(dailyStatsRef);
        final dailyXpForAction = statsSnap.exists
            ? (statsSnap.data()?['dailyXp_$action'] as int? ?? 0)
            : 0;

        // Anti-farming: check if we can award XP today for this action
        final xpToAward = xpToAwardToday(
          action: action,
          currentDailyXpForAction: dailyXpForAction,
        );

        // If no XP to award (cap reached), still update streak but no XP
        final newXp = currentXp + xpToAward;
        final newLevel = levelFromXp(newXp);

        // Calculate new streak (calendar-day aware)
        DateTime? lastStudyDate;
        if (lastStudyDateRaw is Timestamp) {
          lastStudyDate = lastStudyDateRaw.toDate();
        } else if (lastStudyDateRaw is DateTime) {
          lastStudyDate = lastStudyDateRaw;
        }

        int newStreak = 1;
        if (lastStudyDate != null) {
          newStreak = calculateStreak(
            currentStreak: currentStreak,
            lastStudyDate: lastStudyDate,
            today: now,
          );
        } else {
          // First ever activity
          newStreak = 1;
        }

        // Prepare counter increments
        final counterUpdates = <String, FieldValue>{};
        switch (action) {
          case 'chat':
            counterUpdates['totalChats'] = FieldValue.increment(1);
            break;
          case 'note':
            counterUpdates['totalNotes'] = FieldValue.increment(1);
            break;
          case 'quiz':
            counterUpdates['totalQuizzes'] = FieldValue.increment(1);
            break;
          case 'flashcard_review':
            counterUpdates['totalCardsReviewed'] = FieldValue.increment(1);
            break;
          case 'focus_minute':
            counterUpdates['totalFocusMinutes'] = FieldValue.increment(1);
            break;
        }

        // Update user document with XP, level, streak, lastStudyDate, and counters
        transaction.update(userRef, {
          'xp': newXp,
          'level': newLevel,
          'streak': newStreak,
          'lastStudyDate': Timestamp.fromDate(todayOnlyDate),
          ...counterUpdates,
        });

        // Update today's dailyStats with xpEarned, studyMinutes, and per-action XP tracker
        final statsUpdate = <String, dynamic>{
          'xpEarned': FieldValue.increment(xpToAward),
          'studyMinutes': FieldValue.increment(_minutesForAction(action)),
          'dailyXp_$action': FieldValue.increment(xpToAward),
        };
        if (action == 'quiz') {
          statsUpdate['quizzesTaken'] = FieldValue.increment(1);
        } else if (action == 'flashcard_review') {
          statsUpdate['cardsReviewed'] = FieldValue.increment(1);
        }

        if (statsSnap.exists) {
          transaction.update(dailyStatsRef, statsUpdate);
        } else {
          transaction.set(dailyStatsRef, {
            'date': Timestamp.fromDate(todayOnlyDate),
            'xpEarned': xpToAward,
            'studyMinutes': _minutesForAction(action),
            'quizzesTaken': action == 'quiz' ? 1 : 0,
            'cardsReviewed': action == 'flashcard_review' ? 1 : 0,
            'dailyXp_$action': xpToAward,
          });
        }

        // Return empty list here; badge check happens after transaction
        return <Badge>[];
      });

      // Check and unlock badges after transaction (non-blocking if it fails)
      try {
        final badges = await checkAndUnlockBadges();
        return badges;
      } catch (e) {
        developer.log('Badge check failed after recordActivity: $e',
            name: 'ProgressRepository');
        return [];
      }
    } catch (e) {
      // Never let recordActivity break the calling feature
      developer.log('recordActivity failed for $action: $e',
          name: 'ProgressRepository', error: e);
      return [];
    }
  }

  /// Record quiz retry - updates streak but no XP or badge check
  Future<List<Badge>> _recordQuizRetry() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    try {
      final now = DateTime.now();
      final todayOnlyDate = todayOnly();

      final userRef = _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(user.uid);

      await _firestore.runTransaction((transaction) async {
        final userSnap = await transaction.get(userRef);
        if (!userSnap.exists) return;

        final userData = userSnap.data() as Map<String, dynamic>;
        final currentStreak = userData['streak'] as int? ?? 0;
        final lastStudyDateRaw = userData['lastStudyDate'];

        DateTime? lastStudyDate;
        if (lastStudyDateRaw is Timestamp) {
          lastStudyDate = lastStudyDateRaw.toDate();
        } else if (lastStudyDateRaw is DateTime) {
          lastStudyDate = lastStudyDateRaw;
        }

        int newStreak = 1;
        if (lastStudyDate != null) {
          newStreak = calculateStreak(
            currentStreak: currentStreak,
            lastStudyDate: lastStudyDate,
            today: now,
          );
        }

        transaction.update(userRef, {
          'streak': newStreak,
          'lastStudyDate': Timestamp.fromDate(todayOnlyDate),
        });
      });
    } catch (e) {
      developer.log('_recordQuizRetry failed: $e', name: 'ProgressRepository');
    }
    return [];
  }

  /// Map action to approximate study minutes for dailyStats
  int _minutesForAction(String action) {
    switch (action) {
      case 'chat':
        return 2;
      case 'note':
        return 5;
      case 'quiz':
        return 10;
      case 'flashcard_review':
        return 2;
      case 'focus_minute':
        return 1;
      default:
        return 0;
    }
  }

  /// Get current streak from user profile
  Future<int> getCurrentStreak() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    final doc = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .get();

    final data = doc.data();
    return data?['streak'] as int? ?? 0;
  }

  /// Get all quiz attempts for aggregation
  Future<List<QuizAttempt>> getQuizAttempts() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreQuizAttemptsCollection)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return QuizAttempt(
        id: doc.id,
        quizId: data['quizId'] as String? ?? '',
        title: data['title'] as String? ?? '',
        subject: data['subject'] as String? ?? 'General',
        score: data['score'] as int? ?? 0,
        total: data['total'] as int? ?? 0,
        durationSec: data['durationSec'] as int? ?? 0,
        createdAt:
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        answers: (data['answers'] as List)
            .map((a) => QuizAnswerData.fromJson(a as Map<String, dynamic>))
            .toList(),
      );
    }).toList();
  }
}

/// Quiz attempt model for aggregation (not to be confused with domain model)
class QuizAttempt {
  final String id;
  final String quizId;
  final String title;
  final String subject;
  final int score;
  final int total;
  final int durationSec;
  final DateTime createdAt;
  final List<QuizAnswerData> answers;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.title,
    required this.subject,
    required this.score,
    required this.total,
    required this.durationSec,
    required this.createdAt,
    required this.answers,
  });
}

/// Quiz answer data for aggregation
class QuizAnswerData {
  final String question;
  final String subject;
  final bool correct;
  final String? explanation;

  QuizAnswerData({
    required this.question,
    required this.subject,
    required this.correct,
    this.explanation,
  });

  factory QuizAnswerData.fromJson(Map<String, dynamic> json) => QuizAnswerData(
        question: json['question'] as String? ?? '',
        subject: json['subject'] as String? ?? '',
        correct: json['correct'] as bool? ?? false,
        explanation: json['explanation'] as String?,
      );
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
