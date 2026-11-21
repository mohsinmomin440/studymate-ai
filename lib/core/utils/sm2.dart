// SM-2 Spaced Repetition Algorithm
// Based on SuperMemo 2 algorithm for flashcard scheduling

import '../constants/app_constants.dart';

enum SM2Rating {
  again(0, 'Again'),
  hard(1, 'Hard'),
  good(2, 'Good'),
  easy(3, 'Easy');

  const SM2Rating(this.value, this.label);
  final int value;
  final String label;
}

/// SM-2 Card model
class SM2Card {
  SM2Card({
    required this.id,
    required this.front,
    required this.back,
    this.easeFactor = AppConstants.sm2InitialEase,
    this.interval = AppConstants.sm2InitialInterval,
    this.repetitions = 0,
    required this.dueAt,
    this.lapses = 0,
    this.lastReviewed,
  });

  final String id;
  final String front;
  final String back;
  final double easeFactor;
  final int interval;
  final int repetitions;
  final DateTime dueAt;
  final int lapses;
  final DateTime? lastReviewed;

  SM2Card copyWith({
    String? id,
    String? front,
    String? back,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? dueAt,
    int? lapses,
    DateTime? lastReviewed,
  }) {
    return SM2Card(
      id: id ?? this.id,
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

  factory SM2Card.fromJson(Map<String, dynamic> json) => SM2Card(
        id: json['id'] as String,
        front: json['front'] as String,
        back: json['back'] as String,
        easeFactor:
            json['easeFactor'] as double? ?? AppConstants.sm2InitialEase,
        interval: json['interval'] as int? ?? AppConstants.sm2InitialInterval,
        repetitions: json['repetitions'] as int? ?? 0,
        dueAt: DateTime.parse(json['dueAt'] as String),
        lapses: json['lapses'] as int? ?? 0,
        lastReviewed: json['lastReviewed'] != null
            ? DateTime.parse(json['lastReviewed'])
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'front': front,
        'back': back,
        'easeFactor': easeFactor,
        'interval': interval,
        'repetitions': repetitions,
        'dueAt': dueAt.toIso8601String(),
        'lapses': lapses,
        'lastReviewed': lastReviewed?.toIso8601String(),
      };
}

/// SM-2 Result model
class SM2Result {
  SM2Result({
    required this.card,
    required this.rating,
    required this.nextDue,
    required this.newInterval,
    required this.newEaseFactor,
    required this.newRepetitions,
    required this.newLapses,
  });

  final SM2Card card;
  final SM2Rating rating;
  final DateTime nextDue;
  final int newInterval;
  final double newEaseFactor;
  final int newRepetitions;
  final int newLapses;
}

/// SM-2 Algorithm implementation
class SM2Algorithm {
  /// Calculate the next review date and card parameters based on rating
  static SM2Result calculate(SM2Card card, SM2Rating rating) {
    double newEaseFactor = card.easeFactor;
    int newInterval = card.interval;
    int newRepetitions = card.repetitions;
    int newLapses = card.lapses;

    switch (rating) {
      case SM2Rating.again:
        newRepetitions = 0;
        newInterval = AppConstants.sm2MinInterval;
        newLapses += 1;
        newEaseFactor = _calculateNewEaseFactor(newEaseFactor, rating);
        break;

      case SM2Rating.hard:
        if (card.repetitions == 0) {
          newInterval = AppConstants.sm2MinInterval;
        } else if (card.repetitions == 1) {
          newInterval = 6;
        } else {
          newInterval = (card.interval * AppConstants.sm2HardPenalty).round();
        }
        newRepetitions += 1;
        newEaseFactor = _calculateNewEaseFactor(newEaseFactor, rating);
        break;

      case SM2Rating.good:
        if (card.repetitions == 0) {
          newInterval = AppConstants.sm2MinInterval;
        } else if (card.repetitions == 1) {
          newInterval = 6;
        } else {
          newInterval = (card.interval * card.easeFactor).round();
        }
        newRepetitions += 1;
        newEaseFactor = _calculateNewEaseFactor(newEaseFactor, rating);
        break;

      case SM2Rating.easy:
        if (card.repetitions == 0) {
          newInterval = AppConstants.sm2MinInterval;
        } else if (card.repetitions == 1) {
          newInterval = 6;
        } else {
          newInterval =
              (card.interval * card.easeFactor * AppConstants.sm2EasyBonus)
                  .round();
        }
        newRepetitions += 1;
        newEaseFactor = _calculateNewEaseFactor(newEaseFactor, rating);
        break;
    }

    // Minimum interval
    newInterval =
        newInterval.clamp(AppConstants.sm2MinInterval, 36500); // Max ~100 years

    // Ease factor bounds
    newEaseFactor = newEaseFactor.clamp(1.3, 3.0);

    final nextDue = DateTime.now().add(Duration(days: newInterval));

    final updatedCard = card.copyWith(
      easeFactor: newEaseFactor,
      interval: newInterval,
      repetitions: newRepetitions,
      dueAt: nextDue,
      lapses: newLapses,
      lastReviewed: DateTime.now(),
    );

    return SM2Result(
      card: updatedCard,
      rating: rating,
      nextDue: nextDue,
      newInterval: newInterval,
      newEaseFactor: newEaseFactor,
      newRepetitions: newRepetitions,
      newLapses: newLapses,
    );
  }

  static double _calculateNewEaseFactor(double currentEase, SM2Rating rating) {
    switch (rating) {
      case SM2Rating.again:
        return currentEase - 0.2;
      case SM2Rating.hard:
        return currentEase - 0.15;
      case SM2Rating.good:
        return currentEase + 0.05;
      case SM2Rating.easy:
        return currentEase + 0.1;
    }
  }

  /// Create a new card with initial SM-2 parameters
  static SM2Card createNewCard({
    required String id,
    required String front,
    required String back,
  }) {
    return SM2Card(
      id: id,
      front: front,
      back: back,
      dueAt: DateTime.now(),
    );
  }

  /// Get cards due for review
  static List<SM2Card> getDueCards(List<SM2Card> cards) {
    final now = DateTime.now();
    return cards
        .where((card) =>
            card.dueAt.isBefore(now) || card.dueAt.isAtSameMomentAs(now))
        .toList();
  }

  /// Get cards grouped by state
  static (List<SM2Card>, List<SM2Card>, List<SM2Card>, List<SM2Card>)
      getCardsByState(List<SM2Card> cards) {
    final newCards = <SM2Card>[];
    final learning = <SM2Card>[];
    final review = <SM2Card>[];
    final mastered = <SM2Card>[];

    for (final card in cards) {
      if (card.repetitions == 0) {
        newCards.add(card);
      } else if (card.repetitions == 1) {
        learning.add(card);
      } else if (card.interval < 21) {
        review.add(card);
      } else {
        mastered.add(card);
      }
    }

    return (newCards, learning, review, mastered);
  }
}
