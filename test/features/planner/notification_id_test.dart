// Unit tests for planner notification ID generation
import 'package:flutter_test/flutter_test.dart';

/// Utility function to generate deterministic 32-bit notification ID
/// Format: hash(planId + date + reminderHour) fits in 32-bit int range
int generateNotificationId(String planId, DateTime dayDate, int reminderHour) {
  final dateStr = dayDate.toIso8601String().split('T')[0];
  final key = '$planId|$dateStr|$reminderHour';

  // Simple deterministic hash that fits in 32-bit signed integer range
  // We use modulo to ensure it fits in the positive range
  int hash = 0;
  for (int i = 0; i < key.length; i++) {
    hash = (hash * 31 + key.codeUnitAt(i)) % 2147483647;
  }
  return hash;
}

void main() {
  group('generateNotificationId', () {
    test('generates consistent ID for same inputs', () {
      final planId = 'plan_123';
      final dayDate = DateTime(2025, 12, 15);
      final hour = 8;

      final id1 = generateNotificationId(planId, dayDate, hour);
      final id2 = generateNotificationId(planId, dayDate, hour);

      expect(id1, equals(id2));
    });

    test('generates different IDs for different plan IDs', () {
      final dayDate = DateTime(2025, 12, 15);
      final hour = 8;

      final id1 = generateNotificationId('plan_1', dayDate, hour);
      final id2 = generateNotificationId('plan_2', dayDate, hour);

      expect(id1, isNot(equals(id2)));
    });

    test('generates different IDs for different dates', () {
      final planId = 'plan_123';
      final hour = 8;

      final id1 = generateNotificationId(planId, DateTime(2025, 12, 15), hour);
      final id2 = generateNotificationId(planId, DateTime(2025, 12, 16), hour);

      expect(id1, isNot(equals(id2)));
    });

    test('generates different IDs for different hours', () {
      final planId = 'plan_123';
      final dayDate = DateTime(2025, 12, 15);

      final id1 = generateNotificationId(planId, dayDate, 8);
      final id2 = generateNotificationId(planId, dayDate, 9);

      expect(id1, isNot(equals(id2)));
    });

    test('generates 32-bit positive integer IDs', () {
      final planId = 'plan_123';
      final dayDate = DateTime(2025, 12, 15);
      final hour = 8;

      final id = generateNotificationId(planId, dayDate, hour);

      expect(id, greaterThanOrEqualTo(0), reason: 'ID should be non-negative');
      expect(id, lessThan(2147483648),
          reason: 'ID should fit in 32-bit signed int range');
    });

    test('generates stable IDs across multiple calls (deterministic)', () {
      final planId = 'plan_longer_id_with_more_characters';
      final dayDate = DateTime(2025, 6, 15, 10, 30);
      final hour = 10;

      final ids = List.generate(
          10, (_) => generateNotificationId(planId, dayDate, hour));

      expect(ids.toSet().length, equals(1),
          reason: 'All IDs should be identical for same inputs');
    });

    test('handles special characters in plan ID', () {
      final planId = 'plan_abc-123_test@home';
      final dayDate = DateTime(2025, 12, 15);
      final hour = 8;

      final id = generateNotificationId(planId, dayDate, hour);

      expect(id, greaterThanOrEqualTo(0));
    });

    test('produces different IDs for different reminder hours', () {
      final planId = 'plan_xyz';
      final dayDate = DateTime(2025, 3, 1);

      final id8am = generateNotificationId(planId, dayDate, 8);
      final id9am = generateNotificationId(planId, dayDate, 9);

      expect(id8am, isNot(equals(id9am)));
    });

    test('notification IDs fit within 32-bit signed integer range', () {
      // Test with a long plan ID to stress-test the hash
      final planId = 'plan_with_very_long_id_string_to_test_edge_cases';
      final dayDate = DateTime(2025, 12, 15);
      final hour = 8;

      final id = generateNotificationId(planId, dayDate, hour);

      // Should be positive and fit in 32-bit signed int
      expect(id, inInclusiveRange(0, 2147483647));
    });
  });
}
