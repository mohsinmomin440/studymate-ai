// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get about => 'के बारे में';

  @override
  String get account => 'खाता';

  @override
  String get accountAlreadyLinked => 'खाता पहले से लिंक है';

  @override
  String get accountDeleteWarning =>
      'यह कार्य अनिवार्य है। आप सभी सेव किए गए डेटा खो देंगे।';

  @override
  String get accountDeletedSuccessfully =>
      'खाता और डेटा सफलतापूर्वक हटा दिया गया है';

  @override
  String get accountLinkedSuccessfully => 'खाता सफलतापूर्वक लिंक हो गया';

  @override
  String get addDoubtTooltip => 'शंका जोड़ें';

  @override
  String get addWeakTopic => 'कमज़ोर विषय जोड़ें';

  @override
  String get aiAction => 'AI कार्रवाई';

  @override
  String get aiActionFailed => 'AI कार्रवाई विफल';

  @override
  String aiActionFailedDialogContent(Object error) {
    return 'कुछ गलत हुआ: $error\n\nकृपया फिर से प्रयास करें।';
  }

  @override
  String get aiActionFailedDialogTitle => 'AI कार्रवाई विफल';

  @override
  String get aiActionFailedMessage => 'AI कार्रवाई विफल';

  @override
  String get aiActionsButton => 'AI क्रियाएं';

  @override
  String get aiChat => 'AI वार्तालाप';

  @override
  String get aiFlashcards => 'AI फ्लैशकार्ड';

  @override
  String get aiFlashcardsButton => 'AI फ्लैशकार्ड';

  @override
  String get aiIsWorking => 'StudyMate AI वहीं काम कर रहा है...';

  @override
  String get aiResponse => 'AI उत्तर';

  @override
  String get aiResponseLanguage => 'AI उत्तर की भाषा';

  @override
  String get aiResponseStyle => 'AI उत्तर की शैली';

  @override
  String get aiWorkingDialog => 'StudyMate AI काम कर रहा है...';

  @override
  String get allCaughtUp => 'सब कुछ पकड़ लिया!';

  @override
  String get answer => 'उत्तर';

  @override
  String get appLanguage => 'ऐप भाषा';

  @override
  String get appName => 'StudyMate AI';

  @override
  String get askAI => 'AI से पूछें';

  @override
  String get askQuestionGetHelp =>
      'एक प्रश्न पूछें या संदेह के लिए मदद प्राप्त करें';

  @override
  String get authFailed => 'साइन-इन विफल';

  @override
  String get avatar => 'आवाज़';

  @override
  String get back => 'पीछे';

  @override
  String get backToQuizzes => 'क्विज़ की वापसी';

  @override
  String get browseDecks => 'डेक्स ब्राउज़ करें';

  @override
  String get camera => 'कैमरा';

  @override
  String get cameraButton => 'कैमरा';

  @override
  String get cameraDesc =>
      'किसी भी प्रश्न की एक फोटो लेकर AI के साथ तुरंत समाधान प्राप्त करें।';

  @override
  String get cameraPermission => 'कैमरा अनुमति आवश्यक है';

  @override
  String get cameraPermissionSnack => 'कैमरा अनुमति आवश्यक है';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get cancelButton => 'रद्द करें';

  @override
  String get cancelButtonDialog => 'रद्द करें';

  @override
  String get card => 'कार्ड';

  @override
  String cardsDuePlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# कार्ड बाकी',
      one: '1 कार्ड बाकी',
    );
    return '$_temp0';
  }

  @override
  String get cardsDueToday => 'आज निर्धारित कार्ड';

  @override
  String get cardsReviewed => 'समीक्षित कार्ड';

  @override
  String get chatDeleteConfirm =>
      'यह चैट और सभी संदेशों को स्थायी रूप से हटा देगा। क्या आप सुनिश्चित हैं?';

  @override
  String get chatModeExamAnswer => 'परीक्षा उत्तर';

  @override
  String get chatModeExplainSimply => 'सरल भाषा में समझाएं';

  @override
  String get chatModeQuickSummary => 'त्वरित सारांश';

  @override
  String get chatModeStepByStep => 'चरण दर चरण';

  @override
  String get chatModeTeachMeLikeIm10 => 'मुझे 10 साल के बच्चे जैसे सिखाएं';

  @override
  String get chatStepByStepDesc =>
      'शंकाओं को पूछें, चरण-दर-चरण समझाएं, और अपनी गति से सीखें।';

  @override
  String get chatTitle => 'चैट शीर्षक';

  @override
  String get choosePdfFile => 'PDF फ़ाइल चुनें';

  @override
  String get classGrade => 'ग्रेड/कक्षा';

  @override
  String get clearAllDoubtsDialogContent =>
      'यह सभी सेव की गई शंकाओं को हटा देगा। क्या आप पक्के हैं?';

  @override
  String get clearAllDoubtsDialogTitle => 'सभी शंकाएं हटाएं?';

  @override
  String get clearAllTooltip => 'सभी शंकाएं हटाएं';

  @override
  String get clearButton => 'हटाएं';

  @override
  String get close => 'बंद करें';

  @override
  String get comingSoon => 'जल्द आ रहा है';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get contentHeader => 'सामग्री';

  @override
  String get contentRequired => 'सामग्री आवश्यक है';

  @override
  String get continueAsGuest => 'अतिथि के रूप में जारी रखें';

  @override
  String get continueStudying => 'पढ़ाई जारी रखें';

  @override
  String get copiedToClipboard => 'क्लिपबोर्ड में कॉपी किया गया';

  @override
  String get copy => 'कॉपी करें';

  @override
  String get correct => 'सही!';

  @override
  String get count => 'गिनती';

  @override
  String get createChat => 'चैट बनाएं';

  @override
  String get createFirstNote => 'शुरू करने के लिए पहला नोट बनाएं';

  @override
  String get createFirstNoteMessage => 'शुरू करने के लिए पहला नोट बनाएं';

  @override
  String get createNewNote => 'नया नोट बनाएं';

  @override
  String get createNote => 'नोट बनाएं';

  @override
  String get createNoteAction => 'नोट बनाएं';

  @override
  String get createNoteButton => 'नोट बनाएं';

  @override
  String get createNoteTooltip => 'नोट बनाएं';

  @override
  String get createPlan => 'योजना बनाएं';

  @override
  String get createPlanForTasks => 'कार्य देखने के लिए एक अध्ययन योजना बनाएं';

  @override
  String get dailyAILimit => 'दैनिक AI मर्ज़दा पहुँच गई';

  @override
  String get dailyAILimitMessage =>
      'कृपया अगले दिन फिर से प्रयास करें या कम AI अनुरोध उपयोग करें।';

  @override
  String get dailyAILimitReached => 'दैनिक AI मर्ज़दा पहुँच गई';

  @override
  String get dailyAILimitReachedSnack =>
      'दैनिक AI सीमा पूरी हुई। कल फिर कोशिश करें या कम AI अनुरोध करें।';

  @override
  String get dailyAILimitTryTomorrow =>
      'अगले दिन फिर से प्रयास करें या AI अनुरोध घटाएं।';

  @override
  String get dailyGoal => 'दैनिक लक्ष्य';

  @override
  String get dailyLimitReachedDialogMessage =>
      'आपने अपना दैनिक AI कोटा उपयोग कर लिया है। कल फिर कोशिश करें या कम AI अनुरोध करें।';

  @override
  String get dailyLimitReachedDialogTitle => 'दैनिक सीमा पूरी हुई';

  @override
  String get dailyStats => 'दैनिक आंकड़े';

  @override
  String get dailyStudyGoal => 'दैनिक अध्ययन लक्ष्य (मिनट में)';

  @override
  String get dailyStudyGoalMinutes => 'दैनिक अध्ययन लक्ष्य (मिनट में)';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get dayStreak => 'दिन की लत';

  @override
  String get days => 'दिन';

  @override
  String get daysStreak => 'दिनों की लत';

  @override
  String get deckCreated => 'डेक सफलतापूर्वक बनाया गया!';

  @override
  String get deckNotFound => 'डेक नहीं मिला';

  @override
  String get delete => 'हटाएं';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get deleteAccountAndConfirm => 'खाता हटाएं';

  @override
  String get deleteAccountAndDelete => 'मेरा खाता और डेटा हटाएं';

  @override
  String get deleteAction => 'हटाएं';

  @override
  String get deleteButton => 'हटाएं';

  @override
  String get deleteChat => 'चैट हटाएं';

  @override
  String get deleteChatConfirm =>
      'यह चैट और सभी संदेशों को स्थायी रूप से हटा देगा। क्या आप सुनिश्चित हैं?';

  @override
  String get deleteMyAccount => 'मेरा खाता और डेटा हटाएं';

  @override
  String get deleteNote => 'नोट हटाएं';

  @override
  String get deleteNoteConfirm => 'क्या आप इस नोट को हटाना चाहते हैं?';

  @override
  String get deleteNoteConfirmSimple => 'क्या इस नोट को हटाएं?';

  @override
  String get deleteNoteDialogContent =>
      'क्या आप वाकई इस नोट को हटाना चाहते हैं? यह पूर्ववत नहीं हो सकता।';

  @override
  String get deleteNoteDialogTitle => 'नोट हटाएं';

  @override
  String get designSystemPreview => 'डिज़ाइन सिस्टम प्रीव्यू';

  @override
  String get done => 'पूर्ण';

  @override
  String get doubtScanner => 'शंका स्कैनर';

  @override
  String get doubtScannerTitle => 'शंका स्कैनर';

  @override
  String get doubtsTitle => 'शंकाएं';

  @override
  String get dueFlashcards => 'बाकी फ्लैशकार्ड';

  @override
  String get edit => 'संपादित करें';

  @override
  String get editAction => 'संपादित करें';

  @override
  String get editNote => 'नोट संपादित करें';

  @override
  String get editNoteTitle => 'अपना नोट संपादित करें';

  @override
  String get editNoteTitleScreen => 'नोट संपादित करें';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get editProfileTitle => 'प्रोफ़ाइल एडिट करें';

  @override
  String get editYourNote => 'अपना नोट संपादित करें';

  @override
  String get email => 'ईमेल';

  @override
  String get empty => 'रिक्त';

  @override
  String get emptyState => 'कोई डेटा उपलब्ध नहीं';

  @override
  String get english => 'अंग्रेजी';

  @override
  String get enterEmail => 'कृपया अपना ईमेल दर्ज करें';

  @override
  String get enterName => 'कृपया अपना नाम दर्ज करें';

  @override
  String get enterPassword => 'कृपया पासवर्ड दर्ज करें';

  @override
  String get enterTopic => 'कृपया विषय दर्ज करें';

  @override
  String get error => 'त्रुटि';

  @override
  String get errorInNote => 'नोट में त्रुटि';

  @override
  String errorLoading(Object error) {
    return 'उत्तर लोड करने में त्रुटि: $error';
  }

  @override
  String get errorLoadingDashboard => 'डैशबोर्ड लोड करने में विफल';

  @override
  String get errorLoadingDoubtsTitle => 'शंकाएं लोड करने में त्रुटि';

  @override
  String get errorLoadingNotes => 'नोट्स लोड करने में त्रुटि';

  @override
  String errorPickingImage(Object error) {
    return 'छवि चुनने में त्रुटि: $error';
  }

  @override
  String errorPickingImageSnack(Object error) {
    return 'छवि चुनने में त्रुटि: $error';
  }

  @override
  String errorImportingPdf(Object error) {
    return 'PDF आयात करने में त्रुटि: $error';
  }

  @override
  String errorSaving(Object error) {
    return 'सेव करने में त्रुटि: $error';
  }

  @override
  String errorSavingSnack(Object error) {
    return 'सेव करने में त्रुटि: $error';
  }

  @override
  String errorSendingResetEmail(Object error) {
    return 'रीसेट ईमेल भेजने में त्रुटि: $error';
  }

  @override
  String get estimatedTime => 'अंदाज़ित समय';

  @override
  String get examDate => 'परीक्षा की तारीख';

  @override
  String get exampleChatTitle => 'उदाहरण के लिए, कैलकुलस डेरिवेटिव्स';

  @override
  String get extractingKeyPointsDialog => 'मुख्य बिंदु निकाल रहे हैं...';

  @override
  String failedToCreateChat(Object error) {
    return 'चैट बनाने में विफल: $error';
  }

  @override
  String failedToGenerate(Object error) {
    return 'जेनरेट करने में विफल: $error';
  }

  @override
  String get failedToGenerateFlashcardsDialogTitle =>
      'फ्लैशकार्ड बनाने में विफल';

  @override
  String get failedToLoadSettings => 'सेटिंग्स लोड करने में विफल';

  @override
  String failedToSend(Object error) {
    return 'भेजने में विफल: $error';
  }

  @override
  String failedToUpdate(Object error) {
    return 'अपडेट में विफल: $error';
  }

  @override
  String get featureChat => 'AI ट्यूटर चैट';

  @override
  String get featureFlashcards => 'फ्लैशकार्ड';

  @override
  String get featureFocus => 'फ़ोकस टाइमर';

  @override
  String get featureNotes => 'नोट्स';

  @override
  String get featurePlanner => 'प्लानर';

  @override
  String get featureProgress => 'प्रगति';

  @override
  String get featureQuiz => 'क्विज़';

  @override
  String get featureScanner => 'शंका स्कैनर';

  @override
  String get feedback => 'प्रतिक्रिया';

  @override
  String get filledButton => 'फ़िल्ट बटन';

  @override
  String get filter => 'फ़िल्टर';

  @override
  String get finalScore => 'अंतिम स्कोर';

  @override
  String get firebaseSetUp => 'सेटअप की आवश्यकता है';

  @override
  String get flashcard => 'फ्लैशकार्ड';

  @override
  String get flashcardDeck => 'फ्लैशकार्ड डेक';

  @override
  String get flashcardRatingAgain => 'फिर से';

  @override
  String get flashcardRatingEasy => 'आसान';

  @override
  String get flashcardRatingGood => 'अच्छा';

  @override
  String get flashcardRatingHard => 'कठिन';

  @override
  String get flashcards => 'फ्लैशकार्ड';

  @override
  String get flashcardsGenerated => 'फ्लैशकार्ड सफलतापूर्वक जेनरेट किए गए!';

  @override
  String get flashcardsGeneratedSuccess => 'फ्लैशकार्ड सफलतापूर्वक बने';

  @override
  String get flashcardsGeneratedSuccessSnack => 'फ्लैशकार्ड सफलतापूर्वक बने!';

  @override
  String get focus => 'फोकस';

  @override
  String get focusTimerFocus => 'फोकस';

  @override
  String get focusTimerLongBreak => 'लंबा ब्रेक';

  @override
  String get focusTimerPause => 'रोकें';

  @override
  String get focusTimerReset => 'रीसेट';

  @override
  String get focusTimerSessions => 'सत्र';

  @override
  String get focusTimerShortBreak => 'छोटा ब्रेक';

  @override
  String get focusTimerStart => 'शुरू करें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get front => 'सामने';

  @override
  String get gallery => 'गैलरी';

  @override
  String get galleryButton => 'गैलरी';

  @override
  String get galleryPermission => 'फोटो लाइब्रेरी अनुमति आवश्यक है';

  @override
  String get galleryPermissionSnack => 'फोटो लाइब्रेरी अनुमति आवश्यक है';

  @override
  String get generateFlashcardsAction => 'फ्लैशकार्ड बनाएं';

  @override
  String get generateFlashcardsFromNote => 'फ्लैशकार्ड बनाएं';

  @override
  String get generateQuizAction => 'क्विज़ बनाएं';

  @override
  String get generateQuizFromNote => 'क्विज़ बनाएं';

  @override
  String get generateStudyPlan => 'अध्ययन योजना बनाएं';

  @override
  String get generating => 'जेनरेट हो रहा है...';

  @override
  String get generatingFlashcardsDialog => 'फ्लैशकार्ड बना रहे हैं...';

  @override
  String get generatingQuizDialog => 'क्विज़ बना रहे हैं...';

  @override
  String get glassCard => 'ग्लास कार्ड';

  @override
  String get goHome => 'घर जाएं';

  @override
  String get goToScannerAction => 'स्कैनर पर जाएं';

  @override
  String get goalAchieved => 'लक्ष्य प्राप्त कर लिया! 🎉';

  @override
  String get googleSignIn => 'Google के साथ जारी रखें';

  @override
  String get googleSignInFailed => 'गूगल साइन-इन विफल हुआ';

  @override
  String get grade => 'ग्रेड/कक्षा';

  @override
  String get gradientButton => 'ग्रेडिएंट बटन';

  @override
  String get greetingAfternoon => 'शुभ दोपहर';

  @override
  String get greetingEvening => 'शुभ संध्या';

  @override
  String get greetingMorning => 'शुभ प्रभात';

  @override
  String get guestSignInFailed => 'गेस्ट साइन-इन विफल हुआ';

  @override
  String get gujarati => 'गुजराती';

  @override
  String get helpPersonalize => 'आपके अनुभव को व्यक्तिगत बनायें मदद करें';

  @override
  String get hindi => 'हिंदी';

  @override
  String get hoursPerDay => 'प्रतिदिन घंटे';

  @override
  String get howItWorksDesc =>
      'अपने प्रश्न की फोटो लें या गैलरी से चुनें। StudyMate AI उसका विश्लेषण करेगा और चरण-दर-चरण समाधान देगा।';

  @override
  String get howItWorksHeader => 'यह कैसे काम करता है';

  @override
  String get importImageOcr => 'छवि आयात करें (OCR)';

  @override
  String get importImageOcrTitle => 'छवि आयात करें (OCR)';

  @override
  String get importPdfText => 'PDF/टेक्स्ट आयात करें';

  @override
  String get importPdfTextButton => 'PDF/टेक्स्ट आयात करें';

  @override
  String get importPdfButton => 'PDF आयात करें';

  @override
  String get importText => 'आयात टेक्स्ट';

  @override
  String get keyPoints => 'मुख्य बिंदु';

  @override
  String get keyPointsAction => 'मुख्य बिंदु';

  @override
  String get keyPointsExtractedSuccess => 'मुख्य बिंदु सफलतापूर्वक निकाले गए';

  @override
  String get language => 'भाषा';

  @override
  String get learnSmarter => 'AI सशक्त शिक्षण के साथ स्मार्ट रूप से सीखें';

  @override
  String get letsStudy => 'आज स्मार्ट तरीके से पढ़ाई करें।';

  @override
  String get level => 'लेवल';

  @override
  String get lightMode => 'लाइट मोड';

  @override
  String get linkAccount => 'खाता लिंक करें';

  @override
  String get linkAccountWarning =>
      'एक खाता जोड़ें ताकि आपका डेटा स्थायी रूप से सहेजा और अन्य उपकरणों पर पहुँच सकें।';

  @override
  String get linkEmail => 'ईमेल';

  @override
  String get linkEmailAccount => 'ईमेल खाता लिंक करें';

  @override
  String get linkGoogle => 'Google को लिंक करें';

  @override
  String get linkGoogleEmail => 'Google / ईमेल खाता लिंक करें';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get loadingStats => 'स्टैट्स लोड हो रहे हैं...';

  @override
  String get markDone => 'पूरा किया चिह्नित करें';

  @override
  String get min => 'मिनट';

  @override
  String get minutes => 'मिनट';

  @override
  String get mode => 'मोड';

  @override
  String get more => 'अधिक';

  @override
  String moreTasks(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# अधिक कार्य',
      one: 'अधिक 1 कार्य',
    );
    return '$_temp0';
  }

  @override
  String get motivationalQuote1 =>
      'किसी भी विषय में विदेशी व्यक्ति कभी भी शुरू होते थे।';

  @override
  String get motivationalQuote2 =>
      'सफलता छोटे-छोटे प्रयासों का योग्य है जो दिन पर दिन दोहराए जाते हैं।';

  @override
  String get motivationalQuote3 => 'शिक्षण कभी मन को थकाता नहीं।';

  @override
  String get motivationalQuote4 => 'आपकी सीमा केवल आप ही हैं।';

  @override
  String get motivationalQuote5 =>
      'जहां से शुरू करें। जो भी है उसे उपयोग करें। जो भी कर सकें।';

  @override
  String get name => 'नाम';

  @override
  String get newChat => 'नई चैट';

  @override
  String get newNote => 'नया नोट';

  @override
  String get newNoteTitleScreen => 'नया नोट';

  @override
  String get next => 'आगे';

  @override
  String get noCardsDueToday => 'आज कोई कार्ड समीक्षा के लिए नहीं है';

  @override
  String get noChats => 'अभी तक कोई चैट नहीं';

  @override
  String get noDoubtsSavedTitle => 'अभी तक कोई शंका सेव नहीं';

  @override
  String get noInternet => 'इंटरनेट कनेक्शन नहीं';

  @override
  String get noInternetMessage =>
      'कृपया अपनी कनेक्शन की जाँच करें और फिर से प्रयास करें।';

  @override
  String get noNotes => 'अभी तक कोई नोट नहीं';

  @override
  String get noNotesYet => 'अभी तक कोई नोट नहीं';

  @override
  String get noNotesYetTitle => 'अभी तक कोई नोट नहीं';

  @override
  String get noPlansYet => 'अभी तक कोई योजना नहीं है। ऊपर की पहली योजना बनाएं!';

  @override
  String get noTasksToday => 'आज के कोई कार्य नहीं';

  @override
  String get noUserToDelete => 'कोई उपयोगकर्ता हटाने के लिए नहीं है';

  @override
  String get notFoundDescription =>
      'आप जो पृष्ठ खोज रहे हैं वह उपलब्ध नहीं है या उसे बदल दिया गया है।';

  @override
  String get notSet => 'सेट नहीं है';

  @override
  String get note => 'नोट';

  @override
  String get noteCreated => 'नोट बनाया गया';

  @override
  String get noteDetailTitle => 'नोट';

  @override
  String get noteSimplifiedSuccess => 'नोट सफलतापूर्वक सरल बनाया गया';

  @override
  String get noteSummarizedSuccess => 'नोट सफलतापूर्वक सारांशित';

  @override
  String get noteTitleHint => 'नोट का शीर्षक';

  @override
  String get noteTranslatedSuccess => 'नोट सफलतापूर्वक अनुवादित';

  @override
  String get noteUpdated => 'नोट अपडेट किया गया';

  @override
  String get notes => 'नोट्स';

  @override
  String get notesCreated => 'नोट सफलतापूर्वक बनाया गया';

  @override
  String get notesTitle => 'नोट्स';

  @override
  String get notificationDailySession => 'आपके दैनिक अध्ययन सत्र के लिए समय!';

  @override
  String get notificationStreakReminder => 'अपना स्ट्रीक जीवित रखें!';

  @override
  String notificationStreakReminderBody(Object streak) {
    return 'आप $streak दिन का स्ट्रीक बनाए हुए हैं। अब इसे न तोड़ें!';
  }

  @override
  String get notificationStudyReminder => 'अध्ययन अनुस्मारक';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get ok => 'ठीक है';

  @override
  String get okButton => 'ठीक है';

  @override
  String get outOf => 'में से';

  @override
  String get outlinedButton => 'आउटलाइन्ड बटन';

  @override
  String get password => 'पासवर्ड';

  @override
  String get passwordMin6 => 'पासवर्ड कम से कम 6 अक्षर का होना चाहिए';

  @override
  String get passwordResetEmailSent =>
      'पासवर्ड रीसेट ईमेल भेज दिया गया है। अपने इनबॉक्स की जाँच करें।';

  @override
  String get passwordsMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get pasteButton => 'पेस्ट करें';

  @override
  String get pasteText => 'टेक्स्ट पेस्ट करें';

  @override
  String get pasteTextDialogTitle => 'टेक्स्ट पेस्ट करें';

  @override
  String get pasteTextHint => 'यहाँ टेक्स्ट पेस्ट करें...';

  @override
  String get pasteTextTitle => 'टेक्स्ट पेस्ट करें';

  @override
  String get pdfImportComingSoon => 'PDF आयात जल्द आ रहा है';

  @override
  String get pdfImportSuccess => 'PDF सफलतापूर्वक आयात किया गया';

  @override
  String get pdfNoTextFound => 'PDF में कोई टेक्स्ट नहीं मिला';

  @override
  String pdfFileTooLarge(Object maxSize) {
    return 'PDF फ़ाइल बहुत बड़ी है। अधिकतम आकार $maxSize MB है।';
  }

  @override
  String get extractingPdfTextDialog => 'PDF से टेक्स्ट निकाला जा रहा है...';

  @override
  String get perDay => 'प्रतिदिन';

  @override
  String get pinAction => 'पिन करें';

  @override
  String get planner => 'प्लानर';

  @override
  String get pleaseEnterContent => 'कृपया सामग्री दर्ज करें';

  @override
  String get pleaseEnterContentFirst => 'कृपया पहले सामग्री दर्ज करें';

  @override
  String get pleaseSignInAgainToDelete =>
      'कृपया खाता हटाने के लिए फिर से साइन इन करें';

  @override
  String get pleaseTryAgain => 'कृपया पुनः प्रयास करें।';

  @override
  String get preferences => 'प्राथमिकताएं';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get privacyPolicyDataLocation => 'डेटा स्थान';

  @override
  String get privacyPolicyDataProcessing => 'डेटा प्रोसेसिंग';

  @override
  String get privacyPolicyDataStored => 'Firestore में संग्रहीत डेटा';

  @override
  String get privacyPolicyDeleteAccount =>
      'आप अपने खाते और सभी संबंधित डेटा को हटाने के लिए Settings > Account > Delete Account & Data से कर सकते हैं। यह आपके सभी सीख डेटा को स्थायी रूप से हटा देगा।';

  @override
  String get privacyPolicyDeletion => 'हटाना';

  @override
  String get privacyPolicyGemini =>
      '• छवियों और पाठ को Google Gemini के लिए भेजा जाता है और AI सहायता के लिए\\n• Gemini आपके डेटा के उत्तर उत्पन्न करने के लिए प्रोसेस करता है\\n• हम आपके छवियों या चैट संदेशों को Gemini के साथ संग्रहीत नहीं करते\\n• उत्तर आपके Firestore खाते में स्थानीय रूप से सहेजे जाते हैं';

  @override
  String get privacyPolicyLocation =>
      'आपका डेटा Google Cloud पर होस्ट किए गए Firebase Firestore में संग्रहीत है। डेटा पर प्रवाह और रूप में एन्क्रिप्ट है।';

  @override
  String get privacyPolicyScreen => 'गोपनीयता नीति';

  @override
  String get privacyPolicyStudyData =>
      '• प्रोफ़ाइल: नाम, ग्रेड, भाषा, दैनिक लक्ष्य\\n• अध्ययन डेटा: चैट, संदेश, नोट्स, फ्लैशकार्ड, क्विज़\\n• प्रगति: XP, लेवल, स्ट्रिक, दैनिक आंकड़े\\n• प्लाननेटर: अध्ययन योजना और कार्य\\n• बैज: अपहटित उपलब्धि';

  @override
  String get processButton => 'प्रश्न प्रोसेस करें';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get profileSetup => 'अपना प्रोफ़ाइल सेट करें';

  @override
  String get profileUpdatedSuccessfully => 'प्रोफ़ाइल सफलतापूर्वक अपडेट हुई';

  @override
  String get progress => 'प्रगति';

  @override
  String get progressRing => 'प्रोग्रेस रिंग';

  @override
  String get question => 'प्रश्न';

  @override
  String question1of(Object question, Object total) {
    return 'प्रश्न $question में से $total';
  }

  @override
  String get questions => 'प्रश्न';

  @override
  String get quickActions => 'त्वरित क्रियाएं';

  @override
  String get quickQuiz => 'त्वरित क्विज़';

  @override
  String get quizDifficultyEasy => 'आसान';

  @override
  String get quizDifficultyHard => 'कठिन';

  @override
  String get quizDifficultyMedium => 'मध्यम';

  @override
  String get quizGeneratedSuccess => 'क्विज़ सफलतापूर्वक बना';

  @override
  String get quizNotFound => 'क्विज़ नहीं मिला';

  @override
  String get quizzes => 'क्विज़';

  @override
  String get quizzesTaken => 'लिए गए क्विज़';

  @override
  String get rateApp => 'ऐप को रेट करें';

  @override
  String get reauthAndRetry => 'पुनः प्रमाणीकरण और पुनः प्रयास करें';

  @override
  String get rename => 'बदलें';

  @override
  String get renameChat => 'चैट का नाम बदलें';

  @override
  String get resetPassword => 'पासवर्ड रीसेट करें';

  @override
  String get result => 'परिणाम';

  @override
  String get resume => 'जारी रखें';

  @override
  String get retries => 'पुनः प्रयास';

  @override
  String get retryButton => 'पुनः प्रयास';

  @override
  String get retryQuiz => 'क्विज़ फिर से प्रयास करें';

  @override
  String get retryWrongQuestions => 'गलत प्रश्न फिर से प्रयास करें';

  @override
  String get reviewAnswers => 'उत्तरों की समीक्षा करें';

  @override
  String get reviewFlashcard =>
      'स्पेस्ड रिपीटिशन आपकी प्रतिभा को बढ़ावा करने के लिए उपयोग करेगा';

  @override
  String get reviewFlashcards => 'फ्लैशकार्डों की समीक्षा करें';

  @override
  String get runFlutterfireConfigure =>
      'शुरू करने के लिए, आपको Firebase कॉन्फ़िगर करना होगा:\\n1. चलाएं: flutterfire configure\\n2. Auth प्रदाता शुरू करें (गूगल, ईमेल/पासवर्ड)\\n3. Cloud Firestore शुरू करें\\n4. Firebase AI Logic (गैमिनी) शुरू करें\\n5. App Check शुरू करें';

  @override
  String get runSetup => 'मुझे Firebase कॉन्फ़िगर किया है';

  @override
  String get save => 'सेव करें';

  @override
  String get saveButton => 'सेव करें';

  @override
  String get saveChanges => 'सेव करें';

  @override
  String get savedToNotes => 'नोट्स में सेव कर दिया गया!';

  @override
  String get scanDoubt => 'शंका स्कैन करें';

  @override
  String get scanProblemMessage =>
      'स्कैनर से समस्या स्कैन करके शंकाएं सेव करें';

  @override
  String get score => 'स्कोर';

  @override
  String get search => 'खोजें';

  @override
  String get searchChats => 'चैट खोजें';

  @override
  String get searchNotesHint => 'नोट्स खोजें...';

  @override
  String get selectImageHeader => 'छवि चुनें';

  @override
  String get selectSubjectHeader => 'विषय चुनें';

  @override
  String get selectSubjectLabel => 'विषय चुनें';

  @override
  String get selectedImage => 'चुनी गई छवि';

  @override
  String get selectedImageLabel => 'चुनी गई छवि:';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get share => 'साझा करें';

  @override
  String get shareApp => 'ऐप साझा करें';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get signUp => 'साइन अप';

  @override
  String get simplify => 'सरल बनाएं';

  @override
  String get simplifyAction => 'सरल बनाएं';

  @override
  String get simplifyingDialog => 'सरल बना रहे हैं...';

  @override
  String get skip => 'छोड़ें';

  @override
  String get solutionHeader => 'समाधान';

  @override
  String get solutionSaved => 'समाधान संदेहों में सेव किया गया';

  @override
  String get solutionSavedSnack => 'समाधान शंकाओं में सेव किया गया';

  @override
  String get solveQuestion => 'प्रश्न हल करें';

  @override
  String get solveQuestionButton => 'प्रश्न हल करें';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया';

  @override
  String get somethingWentWrongDialogTitle => 'कुछ गलत हो गया';

  @override
  String get somethingWentWrongMessage => 'कुछ गलत हो गया';

  @override
  String get sort => 'क्रमबद्ध करें';

  @override
  String get spacedRepetitionReview =>
      'स्पेस्ड रिपीटिशन आपकी दृढ़ता को भरोसा देगा';

  @override
  String get startNewConversation => 'StudyMate AI के साथ नई बातचीत शुरू करें';

  @override
  String get startNoteSearch => 'नोट खोजें';

  @override
  String get startReview => 'समीक्षा शुरू करें';

  @override
  String get statTile => 'स्टैट टाइल';

  @override
  String get streak => 'स्ट्रिक';

  @override
  String get streakBadge => 'स्ट्रिक बैज';

  @override
  String get student => 'छात्र';

  @override
  String get study => 'पढ़ाई';

  @override
  String get studyHub => 'स्टडी हब';

  @override
  String get studyMateLogo => 'StudyMate AI';

  @override
  String get studyMinutes => 'पढ़ाई के मिनट';

  @override
  String get studyPlanGenerated => 'अध्ययन योजना सफलतापूर्वक उत्पन्न हुई!';

  @override
  String get studyPlanner => 'अध्ययन योजना तालीम';

  @override
  String get subject => 'विषय';

  @override
  String get subjectBiology => 'जीव विज्ञान';

  @override
  String get subjectChemistry => 'रसायन विज्ञान';

  @override
  String get subjectComputerScience => 'कंप्यूटर विज्ञान';

  @override
  String get subjectEnglish => 'अंग्रेजी';

  @override
  String get subjectEnglishSubject => 'अंग्रेज़ी';

  @override
  String get subjectGujarati => 'गुजराती';

  @override
  String get subjectHindi => 'हिंदी';

  @override
  String get subjectHint => 'जैसे, गणित, भौतिक विज्ञान';

  @override
  String get subjectLabel => 'विषय';

  @override
  String get subjectMath => 'गणित';

  @override
  String get subjectMathematics => 'गणित';

  @override
  String get subjectOther => 'अन्य';

  @override
  String get subjectPhysics => 'भौतिक विज्ञान';

  @override
  String get subjectRequired => 'विषय आवश्यक है';

  @override
  String get subjectScience => 'विज्ञान';

  @override
  String get subjectSocial => 'सामाजिक विज्ञान';

  @override
  String get subjectSocialScience => 'सामाजिक विज्ञान';

  @override
  String get subjects => 'रुचि के विषय';

  @override
  String get submitAnswer => 'उत्तर दें';

  @override
  String get summarize => 'सारांश बनाएं';

  @override
  String get summarizeAction => 'सारांश बनाएं';

  @override
  String get summarizingDialog => 'सारांश बना रहे हैं...';

  @override
  String get systemTheme => 'सिस्टम थीम';

  @override
  String get tagsHint => 'बीजगणित, ज्यामिति, महत्वपूर्ण';

  @override
  String get tagsLabel => 'टैग्स (कॉमा से अलग)';

  @override
  String get takeQuiz => 'क्विज़ लें';

  @override
  String get tapAvatarToChange => 'बदलने के लिए एवरे को टैप करें';

  @override
  String get task => 'कार्य';

  @override
  String get tasks => 'कार्य';

  @override
  String get termsOfService =>
      'भूतकाल में, आप हमारी शर्तें और गोपनीयता नीति के साथ सहमति जताने के लिए।';

  @override
  String get textButton => 'टेक्स्ट बटन';

  @override
  String get theme => 'थीम';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get titleLabel => 'शीर्षक';

  @override
  String get titleRequired => 'शीर्षक आवश्यक है';

  @override
  String get today => 'आज';

  @override
  String get todayTask => 'आज का कार्य';

  @override
  String get todayTasks => 'आज के कार्य';

  @override
  String get todaysGoal => 'आज का लक्ष्य';

  @override
  String get toolsDesc =>
      'फ्लैशकार्ड, क्विज़, अध्ययन योजना और फोकस टाइमर - सब एक ऐप में।';

  @override
  String get topic => 'विषय';

  @override
  String get translate => 'अनुवाद करें';

  @override
  String get translateAction => 'अनुवाद करें';

  @override
  String get translatingDialog => 'अनुवाद कर रहे हैं...';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get unmarkDone => 'पूरा किया नहीं चिह्नित करें';

  @override
  String get validEmail => 'वैध ईमेल दर्ज करें';

  @override
  String get viewAll => 'सब देखें';

  @override
  String get voiceInput => 'वॉइस इनपुट';

  @override
  String get weakTopics => 'कमज़ोर विषयों';

  @override
  String get weeklyStats => 'साप्ताहिक आंकड़े';

  @override
  String get welcomeBack => 'फिर से स्वागत है!';

  @override
  String get writeNoteHint => 'यहाँ अपना नोट लिखें...';

  @override
  String get wrong => 'गलत';

  @override
  String get xp => 'XP';

  @override
  String get xpEarned => 'कमाया XP';

  @override
  String get yesterday => 'कल';

  @override
  String get yourScore => 'आपका स्कोर';
}
