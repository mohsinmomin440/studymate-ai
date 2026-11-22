// Badge definitions and unlock logic - pure Dart, no Flutter/Firebase imports

/// Badge model
class Badge {
  final String id;
  final String title;
  final String description;
  final String
      iconName; // e.g. 'emoji_events', 'local_fire_department', 'menu_book'

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
  });
}

/// All available badge definitions
const List<Badge> allBadges = [
  Badge(
    id: 'first_quiz',
    title: 'First Quiz',
    description: 'Complete your first quiz',
    iconName: 'quiz',
  ),
  Badge(
    id: 'quiz_master_10',
    title: 'Quiz Master',
    description: 'Complete 10 quizzes',
    iconName: 'emoji_events',
  ),
  Badge(
    id: 'first_note',
    title: 'Note Taker',
    description: 'Create your first note',
    iconName: 'note',
  ),
  Badge(
    id: 'first_chat',
    title: 'Curious Mind',
    description: 'Ask your first question to AI',
    iconName: 'chat',
  ),
  Badge(
    id: 'streak_7',
    title: 'Week Warrior',
    description: 'Maintain a 7-day study streak',
    iconName: 'local_fire_department',
  ),
  Badge(
    id: 'streak_30',
    title: 'Month Master',
    description: 'Maintain a 30-day study streak',
    iconName: 'whatshot',
  ),
  Badge(
    id: 'cards_100',
    title: 'Flashcard Pro',
    description: 'Review 100 flashcards',
    iconName: 'menu_book',
  ),
  Badge(
    id: 'focus_5_hours',
    title: 'Focus Champion',
    description: 'Accumulate 5 hours of focus time',
    iconName: 'timer',
  ),
];

/// User stats snapshot for badge evaluation
class BadgeStats {
  final int quizzesCompleted;
  final int notesCreated;
  final int chatsStarted;
  final int currentStreak;
  final int cardsReviewed;
  final int focusMinutes;

  const BadgeStats({
    required this.quizzesCompleted,
    required this.notesCreated,
    required this.chatsStarted,
    required this.currentStreak,
    required this.cardsReviewed,
    required this.focusMinutes,
  });

  /// Create empty stats
  BadgeStats.empty()
      : quizzesCompleted = 0,
        notesCreated = 0,
        chatsStarted = 0,
        currentStreak = 0,
        cardsReviewed = 0,
        focusMinutes = 0;
}

/// Check which badges should be newly unlocked based on current stats
/// Returns only badges that are newly earned (not in alreadyUnlocked)
List<Badge> badgesToUnlock(BadgeStats stats, Set<String> alreadyUnlocked) {
  final newlyUnlocked = <Badge>[];

  // First Quiz
  if (stats.quizzesCompleted >= 1 && !alreadyUnlocked.contains('first_quiz')) {
    newlyUnlocked.add(allBadges.firstWhere((b) => b.id == 'first_quiz'));
  }

  // 10 Quizzes
  if (stats.quizzesCompleted >= 10 &&
      !alreadyUnlocked.contains('quiz_master_10')) {
    newlyUnlocked.add(allBadges.firstWhere((b) => b.id == 'quiz_master_10'));
  }

  // First Note
  if (stats.notesCreated >= 1 && !alreadyUnlocked.contains('first_note')) {
    newlyUnlocked.add(allBadges.firstWhere((b) => b.id == 'first_note'));
  }

  // First Chat
  if (stats.chatsStarted >= 1 && !alreadyUnlocked.contains('first_chat')) {
    newlyUnlocked.add(allBadges.firstWhere((b) => b.id == 'first_chat'));
  }

  // 7-Day Streak
  if (stats.currentStreak >= 7 && !alreadyUnlocked.contains('streak_7')) {
    newlyUnlocked.add(allBadges.firstWhere((b) => b.id == 'streak_7'));
  }

  // 30-Day Streak
  if (stats.currentStreak >= 30 && !alreadyUnlocked.contains('streak_30')) {
    newlyUnlocked.add(allBadges.firstWhere((b) => b.id == 'streak_30'));
  }

  // 100 Cards
  if (stats.cardsReviewed >= 100 && !alreadyUnlocked.contains('cards_100')) {
    newlyUnlocked.add(allBadges.firstWhere((b) => b.id == 'cards_100'));
  }

  // 5 Hours Focus (300 minutes)
  if (stats.focusMinutes >= 300 && !alreadyUnlocked.contains('focus_5_hours')) {
    newlyUnlocked.add(allBadges.firstWhere((b) => b.id == 'focus_5_hours'));
  }

  return newlyUnlocked;
}
