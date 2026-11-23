// Quiz repository - Firestore operations for quizzes and attempts

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/quiz_models.dart';

final quizRepositoryProvider =
    Provider<QuizRepository>((ref) => QuizRepository());

class QuizRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _quizzesCollection => _firestore
      .collection(AppConstants.firestoreUsersCollection)
      .doc(_uid)
      .collection(AppConstants.firestoreQuizzesCollection);

  CollectionReference<Map<String, dynamic>> get _attemptsCollection =>
      _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(_uid)
          .collection(AppConstants.firestoreQuizAttemptsCollection);

  /// Create a new quiz from AI-generated question maps
  Future<String> createQuiz({
    required String title,
    required String subject,
    required String difficulty,
    required List<Map<String, dynamic>> questions,
    int? durationMinutes,
  }) async {
    final quizQuestions =
        questions.map((q) => QuizQuestion.fromJson(q)).toList();

    final quiz = Quiz(
      id: _uuid.v4(),
      title: title,
      subject: subject,
      difficulty: difficulty,
      questions: quizQuestions,
      createdAt: DateTime.now(),
      durationMinutes: durationMinutes,
    );

    await _quizzesCollection.doc(quiz.id).set(quiz.toJson());
    return quiz.id;
  }

  /// Get all quizzes for current user (stream)
  Stream<List<Quiz>> getQuizzes() {
    return _quizzesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Quiz.fromFirestore(doc)).toList());
  }

  /// Get a single quiz by ID
  Future<Quiz?> getQuiz(String quizId) async {
    final doc = await _quizzesCollection.doc(quizId).get();
    if (!doc.exists) return null;
    return Quiz.fromFirestore(doc);
  }

  /// Delete a quiz and its attempt history
  Future<void> deleteQuiz(String quizId) async {
    final batch = _firestore.batch();

    // Delete all attempts for this quiz
    final attemptsSnap =
        await _attemptsCollection.where('quizId', isEqualTo: quizId).get();
    for (final doc in attemptsSnap.docs) {
      batch.delete(doc.reference);
    }

    // Delete the quiz
    batch.delete(_quizzesCollection.doc(quizId));

    await batch.commit();
  }

  /// Save a quiz attempt
  Future<String> saveAttempt(QuizAttempt attempt) async {
    final id = _uuid.v4();
    await _attemptsCollection.doc(id).set(attempt.toJson());
    return id;
  }

  /// Get all attempts for a quiz
  Stream<List<QuizAttempt>> getAttempts(String quizId) {
    return _attemptsCollection
        .where('quizId', isEqualTo: quizId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizAttempt.fromFirestore(doc))
            .toList());
  }

  /// Get all attempts for current user
  Stream<List<QuizAttempt>> getAllAttempts() {
    return _attemptsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => QuizAttempt.fromFirestore(doc))
            .toList());
  }

  /// Get quiz history with title
  Stream<List<QuizAttemptWithTitle>> getQuizHistory() {
    return _attemptsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final attempts =
          snapshot.docs.map((doc) => QuizAttempt.fromFirestore(doc)).toList();
      return Future.wait(attempts.map((attempt) async {
        final quiz = await getQuiz(attempt.quizId);
        return QuizAttemptWithTitle(
          attempt: attempt,
          quizTitle: quiz?.title ?? 'Unknown Quiz',
        );
      }));
    });
  }

  /// Get statistics for a quiz
  Future<QuizStats> getQuizStats(String quizId) async {
    final quiz = await getQuiz(quizId);
    if (quiz == null) {
      throw Exception('Quiz not found');
    }

    final attemptsSnap =
        await _attemptsCollection.where('quizId', isEqualTo: quizId).get();
    final attempts =
        attemptsSnap.docs.map((d) => QuizAttempt.fromFirestore(d)).toList();

    if (attempts.isEmpty) {
      return QuizStats(
        quiz: quiz,
        totalAttempts: 0,
        averageScore: 0,
        bestScore: 0,
        totalTimeMinutes: 0,
      );
    }

    final scores = attempts.map((a) => a.percentage).toList();
    final totalTime = attempts.fold<int>(0, (prev, a) => prev + a.durationSec);

    return QuizStats(
      quiz: quiz,
      totalAttempts: attempts.length,
      averageScore:
          (scores.reduce((a, b) => a + b) / scores.length * 100).round(),
      bestScore: (scores.reduce((a, b) => a > b ? a : b) * 100).round(),
      totalTimeMinutes: totalTime ~/ 60,
    );
  }
}

/// Quiz attempt with quiz title (for history display)
class QuizAttemptWithTitle {
  final QuizAttempt attempt;
  final String quizTitle;

  QuizAttemptWithTitle({required this.attempt, required this.quizTitle});
}

/// Quiz statistics
class QuizStats {
  final Quiz quiz;
  final int totalAttempts;
  final int averageScore;
  final int bestScore;
  final int totalTimeMinutes;

  QuizStats({
    required this.quiz,
    required this.totalAttempts,
    required this.averageScore,
    required this.bestScore,
    required this.totalTimeMinutes,
  });
}
