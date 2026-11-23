// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get about => 'About';

  @override
  String get account => 'Account';

  @override
  String get accountAlreadyLinked => 'Account already linked';

  @override
  String get accountDeleteWarning =>
      'This action cannot be undone. You will lose all saved data.';

  @override
  String get accountDeletedSuccessfully =>
      'Account and data deleted successfully';

  @override
  String get accountLinkedSuccessfully => 'Account linked successfully';

  @override
  String get addDoubtTooltip => 'Add Doubt';

  @override
  String get addWeakTopic => 'Add Weak Topic';

  @override
  String get aiAction => 'AI Action';

  @override
  String get aiActionFailed => 'AI Action Failed';

  @override
  String aiActionFailedDialogContent(Object error) {
    return 'Something went wrong: $error\n\nPlease try again.';
  }

  @override
  String get aiActionFailedDialogTitle => 'AI Action Failed';

  @override
  String get aiActionFailedMessage => 'AI Action Failed';

  @override
  String get aiActionsButton => 'AI Actions';

  @override
  String get aiChat => 'AI Chat';

  @override
  String get aiFlashcards => 'AI Flashcards';

  @override
  String get aiFlashcardsButton => 'AI Flashcards';

  @override
  String get aiIsWorking => 'StudyMate AI is working on it...';

  @override
  String get aiResponse => 'AI Response';

  @override
  String get aiResponseLanguage => 'AI Response Language';

  @override
  String get aiResponseStyle => 'AI Response Style';

  @override
  String get aiWorkingDialog => 'StudyMate AI is working on it...';

  @override
  String get allCaughtUp => 'All caught up!';

  @override
  String get answer => 'Answer';

  @override
  String get appLanguage => 'App Language';

  @override
  String get appName => 'StudyMate AI';

  @override
  String get askAI => 'Ask AI';

  @override
  String get askQuestionGetHelp => 'Ask a question or get help with doubts';

  @override
  String get authFailed => 'Authentication failed';

  @override
  String get avatar => 'Avatar';

  @override
  String get back => 'Back';

  @override
  String get backToQuizzes => 'Back to Quizzes';

  @override
  String get browseDecks => 'Browse Decks';

  @override
  String get camera => 'Camera';

  @override
  String get cameraButton => 'Camera';

  @override
  String get cameraDesc =>
      'Take a photo of any question and get instant AI solutions.';

  @override
  String get cameraPermission => 'Camera permission required';

  @override
  String get cameraPermissionSnack => 'Camera permission required';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get cancelButtonDialog => 'Cancel';

  @override
  String get card => 'Card';

  @override
  String cardsDuePlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# cards due',
      one: '1 card due',
    );
    return '$_temp0';
  }

  @override
  String get cardsDueToday => 'Cards Due Today';

  @override
  String get cardsReviewed => 'Cards reviewed';

  @override
  String get chatDeleteConfirm =>
      'This will permanently delete the chat and all messages. Are you sure?';

  @override
  String get chatModeExamAnswer => 'Exam Answer';

  @override
  String get chatModeExplainSimply => 'Explain Simply';

  @override
  String get chatModeQuickSummary => 'Quick Summary';

  @override
  String get chatModeStepByStep => 'Step-by-Step';

  @override
  String get chatModeTeachMeLikeIm10 => 'Teach Me Like I\'m 10';

  @override
  String get chatStepByStepDesc =>
      'Ask doubts, get step-by-step explanations, and learn at your own pace.';

  @override
  String get chatTitle => 'Chat Title';

  @override
  String get choosePdfFile => 'Choose PDF file';

  @override
  String get classGrade => 'Class / Grade';

  @override
  String get clearAllDoubtsDialogContent =>
      'This will delete all saved doubts. Are you sure?';

  @override
  String get clearAllDoubtsDialogTitle => 'Clear All Doubts?';

  @override
  String get clearAllTooltip => 'Clear all doubts';

  @override
  String get clearButton => 'Clear';

  @override
  String get close => 'Close';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get contentHeader => 'Content';

  @override
  String get contentRequired => 'Content required';

  @override
  String get continueAsGuest => 'Continue as Guest';

  @override
  String get continueStudying => 'Continue Studying';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get copy => 'Copy';

  @override
  String get correct => 'Correct!';

  @override
  String get count => 'Count';

  @override
  String get createChat => 'Create Chat';

  @override
  String get createFirstNote => 'Create your first note to get started';

  @override
  String get createFirstNoteMessage => 'Create your first note to get started';

  @override
  String get createNewNote => 'Create a new note';

  @override
  String get createNote => 'Create Note';

  @override
  String get createNoteAction => 'Create Note';

  @override
  String get createNoteButton => 'Create Note';

  @override
  String get createNoteTooltip => 'Create note';

  @override
  String get createPlan => 'Create Plan';

  @override
  String get createPlanForTasks => 'Create a study plan to see tasks here';

  @override
  String get dailyAILimit => 'Daily AI limit reached';

  @override
  String get dailyAILimitMessage =>
      'Try again tomorrow or use fewer AI requests.';

  @override
  String get dailyAILimitReached => 'Daily AI limit reached';

  @override
  String get dailyAILimitReachedSnack =>
      'Daily AI limit reached. Try again tomorrow or use fewer AI requests.';

  @override
  String get dailyAILimitTryTomorrow =>
      'Try again tomorrow or reduce AI requests.';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get dailyLimitReachedDialogMessage =>
      'You\'ve used your daily AI quota. Try again tomorrow or use fewer AI requests.';

  @override
  String get dailyLimitReachedDialogTitle => 'Daily limit reached';

  @override
  String get dailyStats => 'Daily Stats';

  @override
  String get dailyStudyGoal => 'Daily Study Goal (minutes)';

  @override
  String get dailyStudyGoalMinutes => 'Daily Study Goal (minutes)';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get dayStreak => 'Day Streak';

  @override
  String get days => 'Days';

  @override
  String get daysStreak => 'Days Streak';

  @override
  String get deckCreated => 'Deck created successfully!';

  @override
  String get deckNotFound => 'Deck not found';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountAndConfirm => 'Delete Account';

  @override
  String get deleteAccountAndDelete => 'Delete My Account';

  @override
  String get deleteAction => 'Delete';

  @override
  String get deleteButton => 'Delete';

  @override
  String get deleteChat => 'Delete Chat';

  @override
  String get deleteChatConfirm =>
      'This will permanently delete this chat and all messages. Are you sure?';

  @override
  String get deleteMyAccount => 'Delete My Account & Data';

  @override
  String get deleteNote => 'Delete Note';

  @override
  String get deleteNoteConfirm => 'Are you sure you want to delete this note?';

  @override
  String get deleteNoteConfirmSimple =>
      'Are you sure you want to delete this note?';

  @override
  String get deleteNoteDialogContent =>
      'Are you sure you want to delete this note? This cannot be undone.';

  @override
  String get deleteNoteDialogTitle => 'Delete Note';

  @override
  String get designSystemPreview => 'Design System Preview';

  @override
  String get done => 'Done';

  @override
  String get doubtScanner => 'Doubt Scanner';

  @override
  String get doubtScannerTitle => 'Doubt Scanner';

  @override
  String get doubtsTitle => 'Doubts';

  @override
  String get dueFlashcards => 'Due Flashcards';

  @override
  String get edit => 'Edit';

  @override
  String get editAction => 'Edit';

  @override
  String get editNote => 'Edit Note';

  @override
  String get editNoteTitle => 'Edit your note';

  @override
  String get editNoteTitleScreen => 'Edit Note';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get editYourNote => 'Edit your note';

  @override
  String get email => 'Email';

  @override
  String get empty => 'Empty';

  @override
  String get emptyState => 'No data available';

  @override
  String get english => 'English';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get enterName => 'Please enter your name';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get enterTopic => 'Please enter a topic';

  @override
  String get error => 'Something went wrong';

  @override
  String get errorInNote => 'Error in note';

  @override
  String errorLoading(Object error) {
    return 'Error loading messages: $error';
  }

  @override
  String get errorLoadingDashboard => 'Failed to load dashboard';

  @override
  String get errorLoadingDoubtsTitle => 'Error Loading Doubts';

  @override
  String get errorLoadingNotes => 'Error Loading Notes';

  @override
  String errorPickingImage(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String errorPickingImageSnack(Object error) {
    return 'Error picking image: $error';
  }

  @override
  String errorImportingPdf(Object error) {
    return 'Error importing PDF: $error';
  }

  @override
  String errorSaving(Object error) {
    return 'Error saving: $error';
  }

  @override
  String errorSavingSnack(Object error) {
    return 'Error saving: $error';
  }

  @override
  String errorSendingResetEmail(Object error) {
    return 'Error sending reset email: $error';
  }

  @override
  String get estimatedTime => 'Estimated time';

  @override
  String get examDate => 'Exam Date';

  @override
  String get exampleChatTitle => 'e.g., Calculus Derivatives';

  @override
  String get extractingKeyPointsDialog => 'Extracting key points';

  @override
  String failedToCreateChat(Object error) {
    return 'Failed to create chat: $error';
  }

  @override
  String failedToGenerate(Object error) {
    return 'Failed to generate: $error';
  }

  @override
  String get failedToGenerateFlashcardsDialogTitle =>
      'Failed to generate flashcards';

  @override
  String get failedToLoadSettings => 'Failed to load settings';

  @override
  String failedToSend(Object error) {
    return 'Failed to send: $error';
  }

  @override
  String failedToUpdate(Object error) {
    return 'Failed to update: $error';
  }

  @override
  String get featureChat => 'AI Tutor Chat';

  @override
  String get featureFlashcards => 'Flashcards';

  @override
  String get featureFocus => 'Focus Timer';

  @override
  String get featureNotes => 'Notes';

  @override
  String get featurePlanner => 'Planner';

  @override
  String get featureProgress => 'Progress';

  @override
  String get featureQuiz => 'Quiz';

  @override
  String get featureScanner => 'Doubt Scanner';

  @override
  String get feedback => 'Feedback';

  @override
  String get filledButton => 'Filled Button';

  @override
  String get filter => 'Filter';

  @override
  String get finalScore => 'Final Score';

  @override
  String get firebaseSetUp => 'Setup required';

  @override
  String get flashcard => 'Flashcard';

  @override
  String get flashcardDeck => 'Flashcard Deck';

  @override
  String get flashcardRatingAgain => 'Again';

  @override
  String get flashcardRatingEasy => 'Easy';

  @override
  String get flashcardRatingGood => 'Good';

  @override
  String get flashcardRatingHard => 'Hard';

  @override
  String get flashcards => 'Flashcards';

  @override
  String get flashcardsGenerated => 'Generated flashcards successfully!';

  @override
  String get flashcardsGeneratedSuccess => 'Flashcards generated successfully';

  @override
  String get flashcardsGeneratedSuccessSnack =>
      'Generated flashcards successfully!';

  @override
  String get focus => 'Focus';

  @override
  String get focusTimerFocus => 'Focus';

  @override
  String get focusTimerLongBreak => 'Long Break';

  @override
  String get focusTimerPause => 'Pause';

  @override
  String get focusTimerReset => 'Reset';

  @override
  String get focusTimerSessions => 'Sessions';

  @override
  String get focusTimerShortBreak => 'Short Break';

  @override
  String get focusTimerStart => 'Start';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get front => 'Front';

  @override
  String get gallery => 'Gallery';

  @override
  String get galleryButton => 'Gallery';

  @override
  String get galleryPermission => 'Photo library permission required';

  @override
  String get galleryPermissionSnack => 'Photo library permission required';

  @override
  String get generateFlashcardsAction => 'Generate Flashcards';

  @override
  String get generateFlashcardsFromNote => 'Generate Flashcards';

  @override
  String get generateQuizAction => 'Generate Quiz';

  @override
  String get generateQuizFromNote => 'Generate Quiz';

  @override
  String get generateStudyPlan => 'Generate Study Plan';

  @override
  String get generating => 'Generating...';

  @override
  String get generatingFlashcardsDialog => 'Generating flashcards';

  @override
  String get generatingQuizDialog => 'Generating quiz';

  @override
  String get glassCard => 'Glass Card';

  @override
  String get goHome => 'Go Home';

  @override
  String get goToScannerAction => 'Go to Scanner';

  @override
  String get goalAchieved => 'Goal achieved! 🎉';

  @override
  String get googleSignIn => 'Continue with Google';

  @override
  String get googleSignInFailed => 'Google sign-in failed';

  @override
  String get grade => 'Grade/Class';

  @override
  String get gradientButton => 'Gradient Button';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get guestSignInFailed => 'Guest sign-in failed';

  @override
  String get gujarati => 'Gujarati';

  @override
  String get helpPersonalize => 'Help us personalize your experience';

  @override
  String get hindi => 'Hindi';

  @override
  String get hoursPerDay => 'Hours per Day';

  @override
  String get howItWorksDesc =>
      'Take a photo or select an image of your question. StudyMate AI will analyze it and provide a step-by-step solution.';

  @override
  String get howItWorksHeader => 'How it works';

  @override
  String get importImageOcr => 'Import Image (OCR)';

  @override
  String get importImageOcrTitle => 'Import Image (OCR)';

  @override
  String get importPdfText => 'Import PDF/Text';

  @override
  String get importPdfTextButton => 'Import PDF/Text';

  @override
  String get importPdfButton => 'Import PDF';

  @override
  String get importText => 'Import Text';

  @override
  String get keyPoints => 'Key Points';

  @override
  String get keyPointsAction => 'Key Points';

  @override
  String get keyPointsExtractedSuccess => 'Key points extracted successfully';

  @override
  String get language => 'Language';

  @override
  String get learnSmarter => 'Learn smarter with AI';

  @override
  String get letsStudy => 'Let\'s study smarter today.';

  @override
  String get level => 'Level';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get linkAccount => 'Link Account';

  @override
  String get linkAccountWarning =>
      'Link an account to save your data permanently and access it on other devices.';

  @override
  String get linkEmail => 'Email';

  @override
  String get linkEmailAccount => 'Link Email Account';

  @override
  String get linkGoogle => 'Link Google';

  @override
  String get linkGoogleEmail => 'Link Google / Email Account';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingStats => 'Loading stats...';

  @override
  String get markDone => 'Mark Done';

  @override
  String get min => 'min';

  @override
  String get minutes => 'minutes';

  @override
  String get mode => 'Mode';

  @override
  String get more => 'More';

  @override
  String moreTasks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# more tasks',
      one: '1 more task',
    );
    return '$_temp0';
  }

  @override
  String get motivationalQuote1 =>
      'The expert in anything was once a beginner.';

  @override
  String get motivationalQuote2 =>
      'Success is the sum of small efforts repeated day in and day out.';

  @override
  String get motivationalQuote3 => 'Learning never exhausts the mind.';

  @override
  String get motivationalQuote4 => 'Your only limit is you.';

  @override
  String get motivationalQuote5 =>
      'Start where you are. Use what you have. Do what you can.';

  @override
  String get name => 'Name';

  @override
  String get newChat => 'New Chat';

  @override
  String get newNote => 'New Note';

  @override
  String get newNoteTitleScreen => 'New Note';

  @override
  String get next => 'Next';

  @override
  String get noCardsDueToday => 'No cards due for review today';

  @override
  String get noChats => 'No chats yet';

  @override
  String get noDoubtsSavedTitle => 'No doubts saved yet';

  @override
  String get noInternet => 'No Internet Connection';

  @override
  String get noInternetMessage => 'Please check your connection and try again.';

  @override
  String get noNotes => 'No notes yet';

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get noNotesYetTitle => 'No notes yet';

  @override
  String get noPlansYet => 'No plans yet. Generate your first plan above!';

  @override
  String get noTasksToday => 'No tasks for today';

  @override
  String get noUserToDelete => 'No user to delete';

  @override
  String get notFoundDescription =>
      'The page you\'re looking for doesn\'t exist or has been moved.';

  @override
  String get notSet => 'Not set';

  @override
  String get note => 'Note';

  @override
  String get noteCreated => 'Note created';

  @override
  String get noteDetailTitle => 'Note';

  @override
  String get noteSimplifiedSuccess => 'Note simplified successfully';

  @override
  String get noteSummarizedSuccess => 'Note summarized successfully';

  @override
  String get noteTitleHint => 'Note title';

  @override
  String get noteTranslatedSuccess => 'Note translated successfully';

  @override
  String get noteUpdated => 'Note updated';

  @override
  String get notes => 'Notes';

  @override
  String get notesCreated => 'Note created successfully';

  @override
  String get notesTitle => 'Notes';

  @override
  String get notificationDailySession => 'Time for your daily study session!';

  @override
  String get notificationStreakReminder => 'Keep Your Streak Alive!';

  @override
  String notificationStreakReminderBody(Object streak) {
    return 'You\'re on a $streak day streak. Don\'t break it now!';
  }

  @override
  String get notificationStudyReminder => 'Study Reminder';

  @override
  String get notifications => 'Notifications';

  @override
  String get ok => 'OK';

  @override
  String get okButton => 'OK';

  @override
  String get outOf => 'out of';

  @override
  String get outlinedButton => 'Outlined Button';

  @override
  String get password => 'Password';

  @override
  String get passwordMin6 => 'Password must be at least 6 characters';

  @override
  String get passwordResetEmailSent =>
      'Password reset email sent. Check your inbox.';

  @override
  String get passwordsMatch => 'Passwords do not match';

  @override
  String get pasteButton => 'Paste';

  @override
  String get pasteText => 'Paste Text';

  @override
  String get pasteTextDialogTitle => 'Paste Text';

  @override
  String get pasteTextHint => 'Paste text here...';

  @override
  String get pasteTextTitle => 'Paste Text';

  @override
  String get pdfImportComingSoon => 'PDF import coming soon';

  @override
  String get pdfImportSuccess => 'PDF imported successfully';

  @override
  String get pdfNoTextFound => 'No text found in PDF';

  @override
  String pdfFileTooLarge(Object maxSize) {
    return 'PDF file too large. Maximum size is $maxSize MB.';
  }

  @override
  String get extractingPdfTextDialog => 'Extracting text from PDF...';

  @override
  String get perDay => 'per day';

  @override
  String get pinAction => 'Pin';

  @override
  String get planner => 'Planner';

  @override
  String get pleaseEnterContent => 'Please enter content first';

  @override
  String get pleaseEnterContentFirst => 'Please enter content first';

  @override
  String get pleaseSignInAgainToDelete =>
      'Please sign in again to delete your account';

  @override
  String get pleaseTryAgain => 'Please try again.';

  @override
  String get preferences => 'Preferences';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyDataLocation => 'Data Location';

  @override
  String get privacyPolicyDataProcessing => 'Data Processing';

  @override
  String get privacyPolicyDataStored => 'Data Stored in Firestore';

  @override
  String get privacyPolicyDeleteAccount =>
      'You can delete your account and all associated data from Settings > Account > Delete Account & Data. This will permanently remove all your study data.';

  @override
  String get privacyPolicyDeletion => 'Deletion';

  @override
  String get privacyPolicyGemini =>
      '• Images and text are sent to Google Gemini for AI assistance\n• Gemini processes your data to generate responses\n• We do not store your images or chat messages with Gemini\n• Responses are saved locally in your Firestore account';

  @override
  String get privacyPolicyLocation =>
      'Your data is stored in Firebase Firestore, hosted on Google Cloud. Data is encrypted in transit and at rest.';

  @override
  String get privacyPolicyScreen => 'Privacy Policy';

  @override
  String get privacyPolicyStudyData =>
      '• Profile: name, grade, language, daily goal\n• Study data: chats, messages, notes, flashcards, quizzes\n• Progress: XP, level, streak, daily stats\n• Planner: study schedules and tasks\n• Badges: unlocked achievements';

  @override
  String get processButton => 'Process Question';

  @override
  String get profile => 'Profile';

  @override
  String get profileSetup => 'Set Up Your Profile';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get progress => 'Progress';

  @override
  String get progressRing => 'Progress Ring';

  @override
  String get question => 'Question';

  @override
  String question1of(Object question, Object total) {
    return 'Question $question of $total';
  }

  @override
  String get questions => 'Questions';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get quickQuiz => 'Quick Quiz';

  @override
  String get quizDifficultyEasy => 'Easy';

  @override
  String get quizDifficultyHard => 'Hard';

  @override
  String get quizDifficultyMedium => 'Medium';

  @override
  String get quizGeneratedSuccess => 'Quiz generated successfully';

  @override
  String get quizNotFound => 'Quiz not found';

  @override
  String get quizzes => 'Quizzes';

  @override
  String get quizzesTaken => 'Quizzes taken';

  @override
  String get rateApp => 'Rate App';

  @override
  String get reauthAndRetry => 'Re-authenticate & Retry';

  @override
  String get rename => 'Rename';

  @override
  String get renameChat => 'Rename Chat';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get result => 'Result';

  @override
  String get resume => 'Resume';

  @override
  String get retries => 'Retry';

  @override
  String get retryButton => 'Retry';

  @override
  String get retryQuiz => 'Retry Quiz';

  @override
  String get retryWrongQuestions => 'Retry Wrong Questions Only';

  @override
  String get reviewAnswers => 'Review Answers';

  @override
  String get reviewFlashcard =>
      'Spaced repetition will optimize your retention';

  @override
  String get reviewFlashcards => 'Review Flashcards';

  @override
  String get runFlutterfireConfigure =>
      'To get started, you need to configure Firebase:\n\n1. Run: flutterfire configure\n2. Enable Auth providers (Google, Email/Password)\n3. Enable Cloud Firestore\n4. Enable Firebase AI Logic (Gemini)\n5. Enable App Check';

  @override
  String get runSetup => 'I have configured Firebase';

  @override
  String get save => 'Save';

  @override
  String get saveButton => 'Save';

  @override
  String get saveChanges => 'Save';

  @override
  String get savedToNotes => 'Saved to notes!';

  @override
  String get scanDoubt => 'Scan Doubt';

  @override
  String get scanProblemMessage =>
      'Scan a problem with the scanner to save doubts';

  @override
  String get score => 'Score';

  @override
  String get search => 'Search';

  @override
  String get searchChats => 'Search chats';

  @override
  String get searchNotesHint => 'Search notes...';

  @override
  String get selectImageHeader => 'Select Image';

  @override
  String get selectSubjectHeader => 'Select Subject';

  @override
  String get selectSubjectLabel => 'Select Subject';

  @override
  String get selectedImage => 'Selected Image';

  @override
  String get selectedImageLabel => 'Selected Image:';

  @override
  String get settings => 'Settings';

  @override
  String get share => 'Share';

  @override
  String get shareApp => 'Share App';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signUp => 'Sign Up';

  @override
  String get simplify => 'Simplify';

  @override
  String get simplifyAction => 'Simplify';

  @override
  String get simplifyingDialog => 'Simplifying';

  @override
  String get skip => 'Skip';

  @override
  String get solutionHeader => 'Solution';

  @override
  String get solutionSaved => 'Solution saved to doubts';

  @override
  String get solutionSavedSnack => 'Solution saved to doubts';

  @override
  String get solveQuestion => 'Solve Question';

  @override
  String get solveQuestionButton => 'Solve Question';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get somethingWentWrongDialogTitle => 'Something went wrong';

  @override
  String get somethingWentWrongMessage => 'Something went wrong';

  @override
  String get sort => 'Sort';

  @override
  String get spacedRepetitionReview =>
      'Spaced repetition will optimize your retention';

  @override
  String get startNewConversation =>
      'Start a new conversation with StudyMate AI';

  @override
  String get startNoteSearch => 'Search notes';

  @override
  String get startReview => 'Start Review';

  @override
  String get statTile => 'Stat Tile';

  @override
  String get streak => 'Streak';

  @override
  String get streakBadge => 'Streak Badge';

  @override
  String get student => 'Student';

  @override
  String get study => 'Study';

  @override
  String get studyHub => 'Study Hub';

  @override
  String get studyMateLogo => 'StudyMate AI';

  @override
  String get studyMinutes => 'Study minutes';

  @override
  String get studyPlanGenerated => 'Study plan generated successfully!';

  @override
  String get studyPlanner => 'Study Planner';

  @override
  String get subject => 'Subject';

  @override
  String get subjectBiology => 'Biology';

  @override
  String get subjectChemistry => 'Chemistry';

  @override
  String get subjectComputerScience => 'Computer Science';

  @override
  String get subjectEnglish => 'English';

  @override
  String get subjectEnglishSubject => 'English';

  @override
  String get subjectGujarati => 'Gujarati';

  @override
  String get subjectHindi => 'Hindi';

  @override
  String get subjectHint => 'e.g., Mathematics, Physics';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get subjectMath => 'Math';

  @override
  String get subjectMathematics => 'Mathematics';

  @override
  String get subjectOther => 'Other';

  @override
  String get subjectPhysics => 'Physics';

  @override
  String get subjectRequired => 'Subject required';

  @override
  String get subjectScience => 'Science';

  @override
  String get subjectSocial => 'Social Science';

  @override
  String get subjectSocialScience => 'Social Science';

  @override
  String get subjects => 'Subjects of Interest';

  @override
  String get submitAnswer => 'Submit Answer';

  @override
  String get summarize => 'Summarize';

  @override
  String get summarizeAction => 'Summarize';

  @override
  String get summarizingDialog => 'Summarizing';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get tagsHint => 'Algebra, Geometry, Important';

  @override
  String get tagsLabel => 'Tags (comma separated)';

  @override
  String get takeQuiz => 'Take Quiz';

  @override
  String get tapAvatarToChange => 'Tap avatar to change';

  @override
  String get task => 'Task';

  @override
  String get tasks => 'Tasks';

  @override
  String get termsOfService =>
      'By continuing, you agree to our Terms of Service and Privacy Policy.';

  @override
  String get textButton => 'Text Button';

  @override
  String get theme => 'Theme';

  @override
  String get thisWeek => 'This Week';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleRequired => 'Title required';

  @override
  String get today => 'Today';

  @override
  String get todayTask => 'Today\'s Task';

  @override
  String get todayTasks => 'Today\'s Tasks';

  @override
  String get todaysGoal => 'Today\'s Goal';

  @override
  String get toolsDesc =>
      'Flashcards, quizzes, study plans, and focus timer - all in one app.';

  @override
  String get topic => 'Topic';

  @override
  String get translate => 'Translate';

  @override
  String get translateAction => 'Translate';

  @override
  String get translatingDialog => 'Translating';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get unmarkDone => 'Unmark Done';

  @override
  String get validEmail => 'Please enter a valid email';

  @override
  String get viewAll => 'View All';

  @override
  String get voiceInput => 'Voice input';

  @override
  String get weakTopics => 'Weak Topics';

  @override
  String get weeklyStats => 'Weekly Stats';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get writeNoteHint => 'Write your note here...';

  @override
  String get wrong => 'Wrong';

  @override
  String get xp => 'XP';

  @override
  String get xpEarned => 'XP earned';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get yourScore => 'Your Score';
}
