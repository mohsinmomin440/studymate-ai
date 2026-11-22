// Flashcard models - Deck and Card with SM-2 scheduling

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studymate_ai/core/utils/sm2.dart';
import 'package:studymate_ai/core/constants/app_constants.dart';

/// Flashcard data (front/back pair)
class FlashcardData {
  final String front;
  final String back;

  FlashcardData({required this.front, required this.back});

  factory FlashcardData.fromJson(Map<String, dynamic> json) => FlashcardData(
        front: json['front'] as String,
        back: json['back'] as String,
      );

  Map<String, dynamic> toJson() => {
        'front': front,
        'back': back,
      };
}

/// Flashcard deck model
class FlashcardDeck {
  final String id;
  final String title;
  final String subject;
  final int cardCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FlashcardDeck({
    required this.id,
    required this.title,
    required this.subject,
    this.cardCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory FlashcardDeck.fromJson(Map<String, dynamic> json) => FlashcardDeck(
        id: json['id'] as String,
        title: json['title'] as String,
        subject: json['subject'] as String,
        cardCount: json['cardCount'] as int? ?? 0,
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? json['updatedAt'] is Timestamp
                ? (json['updatedAt'] as Timestamp).toDate()
                : DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  factory FlashcardDeck.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FlashcardDeck.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'subject': subject,
        'cardCount': cardCount,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  FlashcardDeck copyWith({
    String? id,
    String? title,
    String? subject,
    int? cardCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FlashcardDeck(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      cardCount: cardCount ?? this.cardCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Flashcard instance in a deck with SM-2 scheduling
class Flashcard {
  final String id;
  final String deckId;
  final String front;
  final String back;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime dueAt;
  final int lapses;
  final DateTime? lastReviewed;

  Flashcard({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.easeFactor = AppConstants.sm2InitialEase,
    this.interval = AppConstants.sm2InitialInterval,
    this.repetitions = 0,
    required this.dueAt,
    this.lapses = 0,
    this.lastReviewed,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'] as String,
        deckId: json['deckId'] as String,
        front: json['front'] as String,
        back: json['back'] as String,
        easeFactor:
            json['easeFactor'] as double? ?? AppConstants.sm2InitialEase,
        interval: json['interval'] as int? ?? AppConstants.sm2InitialInterval,
        repetitions: json['repetitions'] as int? ?? 0,
        dueAt: json['dueAt'] is Timestamp
            ? (json['dueAt'] as Timestamp).toDate()
            : DateTime.parse(json['dueAt'] as String),
        lapses: json['lapses'] as int? ?? 0,
        lastReviewed: json['lastReviewed'] != null
            ? json['lastReviewed'] is Timestamp
                ? (json['lastReviewed'] as Timestamp).toDate()
                : DateTime.parse(json['lastReviewed'])
            : null,
      );

  factory Flashcard.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Flashcard.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toJson() => {
        'deckId': deckId,
        'front': front,
        'back': back,
        'easeFactor': easeFactor,
        'interval': interval,
        'repetitions': repetitions,
        'dueAt': dueAt.toIso8601String(),
        'lapses': lapses,
        if (lastReviewed != null)
          'lastReviewed': lastReviewed!.toIso8601String(),
      };

  Flashcard copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? dueAt,
    int? lapses,
    DateTime? lastReviewed,
  }) {
    return Flashcard(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      dueAt: dueAt ?? this.dueAt,
      lapses: lapses ?? this.lapses,
      lastReviewed: lastReviewed ?? this.lastReviewed,
    );
  }

  /// Convert to SM2Card for algorithm calculations
  SM2Card toSM2Card() {
    return SM2Card(
      id: id,
      front: front,
      back: back,
      easeFactor: easeFactor,
      interval: interval,
      repetitions: repetitions,
      dueAt: dueAt,
      lapses: lapses,
      lastReviewed: lastReviewed,
    );
  }

  /// Create from SM2Card
  static Flashcard fromSM2Card(SM2Card card, String deckId) {
    return Flashcard(
      id: card.id,
      deckId: deckId,
      front: card.front,
      back: card.back,
      easeFactor: card.easeFactor,
      interval: card.interval,
      repetitions: card.repetitions,
      dueAt: card.dueAt,
      lapses: card.lapses,
      lastReviewed: card.lastReviewed,
    );
  }
}
