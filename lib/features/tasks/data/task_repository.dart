import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/firebase_service.dart';
import '../../auth/presentation/auth_view_model.dart';
import '../domain/task.dart';

abstract class TaskRepository {
  Stream<List<TaskItem>> getTasksStream();
  Future<List<TaskItem>> getTasks();
  Future<void> addTask(TaskItem task);
  Future<void> updateTask(TaskItem task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskStatus(String id);
}

class TaskRepositoryImpl implements TaskRepository {
  final String? _uid;
  FirebaseFirestore? _firestore;

  final _controller = StreamController<List<TaskItem>>.broadcast();
  final List<TaskItem> _localTasks = [];

  TaskRepositoryImpl(this._uid) {
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
    if (_localTasks.isEmpty) {
      final now = DateTime.now();
      _localTasks.addAll([
        TaskItem(
          id: 'task_1',
          title: 'Revise Linked Lists',
          description: 'Singly linked, doubly linked, and circular list operations',
          subjectId: 'sub_ds',
          priority: AppConstants.priorityHigh,
          difficulty: 4,
          estimatedMinutes: 60,
          dueAt: DateTime(now.year, now.month, now.day, 11, 0),
          status: AppConstants.statusPending,
          createdAt: now,
          updatedAt: now,
        ),
        TaskItem(
          id: 'task_2',
          title: 'Complete DBMS Notes',
          description: 'Entity-Relationship diagrams and BCNF normalization',
          subjectId: 'sub_dbms',
          priority: AppConstants.priorityMedium,
          difficulty: 3,
          estimatedMinutes: 90,
          dueAt: DateTime(now.year, now.month, now.day, 14, 0),
          status: AppConstants.statusPending,
          createdAt: now,
          updatedAt: now,
        ),
        TaskItem(
          id: 'task_3',
          title: 'Solve OS Previous Year Questions',
          description: 'Banker algorithm and CPU scheduling numericals',
          subjectId: 'sub_os',
          priority: AppConstants.priorityHigh,
          difficulty: 4,
          estimatedMinutes: 90,
          dueAt: DateTime(now.year, now.month, now.day + 1, 10, 0),
          status: AppConstants.statusPending,
          createdAt: now,
          updatedAt: now,
        ),
        TaskItem(
          id: 'task_4',
          title: 'Read Computer Networks Chapter',
          description: 'Transport layer protocols: TCP vs UDP headers',
          subjectId: 'sub_cn',
          priority: AppConstants.priorityLow,
          difficulty: 2,
          estimatedMinutes: 60,
          dueAt: DateTime(now.year, now.month, now.day + 2, 16, 0),
          status: AppConstants.statusPending,
          createdAt: now,
          updatedAt: now,
        ),
      ]);
      _controller.add(List.unmodifiable(_localTasks));
    }
  }

  @override
  Stream<List<TaskItem>> getTasksStream() {
    final uid = _uid;
    if (_firestore != null && uid != null && uid.isNotEmpty) {
      return _firestore!
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .collection(AppConstants.tasksSubcollection)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty && _localTasks.isNotEmpty) {
          return List.unmodifiable(_localTasks);
        }
        return snapshot.docs
            .map((doc) => TaskItem.fromMap(doc.data(), doc.id))
            .toList();
      });
    }
    return _controller.stream;
  }

  @override
  Future<List<TaskItem>> getTasks() async {
    final uid = _uid;
    if (_firestore != null && uid != null && uid.isNotEmpty) {
      try {
        final snap = await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.tasksSubcollection)
            .get();
        if (snap.docs.isNotEmpty) {
          return snap.docs
              .map((doc) => TaskItem.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('Firestore task fetch error: $e');
      }
    }
    return List.unmodifiable(_localTasks);
  }

  @override
  Future<void> addTask(TaskItem task) async {
    final finalTask = TaskItem(
      id: task.id.isEmpty ? const Uuid().v4() : task.id,
      title: task.title,
      description: task.description,
      subjectId: task.subjectId,
      priority: task.priority,
      difficulty: task.difficulty,
      estimatedMinutes: task.estimatedMinutes,
      dueAt: task.dueAt,
      status: task.status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _localTasks.add(finalTask);
    _controller.add(List.unmodifiable(_localTasks));

    final uid = _uid;
    if (_firestore != null && uid != null && uid.isNotEmpty) {
      try {
        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.tasksSubcollection)
            .doc(finalTask.id)
            .set(finalTask.toMap());
      } catch (e) {
        debugPrint('Firestore task add error: $e');
      }
    }
  }

  @override
  Future<void> updateTask(TaskItem task) async {
    final index = _localTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _localTasks[index] = task;
      _controller.add(List.unmodifiable(_localTasks));
    }

    final uid = _uid;
    if (_firestore != null && uid != null && uid.isNotEmpty) {
      try {
        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.tasksSubcollection)
            .doc(task.id)
            .update(task.toMap());
      } catch (e) {
        debugPrint('Firestore task update error: $e');
      }
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    _localTasks.removeWhere((t) => t.id == id);
    _controller.add(List.unmodifiable(_localTasks));

    final uid = _uid;
    if (_firestore != null && uid != null && uid.isNotEmpty) {
      try {
        await _firestore!
            .collection(AppConstants.usersCollection)
            .doc(uid)
            .collection(AppConstants.tasksSubcollection)
            .doc(id)
            .delete();
      } catch (e) {
        debugPrint('Firestore task delete error: $e');
      }
    }
  }

  @override
  Future<void> toggleTaskStatus(String id) async {
    final index = _localTasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final cur = _localTasks[index];
      final newStatus = cur.status == AppConstants.statusCompleted
          ? AppConstants.statusPending
          : AppConstants.statusCompleted;
      final updated = cur.copyWith(status: newStatus);
      _localTasks[index] = updated;
      _controller.add(List.unmodifiable(_localTasks));

      final uid = _uid;
      if (_firestore != null && uid != null && uid.isNotEmpty) {
        try {
          await _firestore!
              .collection(AppConstants.usersCollection)
              .doc(uid)
              .collection(AppConstants.tasksSubcollection)
              .doc(id)
              .update({'status': newStatus, 'updatedAt': DateTime.now().toIso8601String()});
        } catch (e) {
          debugPrint('Firestore toggle error: $e');
        }
      }
    }
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final authState = ref.watch(authProvider);
  return TaskRepositoryImpl(authState.user?.uid);
});

final tasksStreamProvider = StreamProvider<List<TaskItem>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getTasksStream();
});
