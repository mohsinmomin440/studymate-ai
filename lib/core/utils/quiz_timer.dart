// Quiz timer logic - plain Dart, no Flutter dependencies
// Used by QuizTakeScreen for timed quizzes
// Implements deadline-based timing for correct behavior when app goes to background

/// Default clock function for time-based operations
DateTime _defaultClock() => DateTime.now();

/// Represents the state of a quiz timer using a stored deadline
class QuizTimer {
  int _totalSeconds;
  final DateTime? _deadline;
  bool _isExpired = false;
  final DateTime Function() _now;

  /// Creates a timer with a total duration and optional pre-set deadline
  /// [_now] is a clock function for testability, defaults to DateTime.now
  QuizTimer({
    required int totalSeconds,
    DateTime? deadline,
    DateTime Function()? now,
  })  : _totalSeconds = totalSeconds,
        _deadline = deadline,
        _now = now ?? _defaultClock;

  /// Get total seconds
  int get totalSeconds => _totalSeconds;

  /// Create a timer from quiz duration minutes with current time as start
  QuizTimer.fromDurationMinutes(int minutes, {DateTime Function()? clock})
      : _totalSeconds = minutes * 60,
        _deadline =
            (clock ?? _defaultClock)().add(Duration(seconds: minutes * 60)),
        _now = clock ?? _defaultClock;

  /// Check if timer has a time limit
  bool get hasTimeLimit => _totalSeconds > 0;

  /// Check if timer has expired
  bool get isExpired => _isExpired;

  /// Calculate remaining seconds based on current time and deadline
  int get remainingSeconds {
    if (!hasTimeLimit || _deadline == null) return _totalSeconds;
    final now = _now();
    final remaining = _deadline.difference(now).inSeconds;
    return remaining.clamp(0, _totalSeconds);
  }

  /// Check if time has run out (expired or remaining is 0)
  bool isTimeUp() => _isExpired || (hasTimeLimit && remainingSeconds <= 0);

  /// Get formatted time string (MM:SS)
  String get formattedTime {
    final remaining = remainingSeconds;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Advance the timer and check if expired
  /// Returns true if quiz should auto-submit due to timeout
  bool tick() {
    if (_isExpired) return true;
    if (!hasTimeLimit) return false;
    if (isTimeUp()) {
      _isExpired = true;
      return true;
    }
    return false;
  }

  /// Force expire the timer (for manual submission)
  void expire() => _isExpired = true;

  /// Reset timer to initial state
  void reset({int? newDuration}) {
    if (newDuration != null) {
      _totalSeconds = newDuration;
    }
    _isExpired = false;
  }

  /// Get elapsed seconds since timer started
  int get elapsedSeconds => hasTimeLimit
      ? (_totalSeconds - remainingSeconds).clamp(0, _totalSeconds)
      : 0;

  /// Calculate questions answered by a given time
  /// Returns number of questions answered within the time limit
  int questionsAnsweredByTime(int secondsElapsed, int totalQuestions) {
    if (!hasTimeLimit) return totalQuestions;

    // Assume roughly 30 seconds per question as default pace
    // This is informational only - actual answering depends on user
    final estimatedQuestions =
        (secondsElapsed / 30).floor().clamp(0, totalQuestions);
    return estimatedQuestions;
  }
}
