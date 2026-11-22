// Note Repository - Firestore operations for notes

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/note_models.dart';

final noteRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository());

class NoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _notesCollection => _firestore
      .collection(AppConstants.firestoreUsersCollection)
      .doc(_uid)
      .collection(AppConstants.firestoreNotesCollection);

  /// Create a new note
  Future<String> createNote(NoteModel note) async {
    final docRef = await _notesCollection.add(note.toJson());
    return docRef.id;
  }

  /// Get all notes for current user (stream)
  Stream<List<NoteModel>> getNotes() {
    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList());
  }

  /// Get all notes with search query
  Stream<List<NoteModel>> searchNotes(String query) {
    if (query.isEmpty) {
      return getNotes();
    }

    return _notesCollection
        .orderBy('updatedAt', descending: true)
        .get()
        .then((snapshot) =>
            snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList())
        .asStream();
  }

  /// Get a single note by ID
  Future<NoteModel?> getNote(String noteId) async {
    final doc = await _notesCollection.doc(noteId).get();
    if (!doc.exists) return null;
    return NoteModel.fromFirestore(doc);
  }

  /// Update a note
  Future<void> updateNote(NoteModel note) async {
    await _notesCollection.doc(note.id).update(note.toJson());
  }

  /// Delete a note
  Future<void> deleteNote(String noteId) async {
    await _notesCollection.doc(noteId).delete();
  }

  /// Toggle pin status
  Future<void> togglePin(String noteId) async {
    final note = await getNote(noteId);
    if (note != null) {
      await updateNote(note.copyWith(pinned: !note.pinned));
    }
  }

  /// Add tag to note
  Future<void> addTag(String noteId, String tag) async {
    final note = await getNote(noteId);
    if (note != null) {
      final newTags = [...note.tags, tag]..toSet().toList();
      await updateNote(note.copyWith(tags: newTags));
    }
  }

  /// Remove tag from note
  Future<void> removeTag(String noteId, String tag) async {
    final note = await getNote(noteId);
    if (note != null) {
      final newTags = note.tags.where((t) => t != tag).toList();
      await updateNote(note.copyWith(tags: newTags));
    }
  }

  /// Get notes by subject
  Stream<List<NoteModel>> getNotesBySubject(String subject) {
    return _notesCollection
        .where('subject', isEqualTo: subject)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList());
  }

  /// Get pinned notes
  Stream<List<NoteModel>> getPinnedNotes() {
    return _notesCollection
        .where('pinned', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => NoteModel.fromFirestore(doc)).toList());
  }
}
