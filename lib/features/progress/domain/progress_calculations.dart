// Pure Dart progress calculations - no Firebase, no Flutter imports
// Calendar-day aware streak, XP amounts, level thresholds, XP to next level

/// XP amounts per action
const Map<String, int> xpPerAction = {
  'chat': 5,
  'note': 10,
  'quiz': 25,
  'flashcard_review': 2,
  'focus_minute': 1,
};

/// Get XP for a given action, defaults to 0 for unknown actions
int xpForAction(String action) {
  return xpPerAction[action] ?? 0;
}

/// Calculate XP required to reach a given level (level 1 = 0 XP)
int xpForLevel(int level) {
  if (level <= 1) return 0;
  int xp = 0;
  int baseXp = 100;
  for (int i = 2; i <= level; i++) {
    xp += baseXp;
    baseXp = (baseXp * 1.5).floor();
  }
  return xp;
}

/// Calculate current level from total XP
int levelFromXp(int totalXp) {
  if (totalXp < 0) return 1;
  int level = 1;
  int xp = totalXp;
  int levelXpRequired = 100;

  while (xp >= levelXpRequired) {
    xp -= levelXpRequired;
    level++;
    levelXpRequired = (levelXpRequired * 1.5).floor();
  }

  return level;
}

/// Calculate XP needed to reach next level from current XP
int xpToNextLevel(int totalXp) {
  final currentLevel = levelFromXp(totalXp);
  final xpForNextLevel = xpForLevel(currentLevel + 1);
  return xpForNextLevel - totalXp;
}

/// Check if streak should continue based on calendar day comparison
/// Returns true if streak continues (last study was today or yesterday), false if reset
bool shouldContinueStreak(DateTime lastStudyDate, DateTime today) {
  final lastDate =
      DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);
  final todayOnly = DateTime(today.year, today.month, today.day);
  final yesterday = DateTime(today.year, today.month, today.day - 1);

  // Continue if last study was today or yesterday
  return lastDate == todayOnly || lastDate == yesterday;
}

/// Calculate new streak count based on today's activity
/// Calendar-day aware: compares only year/month/day, not 24-hour spans
int calculateStreak({
  required int currentStreak,
  required DateTime lastStudyDate,
  required DateTime today,
}) {
  // First ever activity (no previous study recorded)
  if (currentStreak == 0) {
    return 1;
  }

  if (shouldContinueStreak(lastStudyDate, today)) {
    final lastDateOnly =
        DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);

    // If last study was today, streak stays the same
    if (lastDateOnly == todayOnly) {
      return currentStreak;
    }
    // Otherwise (was yesterday), increment
    return currentStreak + 1;
  }
  // Missed a day - reset streak to 1 (today counts as day 1)
  return 1;
}
