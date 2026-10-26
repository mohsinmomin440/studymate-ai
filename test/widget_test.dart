import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studymate_ai/app/app.dart';
import 'package:studymate_ai/core/theme/theme_provider.dart';

void main() {
  testWidgets('StudyMateApp startup smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const StudyMateApp(),
      ),
    );

    // Initial frame renders splash screen
    await tester.pump();
    expect(find.text('StudyMate AI'), findsWidgets);

    // Settle splash timer
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
