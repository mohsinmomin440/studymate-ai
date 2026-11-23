// AI Service - wraps firebase_ai for all AI interactions
// Handles streaming, retry/backoff, JSON parsing, error mapping

library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/errors/error_mapper.dart';
import '../../../core/services/remote_config_service.dart';
import '../ai_prompts.dart';

/// Provider for AI service
final aiServiceProvider = Provider<AiService>((ref) => AiService());

/// Provider for daily AI usage counter
final dailyAIUsageProvider =
    StateNotifierProvider<DailyAIUsageNotifier, int>((ref) {
  return DailyAIUsageNotifier();
});

/// AI Service using Firebase AI Logic (Gemini Developer API)
class AiService {
  late final FirebaseAI _firebaseAI;
  late final GenerativeModel _chatModel;
  late final GenerativeModel _cheapModel;
  late final RemoteConfigService _remoteConfig;

  bool _initialized = false;

  /// Initialize the AI service
  Future<void> initialize() async {
    if (_initialized) return;

    _firebaseAI = FirebaseAI.googleAI();
    _remoteConfig = RemoteConfigService();

    // Try to initialize Remote Config, fall back to defaults if it fails
    try {
      await _remoteConfig.initialize();
    } catch (e) {
      // Remote Config not configured yet, will use defaults from _setDefaults
    }

    // Use RemoteConfig if available, otherwise fall back to AppConstants defaults
    // This allows updating model names without app update
    final chatModelName = _remoteConfig.chatModel;
    final cheapModelName = _remoteConfig.cheapModel;

    _chatModel = _firebaseAI.generativeModel(
      model: chatModelName,
      generationConfig: GenerationConfig(
        temperature: AppConstants.temperatureChat,
        maxOutputTokens: AppConstants.maxOutputTokensChat,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium,
            HarmBlockMethod.probability),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium,
            HarmBlockMethod.probability),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium,
            HarmBlockMethod.probability),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium,
            HarmBlockMethod.probability),
      ],
    );
    _cheapModel = _firebaseAI.generativeModel(
      model: cheapModelName,
      generationConfig: GenerationConfig(
        temperature: AppConstants.temperatureJSON,
        maxOutputTokens: AppConstants.maxOutputTokensJSON,
        responseMimeType: 'application/json',
      ),
      safetySettings: [
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium,
            HarmBlockMethod.probability),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium,
            HarmBlockMethod.probability),
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium,
            HarmBlockMethod.probability),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium,
            HarmBlockMethod.probability),
      ],
    );
    _initialized = true;
  }

  /// Check and increment daily AI usage counter
  Future<bool> checkAndIncrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(PrefKeys.dailyAIUsageDate) ?? '';
    int count = prefs.getInt(PrefKeys.dailyAIUsageCount) ?? 0;

    if (lastDate != today) {
      count = 0;
      await prefs.setString(PrefKeys.dailyAIUsageDate, today);
    }

    // Use RemoteConfig limit if available, otherwise fall back to AppConstants
    final limit = _initialized
        ? _remoteConfig.dailyAIRequestLimit
        : AppConstants.dailyAIRequestLimit;
    if (count >= limit) {
      return false;
    }

    await prefs.setInt(PrefKeys.dailyAIUsageCount, count + 1);
    return true;
  }

  /// Get current usage count
  Future<int> getDailyUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(PrefKeys.dailyAIUsageDate) ?? '';
    if (lastDate != today) return 0;
    return prefs.getInt(PrefKeys.dailyAIUsageCount) ?? 0;
  }

  /// Generate content with retry and exponential backoff
  Future<GenerateContentResponse> _generateWithRetry(
    GenerativeModel model,
    List<Content> contents, {
    int maxRetries = 3,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        final response = await model.generateContent(contents);
        return response;
      } on FirebaseAIException catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          throw mapExceptionToFailure(e, StackTrace.current);
        }
        // Exponential backoff: 1s, 2s, 4s
        await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          throw AIFailure('Unexpected error: ${e.toString()}');
        }
        await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
      }
    }
  }

  /// Generate content stream with retry
  Stream<GenerateContentResponse> _generateStreamWithRetry(
    GenerativeModel model,
    List<Content> contents, {
    int maxRetries = 3,
  }) async* {
    var attempt = 0;
    while (true) {
      try {
        final stream = model.generateContentStream(contents);
        await for (final chunk in stream) {
          yield chunk;
        }
        return;
      } on FirebaseAIException catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          throw mapExceptionToFailure(e, StackTrace.current);
        }
        await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
      } catch (e) {
        attempt++;
        if (attempt >= maxRetries) {
          throw AIFailure('Unexpected error: ${e.toString()}');
        }
        await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
      }
    }
  }

  /// Start a chat session with system instruction
  ChatSession startChat({
    required String systemPrompt,
    List<Content>? history,
  }) {
    final systemContent = Content.system(systemPrompt);
    final allHistory = [systemContent, if (history != null) ...history];
    return _chatModel.startChat(history: allHistory);
  }

  /// Send a message in a chat session (streaming)
  Stream<GenerateContentResponse> sendMessageStream(
    ChatSession session,
    String message,
  ) {
    return _generateStreamWithRetry(
      _chatModel,
      [Content.text(message)],
    ).transform(StreamTransformer.fromHandlers(
      handleData: (data, sink) {
        // The stream already yields chunks from the model
        // We just pass them through
      },
    ));
  }

  /// Send a message and get full response (non-streaming)
  Future<String> sendMessage(ChatSession session, String message) async {
    final response = await _generateWithRetry(
      _chatModel,
      [Content.text(message)],
    );
    return response.text ?? '';
  }

  /// Generate JSON response (quiz, flashcards, study plan)
  Future<T> generateJson<T>({
    required String prompt,
    required T Function(Map<String, dynamic>) fromJson,
    bool useCheapModel = true,
  }) async {
    final model = useCheapModel ? _cheapModel : _chatModel;
    final response = await _generateWithRetry(model, [Content.text(prompt)]);

    final text = response.text ?? '';
    if (text.isEmpty) {
      throw AIFailure('Empty response from AI');
    }

    try {
      // Clean up potential markdown code fences
      String cleanText = text.trim();
      if (cleanText.startsWith('```json')) {
        cleanText = cleanText.substring(7);
      } else if (cleanText.startsWith('```')) {
        cleanText = cleanText.substring(3);
      }
      if (cleanText.endsWith('```')) {
        cleanText = cleanText.substring(0, cleanText.length - 3);
      }
      cleanText = cleanText.trim();

      final json = jsonDecode(cleanText) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      throw AIFailure('Failed to parse JSON response: ${e.toString()}');
    }
  }

  /// Generate quiz - returns list of maps for quiz repository
  Future<List<Map<String, dynamic>>> generateQuiz({
    required String topic,
    required int count,
    required String difficulty,
    required String subject,
    required String language,
  }) async {
    final prompt = buildQuizPrompt(
      topic: topic,
      count: count,
      difficulty: difficulty,
      subject: subject,
      language: language,
    );

    return generateJson(
      prompt: prompt,
      fromJson: (json) {
        final list = json['questions'] as List? ?? json as List;
        return list.map((e) => (e as Map<String, dynamic>)).toList();
      },
      useCheapModel: true,
    );
  }

  /// Generate flashcards
  Future<List<FlashcardData>> generateFlashcards({
    required String topic,
    required int count,
    required String subject,
    required String language,
  }) async {
    final prompt = buildFlashcardPrompt(
      topic: topic,
      count: count,
      subject: subject,
      language: language,
    );

    return generateJson(
      prompt: prompt,
      fromJson: (json) {
        final list = json['cards'] as List? ?? json as List;
        return list
            .map((e) => FlashcardData.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      useCheapModel: true,
    );
  }

  /// Generate study plan
  Future<StudyPlanData> generateStudyPlan({
    required DateTime examDate,
    required List<String> subjects,
    required int hoursPerDay,
    required List<String> weakTopics,
    required String language,
  }) async {
    final prompt = buildStudyPlanPrompt(
      examDate: examDate,
      subjects: subjects,
      hoursPerDay: hoursPerDay,
      weakTopics: weakTopics,
      language: language,
    );

    return generateJson(
      prompt: prompt,
      fromJson: (json) => StudyPlanData.fromJson(json),
      useCheapModel: true,
    );
  }

  /// Summarize note
  Future<String> summarizeNote({
    required String noteText,
    required String language,
  }) async {
    final prompt = buildSummarizePrompt(noteText: noteText, language: language);
    final response =
        await _generateWithRetry(_cheapModel, [Content.text(prompt)]);
    return response.text ?? '';
  }

  /// Simplify note
  Future<String> simplifyNote({
    required String noteText,
    required String language,
  }) async {
    final prompt = buildSimplifyPrompt(noteText: noteText, language: language);
    final response =
        await _generateWithRetry(_cheapModel, [Content.text(prompt)]);
    return response.text ?? '';
  }

  /// Translate note
  Future<String> translateNote({
    required String noteText,
    required String targetLanguage,
  }) async {
    final prompt = buildTranslatePrompt(
        noteText: noteText, targetLanguage: targetLanguage);
    final response =
        await _generateWithRetry(_cheapModel, [Content.text(prompt)]);
    return response.text ?? '';
  }

  /// Extract key points
  Future<String> extractKeyPoints({
    required String noteText,
    required String language,
  }) async {
    final prompt = buildKeyPointsPrompt(noteText: noteText, language: language);
    final response =
        await _generateWithRetry(_cheapModel, [Content.text(prompt)]);
    return response.text ?? '';
  }

  /// Generate flashcards from note text
  Future<List<FlashcardData>> generateFlashcardsFromNote({
    required String noteText,
    required int count,
    required String subject,
    required String language,
  }) async {
    final prompt = '''
Generate $count flashcards from the following note in $subject.
Language: $language.

Output ONLY valid JSON matching this schema:
$flashcardJsonSchema

Note:
$noteText
''';

    return generateJson(
      prompt: prompt,
      fromJson: (json) {
        final list = json['cards'] as List? ?? json as List;
        return list
            .map((e) => FlashcardData.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      useCheapModel: true,
    );
  }

  /// Generate quiz from note text
  Future<List<QuizQuestion>> generateQuizFromNote({
    required String noteText,
    required int count,
    required String difficulty,
    required String subject,
    required String language,
  }) async {
    final prompt = '''
Generate a $difficulty quiz with $count multiple-choice questions from the following note in $subject.
Language: $language.

Output ONLY valid JSON matching this schema:
$quizJsonSchema

Note:
$noteText
''';

    return generateJson(
      prompt: prompt,
      fromJson: (json) {
        final list = json['questions'] as List? ?? json as List;
        return list
            .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
            .toList();
      },
      useCheapModel: true,
    );
  }

  /// Analyze an image with text prompt (multimodal)
  /// Returns a step-by-step solution.
  /// Throws [AIFailure] on error for proper error handling.
  /// Supports Spark plan with quota limits.
  Future<String> analyzeImageWithText({
    required String imagePath,
    required String subject,
    required String question,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Read image file bytes
    final imageBytes = await File(imagePath).readAsBytes();

    // Build prompt with subject context
    final prompt = '''
You are StudyMate AI, a helpful study tutor. Analyze the image provided and solve the problem step by step.

Subject: $subject
Question: $question

Provide a detailed step-by-step solution with explanations. Format your answer clearly with markdown.
''';

    // Create multimodal content with image and text
    // Combine image and text prompt into a single user message
    final content = [
      Content('user', [
        InlineDataPart('image/png', imageBytes),
        TextPart(prompt),
      ]),
    ];

    final response = await _generateWithRetry(_chatModel, content);
    return response.text ?? '';
  }
}

/// Daily AI usage counter notifier
class DailyAIUsageNotifier extends StateNotifier<int> {
  DailyAIUsageNotifier() : super(0) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(PrefKeys.dailyAIUsageDate) ?? '';
    if (lastDate == today) {
      state = prefs.getInt(PrefKeys.dailyAIUsageCount) ?? 0;
    } else {
      state = 0;
    }
  }

  Future<void> increment() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString(PrefKeys.dailyAIUsageDate) ?? '';
    int count = prefs.getInt(PrefKeys.dailyAIUsageCount) ?? 0;

    if (lastDate != today) {
      count = 0;
      await prefs.setString(PrefKeys.dailyAIUsageDate, today);
    }

    count++;
    await prefs.setInt(PrefKeys.dailyAIUsageCount, count);
    state = count;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(PrefKeys.dailyAIUsageCount);
    await prefs.remove(PrefKeys.dailyAIUsageDate);
    state = 0;
  }
}

/// Quiz question model
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        question: json['question'] as String,
        options: (json['options'] as List).map((e) => e as String).toList(),
        correctIndex: json['correctIndex'] as int,
        explanation: json['explanation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
      };
}

/// Flashcard data model
class FlashcardData {
  final String front;
  final String back;

  FlashcardData({required this.front, required this.back});

  factory FlashcardData.fromJson(Map<String, dynamic> json) => FlashcardData(
        front: json['front'] as String,
        back: json['back'] as String,
      );

  Map<String, dynamic> toJson() => {
        'front': front,
        'back': back,
      };
}

/// Study plan data model
class StudyPlanData {
  final List<StudyDay> days;

  StudyPlanData({required this.days});

  factory StudyPlanData.fromJson(Map<String, dynamic> json) => StudyPlanData(
        days: (json['days'] as List)
            .map((e) => StudyDay.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'days': days.map((e) => e.toJson()).toList(),
      };
}

class StudyDay {
  final DateTime date;
  final List<StudyTask> tasks;

  StudyDay({required this.date, required this.tasks});

  factory StudyDay.fromJson(Map<String, dynamic> json) => StudyDay(
        date: DateTime.parse(json['date'] as String),
        tasks: (json['tasks'] as List)
            .map((e) => StudyTask.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().split('T')[0],
        'tasks': tasks.map((e) => e.toJson()).toList(),
      };
}

class StudyTask {
  final String title;
  final String subject;
  final int estimatedMinutes;
  final String type; // study, review, practice, break

  StudyTask({
    required this.title,
    required this.subject,
    required this.estimatedMinutes,
    required this.type,
  });

  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
        title: json['title'] as String,
        subject: json['subject'] as String,
        estimatedMinutes: json['estimatedMinutes'] as int,
        type: json['type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'subject': subject,
        'estimatedMinutes': estimatedMinutes,
        'type': type,
      };
}
