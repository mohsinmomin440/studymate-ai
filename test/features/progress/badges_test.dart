// Unit tests for badge unlock logic

import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/features/progress/domain/badges.dart';

void main() {
  group('badgesToUnlock', () {
    test('empty stats unlocks nothing', () {
      final stats = BadgeStats.empty();
      final result = badgesToUnlock(stats, {});
      expect(result, isEmpty);
    });

    test('first quiz unlocks at 1 quiz', () {
      final stats = BadgeStats(
        quizzesCompleted: 1,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 0,
        cardsReviewed: 0,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), contains('first_quiz'));
      expect(result.length, equals(1));
    });

    test('first quiz does not unlock at 0 quizzes', () {
      final stats = BadgeStats(
        quizzesCompleted: 0,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 0,
        cardsReviewed: 0,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), isNot(contains('first_quiz')));
    });

    test('quiz master 10 unlocks at 10 quizzes', () {
      final stats = BadgeStats(
        quizzesCompleted: 10,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 0,
        cardsReviewed: 0,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), contains('quiz_master_10'));
    });

    test('quiz master 10 does not unlock at 9 quizzes', () {
      final stats = BadgeStats(
        quizzesCompleted: 9,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 0,
        cardsReviewed: 0,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(
          result.map((b) => b.id).toList(), isNot(contains('quiz_master_10')));
    });

    test('first note unlocks at 1 note', () {
      final stats = BadgeStats(
        quizzesCompleted: 0,
        notesCreated: 1,
        chatsStarted: 0,
        currentStreak: 0,
        cardsReviewed: 0,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), contains('first_note'));
    });

    test('first chat unlocks at 1 chat', () {
      final stats = BadgeStats(
        quizzesCompleted: 0,
        notesCreated: 0,
        chatsStarted: 1,
        currentStreak: 0,
        cardsReviewed: 0,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), contains('first_chat'));
    });

    test('streak 7 unlocks at 7 day streak', () {
      final stats = BadgeStats(
        quizzesCompleted: 0,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 7,
        cardsReviewed: 0,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), contains('streak_7'));
    });

    test('streak 7 does not unlock at 6 day streak', () {
      final stats = BadgeStats(
        quizzesCompleted: 0,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 6,
        cardsReviewed: 0,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), isNot(contains('streak_7')));
    });

    test('streak 30 unlocks at 30 day streak', () {
      final stats = BadgeStats(
        quizzesCompleted: 0,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 30,
        cardsReviewed: 0,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), contains('streak_30'));
    });

    test('100 cards unlocks at 100 cards reviewed', () {
      final stats = BadgeStats(
        quizzesCompleted: 0,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 0,
        cardsReviewed: 100,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), contains('cards_100'));
    });

    test('100 cards does not unlock at 99 cards reviewed', () {
      final stats = BadgeStats(
        quizzesCompleted: 0,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 0,
        cardsReviewed: 99,
        focusMinutes: 0,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), isNot(contains('cards_100')));
    });

    test('focus 5 hours unlocks at 300 minutes', () {
      final stats = BadgeStats(
        quizzesCompleted: 0,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 0,
        cardsReviewed: 0,
        focusMinutes: 300,
      );
      final result = badgesToUnlock(stats, {});
      expect(result.map((b) => b.id).toList(), contains('focus_5_hours'));
    });

    test('focus 5 hours does not unlock at 299 minutes', () {
      final stats = BadgeStats(
        quizzesCompleted: 0,
        notesCreated: 0,
        chatsStarted: 0,
        currentStreak: 0,
        cardsReviewed: 0,
        focusMinutes: 299,
      );
      final result = badgesToUnlock(stats, {});
      expect(
          result.map((b) => b.id).toList(), isNot(contains('focus_5_hours')));
    });

    test('multiple badges unlock at once', () {
      final stats = BadgeStats(
        quizzesCompleted: 10,
        notesCreated: 1,
        chatsStarted: 1,
        currentStreak: 7,
        cardsReviewed: 100,
        focusMinutes: 300,
      );
      final result = badgesToUnlock(stats, {});
      // 7 badges: first_quiz, quiz_master_10, first_note, first_chat, streak_7, cards_100, focus_5_hours
      // streak_30 needs 30 streak, not met
      expect(result.length, equals(7));
    });

    test('already unlocked badges are not returned again', () {
      final stats = BadgeStats(
        quizzesCompleted: 10,
        notesCreated: 1,
        chatsStarted: 1,
        currentStreak: 7,
        cardsReviewed: 100,
        focusMinutes: 300,
      );
      final alreadyUnlocked = {'first_quiz', 'first_note', 'first_chat'};
      final result = badgesToUnlock(stats, alreadyUnlocked);
      expect(result.map((b) => b.id).toList(), isNot(contains('first_quiz')));
      expect(result.map((b) => b.id).toList(), isNot(contains('first_note')));
      expect(result.map((b) => b.id).toList(), isNot(contains('first_chat')));
      // 7 total - 3 already unlocked = 4
      expect(result.length, equals(4));
    });

    test('unlocked set with all badges returns empty', () {
      final stats = BadgeStats(
        quizzesCompleted: 10,
        notesCreated: 1,
        chatsStarted: 1,
        currentStreak: 30,
        cardsReviewed: 100,
        focusMinutes: 300,
      );
      final alreadyUnlocked = allBadges.map((b) => b.id).toSet();
      final result = badgesToUnlock(stats, alreadyUnlocked);
      expect(result, isEmpty);
    });

    test('badge order matches allBadges order', () {
      final stats = BadgeStats(
        quizzesCompleted: 10,
        notesCreated: 1,
        chatsStarted: 1,
        currentStreak: 30,
        cardsReviewed: 100,
        focusMinutes: 300,
      );
      final result = badgesToUnlock(stats, {});
      final resultIds = result.map((b) => b.id).toList();
      final expectedOrder = allBadges.map((b) => b.id).toList();
      expect(resultIds, equals(expectedOrder));
    });
  });

  group('Badge model', () {
    test('all badges have unique IDs', () {
      final ids = allBadges.map((b) => b.id).toSet();
      expect(ids.length, equals(allBadges.length));
    });

    test('all badges have non-empty title and description', () {
      for (final badge in allBadges) {
        expect(badge.title, isNotEmpty);
        expect(badge.description, isNotEmpty);
        expect(badge.iconName, isNotEmpty);
      }
    });
  });
}
