class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String timezone;
  final int dailyStudyMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.timezone = 'Asia/Kolkata',
    this.dailyStudyMinutes = 180,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'timezone': timezone,
      'dailyStudyMinutes': dailyStudyMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      timezone: map['timezone'] as String? ?? 'Asia/Kolkata',
      dailyStudyMinutes: map['dailyStudyMinutes'] as int? ?? 180,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  AppUser copyWith({
    String? displayName,
    int? dailyStudyMinutes,
    String? timezone,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      timezone: timezone ?? this.timezone,
      dailyStudyMinutes: dailyStudyMinutes ?? this.dailyStudyMinutes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
