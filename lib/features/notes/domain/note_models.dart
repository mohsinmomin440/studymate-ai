// Note models for Firestore storage

library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Note model for user notes
class NoteModel {
  final String id;
  final String title;
  final String body;
  final String subject;
  final List<String> tags;
  final bool pinned;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.body,
    required this.subject,
    List<String>? tags,
    this.pinned = false,
    required this.createdAt,
    required this.updatedAt,
  }) : tags = tags ?? [];

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        subject: json['subject'] as String,
        tags: (json['tags'] as List?)?.cast<String>() ?? [],
        pinned: json['pinned'] as bool? ?? false,
        createdAt: json['createdAt'] is Timestamp
            ? (json['createdAt'] as Timestamp).toDate()
            : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] is Timestamp
            ? (json['updatedAt'] as Timestamp).toDate()
            : DateTime.parse(json['updatedAt'] as String),
      );

  factory NoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoteModel.fromJson({'id': doc.id, ...data});
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'subject': subject,
        'tags': tags,
        'pinned': pinned,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  NoteModel copyWith({
    String? id,
    String? title,
    String? body,
    String? subject,
    List<String>? tags,
    bool? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      subject: subject ?? this.subject,
      tags: tags ?? this.tags,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
