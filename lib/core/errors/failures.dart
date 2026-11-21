/// App failures for error handling
library;

import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server/API failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});

  factory ServerFailure.fromException(Object e, {String? code}) {
    final message = e.toString();
    if (message.contains('permission-denied') ||
        message.contains('PERMISSION_DENIED')) {
      return const ServerFailure('Permission denied. Please check your access.',
          code: 'permission_denied');
    }
    if (message.contains('unauthenticated') ||
        message.contains('UNAUTHENTICATED')) {
      return const ServerFailure('Session expired. Please sign in again.',
          code: 'unauthenticated');
    }
    if (message.contains('not-found') || message.contains('NOT_FOUND')) {
      return const ServerFailure('Resource not found.', code: 'not_found');
    }
    if (message.contains('already-exists') ||
        message.contains('ALREADY_EXISTS')) {
      return const ServerFailure('This already exists.',
          code: 'already_exists');
    }
    if (message.contains('quota-exceeded') ||
        message.contains('QUOTA_EXCEEDED') ||
        message.contains('429')) {
      return const ServerFailure(
          'Daily limit reached. Please try again tomorrow.',
          code: 'quota_exceeded');
    }
    if (message.contains('network') ||
        message.contains('NETWORK') ||
        message.contains('timeout')) {
      return const ServerFailure('Network error. Check your connection.',
          code: 'network_error');
    }
    if (message.contains('blocked') ||
        message.contains('safety') ||
        message.contains('SAFETY')) {
      return const ServerFailure(
          'Content was blocked. Please rephrase your request.',
          code: 'content_blocked');
    }
    return ServerFailure('Something went wrong. Please try again.', code: code);
  }
}

/// Cache/local storage failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Validation failures
class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure(super.message,
      {this.fieldErrors = const {}, super.code});

  factory ValidationFailure.single(String field, String message) {
    return ValidationFailure(message,
        fieldErrors: {field: message}, code: 'validation_error');
  }

  factory ValidationFailure.multiple(Map<String, String> errors) {
    return ValidationFailure('Please fix the errors below',
        fieldErrors: errors, code: 'validation_error');
  }
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'weak-password':
        return const AuthFailure(
            'Password is too weak. Use at least 6 characters.',
            code: 'weak_password');
      case 'email-already-in-use':
        return const AuthFailure('An account with this email already exists.',
            code: 'email_in_use');
      case 'invalid-email':
        return const AuthFailure('Invalid email address.',
            code: 'invalid_email');
      case 'user-disabled':
        return const AuthFailure('This account has been disabled.',
            code: 'user_disabled');
      case 'user-not-found':
        return const AuthFailure('No account found with this email.',
            code: 'user_not_found');
      case 'wrong-password':
        return const AuthFailure('Incorrect password.', code: 'wrong_password');
      case 'too-many-requests':
        return const AuthFailure('Too many attempts. Please try again later.',
            code: 'too_many_requests');
      case 'operation-not-allowed':
        return const AuthFailure('This sign-in method is not enabled.',
            code: 'not_allowed');
      case 'account-exists-with-different-credential':
        return const AuthFailure(
            'An account already exists with a different sign-in method.',
            code: 'different_credential');
      case 'requires-recent-login':
        return const AuthFailure('Please sign in again to continue.',
            code: 'reauth_required');
      case 'credential-already-in-use':
        return const AuthFailure(
            'This credential is already linked to another account.',
            code: 'credential_in_use');
      case 'invalid-credential':
        return const AuthFailure('Invalid credentials. Please try again.',
            code: 'invalid_credential');
      default:
        return AuthFailure('Authentication failed: $code', code: code);
    }
  }
}

/// AI-specific failures
class AIFailure extends Failure {
  const AIFailure(super.message, {super.code});

  factory AIFailure.quotaExceeded() =>
      const AIFailure('Daily AI limit reached. Try again tomorrow.',
          code: 'ai_quota');
  factory AIFailure.modelUnavailable() =>
      const AIFailure('AI model is temporarily unavailable.',
          code: 'model_unavailable');
  factory AIFailure.invalidResponse() =>
      const AIFailure('AI returned an invalid response. Please try again.',
          code: 'invalid_response');
  factory AIFailure.contentBlocked() =>
      const AIFailure('Your request was blocked. Please rephrase.',
          code: 'content_blocked');
  factory AIFailure.networkError() =>
      const AIFailure('Network error. Check your connection.',
          code: 'network_error');
  factory AIFailure.unknown(Object e) => AIFailure.fromException(e);

  factory AIFailure.fromException(Object e) {
    final message = e.toString().toLowerCase();
    if (message.contains('429') ||
        message.contains('quota') ||
        message.contains('rate limit')) {
      return AIFailure.quotaExceeded();
    }
    if (message.contains('blocked') || message.contains('safety')) {
      return AIFailure.contentBlocked();
    }
    if (message.contains('network') ||
        message.contains('timeout') ||
        message.contains('connection')) {
      return AIFailure.networkError();
    }
    if (message.contains('model') && message.contains('unavailable')) {
      return AIFailure.modelUnavailable();
    }
    return const AIFailure('AI request failed. Please try again.',
        code: 'unknown');
  }
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred'])
      : super(code: 'unknown');
}
