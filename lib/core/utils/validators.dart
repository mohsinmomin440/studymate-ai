/// Input validators for forms
library;

class Validators {
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }

  static String? noteTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Title is required';
    }
    if (value.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  static String? noteBody(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Note content cannot be empty';
    }
    if (value.length > 50000) {
      return 'Note is too long (max 50,000 characters)';
    }
    return null;
  }

  static String? deckTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deck title is required';
    }
    if (value.trim().length > 80) {
      return 'Title must be less than 80 characters';
    }
    return null;
  }

  static String? flashcardFront(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Question is required';
    }
    if (value.length > 500) {
      return 'Question must be less than 500 characters';
    }
    return null;
  }

  static String? flashcardBack(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Answer is required';
    }
    if (value.length > 1000) {
      return 'Answer must be less than 1000 characters';
    }
    return null;
  }

  static String? quizTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quiz title is required';
    }
    if (value.trim().length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  static String? positiveInteger(String? value, {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }

  static String? minMaxInteger(String? value, int min, int max,
      {String fieldName = 'Value'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < min || parsed > max) {
      return '$fieldName must be between $min and $max';
    }
    return null;
  }
}
