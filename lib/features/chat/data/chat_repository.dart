// Chat Repository - Firestore operations for chats

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/chat_models.dart';

final chatRepositoryProvider =
    Provider<ChatRepository>((ref) => ChatRepository());

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  CollectionReference<Map<String, dynamic>> get _chatsCollection => _firestore
      .collection(AppConstants.firestoreUsersCollection)
      .doc(_uid)
      .collection(AppConstants.firestoreChatsCollection);

  /// Create a new chat
  Future<String> createChat({
    required String title,
    required String subject,
    required String mode,
  }) async {
    final docRef = await _chatsCollection.add({
      'title': title,
      'subject': subject,
      'mode': mode,
      'messageCount': 0,
      'lastMessagePreview': '',
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  /// Get all chats for current user (stream)
  Stream<List<ChatSessionModel>> getChats() {
    return _chatsCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatSessionModel.fromFirestore(doc))
            .toList());
  }

  /// Get a single chat by ID
  Future<ChatSessionModel?> getChat(String chatId) async {
    final doc = await _chatsCollection.doc(chatId).get();
    if (!doc.exists) return null;
    return ChatSessionModel.fromFirestore(doc);
  }

  /// Update chat metadata
  Future<void> updateChat(
    String chatId, {
    String? title,
    int? messageCount,
    String? lastMessagePreview,
  }) async {
    final updates = <String, dynamic>{};
    if (title != null) updates['title'] = title;
    if (messageCount != null) updates['messageCount'] = messageCount;
    if (lastMessagePreview != null)
      updates['lastMessagePreview'] = lastMessagePreview;
    updates['updatedAt'] = FieldValue.serverTimestamp();

    await _chatsCollection.doc(chatId).update(updates);
  }

  /// Delete a chat and all its messages
  Future<void> deleteChat(String chatId) async {
    // Delete all messages in subcollection
    final messagesRef = _chatsCollection
        .doc(chatId)
        .collection(AppConstants.firestoreMessagesCollection);
    final batch = _firestore.batch();

    final messages = await messagesRef.get();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }

    // Delete chat document
    batch.delete(_chatsCollection.doc(chatId));

    await batch.commit();
  }

  /// Add a message to a chat
  Future<String> addMessage(String chatId, ChatMessage message) async {
    final messagesRef = _chatsCollection
        .doc(chatId)
        .collection(AppConstants.firestoreMessagesCollection);
    final docRef = await messagesRef.add(message.toJson());
    return docRef.id;
  }

  /// Get messages for a chat (stream)
  Stream<List<ChatMessage>> getMessages(String chatId, {int limit = 50}) {
    return _chatsCollection
        .doc(chatId)
        .collection(AppConstants.firestoreMessagesCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromJson({'id': doc.id, ...doc.data()}))
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt)));
  }

  /// Get messages for AI context (last N messages, oldest first)
  Future<List<ChatMessage>> getMessagesForContext(String chatId,
      {int limit = 10}) async {
    final messagesRef = _chatsCollection
        .doc(chatId)
        .collection(AppConstants.firestoreMessagesCollection);
    final snapshot = await messagesRef
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final messages = snapshot.docs
        .map((doc) => ChatMessage.fromJson({'id': doc.id, ...doc.data()}))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return messages;
  }

  /// Rename a chat
  Future<void> renameChat(String chatId, String newTitle) async {
    await _chatsCollection.doc(chatId).update({
      'title': newTitle,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
