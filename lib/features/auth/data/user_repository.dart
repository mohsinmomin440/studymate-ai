// User repository - Firestore operations for user profile

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

final userRepositoryProvider =
    Provider<UserRepository>((ref) => UserRepository());

final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  return ref.watch(userRepositoryProvider).userProfileStream();
});

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user's profile from Firestore
  Stream<UserProfile?> userProfileStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value(null);

    return _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.exists ? UserProfile.fromFirestore(snapshot) : null);
  }

  /// Get current user's profile (single fetch)
  Future<UserProfile?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .get();

    if (!doc.exists) return null;
    return UserProfile.fromFirestore(doc);
  }

  /// Create or update user profile
  Future<void> saveUserProfile({
    required String name,
    String? photoUrl,
    String? grade,
    String? language,
    int? dailyGoalMin,
    String? avatarColor,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final Map<String, dynamic> data = {
      'name': name,
      'lastStudyDate': FieldValue.serverTimestamp(),
    };

    if (photoUrl != null) data['photoUrl'] = photoUrl;
    if (grade != null) data['grade'] = grade;
    if (language != null) data['language'] = language;
    if (dailyGoalMin != null) data['dailyGoalMin'] = dailyGoalMin;
    if (avatarColor != null) data['avatarColor'] = avatarColor;

    await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  }

  /// Get user's daily stats for a specific date
  Future<DailyStat?> getDailyStat(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final doc = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreDailyStatsCollection)
        .doc(dateStr)
        .get();

    if (!doc.exists) return null;
    return DailyStat.fromFirestore(doc);
  }

  /// Create daily stat document if it doesn't exist
  Future<void> ensureDailyStatExists(DateTime date) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final docRef = _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestoreDailyStatsCollection)
        .doc(dateStr);

    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'date': Timestamp.fromDate(date),
        'studyMinutes': 0,
        'xpEarned': 0,
        'quizzesTaken': 0,
        'cardsReviewed': 0,
      });
    }
  }

  /// Update daily stats
  Future<void> updateDailyStats({
    required int studyMinutes,
    int? xpEarned,
    int? quizzesTaken,
    int? cardsReviewed,
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

    await ensureDailyStatExists(now);

    await docRef.update({
      'studyMinutes': FieldValue.increment(studyMinutes),
      'xpEarned': FieldValue.increment(xpEarned ?? 0),
      'quizzesTaken': FieldValue.increment(quizzesTaken ?? 0),
      'cardsReviewed': FieldValue.increment(cardsReviewed ?? 0),
    });
  }

  /// Increment xp by amount for today
  Future<void> addXpToday(int amount) async {
    await updateDailyStats(studyMinutes: 0, xpEarned: amount);
  }

  /// Get weekly stats for charts
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

  /// Get upcoming study tasks from active plans
  Stream<List<StudyTask>> upcomingTasksStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(user.uid)
        .collection(AppConstants.firestorePlansCollection)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<StudyTask> tasks = [];
      final now = DateTime.now();

      for (final planDoc in snapshot.docs) {
        final planData = planDoc.data();
        final days = (planData['days'] as List<dynamic>);

        for (final dayData in days) {
          final day = dayData as Map<String, dynamic>;
          final dateStr = day['date'] as String;
          final date = DateTime.parse(dateStr);

          // Check if today or future
          if (!date.isBefore(DateTime(now.year, now.month, now.day))) {
            final dayTasks = (day['tasks'] as List<dynamic>);
            for (final taskData in dayTasks) {
              final task = taskData as Map<String, dynamic>;
              if (!(task['done'] as bool? ?? false)) {
                tasks.add(StudyTask(
                  title: task['title'] as String,
                  subject: task['subject'] as String? ?? '',
                  plannedDate: date,
                ));
              }
            }
          }
        }
      }

      return tasks;
    });
  }
}

/// User profile model
class UserProfile {
  final String name;
  final String? photoUrl;
  final String? grade;
  final String? language;
  final int? dailyGoalMin;
  final int xp;
  final int level;
  final int streak;
  final String? avatarColor;
  final DateTime? lastStudyDate;

  UserProfile({
    required this.name,
    this.photoUrl,
    this.grade,
    this.language,
    this.dailyGoalMin,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.avatarColor,
    this.lastStudyDate,
  });

  factory UserProfile.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserProfile(
      name: data['name'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      grade: data['grade'] as String?,
      language: data['language'] as String?,
      dailyGoalMin:
          data['dailyGoalMin'] as int? ?? AppConstants.defaultDailyGoal,
      xp: data['xp'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      streak: data['streak'] as int? ?? 0,
      avatarColor: data['avatarColor'] as String?,
      lastStudyDate: (data['lastStudyDate'] as Timestamp?)?.toDate(),
    );
  }
}

/// Daily stat document from Firestore
class DailyStat {
  final DateTime date;
  final int studyMinutes;
  final int xpEarned;
  final int quizzesTaken;
  final int cardsReviewed;

  DailyStat({
    required this.date,
    required this.studyMinutes,
    required this.xpEarned,
    required this.quizzesTaken,
    required this.cardsReviewed,
  });

  factory DailyStat.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return DailyStat(
      date: (data['date'] as Timestamp).toDate(),
      studyMinutes: data['studyMinutes'] as int? ?? 0,
      xpEarned: data['xpEarned'] as int? ?? 0,
      quizzesTaken: data['quizzesTaken'] as int? ?? 0,
      cardsReviewed: data['cardsReviewed'] as int? ?? 0,
    );
  }
}

/// Study task model
class StudyTask {
  final String title;
  final String subject;
  final DateTime plannedDate;

  StudyTask({
    required this.title,
    required this.subject,
    required this.plannedDate,
  });
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
