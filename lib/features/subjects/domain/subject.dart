class Subject {
  final String id;
  final String name;
  final String description;
  final int difficulty;
  final int targetMinutes;
  final int studiedMinutes;
  final DateTime? examAt;
  final String colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Subject({
    required this.id,
    required this.name,
    this.description = '',
    this.difficulty = 3,
    this.targetMinutes = 1200,
    this.studiedMinutes = 0,
    this.examAt,
    this.colorHex = '#6750A4',
    required this.createdAt,
    required this.updatedAt,
  });

  double get progressPercentage {
    if (targetMinutes <= 0) return 0.0;
    final pct = studiedMinutes / targetMinutes;
    return pct > 1.0 ? 1.0 : pct;
  }

  int? get daysUntilExam {
    if (examAt == null) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final examDay = DateTime(examAt!.year, examAt!.month, examAt!.day);
    return examDay.difference(today).inDays;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'difficulty': difficulty,
      'targetMinutes': targetMinutes,
      'studiedMinutes': studiedMinutes,
      'examAt': examAt?.toIso8601String(),
      'colorHex': colorHex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map, String id) {
    return Subject(
      id: id,
      name: map['name'] as String? ?? 'Untitled Subject',
      description: map['description'] as String? ?? '',
      difficulty: map['difficulty'] as int? ?? 3,
      targetMinutes: map['targetMinutes'] as int? ?? 1200,
      studiedMinutes: map['studiedMinutes'] as int? ?? 0,
      examAt: map['examAt'] != null ? DateTime.tryParse(map['examAt'].toString()) : null,
      colorHex: map['colorHex'] as String? ?? '#6750A4',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Subject copyWith({
    String? name,
    String? description,
    int? difficulty,
    int? targetMinutes,
    int? studiedMinutes,
    DateTime? examAt,
    String? colorHex,
  }) {
    return Subject(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      studiedMinutes: studiedMinutes ?? this.studiedMinutes,
      examAt: examAt ?? this.examAt,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
