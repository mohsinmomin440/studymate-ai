/// App-wide constants
library;

class AppConstants {
  // App info
  static const String appName = 'StudyMate AI';
  static const String packageName = 'com.studymate.studymate_ai';
  static const String version = '1.0.0';
  static const int buildNumber = 1;

  // Firebase
  static const String firestoreUsersCollection = 'users';
  static const String firestoreChatsCollection = 'chats';
  static const String firestoreMessagesCollection = 'messages';
  static const String firestoreDoubtsCollection = 'doubts';
  static const String firestoreNotesCollection = 'notes';
  static const String firestoreDecksCollection = 'decks';
  static const String firestoreCardsCollection = 'cards';
  static const String firestoreQuizzesCollection = 'quizzes';
  static const String firestoreQuizAttemptsCollection = 'quizAttempts';
  static const String firestorePlansCollection = 'plans';
  static const String firestoreDailyStatsCollection = 'dailyStats';
  static const String firestoreBadgesCollection = 'badges';

  // AI - Gemini models (current Firebase AI Logic model names)
  static const String defaultChatModel = 'gemini-3.5-flash';
  static const String defaultCheapModel = 'gemini-3.5-flash-lite';
  static const int maxChatHistoryMessages = 10;
  static const int maxOutputTokensChat = 2048;
  static const int maxOutputTokensJSON = 4096;
  static const double temperatureChat = 0.7;
  static const double temperatureJSON = 0.3;

  // Quota limits (free tier protection)
  static const int dailyAIRequestLimit = 50;
  static const int dailyImageRequestLimit = 10;
  static const int maxInputChars = 10000;

  // Spaced repetition (SM-2)
  static const double sm2InitialEase = 2.5;
  static const int sm2InitialInterval = 1;
  static const int sm2MinInterval = 1;
  static const double sm2EasyBonus = 1.3;
  static const double sm2HardPenalty = 1.2;
  static const double sm2AgainPenalty = 0.5;

  // Gamification
  static const int xpPerChatMessage = 5;
  static const int xpPerNoteCreated = 10;
  static const int xpPerQuizCompleted = 25;
  static const int xpPerFlashcardReview = 2;
  static const int xpPerFocusMinute = 1;
  static const int xpPerLevelBase = 100;
  static const double xpLevelMultiplier = 1.5;

  // Streak
  static const int streakFreezeCost = 50; // XP cost

  // Notifications
  static const String channelId = 'studymate_notifications';
  static const String channelName = 'StudyMate Notifications';
  static const String channelDescription = 'Study reminders and streak alerts';

  // UI
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Localization
  static const List<String> supportedLocales = ['en', 'gu', 'hi'];
  static const String defaultLocale = 'en';

  // Subjects
  static const List<String> subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'Gujarati',
    'Hindi',
    'Social Science',
    'Computer Science',
    'Other',
  ];

  // Chat modes
  static const List<String> chatModes = [
    'Explain Simply',
    'Step-by-Step',
    'Exam Answer',
    'Quick Summary',
    'Teach Me Like I\'m 10',
  ];

  // Quiz difficulties
  static const List<String> quizDifficulties = ['Easy', 'Medium', 'Hard'];

  // Quiz question counts
  static const List<int> quizQuestionCounts = [5, 10, 15];

  // Focus timer defaults
  static const int defaultFocusMinutes = 25;
  static const int defaultBreakMinutes = 5;
  static const int defaultLongBreakMinutes = 15;
  static const int defaultSessionsBeforeLongBreak = 4;

  // User defaults
  static const int defaultDailyGoal = 60; // minutes
}

/// Remote Config keys
class RemoteConfigKeys {
  static const String chatModel = 'chat_model';
  static const String cheapModel = 'cheap_model';
  static const String enableQuizGeneration = 'enable_quiz_generation';
  static const String enableFlashcardGeneration = 'enable_flashcard_generation';
  static const String enableStudyPlanner = 'enable_study_planner';
  static const String enableDoubtScanner = 'enable_doubt_scanner';
  static const String dailyAIRequestLimit = 'daily_ai_request_limit';
  static const String motivationalQuotes = 'motivational_quotes';
  static const String appMaintenanceMode = 'app_maintenance_mode';
  static const String maintenanceMessage = 'maintenance_message';
}

/// Shared preferences keys
class PrefKeys {
  static const String onboardingCompleted = 'onboarding_completed';
  static const String selectedLanguage = 'selected_language';
  static const String selectedTheme = 'selected_theme'; // system, light, dark
  static const String dailyGoalMinutes = 'daily_goal_minutes';
  static const String aiResponseLanguage = 'ai_response_language';
  static const String aiResponseStyle = 'ai_response_style';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String streakFreezeUsed = 'streak_freeze_used';
  static const String lastStreakFreezeDate = 'last_streak_freeze_date';
  static const String dailyAIUsageCount = 'daily_ai_usage_count';
  static const String dailyAIUsageDate = 'daily_ai_usage_date';
  static const String dailyImageUsageCount = 'daily_image_usage_count';
  static const String dailyImageUsageDate = 'daily_image_usage_date';
  static const String hasSeenWhatsNew = 'has_seen_whats_new';
  static const String lastAppVersion = 'last_app_version';
}
