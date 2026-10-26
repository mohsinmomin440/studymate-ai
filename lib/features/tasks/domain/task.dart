import '../../../core/constants/app_constants.dart';

class TaskItem {
  final String id;
  final String title;
  final String description;
  final String subjectId;
  final String priority; // low, medium, high
  final int difficulty; // 1 to 5
  final int estimatedMinutes;
  final DateTime? dueAt;
  final String status; // pending, inProgress, completed, cancelled
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.subjectId,
    this.priority = AppConstants.priorityMedium,
    this.difficulty = 3,
    this.estimatedMinutes = 60,
    this.dueAt,
    this.status = AppConstants.statusPending,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isCompleted => status == AppConstants.statusCompleted;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'subjectId': subjectId,
      'priority': priority,
      'difficulty': difficulty,
      'estimatedMinutes': estimatedMinutes,
      'dueAt': dueAt?.toIso8601String(),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map, String id) {
    return TaskItem(
      id: id,
      title: map['title'] as String? ?? 'Untitled Task',
      description: map['description'] as String? ?? '',
      subjectId: map['subjectId'] as String? ?? '',
      priority: map['priority'] as String? ?? AppConstants.priorityMedium,
      difficulty: map['difficulty'] as int? ?? 3,
      estimatedMinutes: map['estimatedMinutes'] as int? ?? 60,
      dueAt: map['dueAt'] != null ? DateTime.tryParse(map['dueAt'].toString()) : null,
      status: map['status'] as String? ?? AppConstants.statusPending,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  TaskItem copyWith({
    String? title,
    String? description,
    String? subjectId,
    String? priority,
    int? difficulty,
    int? estimatedMinutes,
    DateTime? dueAt,
    String? status,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectId: subjectId ?? this.subjectId,
      priority: priority ?? this.priority,
      difficulty: difficulty ?? this.difficulty,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      dueAt: dueAt ?? this.dueAt,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
