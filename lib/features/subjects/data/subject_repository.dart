import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/firebase_service.dart';
import '../../auth/presentation/auth_view_model.dart';
import '../domain/subject.dart';

abstract class SubjectRepository {
  Stream<List<Subject>> getSubjectsStream();
  Future<List<Subject>> getSubjects();
  Future<Subject?> getSubjectById(String id);
  Future<void> addSubject(Subject subject);
  Future<void> updateSubject(Subject subject);
  Future<void> deleteSubject(String id);
}

class SubjectRepositoryImpl implements SubjectRepository {
  final String? _uid;
  FirebaseFirestore? _firestore;

  final _controller = StreamController<List<Subject>>.broadcast();
  final List<Subject> _localSubjects = [];

  SubjectRepositoryImpl(this._uid) {
    if (FirebaseService.isInitialized) {
      try {
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        debugPrint('Firestore not ready: $e');
      }
    }
    _initDefaultData();
  }

  void _initDefaultData() {
    if (_localSubjects.isEmpty) {
      final now = DateTime.now();
      _localSubjects.addAll([
        Subject(
          id: 'sub_ds',
          name: 'Data Structures',
          description: 'Core data structures and algorithms',
          difficulty: 4,
          targetMinutes: 1200, // 20 hrs
          studiedMinutes: 780, // 13 hrs (~65%)
          examAt: now.add(const Duration(days: 12)),
          colorHex: '#6750A4',
          createdAt: now,
          updatedAt: now,
        ),
        Subject(
          id: 'sub_dbms',
          name: 'Database Management',
          description: 'Relational algebra, SQL, Normalization',
          difficulty: 3,
          targetMinutes: 960, // 16 hrs
          studiedMinutes: 400, // ~42%
          examAt: now.add(const Duration(days: 20)),
          colorHex: '#3882F6',
          createdAt: now,
          updatedAt: now,
        ),
        Subject(
          id: 'sub_os',
          name: 'Operating Systems',
          description: 'Process management, memory paging, deadlocks',
          difficulty: 4,
          targetMinutes: 900, // 15 hrs
          studiedMinutes: 250, // ~28%
          examAt: now.add(const Duration(days: 27)),
          colorHex: '#10B981',
          createdAt: now,
          updatedAt: now,
        ),
        Subject(
          id: 'sub_cn',
          name: 'Computer Networks',
          description: 'OSI Model, TCP/IP, Routing algorithms',
          difficulty: 3,
          targetMinutes: 720, // 12 hrs
          studiedMinutes: 130, // ~18%
          examAt: now.add(const Duration(days: 35)),
          colorHex: '#F59E0B',
          createdAt: now,
          updatedAt: now,
        ),
      ]);
      _controller.add(List.unmodifiable(_localSubjects));
    }
  }

  @override
  Stream<List<Subject>> getSubjectsStream() {
    final uid = _uid;
    if (_firestore != null && uid != null && uid.isNotEmpty) {
      return _firestore!
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .collection(AppConstants.subjectsSubcollection)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty && _localSubjects.isNotEmpty) {
          return List.unmodifiable(_localSubjects);
        }
        final list = snapshot.docs
            .map((doc) => Subject.fromMap(doc.data(), doc.id))
            .toList();
        return list;
      });
    }
    return _controller.stream;
  }

  @override
  Future<List<Subject>> getSubjects() async {
    final uid = _uid;
    if (_firestore != null && uid != null && uid.isNotEmpty) {
      try {
        final snap = await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.subjectsSubcollection)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((doc) => Subject.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('Firestore fetch error: $e');
      }
    }
    return List.unmodifiable(_localSubjects);
  }

  @override
  Future<Subject?> getSubjectById(String id) async {
    try {
      return _localSubjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addSubject(Subject subject) async {
    final sub = subject.id.isEmpty
        ? subject.copyWith()
        : subject;
    final finalSubject = Subject(
      id: sub.id.isEmpty ? const Uuid().v4() : sub.id,
      name: sub.name,
      description: sub.description,
      difficulty: sub.difficulty,
      targetMinutes: sub.targetMinutes,
      studiedMinutes: sub.studiedMinutes,
      examAt: sub.examAt,
      colorHex: sub.colorHex,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _localSubjects.add(finalSubject);
    _controller.add(List.unmodifiable(_localSubjects));

    final uid = _uid;
    if (_firestore != null && uid != null && uid.isNotEmpty) {
      try {
        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.subjectsSubcollection)
            .doc(finalSubject.id)
            .set(finalSubject.toMap());
      } catch (e) {
        debugPrint('Firestore save error: $e');
      }
    }
  }

  @override
  Future<void> updateSubject(Subject subject) async {
    final index = _localSubjects.indexWhere((s) => s.id == subject.id);
    if (index != -1) {
      _localSubjects[index] = subject;
      _controller.add(List.unmodifiable(_localSubjects));
    }

    final uid = _uid;
    if (_firestore != null && uid != null && uid.isNotEmpty) {
      try {
        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.subjectsSubcollection)
            .doc(subject.id)
            .update(subject.toMap());
      } catch (e) {
        debugPrint('Firestore update error: $e');
      }
    }
  }

  @override
  Future<void> deleteSubject(String id) async {
    _localSubjects.removeWhere((s) => s.id == id);
    _controller.add(List.unmodifiable(_localSubjects));

    final uid = _uid;
    if (_firestore != null && uid != null && uid.isNotEmpty) {
      try {
        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.subjectsSubcollection)
            .doc(id)
            .delete();
      } catch (e) {
        debugPrint('Firestore delete error: $e');
      }
    }
  }
}

final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  final authState = ref.watch(authProvider);
  return SubjectRepositoryImpl(authState.user?.uid);
});

final subjectsStreamProvider = StreamProvider<List<Subject>>((ref) {
  final repo = ref.watch(subjectRepositoryProvider);
  return repo.getSubjectsStream();
});
