/// Debouncer for rate-limiting rapid calls
library;

import 'dart:async';

class Debouncer {
  Timer? _timer;
  final Duration delay;

  Debouncer({required this.delay});

  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}

class Throttler {
  DateTime? _lastRun;
  final Duration interval;

  Throttler({required this.interval});

  void call(void Function() callback) {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= interval) {
      _lastRun = now;
      callback();
    }
  }
}
