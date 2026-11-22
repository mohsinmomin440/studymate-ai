// Flashcard repository - Firestore operations for decks and cards

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/sm2.dart';
import '../domain/flashcard_models.dart';

final flashcardRepositoryProvider =
    Provider<FlashcardRepository>((ref) => FlashcardRepository());

class FlashcardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _decksCollection => _firestore
      .collection(AppConstants.firestoreUsersCollection)
      .doc(_uid)
      .collection(AppConstants.firestoreDecksCollection);

  CollectionReference<Map<String, dynamic>> getDeckCards(String deckId) {
    return _decksCollection.doc(deckId).collection('cards');
  }

  /// Create a new deck
  Future<String> createDeck({
    required String title,
    required String subject,
    List<FlashcardData>? initialCards,
  }) async {
    final deck = FlashcardDeck(
      id: _uuid.v4(),
      title: title,
      subject: subject,
      createdAt: DateTime.now(),
    );

    final deckRef = _decksCollection.doc(deck.id);

    if (initialCards != null && initialCards.isNotEmpty) {
      // Create deck first
      await deckRef.set(deck.toJson());

      // Add cards in batch
      final batch = _firestore.batch();
      for (final card in initialCards) {
        final cardDoc = getDeckCards(deck.id).doc();
        final flashcard = Flashcard(
          id: cardDoc.id,
          deckId: deck.id,
          front: card.front,
          back: card.back,
          dueAt: DateTime.now(),
        );
        batch.set(cardDoc, flashcard.toJson());
      }
      await batch.commit();

      // Update card count
      await deckRef.update({'cardCount': initialCards.length});
    } else {
      await deckRef.set(deck.toJson());
    }

    return deck.id;
  }

  /// Get all decks for current user (stream)
  Stream<List<FlashcardDeck>> getDecks() {
    return _decksCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlashcardDeck.fromFirestore(doc))
            .toList());
  }

  /// Get a single deck by ID
  Future<FlashcardDeck?> getDeck(String deckId) async {
    final doc = await _decksCollection.doc(deckId).get();
    if (!doc.exists) return null;
    return FlashcardDeck.fromFirestore(doc);
  }

  /// Update a deck
  Future<void> updateDeck(FlashcardDeck deck) async {
    await _decksCollection.doc(deck.id).update(deck.toJson());
  }

  /// Delete a deck and all its cards
  Future<void> deleteDeck(String deckId) async {
    final batch = _firestore.batch();

    // Delete all cards in the deck
    final cardsSnap = await getDeckCards(deckId).get();
    for (final doc in cardsSnap.docs) {
      batch.delete(doc.reference);
    }

    // Delete the deck
    batch.delete(_decksCollection.doc(deckId));

    await batch.commit();
  }

  /// Create a card in a deck
  Future<String> createCard({
    required String deckId,
    required String front,
    required String back,
  }) async {
    final card = Flashcard(
      id: _uuid.v4(),
      deckId: deckId,
      front: front,
      back: back,
      dueAt: DateTime.now(),
    );

    await getDeckCards(deckId).doc(card.id).set(card.toJson());
    return card.id;
  }

  /// Get all cards in a deck (stream)
  Stream<List<Flashcard>> getCards(String deckId) {
    return getDeckCards(deckId)
        .where('dueAt', isLessThanOrEqualTo: DateTime.now())
        .orderBy('dueAt')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Flashcard.fromFirestore(doc)).toList());
  }

  /// Get all cards in a deck (non-due, for display/editing)
  Stream<List<Flashcard>> getAllCards(String deckId) {
    return getDeckCards(deckId).orderBy('dueAt').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Flashcard.fromFirestore(doc)).toList());
  }

  /// Get a single card by ID
  Future<Flashcard?> getCard(String deckId, String cardId) async {
    final doc = await getDeckCards(deckId).doc(cardId).get();
    if (!doc.exists) return null;
    return Flashcard.fromFirestore(doc);
  }

  /// Update a card
  Future<void> updateCard(Flashcard card) async {
    await getDeckCards(card.deckId).doc(card.id).update(card.toJson());
  }

  /// Delete a card
  Future<void> deleteCard(String deckId, String cardId) async {
    await getDeckCards(deckId).doc(cardId).delete();
  }

  /// Update card count in deck
  Future<void> _updateCardCount(String deckId, int newCount) async {
    await _decksCollection.doc(deckId).update({'cardCount': newCount});
  }

  /// Record card review and update SM-2 scheduling
  Future<Flashcard> reviewCard({
    required String deckId,
    required String cardId,
    required int rating, // 0=Again, 1=Hard, 2=Good, 3=Easy
  }) async {
    final card = await getCard(deckId, cardId);
    if (card == null) {
      throw Exception('Card not found');
    }

    // Use SM-2 algorithm to calculate new schedule
    final ratingEnum = SM2Rating.values[rating.clamp(0, 3)];
    final result = SM2Algorithm.calculate(card.toSM2Card(), ratingEnum);

    // Convert SM2Card back to Flashcard and update
    final updatedFlashcard = Flashcard.fromSM2Card(result.card, card.deckId);
    await updateCard(updatedFlashcard);

    // Update deck card count (no change in count, just update timestamp)
    await _updateDeckTimestamp(deckId);

    return updatedFlashcard;
  }

  Future<void> _updateDeckTimestamp(String deckId) async {
    await _decksCollection.doc(deckId).update({
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Create cards from AI-generated data (list of maps with 'front' and 'back' keys)
  Future<List<String>> createCardsFromData({
    required String deckId,
    required List<Map<String, dynamic>> cardsData,
  }) async {
    final cardIds = <String>[];
    final batch = _firestore.batch();

    for (final cardData in cardsData) {
      final card = Flashcard(
        id: _uuid.v4(),
        deckId: deckId,
        front: cardData['front'] as String,
        back: cardData['back'] as String,
        dueAt: DateTime.now(),
      );
      batch.set(getDeckCards(deckId).doc(card.id), card.toJson());
      cardIds.add(card.id);
    }

    await batch.commit();

    // Update card count
    await _updateCardCount(
        deckId,
        await _decksCollection.doc(deckId).get().then(
                (d) => (d.data() ?? {'cardCount': 0})['cardCount'] as int) +
            cardsData.length);

    return cardIds;
  }

  /// Get total due cards count across all decks
  Future<int> getDueCardsCount() async {
    if (_uid.isEmpty) return 0;

    final now = Timestamp.now();

    final decksSnapshot = await _decksCollection.get();

    int totalDue = 0;

    for (final deckDoc in decksSnapshot.docs) {
      final cardsSnapshot = await _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(_uid)
          .collection(AppConstants.firestoreDecksCollection)
          .doc(deckDoc.id)
          .collection('cards')
          .where('dueAt', isLessThanOrEqualTo: now)
          .get();

      totalDue += cardsSnapshot.docs.length;
    }

    return totalDue;
  }

  /// Get stats for a deck
  Future<DeckStats> getDeckStats(String deckId) async {
    final deck = await getDeck(deckId);
    if (deck == null) {
      throw Exception('Deck not found');
    }

    final cardsSnap = await getDeckCards(deckId).get();
    final cards =
        cardsSnap.docs.map((d) => Flashcard.fromFirestore(d)).toList();

    final now = DateTime.now();
    int dueCount = 0;
    int masteredCount = 0; // intervals >= 21 days
    int learningCount = 0; // repetitions 1-2
    int newCount = 0; // repetitions 0

    for (final card in cards) {
      if (card.dueAt.isBefore(now) || card.dueAt.isAtSameMomentAs(now)) {
        dueCount++;
      }
      if (card.interval >= 21) {
        masteredCount++;
      }
      if (card.repetitions == 1 || card.repetitions == 2) {
        learningCount++;
      }
      if (card.repetitions == 0) {
        newCount++;
      }
    }

    return DeckStats(
      deck: deck,
      totalCards: cards.length,
      dueToday: dueCount,
      mastered: masteredCount,
      learning: learningCount,
      newCards: newCount,
    );
  }
}

/// Deck statistics
class DeckStats {
  final FlashcardDeck deck;
  final int totalCards;
  final int dueToday;
  final int mastered;
  final int learning;
  final int newCards;

  DeckStats({
    required this.deck,
    required this.totalCards,
    required this.dueToday,
    required this.mastered,
    required this.learning,
    required this.newCards,
  });
}
