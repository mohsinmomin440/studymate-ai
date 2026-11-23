// Quiz models

import 'package:cloud_firestore/cloud_firestore.dart';

/// Quiz question model
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        question: json['question'] as String,
        options: (json['options'] as List).map((e) => e as String).toList(),
        correctIndex: json['correctIndex'] as int,
        explanation: json['explanation'] as String,
      );

  factory QuizQuestion.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizQuestion.fromJson(data);
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}

/// Quiz model
class Quiz {
  final String id;
  final String title;
  final String subject;
  final String difficulty;
  final List<QuizQuestion> questions;
  final DateTime createdAt;
  final int? durationMinutes; // Optional timer duration (e.g., 30 = 30 min)

  Quiz({
    required this.id,
    required this.title,
    required this.subject,
    required this.difficulty,
    required this.questions,
    required this.createdAt,
    this.durationMinutes,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      difficulty: json['difficulty'] as String,
      questions: (json['questions'] as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
      durationMinutes: json['durationMinutes'] as int?,
    );
  }

  factory Quiz.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quiz.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'subject': subject,
        'difficulty': difficulty,
        'questions': questions.map((q) => q.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        if (durationMinutes != null) 'durationMinutes': durationMinutes,
      };
}

/// Quiz attempt record
class QuizAttempt {
  final String id;
  final String quizId;
  final int score;
  final int total;
  final List<AnsweredQuestion> answers;
  final int durationSec;
  final DateTime createdAt;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.score,
    required this.total,
    required this.answers,
    required this.durationSec,
    required this.createdAt,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'] as String,
      quizId: json['quizId'] as String,
      score: json['score'] as int,
      total: json['total'] as int,
      answers: (json['answers'] as List)
          .map((e) => AnsweredQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      durationSec: json['durationSec'] as int,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.parse(json['createdAt'] as String),
    );
  }

  factory QuizAttempt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuizAttempt.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toJson() => {
        'quizId': quizId,
        'score': score,
        'total': total,
        'answers': answers.map((a) => a.toJson()).toList(),
        'durationSec': durationSec,
        'createdAt': createdAt.toIso8601String(),
      };

  double get percentage => total > 0 ? score / total : 0.0;
}

/// Answered question during quiz attempt
class AnsweredQuestion {
  final String question;
  final List<String> options;
  final int selectedIndex;
  final int correctIndex;
  final String explanation;

  AnsweredQuestion({
    required this.question,
    required this.options,
    required this.selectedIndex,
    required this.correctIndex,
    required this.explanation,
  });

  factory AnsweredQuestion.fromJson(Map<String, dynamic> json) =>
      AnsweredQuestion(
        question: json['question'] as String,
        options: (json['options'] as List).map((e) => e as String).toList(),
        selectedIndex: json['selectedIndex'] as int,
        correctIndex: json['correctIndex'] as int,
        explanation: json['explanation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'selectedIndex': selectedIndex,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}
