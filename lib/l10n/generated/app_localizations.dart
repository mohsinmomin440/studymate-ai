import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'StudyMate AI'**
  String get appName;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// No description provided for @letsStudy.
  ///
  /// In en, this message translates to:
  /// **'Let\'s study smarter today.'**
  String get letsStudy;

  /// No description provided for @continueStudying.
  ///
  /// In en, this message translates to:
  /// **'Continue Studying'**
  String get continueStudying;

  /// No description provided for @todaysGoal.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Goal'**
  String get todaysGoal;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @askAI.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAI;

  /// No description provided for @scanDoubt.
  ///
  /// In en, this message translates to:
  /// **'Scan Doubt'**
  String get scanDoubt;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @quickQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quick Quiz'**
  String get quickQuiz;

  /// No description provided for @dueFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Due Flashcards'**
  String get dueFlashcards;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @xp.
  ///
  /// In en, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @gujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get gujarati;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @aiResponseLanguage.
  ///
  /// In en, this message translates to:
  /// **'AI Response Language'**
  String get aiResponseLanguage;

  /// No description provided for @aiResponseStyle.
  ///
  /// In en, this message translates to:
  /// **'AI Response Style'**
  String get aiResponseStyle;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleSignIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade/Class'**
  String get grade;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects of Interest'**
  String get subjects;

  /// No description provided for @dailyStudyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Study Goal (minutes)'**
  String get dailyStudyGoal;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retries.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retries;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @emptyState.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get emptyState;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @chatModeExplainSimply.
  ///
  /// In en, this message translates to:
  /// **'Explain Simply'**
  String get chatModeExplainSimply;

  /// No description provided for @chatModeStepByStep.
  ///
  /// In en, this message translates to:
  /// **'Step-by-Step'**
  String get chatModeStepByStep;

  /// No description provided for @chatModeExamAnswer.
  ///
  /// In en, this message translates to:
  /// **'Exam Answer'**
  String get chatModeExamAnswer;

  /// No description provided for @chatModeQuickSummary.
  ///
  /// In en, this message translates to:
  /// **'Quick Summary'**
  String get chatModeQuickSummary;

  /// No description provided for @chatModeTeachMeLikeIm10.
  ///
  /// In en, this message translates to:
  /// **'Teach Me Like I\'m 10'**
  String get chatModeTeachMeLikeIm10;

  /// No description provided for @subjectMathematics.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get subjectMathematics;

  /// No description provided for @subjectPhysics.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get subjectPhysics;

  /// No description provided for @subjectChemistry.
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get subjectChemistry;

  /// No description provided for @subjectBiology.
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get subjectBiology;

  /// No description provided for @subjectEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get subjectEnglish;

  /// No description provided for @subjectGujarati.
  ///
  /// In en, this message translates to:
  /// **'Gujarati'**
  String get subjectGujarati;

  /// No description provided for @subjectHindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get subjectHindi;

  /// No description provided for @subjectSocialScience.
  ///
  /// In en, this message translates to:
  /// **'Social Science'**
  String get subjectSocialScience;

  /// No description provided for @subjectComputerScience.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get subjectComputerScience;

  /// No description provided for @subjectOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get subjectOther;

  /// No description provided for @flashcardRatingAgain.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get flashcardRatingAgain;

  /// No description provided for @flashcardRatingHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get flashcardRatingHard;

  /// No description provided for @flashcardRatingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get flashcardRatingGood;

  /// No description provided for @flashcardRatingEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get flashcardRatingEasy;

  /// No description provided for @quizDifficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get quizDifficultyEasy;

  /// No description provided for @quizDifficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get quizDifficultyMedium;

  /// No description provided for @quizDifficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get quizDifficultyHard;

  /// No description provided for @focusTimerFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focusTimerFocus;

  /// No description provided for @focusTimerShortBreak.
  ///
  /// In en, this message translates to:
  /// **'Short Break'**
  String get focusTimerShortBreak;

  /// No description provided for @focusTimerLongBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get focusTimerLongBreak;

  /// No description provided for @focusTimerStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get focusTimerStart;

  /// No description provided for @focusTimerPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get focusTimerPause;

  /// No description provided for @focusTimerReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get focusTimerReset;

  /// No description provided for @focusTimerSessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get focusTimerSessions;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @flashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get flashcards;

  /// No description provided for @quizzes.
  ///
  /// In en, this message translates to:
  /// **'Quizzes'**
  String get quizzes;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @planner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get planner;

  /// No description provided for @focus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get focus;

  /// No description provided for @study.
  ///
  /// In en, this message translates to:
  /// **'Study'**
  String get study;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @designSystemPreview.
  ///
  /// In en, this message translates to:
  /// **'Design System Preview'**
  String get designSystemPreview;

  /// No description provided for @gradientButton.
  ///
  /// In en, this message translates to:
  /// **'Gradient Button'**
  String get gradientButton;

  /// No description provided for @outlinedButton.
  ///
  /// In en, this message translates to:
  /// **'Outlined Button'**
  String get outlinedButton;

  /// No description provided for @textButton.
  ///
  /// In en, this message translates to:
  /// **'Text Button'**
  String get textButton;

  /// No description provided for @filledButton.
  ///
  /// In en, this message translates to:
  /// **'Filled Button'**
  String get filledButton;

  /// No description provided for @glassCard.
  ///
  /// In en, this message translates to:
  /// **'Glass Card'**
  String get glassCard;

  /// No description provided for @statTile.
  ///
  /// In en, this message translates to:
  /// **'Stat Tile'**
  String get statTile;

  /// No description provided for @progressRing.
  ///
  /// In en, this message translates to:
  /// **'Progress Ring'**
  String get progressRing;

  /// No description provided for @streakBadge.
  ///
  /// In en, this message translates to:
  /// **'Streak Badge'**
  String get streakBadge;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// No description provided for @loadingStats.
  ///
  /// In en, this message translates to:
  /// **'Loading stats...'**
  String get loadingStats;

  /// No description provided for @deckNotFound.
  ///
  /// In en, this message translates to:
  /// **'Deck not found'**
  String get deckNotFound;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @answer.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get answer;

  /// No description provided for @front.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get front;

  /// No description provided for @subjectMath.
  ///
  /// In en, this message translates to:
  /// **'Math'**
  String get subjectMath;

  /// No description provided for @subjectScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get subjectScience;

  /// No description provided for @subjectEnglishSubject.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get subjectEnglishSubject;

  /// No description provided for @subjectSocial.
  ///
  /// In en, this message translates to:
  /// **'Social Science'**
  String get subjectSocial;

  /// No description provided for @studyHub.
  ///
  /// In en, this message translates to:
  /// **'Study Hub'**
  String get studyHub;

  /// No description provided for @dailyStats.
  ///
  /// In en, this message translates to:
  /// **'Daily Stats'**
  String get dailyStats;

  /// No description provided for @weeklyStats.
  ///
  /// In en, this message translates to:
  /// **'Weekly Stats'**
  String get weeklyStats;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @studyMinutes.
  ///
  /// In en, this message translates to:
  /// **'Study minutes'**
  String get studyMinutes;

  /// No description provided for @xpEarned.
  ///
  /// In en, this message translates to:
  /// **'XP earned'**
  String get xpEarned;

  /// No description provided for @cardsReviewed.
  ///
  /// In en, this message translates to:
  /// **'Cards reviewed'**
  String get cardsReviewed;

  /// No description provided for @quizzesTaken.
  ///
  /// In en, this message translates to:
  /// **'Quizzes taken'**
  String get quizzesTaken;

  /// No description provided for @weakTopics.
  ///
  /// In en, this message translates to:
  /// **'Weak Topics'**
  String get weakTopics;

  /// No description provided for @estimatedTime.
  ///
  /// In en, this message translates to:
  /// **'Estimated time'**
  String get estimatedTime;

  /// No description provided for @addWeakTopic.
  ///
  /// In en, this message translates to:
  /// **'Add Weak Topic'**
  String get addWeakTopic;

  /// No description provided for @examDate.
  ///
  /// In en, this message translates to:
  /// **'Exam Date'**
  String get examDate;

  /// No description provided for @hoursPerDay.
  ///
  /// In en, this message translates to:
  /// **'Hours per Day'**
  String get hoursPerDay;

  /// No description provided for @generateStudyPlan.
  ///
  /// In en, this message translates to:
  /// **'Generate Study Plan'**
  String get generateStudyPlan;

  /// No description provided for @studyPlanner.
  ///
  /// In en, this message translates to:
  /// **'Study Planner'**
  String get studyPlanner;

  /// No description provided for @noPlansYet.
  ///
  /// In en, this message translates to:
  /// **'No plans yet. Generate your first plan above!'**
  String get noPlansYet;

  /// No description provided for @studyPlanGenerated.
  ///
  /// In en, this message translates to:
  /// **'Study plan generated successfully!'**
  String get studyPlanGenerated;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark Done'**
  String get markDone;

  /// No description provided for @unmarkDone.
  ///
  /// In en, this message translates to:
  /// **'Unmark Done'**
  String get unmarkDone;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @startReview.
  ///
  /// In en, this message translates to:
  /// **'Start Review'**
  String get startReview;

  /// No description provided for @retryWrongQuestions.
  ///
  /// In en, this message translates to:
  /// **'Retry Wrong Questions Only'**
  String get retryWrongQuestions;

  /// No description provided for @retryQuiz.
  ///
  /// In en, this message translates to:
  /// **'Retry Quiz'**
  String get retryQuiz;

  /// No description provided for @backToQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Back to Quizzes'**
  String get backToQuizzes;

  /// No description provided for @takeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take Quiz'**
  String get takeQuiz;

  /// No description provided for @submitAnswer.
  ///
  /// In en, this message translates to:
  /// **'Submit Answer'**
  String get submitAnswer;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @quizNotFound.
  ///
  /// In en, this message translates to:
  /// **'Quiz not found'**
  String get quizNotFound;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @question1of.
  ///
  /// In en, this message translates to:
  /// **'Question {question} of {total}'**
  String question1of(Object question, Object total);

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @wrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get wrong;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @finalScore.
  ///
  /// In en, this message translates to:
  /// **'Final Score'**
  String get finalScore;

  /// No description provided for @outOf.
  ///
  /// In en, this message translates to:
  /// **'out of'**
  String get outOf;

  /// No description provided for @reviewAnswers.
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get reviewAnswers;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating...'**
  String get generating;

  /// No description provided for @aiIsWorking.
  ///
  /// In en, this message translates to:
  /// **'StudyMate AI is working on it...'**
  String get aiIsWorking;

  /// No description provided for @profileSetup.
  ///
  /// In en, this message translates to:
  /// **'Set Up Your Profile'**
  String get profileSetup;

  /// No description provided for @helpPersonalize.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your experience'**
  String get helpPersonalize;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update: {error}'**
  String failedToUpdate(Object error);

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @tapAvatarToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap avatar to change'**
  String get tapAvatarToChange;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @classGrade.
  ///
  /// In en, this message translates to:
  /// **'Class / Grade'**
  String get classGrade;

  /// No description provided for @dailyStudyGoalMinutes.
  ///
  /// In en, this message translates to:
  /// **'Daily Study Goal (minutes)'**
  String get dailyStudyGoalMinutes;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveChanges;

  /// No description provided for @linkAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get linkAccount;

  /// No description provided for @linkGoogleEmail.
  ///
  /// In en, this message translates to:
  /// **'Link Google / Email Account'**
  String get linkGoogleEmail;

  /// No description provided for @linkEmailAccount.
  ///
  /// In en, this message translates to:
  /// **'Link Email Account'**
  String get linkEmailAccount;

  /// No description provided for @linkGoogle.
  ///
  /// In en, this message translates to:
  /// **'Link Google'**
  String get linkGoogle;

  /// No description provided for @linkEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get linkEmail;

  /// No description provided for @linkAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Link an account to save your data permanently and access it on other devices.'**
  String get linkAccountWarning;

  /// No description provided for @accountAlreadyLinked.
  ///
  /// In en, this message translates to:
  /// **'Account already linked'**
  String get accountAlreadyLinked;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @motivationalQuote1.
  ///
  /// In en, this message translates to:
  /// **'The expert in anything was once a beginner.'**
  String get motivationalQuote1;

  /// No description provided for @motivationalQuote2.
  ///
  /// In en, this message translates to:
  /// **'Success is the sum of small efforts repeated day in and day out.'**
  String get motivationalQuote2;

  /// No description provided for @motivationalQuote3.
  ///
  /// In en, this message translates to:
  /// **'Learning never exhausts the mind.'**
  String get motivationalQuote3;

  /// No description provided for @motivationalQuote4.
  ///
  /// In en, this message translates to:
  /// **'Your only limit is you.'**
  String get motivationalQuote4;

  /// No description provided for @motivationalQuote5.
  ///
  /// In en, this message translates to:
  /// **'Start where you are. Use what you have. Do what you can.'**
  String get motivationalQuote5;

  /// No description provided for @flashcard.
  ///
  /// In en, this message translates to:
  /// **'Flashcard'**
  String get flashcard;

  /// No description provided for @flashcardDeck.
  ///
  /// In en, this message translates to:
  /// **'Flashcard Deck'**
  String get flashcardDeck;

  /// No description provided for @cardsDueToday.
  ///
  /// In en, this message translates to:
  /// **'Cards Due Today'**
  String get cardsDueToday;

  /// No description provided for @reviewFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Review Flashcards'**
  String get reviewFlashcards;

  /// No description provided for @aiChat.
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// No description provided for @askQuestionGetHelp.
  ///
  /// In en, this message translates to:
  /// **'Ask a question or get help with doubts'**
  String get askQuestionGetHelp;

  /// No description provided for @aiResponse.
  ///
  /// In en, this message translates to:
  /// **'AI Response'**
  String get aiResponse;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @savedToNotes.
  ///
  /// In en, this message translates to:
  /// **'Saved to notes!'**
  String get savedToNotes;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages: {error}'**
  String errorLoading(Object error);

  /// No description provided for @failedToSend.
  ///
  /// In en, this message translates to:
  /// **'Failed to send: {error}'**
  String failedToSend(Object error);

  /// No description provided for @deleteChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete this chat and all messages. Are you sure?'**
  String get deleteChatConfirm;

  /// No description provided for @noInternetMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get noInternetMessage;

  /// No description provided for @studyMateLogo.
  ///
  /// In en, this message translates to:
  /// **'StudyMate AI'**
  String get studyMateLogo;

  /// No description provided for @learnSmarter.
  ///
  /// In en, this message translates to:
  /// **'Learn smarter with AI'**
  String get learnSmarter;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our Terms of Service and Privacy Policy.'**
  String get termsOfService;

  /// No description provided for @runFlutterfireConfigure.
  ///
  /// In en, this message translates to:
  /// **'To get started, you need to configure Firebase:\n\n1. Run: flutterfire configure\n2. Enable Auth providers (Google, Email/Password)\n3. Enable Cloud Firestore\n4. Enable Firebase AI Logic (Gemini)\n5. Enable App Check'**
  String get runFlutterfireConfigure;

  /// No description provided for @firebaseSetUp.
  ///
  /// In en, this message translates to:
  /// **'Setup required'**
  String get firebaseSetUp;

  /// No description provided for @runSetup.
  ///
  /// In en, this message translates to:
  /// **'I have configured Firebase'**
  String get runSetup;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get goHome;

  /// No description provided for @privacyPolicyDataStored.
  ///
  /// In en, this message translates to:
  /// **'Data Stored in Firestore'**
  String get privacyPolicyDataStored;

  /// No description provided for @privacyPolicyStudyData.
  ///
  /// In en, this message translates to:
  /// **'• Profile: name, grade, language, daily goal\n• Study data: chats, messages, notes, flashcards, quizzes\n• Progress: XP, level, streak, daily stats\n• Planner: study schedules and tasks\n• Badges: unlocked achievements'**
  String get privacyPolicyStudyData;

  /// No description provided for @privacyPolicyDataProcessing.
  ///
  /// In en, this message translates to:
  /// **'Data Processing'**
  String get privacyPolicyDataProcessing;

  /// No description provided for @privacyPolicyGemini.
  ///
  /// In en, this message translates to:
  /// **'• Images and text are sent to Google Gemini for AI assistance\n• Gemini processes your data to generate responses\n• We do not store your images or chat messages with Gemini\n• Responses are saved locally in your Firestore account'**
  String get privacyPolicyGemini;

  /// No description provided for @privacyPolicyDeletion.
  ///
  /// In en, this message translates to:
  /// **'Deletion'**
  String get privacyPolicyDeletion;

  /// No description provided for @privacyPolicyDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'You can delete your account and all associated data from Settings > Account > Delete Account & Data. This will permanently remove all your study data.'**
  String get privacyPolicyDeleteAccount;

  /// No description provided for @privacyPolicyDataLocation.
  ///
  /// In en, this message translates to:
  /// **'Data Location'**
  String get privacyPolicyDataLocation;

  /// No description provided for @privacyPolicyLocation.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored in Firebase Firestore, hosted on Google Cloud. Data is encrypted in transit and at rest.'**
  String get privacyPolicyLocation;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account & Data'**
  String get deleteMyAccount;

  /// No description provided for @privacyPolicyScreen.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyScreen;

  /// No description provided for @accountLinkedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account linked successfully'**
  String get accountLinkedSuccessfully;

  /// No description provided for @accountDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account and data deleted successfully'**
  String get accountDeletedSuccessfully;

  /// No description provided for @featureFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Flashcards'**
  String get featureFlashcards;

  /// No description provided for @featureQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get featureQuiz;

  /// No description provided for @featurePlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get featurePlanner;

  /// No description provided for @featureProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get featureProgress;

  /// No description provided for @featureFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus Timer'**
  String get featureFocus;

  /// No description provided for @featureChat.
  ///
  /// In en, this message translates to:
  /// **'AI Tutor Chat'**
  String get featureChat;

  /// No description provided for @featureScanner.
  ///
  /// In en, this message translates to:
  /// **'Doubt Scanner'**
  String get featureScanner;

  /// No description provided for @featureNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get featureNotes;

  /// No description provided for @notificationStudyReminder.
  ///
  /// In en, this message translates to:
  /// **'Study Reminder'**
  String get notificationStudyReminder;

  /// No description provided for @notificationDailySession.
  ///
  /// In en, this message translates to:
  /// **'Time for your daily study session!'**
  String get notificationDailySession;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat Title'**
  String get chatTitle;

  /// No description provided for @exampleChatTitle.
  ///
  /// In en, this message translates to:
  /// **'e.g., Calculus Derivatives'**
  String get exampleChatTitle;

  /// No description provided for @createChat.
  ///
  /// In en, this message translates to:
  /// **'Create Chat'**
  String get createChat;

  /// No description provided for @failedToCreateChat.
  ///
  /// In en, this message translates to:
  /// **'Failed to create chat: {error}'**
  String failedToCreateChat(Object error);

  /// No description provided for @renameChat.
  ///
  /// In en, this message translates to:
  /// **'Rename Chat'**
  String get renameChat;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChat;

  /// No description provided for @chatDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete the chat and all messages. Are you sure?'**
  String get chatDeleteConfirm;

  /// No description provided for @noChats.
  ///
  /// In en, this message translates to:
  /// **'No chats yet'**
  String get noChats;

  /// No description provided for @startNewConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation with StudyMate AI'**
  String get startNewConversation;

  /// No description provided for @newConversation.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newConversation;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @solveQuestion.
  ///
  /// In en, this message translates to:
  /// **'Solve Question'**
  String get solveQuestion;

  /// No description provided for @createNote.
  ///
  /// In en, this message translates to:
  /// **'Create Note'**
  String get createNote;

  /// No description provided for @aiFlashcards.
  ///
  /// In en, this message translates to:
  /// **'AI Flashcards'**
  String get aiFlashcards;

  /// No description provided for @cameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission required'**
  String get cameraPermission;

  /// No description provided for @galleryPermission.
  ///
  /// In en, this message translates to:
  /// **'Photo library permission required'**
  String get galleryPermission;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image: {error}'**
  String errorPickingImage(Object error);

  /// No description provided for @solutionSaved.
  ///
  /// In en, this message translates to:
  /// **'Solution saved to doubts'**
  String get solutionSaved;

  /// No description provided for @errorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving: {error}'**
  String errorSaving(Object error);

  /// No description provided for @flashcardsGenerated.
  ///
  /// In en, this message translates to:
  /// **'Generated flashcards successfully!'**
  String get flashcardsGenerated;

  /// No description provided for @doubtScanner.
  ///
  /// In en, this message translates to:
  /// **'Doubt Scanner'**
  String get doubtScanner;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @aiActionFailed.
  ///
  /// In en, this message translates to:
  /// **'AI Action Failed'**
  String get aiActionFailed;

  /// No description provided for @pleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please try again.'**
  String get pleaseTryAgain;

  /// No description provided for @importPdfText.
  ///
  /// In en, this message translates to:
  /// **'Import PDF/Text'**
  String get importPdfText;

  /// No description provided for @pasteText.
  ///
  /// In en, this message translates to:
  /// **'Paste Text'**
  String get pasteText;

  /// No description provided for @choosePdfFile.
  ///
  /// In en, this message translates to:
  /// **'Choose PDF file'**
  String get choosePdfFile;

  /// No description provided for @pdfImportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'PDF import coming soon'**
  String get pdfImportComingSoon;

  /// No description provided for @importImageOcr.
  ///
  /// In en, this message translates to:
  /// **'Import Image (OCR)'**
  String get importImageOcr;

  /// No description provided for @pleaseEnterContent.
  ///
  /// In en, this message translates to:
  /// **'Please enter content first'**
  String get pleaseEnterContent;

  /// No description provided for @aiAction.
  ///
  /// In en, this message translates to:
  /// **'AI Action'**
  String get aiAction;

  /// No description provided for @summarize.
  ///
  /// In en, this message translates to:
  /// **'Summarize'**
  String get summarize;

  /// No description provided for @keyPoints.
  ///
  /// In en, this message translates to:
  /// **'Key Points'**
  String get keyPoints;

  /// No description provided for @translate.
  ///
  /// In en, this message translates to:
  /// **'Translate'**
  String get translate;

  /// No description provided for @generateFlashcardsFromNote.
  ///
  /// In en, this message translates to:
  /// **'Generate Flashcards'**
  String get generateFlashcardsFromNote;

  /// No description provided for @generateQuizFromNote.
  ///
  /// In en, this message translates to:
  /// **'Generate Quiz'**
  String get generateQuizFromNote;

  /// No description provided for @simplify.
  ///
  /// In en, this message translates to:
  /// **'Simplify'**
  String get simplify;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get deleteNoteConfirm;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @deckCreated.
  ///
  /// In en, this message translates to:
  /// **'Deck created successfully!'**
  String get deckCreated;

  /// No description provided for @failedToGenerate.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate: {error}'**
  String failedToGenerate(Object error);

  /// No description provided for @enterTopic.
  ///
  /// In en, this message translates to:
  /// **'Please enter a topic'**
  String get enterTopic;

  /// No description provided for @topic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get topic;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'cards'**
  String get cards;

  /// No description provided for @chatStepByStepDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask doubts, get step-by-step explanations, and learn at your own pace.'**
  String get chatStepByStepDesc;

  /// No description provided for @cameraDesc.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of any question and get instant AI solutions.'**
  String get cameraDesc;

  /// No description provided for @toolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Flashcards, quizzes, study plans, and focus timer - all in one app.'**
  String get toolsDesc;

  /// No description provided for @failedToLoadSettings.
  ///
  /// In en, this message translates to:
  /// **'Failed to load settings'**
  String get failedToLoadSettings;

  /// No description provided for @noUserToDelete.
  ///
  /// In en, this message translates to:
  /// **'No user to delete'**
  String get noUserToDelete;

  /// No description provided for @reauthAndRetry.
  ///
  /// In en, this message translates to:
  /// **'Re-authenticate & Retry'**
  String get reauthAndRetry;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get perDay;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @validEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get validEmail;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get enterName;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @passwordMin6.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMin6;

  /// No description provided for @passwordsMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsMatch;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authFailed;

  /// No description provided for @googleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get googleSignInFailed;

  /// No description provided for @guestSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Guest sign-in failed'**
  String get guestSignInFailed;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @pleaseSignInAgainToDelete.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to delete your account'**
  String get pleaseSignInAgainToDelete;

  /// No description provided for @accountDeleteWarning.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. You will lose all saved data.'**
  String get accountDeleteWarning;

  /// No description provided for @deleteAccountAndDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteAccountAndDelete;

  /// No description provided for @deleteAccountAndConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountAndConfirm;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
