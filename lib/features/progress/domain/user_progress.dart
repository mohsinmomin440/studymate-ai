// User progress domain model

/// User progress state for StateNotifier
class UserProgressState {
  final String name;
  final String? photoUrl;
  final int xp;
  final int level;
  final int streak;
  final int dailyGoalMin;
  final int todayMinutes;
  final int cardsDueToday;
  final int badgesUnlocked;
  final double xpProgress;

  const UserProgressState({
    required this.name,
    this.photoUrl,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.dailyGoalMin = 60,
    this.todayMinutes = 0,
    this.cardsDueToday = 0,
    this.badgesUnlocked = 0,
    required this.xpProgress,
  });

  UserProgressState copyWith({
    String? name,
    String? photoUrl,
    int? xp,
    int? level,
    int? streak,
    int? dailyGoalMin,
    int? todayMinutes,
    int? cardsDueToday,
    int? badgesUnlocked,
    double? xpProgress,
  }) {
    return UserProgressState(
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      dailyGoalMin: dailyGoalMin ?? this.dailyGoalMin,
      todayMinutes: todayMinutes ?? this.todayMinutes,
      cardsDueToday: cardsDueToday ?? this.cardsDueToday,
      badgesUnlocked: badgesUnlocked ?? this.badgesUnlocked,
      xpProgress: xpProgress ?? this.xpProgress,
    );
  }
}

/// Weekly stat for charts
class WeeklyStat {
  final DateTime date;
  final int studyMinutes;
  final int xpEarned;
  final int quizScore;

  WeeklyStat({
    required this.date,
    required this.studyMinutes,
    required this.xpEarned,
    required this.quizScore,
  });
}
