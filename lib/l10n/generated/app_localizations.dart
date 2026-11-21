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

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

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
  /// **'No internet connection'**
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
