/// Global constants across StudyMate AI
class AppConstants {
  AppConstants._();

  static const String appName = 'StudyMate AI';
  static const String appTagline = 'Your Intelligent Study Companion';
  static const String appTaglineDark = 'Smarter Study. Brighter Future.';

  // SharedPreferences Keys
  static const String themeModeKey = 'app_theme_mode';
  static const String hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String userAuthKey = 'user_auth_cached';

  // Firestore Collections & Subcollections
  static const String usersCollection = 'users';
  static const String subjectsSubcollection = 'subjects';
  static const String tasksSubcollection = 'tasks';
  static const String studyPlansSubcollection = 'study_plans';
  static const String studySessionsSubcollection = 'study_sessions';
  static const String quizSetsSubcollection = 'quiz_sets';
  static const String quizAttemptsSubcollection = 'quiz_attempts';
  static const String studyMaterialsSubcollection = 'study_materials';

  // Task Statuses
  static const String statusPending = 'pending';
  static const String statusInProgress = 'inProgress';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // Task Priorities
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';
}
