// Unit tests for SM-2 algorithm
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/core/utils/sm2.dart';
import 'package:studymate_ai/core/constants/app_constants.dart';

void main() {
  group('SM2Algorithm', () {
    group('rating - Again (0)', () {
      test('resets repetitions and increases lapses', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 10,
          repetitions: 3,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.again);

        expect(result.newRepetitions, equals(0));
        expect(result.card.lapses, equals(1));
        expect(result.newEaseFactor, equals(2.3)); // 2.5 - 0.2
        expect(result.newInterval, equals(1)); // minimum interval
      });

      test('decreases ease factor', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 1,
          repetitions: 0,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.again);

        expect(result.newEaseFactor, equals(2.3));
      });

      test('applies penalty for cards with repetitions > 0', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 10,
          repetitions: 5,
          dueAt: DateTime.now(),
          lapses: 2,
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.again);

        expect(result.card.lapses, equals(3));
        expect(result.newInterval, equals(1));
      });
    });

    group('rating - Hard (1)', () {
      test('increments repetitions and increases interval', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 5,
          repetitions: 2,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.hard);

        expect(result.newRepetitions, equals(3));
        // interval * hardPenalty (1.2) = 6
        expect(result.newInterval, equals(6));
        expect(result.newEaseFactor, equals(2.35)); // 2.5 - 0.15
      });

      test('sets interval to 6 for second repetition', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 1,
          repetitions: 1,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.hard);

        expect(result.newRepetitions, equals(2));
        expect(result.newInterval, equals(6));
      });

      test('sets min interval for first repetition', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 1,
          repetitions: 0,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.hard);

        expect(result.newRepetitions, equals(1));
        expect(result.newInterval, equals(1)); // min interval for first rep
      });
    });

    group('rating - Good (2)', () {
      test('increments repetitions and calculates normal interval', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 6,
          repetitions: 2,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.good);

        expect(result.newRepetitions, equals(3));
        // interval * easeFactor = 6 * 2.5 = 15
        expect(result.newInterval, equals(15));
        expect(result.newEaseFactor, equals(2.55)); // 2.5 + 0.05
      });

      test('sets interval to 6 for second repetition', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 1,
          repetitions: 1,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.good);

        expect(result.newRepetitions, equals(2));
        expect(result.newInterval, equals(6));
      });

      test('sets min interval for first repetition', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 1,
          repetitions: 0,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.good);

        expect(result.newRepetitions, equals(1));
        expect(result.newInterval, equals(1)); // min interval for first rep
      });
    });

    group('rating - Easy (3)', () {
      test('increments repetitions and applies easy bonus', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 6,
          repetitions: 2,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.easy);

        expect(result.newRepetitions, equals(3));
        // interval * easeFactor * easyBonus (1.3) = 6 * 2.5 * 1.3 = 19.5
        expect(result.newInterval, equals(20));
        expect(result.newEaseFactor, equals(2.6)); // 2.5 + 0.1
      });
    });

    group('ease factor bounds', () {
      test('minimum ease factor is 1.3', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 1.35,
          interval: 1,
          repetitions: 5,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.again);

        expect(result.newEaseFactor, equals(1.3));
      });

      test('maximum ease factor is 3.0', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.95,
          interval: 10,
          repetitions: 5,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.easy);

        expect(result.newEaseFactor, equals(3.0));
      });
    });

    group('interval bounds', () {
      test('interval is clamped to minimum', () {
        final card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 1.3,
          interval: 36500,
          repetitions: 5,
          dueAt: DateTime.now(),
        );

        final result = SM2Algorithm.calculate(card, SM2Rating.again);

        expect(result.newInterval, equals(AppConstants.sm2MinInterval));
      });
    });

    group('interval growth', () {
      test('interval grows over multiple good ratings', () {
        var card = SM2Card(
          id: 'test-card',
          front: 'Question',
          back: 'Answer',
          easeFactor: 2.5,
          interval: 1,
          repetitions: 0,
          dueAt: DateTime.now(),
        );

        // First good rating: repetitions becomes 1, interval is min(1) for first rep
        card = SM2Algorithm.calculate(card, SM2Rating.good).card;
        expect(card.repetitions, equals(1));
        expect(card.interval, equals(1)); // min interval for first rep

        // Second good rating: repetitions becomes 2, interval is 6
        card = SM2Algorithm.calculate(card, SM2Rating.good).card;
        expect(card.repetitions, equals(2));
        expect(card.interval, equals(6));

        // Third good rating: repetitions becomes 3, easeFactor becomes 2.6
        // interval = 6 * 2.6 = 15.6 → 16
        card = SM2Algorithm.calculate(card, SM2Rating.good).card;
        expect(card.repetitions, equals(3));
        expect(card.interval, equals(16));

        // Fourth good rating: easeFactor becomes 2.65
        // interval = 16 * 2.65 = 42.4 → 42
        card = SM2Algorithm.calculate(card, SM2Rating.good).card;
        expect(card.interval, equals(42));
      });
    });

    group('createNewCard', () {
      test('creates card with initial values', () {
        final card = SM2Algorithm.createNewCard(
          id: 'new-card',
          front: 'What is 2+2?',
          back: '4',
        );

        expect(card.id, equals('new-card'));
        expect(card.front, equals('What is 2+2?'));
        expect(card.back, equals('4'));
        expect(card.easeFactor, equals(AppConstants.sm2InitialEase));
        expect(card.interval, equals(AppConstants.sm2InitialInterval));
        expect(card.repetitions, equals(0));
        expect(card.lapses, equals(0));
      });
    });

    group('getDueCards', () {
      test('returns cards that are due', () {
        final now = DateTime.now();
        final cards = [
          SM2Card(
            id: 'card1',
            front: 'Q1',
            back: 'A1',
            dueAt: now.subtract(Duration(days: 1)),
          ),
          SM2Card(
            id: 'card2',
            front: 'Q2',
            back: 'A2',
            dueAt: now,
          ),
          SM2Card(
            id: 'card3',
            front: 'Q3',
            back: 'A3',
            dueAt: now.add(Duration(days: 1)),
          ),
        ];

        final dueCards = SM2Algorithm.getDueCards(cards);

        expect(dueCards.length, equals(2));
        expect(dueCards.map((c) => c.id), contains('card1'));
        expect(dueCards.map((c) => c.id), contains('card2'));
      });
    });

    group('getCardsByState', () {
      test('categorizes cards by their state', () {
        final now = DateTime.now();
        final cards = [
          SM2Card(id: 'new', front: 'Q', back: 'A', dueAt: now, repetitions: 0),
          SM2Card(
              id: 'learning1',
              front: 'Q',
              back: 'A',
              dueAt: now,
              repetitions: 1),
          SM2Card(
              id: 'review',
              front: 'Q',
              back: 'A',
              dueAt: now,
              repetitions: 3,
              interval: 10),
          SM2Card(
              id: 'mastered',
              front: 'Q',
              back: 'A',
              dueAt: now,
              repetitions: 10,
              interval: 30),
        ];

        final (newCards, learningCards, reviewCards, masteredCards) =
            SM2Algorithm.getCardsByState(cards);

        expect(newCards.length, equals(1));
        expect(newCards.first.id, equals('new'));

        expect(learningCards.length, equals(1));
        expect(learningCards.first.id, equals('learning1'));

        expect(reviewCards.length, equals(1));
        expect(reviewCards.first.id, equals('review'));

        expect(masteredCards.length, equals(1));
        expect(masteredCards.first.id, equals('mastered'));
      });
    });
  });
}
