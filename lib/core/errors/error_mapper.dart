/// Map exceptions to user-friendly failure messages
library;

import 'failures.dart';

/// Maps any exception to an appropriate Failure
Failure mapExceptionToFailure(Object error, StackTrace? stackTrace) {
  // Firebase Auth errors
  if (error.toString().contains('FirebaseAuthException') ||
      error.toString().contains('auth/')) {
    final code = _extractAuthCode(error.toString());
    return AuthFailure.fromCode(code);
  }

  // Firestore errors
  if (error.toString().contains('FirebaseException') ||
      error.toString().contains('firestore/')) {
    return ServerFailure.fromException(error);
  }

  // AI errors
  if (error.toString().toLowerCase().contains('gemini') ||
      error.toString().toLowerCase().contains('generative') ||
      error.toString().toLowerCase().contains('ai')) {
    return AIFailure.fromException(error);
  }

  // Network errors
  if (error is Exception) {
    final message = error.toString().toLowerCase();
    if (message.contains('socket') ||
        message.contains('timeout') ||
        message.contains('connection') ||
        message.contains('network') ||
        message.contains('http')) {
      return const ServerFailure('Network error. Please check your connection.',
          code: 'network_error');
    }
  }

  return UnknownFailure(error.toString());
}

String _extractAuthCode(String errorString) {
  // Extract error code from Firebase Auth exception string
  final patterns = [
    RegExp(r'\[(auth/[^\]]+)\]'),
    RegExp(r'code: (auth/[^\s,]+)'),
    RegExp(r'code=([^\s,]+)'),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(errorString);
    if (match != null) {
      return match.group(1) ?? 'unknown';
    }
  }

  // Check for known codes in the message
  const knownCodes = [
    'weak-password',
    'email-already-in-use',
    'invalid-email',
    'user-disabled',
    'user-not-found',
    'wrong-password',
    'too-many-requests',
    'operation-not-allowed',
    'account-exists-with-different-credential',
    'requires-recent-login',
    'credential-already-in-use',
    'invalid-credential',
  ];

  for (final code in knownCodes) {
    if (errorString.contains(code)) {
      return code;
    }
  }

  return 'unknown';
}

/// Get user-friendly message for any failure
String getFailureMessage(Failure failure) {
  return failure.message;
}

/// Check if failure is retryable
bool isRetryableFailure(Failure failure) {
  return failure is ServerFailure &&
          (failure.code == 'network_error' ||
              failure.code == 'quota_exceeded') ||
      failure is AIFailure &&
          (failure.code == 'network_error' ||
              failure.code == 'model_unavailable');
}
