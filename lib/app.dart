import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/constants/app_constants.dart';
import 'l10n/generated/app_localizations.dart';
import 'main.dart' show FirebaseInitializer;

/// Main app widget
class StudyMateApp extends ConsumerStatefulWidget {
  const StudyMateApp({super.key});

  @override
  ConsumerState<StudyMateApp> createState() => _StudyMateAppState();
}

class _StudyMateAppState extends ConsumerState<StudyMateApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    await FirebaseInitializer.initialize();
    if (mounted) {
      // Check if Firebase was initialized successfully
      // For now, we'll skip auth initialization and show setup screen if needed
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: FirebaseSetupScreen(),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales:
          AppConstants.supportedLocales.map((code) => Locale(code)).toList(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

/// Friendly setup screen shown when Firebase is not configured
class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.school_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome to StudyMate AI',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Setup required',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text(
                  'To get started, you need to configure Firebase:\n\n'
                  '1. Run: flutterfire configure\n'
                  '2. Enable Auth providers (Google, Email/Password)\n'
                  '3. Enable Cloud Firestore\n'
                  '4. Enable Firebase AI Logic (Gemini)\n'
                  '5. Enable App Check',
                  style: TextStyle(height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () {
                    // In production, this would attempt Firebase init
                    // For now show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Run "flutterfire configure" in terminal')),
                    );
                  },
                  child: const Text('I have configured Firebase'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
