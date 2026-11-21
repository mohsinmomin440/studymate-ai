// Chat models for Firestore storage

library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ai/firebase_ai.dart';

/// Chat message model
class ChatMessage {
  final String id;
  final String role; // 'user' | 'model'
  final String text;
  final DateTime createdAt;
  final String? subject;
  final String? mode;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.subject,
    this.mode,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        role: json['role'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        subject: json['subject'] as String?,
        mode: json['mode'] as String?,
      );

  /// Create a user message
  factory ChatMessage.user({
    required String id,
    required String text,
    String? subject,
    String? mode,
  }) =>
      ChatMessage(
        id: id,
        role: 'user',
        text: text,
        createdAt: DateTime.now(),
        subject: subject,
        mode: mode,
      );

  /// Create a model message
  factory ChatMessage.model({
    required String id,
    required String text,
  }) =>
      ChatMessage(
        id: id,
        role: 'model',
        text: text,
        createdAt: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
        'subject': subject,
        'mode': mode,
      };

  /// Convert to Firestore Content for AI
  Content toContent() {
    if (role == 'user') {
      return Content.text(text);
    } else {
      return Content.model([TextPart(text)]);
    }
  }
}

/// Chat session model
class ChatSessionModel {
  final String id;
  final String title;
  final String subject;
  final String mode;
  final DateTime updatedAt;
  final DateTime createdAt;
  final int messageCount;
  final String? lastMessagePreview;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.mode,
    required this.updatedAt,
    required this.createdAt,
    this.messageCount = 0,
    this.lastMessagePreview,
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) =>
      ChatSessionModel(
        id: json['id'] as String,
        title: json['title'] as String,
        subject: json['subject'] as String,
        mode: json['mode'] as String,
        updatedAt: json['updatedAt'] is Timestamp
            ? (json['updatedAt'] as Timestamp).toDate()
            : DateTime.parse(json['updatedAt'] as String),
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt'] as String),
        messageCount: json['messageCount'] as int? ?? 0,
        lastMessagePreview: json['lastMessagePreview'] as String?,
      );

  factory ChatSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatSessionModel.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'subject': subject,
        'mode': mode,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'messageCount': messageCount,
        'lastMessagePreview': lastMessagePreview,
      };
}
