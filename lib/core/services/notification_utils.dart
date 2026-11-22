// Shared notification utilities for deterministic ID generation and scheduling

import 'package:timezone/timezone.dart' as tz;

/// Generates a deterministic 32-bit notification ID using FNV-1a hash algorithm.
/// This ensures IDs are stable across app restarts and fit in 32-bit signed int range.
///
/// Format: FNV-1a hash of (planId + "|" + dateStr + "|" + reminderHour)
int generateNotificationId(String planId, DateTime dayDate, int reminderHour) {
  final dateStr = dayDate.toIso8601String().split('T')[0];
  final key = '$planId|$dateStr|$reminderHour';

  // FNV-1a hash algorithm for 32-bit integer
  const uint32aOffset = 2166136261;
  const uint32aPrime = 16777619;
  int hash = uint32aOffset;

  for (int i = 0; i < key.length; i++) {
    hash ^= key.codeUnitAt(i);
    hash = (hash * uint32aPrime) & 0xFFFFFFFF;
  }

  // Ensure positive and fit in 32-bit signed int range
  return hash % 2147483647;
}

/// Creates a TZDateTime for a given date at the specified hour/minute.
tz.TZDateTime makeReminderDateTime(DateTime dayDate, int hour, int minute) {
  return tz.TZDateTime(
    tz.local,
    dayDate.year,
    dayDate.month,
    dayDate.day,
    hour,
    minute,
  );
}
