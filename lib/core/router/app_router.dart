import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/widgets/gap.dart';
import '../../core/theme/app_theme.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/chat/chat_feature.dart';
import '../../features/notes/notes_feature.dart';
import '../../features/scanner/scanner_feature.dart';
import '../../features/scanner/presentation/doubts_list_screen.dart';
import '../../features/flashcards/flashcards_feature.dart';
import '../../features/quiz/quiz_feature.dart';
import '../../features/planner/planner_feature.dart';
import '../../features/focus/presentation/focus_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/profile_setup_screen.dart';
import '../../features/auth/presentation/not_found_screen.dart';
import '../../features/home/presentation/study_hub_screen.dart';
import '../../features/home/presentation/design_preview_screen.dart';

/// App route paths
class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const auth = '/auth';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  static const studyHub = '/study';
  static const chat = '/chat';
  static const chatDetail = '/chat/:chatId';
  static const scanner = '/scanner';
  static const doubts = '/doubts';
  static const notes = '/notes';
  static const notesCreate = '/notes/create';
  static const noteDetail = '/notes/:noteId';
  static const flashcards = '/flashcards';
  static const flashcardsCreate = '/flashcards/create';
  static const flashcardsEdit = '/flashcards/:deckId/edit';
  static const deckDetail = '/flashcards/:deckId';
  static const studyMode = '/flashcards/:deckId/study';
  static const cardCreate = '/card/create/:deckId';
  static const cardEdit = '/card/:deckId/:cardId/edit';
  static const quiz = '/quiz';
  static const quizCreate = '/quiz/create';
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
                path: AppRoutes.studyHub,
                builder: (context, state) => const StudyHubScreen(),
              ),
              GoRoute(
                path: AppRoutes.flashcards,
                builder: (context, state) => FlashcardsScreen(),
              ),
              GoRoute(
                path: AppRoutes.flashcardsCreate,
                builder: (context, state) => CreateEditDeckScreen(),
              ),
              GoRoute(
                path: AppRoutes.flashcardsEdit,
                builder: (context, state) => CreateEditDeckScreen(
                    deckId: state.pathParameters['deckId']),
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
                builder: (context, state) => QuizScreen(),
              ),
              GoRoute(
                path: AppRoutes.quizCreate,
                builder: (context, state) => QuizCreateScreen(),
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
                path: AppRoutes.notes,
                builder: (context, state) => const NotesScreen(),
              ),
              GoRoute(
                path: AppRoutes.notesCreate,
                builder: (context, state) => const CreateEditNoteScreen(),
              ),
              GoRoute(
                path: AppRoutes.noteDetail,
                builder: (context, state) => NoteDetailScreen(
                  noteId: state.pathParameters['noteId']!,
                ),
              ),
              GoRoute(
                path: AppRoutes.scanner,
                builder: (context, state) => const ScannerScreen(),
              ),
              GoRoute(
                path: AppRoutes.doubts,
                builder: (context, state) => const DoubtsListScreen(),
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
                path: AppRoutes.planner,
                builder: (context, state) => const PlannerScreen(),
              ),
              GoRoute(
                path: AppRoutes.planDetail,
                builder: (context, state) => PlanDetailScreen(
                  planId: state.pathParameters['planId']!,
                ),
              ),
              GoRoute(
                path: AppRoutes.focus,
                builder: (context, state) => const FocusScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),
        ],
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
