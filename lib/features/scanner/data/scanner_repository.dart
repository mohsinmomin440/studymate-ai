// Scanner Repository - Save solved doubts

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';

final scannerRepositoryProvider =
    Provider<ScannerRepository>((ref) => ScannerRepository());

class ScannerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _doubtsCollection => _firestore
      .collection(AppConstants.firestoreUsersCollection)
      .doc(_uid)
      .collection(AppConstants.firestoreDoubtsCollection);

  /// Save a doubt question and answer
  Future<String> saveDoubt({
    required String question,
    required String answer,
    required String subject,
  }) async {
    final docRef = await _doubtsCollection.add({
      'question': question,
      'answer': answer,
      'subject': subject,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Get all doubts (stream)
  Stream<List<DoubtModel>> getDoubts() {
    return _doubtsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => DoubtModel.fromFirestore(doc)).toList());
  }

  /// Get a single doubt by ID
  Future<DoubtModel?> getDoubt(String doubtId) async {
    final doc = await _doubtsCollection.doc(doubtId).get();
    if (!doc.exists) return null;
    return DoubtModel.fromFirestore(doc);
  }

  /// Delete a doubt
  Future<void> deleteDoubt(String doubtId) async {
    await _doubtsCollection.doc(doubtId).delete();
  }

  /// Convert doubt to flashcards (saves to flashcard collection)
  Stream<List<FlashcardData>> getFlashcardsFromDoubt(String doubtId) {
    return _doubtsCollection
        .doc(doubtId)
        .collection('flashcards')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FlashcardData.fromFirestore(doc))
            .toList());
  }
}

/// Doubt model
class DoubtModel {
  final String id;
  final String question;
  final String answer;
  final String subject;
  final DateTime createdAt;

  DoubtModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.subject,
    required this.createdAt,
  });

  factory DoubtModel.fromJson(Map<String, dynamic> json) => DoubtModel(
        id: json['id'] as String,
        question: json['question'] as String,
        answer: json['answer'] as String,
        subject: json['subject'] as String,
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt'] as String),
      );

  factory DoubtModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoubtModel.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toJson() => {
        'question': question,
        'answer': answer,
        'subject': subject,
        'createdAt': createdAt.toIso8601String(),
      };
}

/// Flashcard data for doubt conversion
class FlashcardData {
  final String front;
  final String back;

  FlashcardData({required this.front, required this.back});

  factory FlashcardData.fromJson(Map<String, dynamic> json) => FlashcardData(
        front: json['front'] as String,
        back: json['back'] as String,
      );

  factory FlashcardData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FlashcardData.fromJson(
        {'front': data['front'], 'back': data['back']});
  }

  Map<String, dynamic> toJson() => {
        'front': front,
        'back': back,
      };
}
