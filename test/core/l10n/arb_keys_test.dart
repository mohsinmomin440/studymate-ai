// Unit tests for ARB key validation
// Validates that all three ARB files have identical keys and no empty values

import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ARB Key Validation', () {
    late Map<String, dynamic> enArb;
    late Map<String, dynamic> guArb;
    late Map<String, dynamic> hiArb;

    setUpAll(() {
      final enFile = File('lib/l10n/app_en.arb');
      final guFile = File('lib/l10n/app_gu.arb');
      final hiFile = File('lib/l10n/app_hi.arb');

      enArb = jsonDecode(enFile.readAsStringSync()) as Map<String, dynamic>;
      guArb = jsonDecode(guFile.readAsStringSync()) as Map<String, dynamic>;
      hiArb = jsonDecode(hiFile.readAsStringSync()) as Map<String, dynamic>;
    });

    test('All three ARB files have identical keys', () {
      // Get keys excluding metadata (starting with @)
      final enKeys = enArb.keys.where((k) => !k.startsWith('@')).toSet();
      final guKeys = guArb.keys.where((k) => !k.startsWith('@')).toSet();
      final hiKeys = hiArb.keys.where((k) => !k.startsWith('@')).toSet();

      expect(
        guKeys,
        equals(enKeys),
        reason: 'Gujarati ARB is missing keys present in English. '
            'Missing: ${enKeys.difference(guKeys).join(", ")}. '
            'Extra: ${guKeys.difference(enKeys).join(", ")}',
      );
      expect(
        hiKeys,
        equals(enKeys),
        reason: 'Hindi ARB is missing keys present in English. '
            'Missing: ${enKeys.difference(hiKeys).join(", ")}. '
            'Extra: ${hiKeys.difference(enKeys).join(", ")}',
      );
    });

    test('English ARB has no empty string values', () {
      final emptyKeys = <String>[];
      for (final entry in enArb.entries) {
        if (!entry.key.startsWith('@')) {
          final value = entry.value;
          if (value is String && value.trim().isEmpty) {
            emptyKeys.add(entry.key);
          }
        }
      }
      expect(
        emptyKeys,
        isEmpty,
        reason:
            'English ARB has empty values for keys: ${emptyKeys.join(", ")}',
      );
    });

    test('Gujarati ARB has no empty string values', () {
      final emptyKeys = <String>[];
      for (final entry in guArb.entries) {
        if (!entry.key.startsWith('@')) {
          final value = entry.value;
          if (value is String && value.trim().isEmpty) {
            emptyKeys.add(entry.key);
          }
        }
      }
      expect(
        emptyKeys,
        isEmpty,
        reason:
            'Gujarati ARB has empty values for keys: ${emptyKeys.join(", ")}',
      );
    });

    test('Hindi ARB has no empty string values', () {
      final emptyKeys = <String>[];
      for (final entry in hiArb.entries) {
        if (!entry.key.startsWith('@')) {
          final value = entry.value;
          if (value is String && value.trim().isEmpty) {
            emptyKeys.add(entry.key);
          }
        }
      }
      expect(
        emptyKeys,
        isEmpty,
        reason: 'Hindi ARB has empty values for keys: ${emptyKeys.join(", ")}',
      );
    });

    test('All locale metadata keys are correct', () {
      expect(enArb['@@locale'], 'en');
      expect(guArb['@@locale'], 'gu');
      expect(hiArb['@@locale'], 'hi');
    });
  });
}
