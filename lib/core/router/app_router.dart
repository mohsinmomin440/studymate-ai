import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/gap.dart';
import '../../core/theme/app_theme.dart';

/// App route paths
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  static const chat = '/chat';
  static const chatDetail = '/chat/:chatId';
  static const scanner = '/scanner';
  static const notes = '/notes';
  static const noteDetail = '/notes/:noteId';
  static const flashcards = '/flashcards';
  static const deckDetail = '/flashcards/:deckId';
  static const studyMode = '/flashcards/:deckId/study';
  static const quiz = '/quiz';
  static const quizDetail = '/quiz/:quizId';
  static const quizTake = '/quiz/:quizId/take';
  static const quizResult = '/quiz/:quizId/result';
  static const planner = '/planner';
  static const planDetail = '/planner/:planId';
  static const focus = '/focus';
  static const progress = '/progress';
  static const settings = '/settings';
  static const designPreview = '/design-preview';
}

/// Router provider with auth state listening
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;
      final isEmailVerified = user?.emailVerified ?? false;
      final location = state.matchedLocation;

      // Public routes that don't need auth
      final isPublicRoute = [
        AppRoutes.splash,
        AppRoutes.onboarding,
        AppRoutes.auth,
      ].contains(location);

      // Routes that need auth but not email verification
      final isAuthOnlyRoute = [
        AppRoutes.profileSetup,
      ].contains(location);

      // Protected routes needing full auth
      final isProtectedRoute = !isPublicRoute && !isAuthOnlyRoute;

      if (!isAuthenticated && isProtectedRoute) {
        return AppRoutes.auth;
      }

      if (isAuthenticated && !isEmailVerified && isProtectedRoute) {
        return AppRoutes.profileSetup; // Will handle verification there
      }

      if (isAuthenticated && location == AppRoutes.auth) {
        return AppRoutes.home;
      }

      if (isAuthenticated && location == AppRoutes.splash) {
        return AppRoutes.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.auth,
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.chat,
                builder: (context, state) => const ChatListScreen(),
              ),
              GoRoute(
                path: AppRoutes.chatDetail,
                builder: (context, state) => ChatDetailScreen(
                  chatId: state.pathParameters['chatId']!,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scanner,
                builder: (context, state) => const ScannerScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.planner,
                builder: (context, state) => const PlannerScreen(),
              ),
              GoRoute(
                path: AppRoutes.planDetail,
                builder: (context, state) => PlanDetailScreen(
                  planId: state.pathParameters['planId']!,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
      // Nested routes that don't fit in bottom nav
      GoRoute(
        path: AppRoutes.notes,
        builder: (context, state) => const NotesScreen(),
      ),
      GoRoute(
        path: AppRoutes.noteDetail,
        builder: (context, state) => NoteDetailScreen(
          noteId: state.pathParameters['noteId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.flashcards,
        builder: (context, state) => const FlashcardsScreen(),
      ),
      GoRoute(
        path: AppRoutes.deckDetail,
        builder: (context, state) => DeckDetailScreen(
          deckId: state.pathParameters['deckId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.studyMode,
        builder: (context, state) => StudyModeScreen(
          deckId: state.pathParameters['deckId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: AppRoutes.quizDetail,
        builder: (context, state) => QuizDetailScreen(
          quizId: state.pathParameters['quizId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.quizTake,
        builder: (context, state) => QuizTakeScreen(
          quizId: state.pathParameters['quizId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.quizResult,
        builder: (context, state) => QuizResultScreen(
          quizId: state.pathParameters['quizId']!,
          attemptId: state.uri.queryParameters['attemptId'],
        ),
      ),
      GoRoute(
        path: AppRoutes.focus,
        builder: (context, state) => const FocusScreen(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.designPreview,
        builder: (context, state) => const DesignPreviewScreen(),
      ),
    ],
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});

/// Main shell with bottom navigation
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar:
          _CustomBottomNavBar(navigationShell: navigationShell),
    );
  }
}

/// Custom animated bottom navigation bar
class _CustomBottomNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _CustomBottomNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = navigationShell.currentIndex;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                index: 0,
                currentIndex: currentIndex,
                icon: Icons.home_rounded,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                onTap: () => navigationShell.goBranch(0),
              ),
              _NavItem(
                index: 1,
                currentIndex: currentIndex,
                icon: Icons.school_rounded,
                activeIcon: Icons.school_rounded,
                label: 'Study',
                onTap: () => navigationShell.goBranch(1),
              ),
              _CenterFAB(
                currentIndex: currentIndex,
                onTap: () => navigationShell.goBranch(2),
              ),
              _NavItem(
                index: 3,
                currentIndex: currentIndex,
                icon: Icons.calendar_today_rounded,
                activeIcon: Icons.calendar_today_rounded,
                label: 'Planner',
                onTap: () => navigationShell.goBranch(3),
              ),
              _NavItem(
                index: 4,
                currentIndex: currentIndex,
                icon: Icons.person_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profile',
                onTap: () => navigationShell.goBranch(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = index == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey(isActive),
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 26,
                ),
              ),
              const Gap(2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: theme.textTheme.labelSmall!.copyWith(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterFAB extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onTap;

  const _CenterFAB({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = currentIndex == 2;

    return Expanded(
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          transform: Matrix4.diagonal3Values(
              isActive ? 1.1 : 1.0, isActive ? 1.1 : 1.0, 1.0),
          child: Material(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.surface,
            elevation: isActive ? 8 : 4,
            shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isActive ? theme.gradients.primary : null,
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: isActive
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Splash screen - animated logo transition
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _scale = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _scale = 1.0);
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go(AppRoutes.onboarding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              child: const Icon(
                Icons.school_rounded,
                size: 80,
                color: Color(0xFF6C5CE7),
              ),
            ),
            const Gap(32),
            Text(
              'StudyMate AI',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(16),
            Text(
              'Learn smarter with AI',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Onboarding screens
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int _currentPage = 0;
  final int _totalPages = 3;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = [
      _OnboardingPage(
        title: 'Learn Smarter',
        message:
            'Ask AI to explain difficult topics, generate notes, flashcards, and quizzes.',
        icon: Icons.auto_awesome,
      ),
      _OnboardingPage(
        title: 'Track Progress',
        message:
            'Set daily goals, earn XP, track streaks, and level up your learning journey.',
        icon: Icons.bar_chart,
      ),
      _OnboardingPage(
        title: 'Study Anywhere',
        message: 'Offline mode, cloud sync, and multi-language support.',
        icon: Icons.download,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: _totalPages,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  return pages[index < pages.length ? index : 0];
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_totalPages, (index) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      );
                    }),
                  ),
                  const Gap(24),
                  FilledButton(
                    onPressed: () {
                      // Check if user is already authenticated
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        context.go(AppRoutes.home);
                      } else {
                        context.go(AppRoutes.auth);
                      }
                    },
                    child: const Text('Get Started'),
                  ),
                  const Gap(12),
                  TextButton(
                    onPressed: () {
                      // Skip onboarding
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        context.go(AppRoutes.home);
                      } else {
                        context.go(AppRoutes.auth);
                      }
                    },
                    child: const Text('Skip'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const _OnboardingPage({
    required this.title,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              icon,
              size: 120,
              color: theme.colorScheme.primary,
            ),
            const Gap(32),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome to StudyMate AI',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(8),
              Text(
                'Sign in to continue your learning journey',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(40),
              FilledButton(
                onPressed: () {
                  // Google Sign In - will be implemented in Phase 2
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login, size: 24),
                    const Gap(12),
                    Text('Sign in with Google',
                        style: theme.textTheme.labelLarge),
                  ],
                ),
              ),
              const Gap(16),
              OutlinedButton(
                onPressed: () {
                  // Email sign in - will be implemented in Phase 2
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email_outlined, size: 24),
                    const Gap(12),
                    Text('Continue with Email',
                        style: theme.textTheme.labelLarge),
                  ],
                ),
              ),
              const Gap(24),
              Divider(
                indent: 32,
                endIndent: 32,
                color: theme.colorScheme.outlineVariant,
              ),
              const Gap(16),
              OutlinedButton.icon(
                onPressed: () {
                  // Guest mode - will be implemented in Phase 2
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.person_outline, size: 24),
                label: const Text('Continue as Guest',
                    style: TextStyle(fontSize: 16)),
              ),
              const Gap(40),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Back to Splash',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Profile Setup')));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home')));
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Chat List')));
}

class ChatDetailScreen extends StatelessWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Chat: $chatId')));
}

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Scanner')));
}

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Planner')));
}

class PlanDetailScreen extends StatelessWidget {
  final String planId;
  const PlanDetailScreen({super.key, required this.planId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Plan: $planId')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings')));
}

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Notes')));
}

class NoteDetailScreen extends StatelessWidget {
  final String noteId;
  const NoteDetailScreen({super.key, required this.noteId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Note: $noteId')));
}

class FlashcardsScreen extends StatelessWidget {
  const FlashcardsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Flashcards')));
}

class DeckDetailScreen extends StatelessWidget {
  final String deckId;
  const DeckDetailScreen({super.key, required this.deckId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Deck: $deckId')));
}

class StudyModeScreen extends StatelessWidget {
  final String deckId;
  const StudyModeScreen({super.key, required this.deckId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Study: $deckId')));
}

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Quiz')));
}

class QuizDetailScreen extends StatelessWidget {
  final String quizId;
  const QuizDetailScreen({super.key, required this.quizId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Quiz: $quizId')));
}

class QuizTakeScreen extends StatelessWidget {
  final String quizId;
  const QuizTakeScreen({super.key, required this.quizId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Take Quiz: $quizId')));
}

class QuizResultScreen extends StatelessWidget {
  final String quizId;
  final String? attemptId;
  const QuizResultScreen({super.key, required this.quizId, this.attemptId});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text('Result: $quizId')));
}

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Focus')));
}

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Progress')));
}

class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Design Preview')));
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: Theme.of(context).colorScheme.error),
              const Gap(16),
              Text('Page not found',
                  style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
      );
}
