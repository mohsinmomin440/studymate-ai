// Unit tests for ARB key validation
// Validates that all three ARB files have identical keys and no empty values

import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

/// Extract placeholder variable names from an ARB string.
/// Handles both simple placeholders like {name} and ICU plurals like {count, plural, one{...} other{...}}
/// For plurals, extracts just the variable name (first parameter) and ignores the formatted content
Set<String> _extractPlaceholders(String value) {
  final placeholders = <String>{};

  // First, find top-level placeholders (those with outer braces)
  // A top-level placeholder is one where the opening { is followed by content that
  // doesn't start with another { (which would indicate nested content like plurals)

  int i = 0;
  while (i < value.length) {
    if (value[i] == '{') {
      // Find the matching closing brace
      int depth = 1;
      int end = i + 1;
      while (end < value.length && depth > 0) {
        if (value[end] == '{') depth++;
        if (value[end] == '}') depth--;
        end++;
      }
      // end-1 is the position of the closing }
      // Extract content inside the top-level braces
      final content = value.substring(i + 1, end - 1).trim();

      // Check if this is a simple placeholder or ICU format
      // ICU plurals have: variable, plural/select, one{...} other{...}
      if (content.contains(',')) {
        // ICU plural/select format - extract the variable name
        final parts = content.split(',');
        if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
          // The variable name is always the first part before the comma
          placeholders.add(parts[0].trim());
        }
      } else if (content.isNotEmpty) {
        // Simple placeholder - add it
        placeholders.add(content);
      }

      i = end;
    } else {
      i++;
    }
  }
  return placeholders;
}

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

    test('All three ARB files have matching placeholders', () {
      // Get keys excluding metadata (starting with @)
      final enKeys = enArb.keys.where((k) => !k.startsWith('@')).toSet();

      for (final key in enKeys) {
        // Extract placeholders from each locale's value for this key
        String? enValue;
        String? guValue;
        String? hiValue;

        if (enArb[key] is String) enValue = enArb[key] as String;
        if (guArb[key] is String) guValue = guArb[key] as String;
        if (hiArb[key] is String) hiValue = hiArb[key] as String;

        if (enValue != null) {
          final enPlaceholders = _extractPlaceholders(enValue);
          if (guValue != null) {
            final guPlaceholders = _extractPlaceholders(guValue);
            expect(
              guPlaceholders,
              equals(enPlaceholders),
              reason: 'Gujarati placeholders mismatch for key "$key": '
                  'English has $enPlaceholders but Gujarati has $guPlaceholders',
            );
          }
          if (hiValue != null) {
            final hiPlaceholders = _extractPlaceholders(hiValue);
            expect(
              hiPlaceholders,
              equals(enPlaceholders),
              reason: 'Hindi placeholders mismatch for key "$key": '
                  'English has $enPlaceholders but Hindi has $hiPlaceholders',
            );
          }
        }
      }
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
