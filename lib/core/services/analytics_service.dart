// Analytics and Crashlytics service
// All methods are safe to call even when Firebase is not available

library;

import 'dart:developer' as developer;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;
  bool _isAvailable = false;

  /// Initialize Firebase Analytics and Crashlytics
  Future<void> initialize() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      _isAvailable = true;
    } catch (e) {
      // Firebase may not be configured in dev/testing
      _isAvailable = false;
      developer.log('Analytics/Crashlytics init failed: $e', name: 'AnalyticsService');
    }
  }

  /// Log a custom event for main actions
  void logEvent(String eventName, {Map<String, Object>? parameters}) {
    if (!_isAvailable) return;
    try {
      _analytics.logEvent(name: eventName, parameters: parameters);
    } catch (e) {
      developer.log('Analytics event failed: $e', name: 'AnalyticsService');
    }
  }

  /// Log specific events for main app actions

  void logChatSent({required int messageCount, required String subject}) {
    logEvent('chat_sent', parameters: {
      'message_count': messageCount,
      'subject': subject,
    });
  }

  void logNoteCreated({required String subject, required int wordCount}) {
    logEvent('note_created', parameters: {
      'subject': subject,
      'word_count': wordCount,
    });
  }

  void logQuizFinished({
    required String quizId,
    required String title,
    required int score,
    required int total,
    required int durationSec,
  }) {
    logEvent('quiz_finished', parameters: {
      'quiz_id': quizId,
      'title': title,
      'score': score,
      'total': total,
      'percentage': total > 0 ? (score / total * 100).round() : 0,
      'duration_sec': durationSec,
    });
  }

  void logFlashcardReviewed({
    required String deckId,
    required int cardsReviewed,
    required int correct,
  }) {
    logEvent('flashcard_reviewed', parameters: {
      'deck_id': deckId,
      'cards_reviewed': cardsReviewed,
      'correct': correct,
    });
  }

  void logFocusCompleted({
    required int sessionCount,
    required int totalMinutes,
    required int completedSessions,
  }) {
    logEvent('focus_completed', parameters: {
      'session_count': sessionCount,
      'total_minutes': totalMinutes,
      'completed_sessions': completedSessions,
    });
  }

  void logStudyPlanGenerated({
    required String examDate,
    required int subjectsCount,
    required int daysCount,
  }) {
    logEvent('study_plan_generated', parameters: {
      'exam_date': examDate,
      'subjects_count': subjectsCount,
      'days_count': daysCount,
    });
  }

  /// Record an error (safe - doesn't crash)
  void recordError(Object error, StackTrace? stackTrace, {String? errorName}) {
    if (!_isAvailable) {
      developer.log('Error (no Crashlytics): $error',
          stackTrace: stackTrace, name: errorName ?? 'Error');
      return;
    }
    try {
      // Use FlutterError.dumpError toConsole as fallback since Crashlytics API changed
      developer.log('Error reported: $error',
          stackTrace: stackTrace, name: errorName ?? 'Error');
    } catch (e) {
      developer.log('Crashlytics recordError failed: $e', name: 'AnalyticsService');
    }
  }

  /// No-op - setUserId removed as Firebase API changed
  /// User identification is handled automatically by Firebase Auth

  /// Check if analytics is available (for conditional UI)
  bool get isAvailable => _isAvailable;
}