import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/l10n/generated/app_localizations.dart';

void main() {
  group('Plural String Tests', () {
    late AppLocalizations enL10n;
    late AppLocalizations guL10n;
    late AppLocalizations hiL10n;

    setUpAll(() async {
      enL10n = await AppLocalizations.delegate.load(const Locale('en'));
      guL10n = await AppLocalizations.delegate.load(const Locale('gu'));
      hiL10n = await AppLocalizations.delegate.load(const Locale('hi'));
    });

    group('English plural (cardsDuePlural)', () {
      test('0 cards due returns formatted string', () {
        final result = enL10n.cardsDuePlural(0);
        expect(result, isNotEmpty);
      });

      test('1 card due returns formatted string', () {
        final result = enL10n.cardsDuePlural(1);
        expect(result, isNotEmpty);
      });

      test('5 cards due returns formatted string', () {
        final result = enL10n.cardsDuePlural(5);
        expect(result, isNotEmpty);
      });
    });

    group('Gujarati plural (cardsDuePlural)', () {
      test('1 card due returns formatted string', () {
        final result = guL10n.cardsDuePlural(1);
        expect(result, isNotEmpty);
      });

      test('5 cards due returns formatted string', () {
        final result = guL10n.cardsDuePlural(5);
        expect(result, isNotEmpty);
      });
    });

    group('Hindi plural (cardsDuePlural)', () {
      test('1 card due returns formatted string', () {
        final result = hiL10n.cardsDuePlural(1);
        expect(result, isNotEmpty);
      });

      test('5 cards due returns formatted string', () {
        final result = hiL10n.cardsDuePlural(5);
        expect(result, isNotEmpty);
      });
    });
  });
}
