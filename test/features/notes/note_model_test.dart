// Unit tests for NoteModel
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:studymate_ai/features/notes/domain/note_models.dart';

void main() {
  late NoteModel noteModel;

  setUp(() {
    noteModel = NoteModel(
      id: 'test-note-id',
      title: 'Test Note',
      body: 'This is a test note body.',
      subject: 'Mathematics',
      tags: ['algebra', 'equations'],
      pinned: true,
      createdAt: DateTime(2024, 1, 15, 10, 30),
      updatedAt: DateTime(2024, 1, 15, 11, 45),
    );
  });

  group('NoteModel', () {
    test('creates a valid NoteModel with all properties', () {
      expect(noteModel.id, equals('test-note-id'));
      expect(noteModel.title, equals('Test Note'));
      expect(noteModel.body, equals('This is a test note body.'));
      expect(noteModel.subject, equals('Mathematics'));
      expect(noteModel.tags, equals(['algebra', 'equations']));
      expect(noteModel.pinned, isTrue);
      expect(noteModel.createdAt, equals(DateTime(2024, 1, 15, 10, 30)));
      expect(noteModel.updatedAt, equals(DateTime(2024, 1, 15, 11, 45)));
    });

    test('creates a NoteModel with default tags and pinned values', () {
      final noteWithoutOptional = NoteModel(
        id: 'test-id',
        title: 'Title',
        body: 'Body',
        subject: 'Science',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(noteWithoutOptional.tags, isEmpty);
      expect(noteWithoutOptional.pinned, isFalse);
    });

    group('fromJson', () {
      test('parses a valid JSON map correctly', () {
        final json = {
          'id': 'json-note-id',
          'title': 'JSON Note',
          'body': 'JSON body content',
          'subject': 'Physics',
          'tags': ['mechanics', 'forces'],
          'pinned': false,
          'createdAt': '2024-01-15T10:00:00.000',
          'updatedAt': '2024-01-15T10:30:00.000',
        };

        final note = NoteModel.fromJson(json);

        expect(note.id, equals('json-note-id'));
        expect(note.title, equals('JSON Note'));
        expect(note.body, equals('JSON body content'));
        expect(note.subject, equals('Physics'));
        expect(note.tags, equals(['mechanics', 'forces']));
        expect(note.pinned, isFalse);
      });

      test('parses JSON with Timestamp dates', () {
        final now = Timestamp.fromDate(DateTime(2024, 1, 15, 10, 0));
        final later = Timestamp.fromDate(DateTime(2024, 1, 15, 11, 0));

        final json = {
          'id': 'timestamp-note',
          'title': 'Timestamp Note',
          'body': 'Body',
          'subject': 'Chemistry',
          'tags': [],
          'pinned': true,
          'createdAt': now,
          'updatedAt': later,
        };

        final note = NoteModel.fromJson(json);

        expect(note.createdAt, equals(DateTime(2024, 1, 15, 10, 0)));
        expect(note.updatedAt, equals(DateTime(2024, 1, 15, 11, 0)));
      });

      test('handles null optional fields', () {
        final json = {
          'id': 'minimal-note',
          'title': 'Minimal',
          'body': 'Content',
          'subject': 'Biology',
          'createdAt': '2024-01-15T10:00:00.000',
          'updatedAt': '2024-01-15T10:30:00.000',
        };

        final note = NoteModel.fromJson(json);

        expect(note.tags, isEmpty);
        expect(note.pinned, isFalse);
      });
    });

    group('toJson', () {
      test('converts NoteModel to JSON map correctly', () {
        final json = noteModel.toJson();

        expect(json['title'], equals('Test Note'));
        expect(json['body'], equals('This is a test note body.'));
        expect(json['subject'], equals('Mathematics'));
        expect(json['tags'], equals(['algebra', 'equations']));
        expect(json['pinned'], isTrue);
        expect(json['createdAt'], equals('2024-01-15T10:30:00.000'));
        expect(json['updatedAt'], equals('2024-01-15T11:45:00.000'));
      });

      test('JSON does not include id field (as per Firestore convention)', () {
        final json = noteModel.toJson();
        expect(json.containsKey('id'), isFalse);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated title', () {
        final updated = noteModel.copyWith(title: 'Updated Title');

        expect(updated.title, equals('Updated Title'));
        expect(updated.body, equals(noteModel.body));
        expect(updated.id, equals(noteModel.id));
      });

      test('creates a copy with updated tags', () {
        final updated = noteModel.copyWith(
          tags: ['new-tag'],
          pinned: false,
        );

        expect(updated.tags, equals(['new-tag']));
        expect(updated.pinned, isFalse);
      });

      test('creates a copy with updated timestamps', () {
        final newDate = DateTime(2024, 2, 1);
        final updated = noteModel.copyWith(
          createdAt: newDate,
          updatedAt: newDate,
        );

        expect(updated.createdAt, equals(newDate));
        expect(updated.updatedAt, equals(newDate));
      });

      test('preserves unchanged values when not specified', () {
        final updated = noteModel.copyWith(title: 'New Title');

        expect(updated.title, equals('New Title'));
        expect(updated.body, equals(noteModel.body));
        expect(updated.subject, equals(noteModel.subject));
        expect(updated.tags, equals(noteModel.tags));
        expect(updated.pinned, equals(noteModel.pinned));
      });
    });
  });
}