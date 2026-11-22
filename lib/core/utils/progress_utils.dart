/// Progress utilities for streak, XP, level, and badge calculations
/// These are pure functions that can be tested without Firebase.
library;

import '../constants/app_constants.dart';

/// Calculate the XP required to reach a given level
int xpForLevel(int level) {
  if (level <= 1) return 0;
  int xp = 0;
  int baseXp = AppConstants.xpPerLevelBase;
  for (int i = 2; i <= level; i++) {
    xp += baseXp;
    baseXp = (baseXp * AppConstants.xpLevelMultiplier).round();
  }
  return xp;
}

/// Calculate the current level from total XP
int calculateLevel(int totalXp) {
  int level = 1;
  int xp = totalXp;
  int levelXpRequired = AppConstants.xpPerLevelBase;

  while (xp >= levelXpRequired) {
    xp -= levelXpRequired;
    level++;
    levelXpRequired =
        (levelXpRequired * AppConstants.xpLevelMultiplier).round();
  }

  return level;
}

/// Calculate XP progress towards next level (0.0 to 1.0)
double calculateXpProgress(int totalXp) {
  int level = calculateLevel(totalXp);
  int xpForThisLevel = xpForLevel(level);
  int xpForNextLevel = xpForLevel(level + 1);
  int xpInCurrentLevel = totalXp - xpForThisLevel;
  int xpNeededForNext = xpForNextLevel - xpForThisLevel;
  return xpNeededForNext > 0 ? xpInCurrentLevel / xpNeededForNext : 1.0;
}

/// Calculate XP reward for a given activity
int calculateXpReward(String activity) {
  switch (activity) {
    case 'chat_message':
      return AppConstants.xpPerChatMessage;
    case 'note_created':
      return AppConstants.xpPerNoteCreated;
    case 'quiz_completed':
      return AppConstants.xpPerQuizCompleted;
    case 'flashcard_review':
      return AppConstants.xpPerFlashcardReview;
    case 'focus_minute':
      return AppConstants.xpPerFocusMinute;
    default:
      return 0;
  }
}

/// Check if streak should continue or reset based on last study date
/// Returns true if streak continues, false if it should reset
bool shouldContinueStreak(DateTime lastStudyDate, DateTime today) {
  final yesterday = DateTime(today.year, today.month, today.day - 1);
  final lastDate =
      DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);
  final todayOnly = DateTime(today.year, today.month, today.day);

  return lastDate.isAfter(yesterday) || (lastDate == todayOnly);
}

/// Calculate new streak count based on today's activity
int calculateNewStreak({
  required int currentStreak,
  required DateTime lastStudyDate,
  required DateTime today,
}) {
  if (shouldContinueStreak(lastStudyDate, today)) {
    // If last study was today, streak stays the same
    final lastDateOnly =
        DateTime(lastStudyDate.year, lastStudyDate.month, lastStudyDate.day);
    final todayOnly = DateTime(today.year, today.month, today.day);
    if (lastDateOnly == todayOnly) {
      return currentStreak;
    }
    // Otherwise increment
    return currentStreak + 1;
  }
  // Reset streak to 1 (today)
  return 1;
}
