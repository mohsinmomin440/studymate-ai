import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../shared/widgets/gap.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/app_chip.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/streak_badge.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/stat_tile.dart';
import '../../shared/widgets/glass_card.dart';
import '../../features/chat/chat_feature.dart';
import '../../features/notes/notes_feature.dart';
import '../../features/scanner/scanner_feature.dart';
import '../../features/flashcards/flashcards_feature.dart';
import '../../features/quiz/quiz_feature.dart';

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
                builder: (context, state) => StudyHubScreen(),
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

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (!mounted) return;
        context.go(AppRoutes.profileSetup);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign in failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInAsGuest() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInAnonymously();
      if (!mounted) return;
      context.go(AppRoutes.profileSetup);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guest sign in failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseAuth.instance.sendPasswordResetEmail(
                email: emailController.text.trim(),
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password reset email sent. Check your inbox.'),
                ),
              );
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

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
                onPressed: _isLoading ? null : _signInWithGoogle,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Row(
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
                onPressed: _isLoading
                    ? null
                    : () => showDialog(
                          context: context,
                          builder: (context) => const EmailSignInDialog(),
                        ),
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
                onPressed: _isLoading ? null : _signInAsGuest,
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
                onPressed: () => _showForgotPasswordDialog(),
                child: const Text('Forgot Password?'),
              ),
              const Gap(16),
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

class EmailSignInDialog extends StatefulWidget {
  const EmailSignInDialog({super.key});

  @override
  State<EmailSignInDialog> createState() => _EmailSignInDialogState();
}

class _EmailSignInDialogState extends State<EmailSignInDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  void _toggleMode() {
    setState(() => _isSignUp = !_isSignUp);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      context.go(AppRoutes.profileSetup);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isSignUp ? 'Create Account' : 'Sign In'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email required';
                if (!value.contains('@')) return 'Enter valid email';
                return null;
              },
            ),
            const Gap(16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password required';
                if (value.length < 6) return 'Min 6 characters';
                return null;
              },
            ),
            const Gap(8),
            TextButton(
              onPressed: _isLoading ? null : _toggleMode,
              child: Text(_isSignUp
                  ? 'Have an account? Sign In'
                  : 'Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        TextButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(_isSignUp ? 'Sign Up' : 'Sign In'),
        ),
      ],
    );
  }
}

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _dailyGoalController = TextEditingController(text: '60');
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _isGuest = FirebaseAuth.instance.currentUser?.isAnonymous ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gradeController.dispose();
    _dailyGoalController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final name = _nameController.text.trim();
    final grade = _gradeController.text.trim();
    final dailyGoal = int.tryParse(_dailyGoalController.text) ?? 60;

    await user.updateDisplayName(name);

    // Save to Firestore user document
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(user.uid).set({
      'name': name,
      'grade': grade,
      'dailyGoalMin': dailyGoal,
      'lastStudyDate': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  Future<void> _linkToGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.isAnonymous) {
        await user.linkWithCredential(credential);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account upgraded to Google!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _linkToEmail(String email, String password) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || !user.isAnonymous) return;

      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.linkWithCredential(credential);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account upgraded to Email!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Complete Your Profile',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(8),
                Text(
                  'Tell us about yourself to personalize your experience',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Gap(32),
                AppTextField(
                  label: 'Full Name',
                  hint: 'Enter your name',
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                ),
                const Gap(16),
                AppTextField(
                  label: 'Class/Grade',
                  hint: 'e.g., 12th Grade, Computer Science',
                  controller: _gradeController,
                  textCapitalization: TextCapitalization.words,
                ),
                const Gap(16),
                SizedBox(
                  height: 200,
                  child: ListView(
                    children: [
                      Text(
                        'Subjects of Interest',
                        style: theme.textTheme.titleSmall,
                      ),
                      const Gap(8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          AppChip(label: 'Mathematics'),
                          AppChip(label: 'Physics'),
                          AppChip(label: 'Chemistry'),
                          AppChip(label: 'Biology'),
                          AppChip(label: 'English'),
                          AppChip(label: 'Gujarati'),
                          AppChip(label: 'Hindi'),
                          AppChip(label: 'Computer Science'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                AppTextField(
                  label: 'Daily Study Goal (minutes)',
                  hint: 'e.g., 60',
                  controller: _dailyGoalController,
                  keyboardType: TextInputType.number,
                ),
                const Gap(16),
                SizedBox(
                  height: 200,
                  child: ListView(
                    children: [
                      Text(
                        'Preferred Language',
                        style: theme.textTheme.titleSmall,
                      ),
                      const Gap(8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          AppChip(label: 'English'),
                          AppChip(label: 'Gujarati'),
                          AppChip(label: 'Hindi'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Gap(32),
                if (_isGuest) ...[
                  Text(
                    'Want to save your progress?',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const Gap(8),
                  Text(
                    'Link your account to avoid losing data when reinstalling.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(16),
                  FilledButton.tonal(
                    onPressed: _showLinkAccountDialog,
                    child: const Text('Link to Google Account'),
                  ),
                  const Gap(8),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) =>
                            _EmailLinkDialog(onLink: _linkToEmail),
                      );
                    },
                    child: const Text('Or link to Email'),
                  ),
                  const Gap(16),
                  Divider(
                    indent: 32,
                    endIndent: 32,
                    color: theme.colorScheme.outlineVariant,
                  ),
                  const Gap(16),
                ],
                FilledButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _saveProfile();
                    }
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLinkAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle_rounded),
              title: const Text('Google'),
              onTap: () {
                Navigator.of(context).pop();
                _linkToGoogle();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => _EmailLinkDialog(onLink: _linkToEmail),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _EmailLinkDialog extends StatefulWidget {
  final void Function(String email, String password) onLink;

  const _EmailLinkDialog({required this.onLink});

  @override
  State<_EmailLinkDialog> createState() => _EmailLinkDialogState();
}

class _EmailLinkDialogState extends State<_EmailLinkDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Link to Email'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Email required';
                if (!value.contains('@')) return 'Enter valid email';
                return null;
              },
            ),
            const Gap(16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Password required';
                if (value.length < 6) return 'Min 6 characters';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop();
              widget.onLink(
                _emailController.text.trim(),
                _passwordController.text,
              );
            }
          },
          child: const Text('Link'),
        ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home')));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Settings')));
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

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Focus')));
}

class StudyHubScreen extends StatelessWidget {
  const StudyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'What do you want to study today?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(24),
          _buildStudyCard(
            context: context,
            title: 'Flashcards',
            subtitle: 'Review and create flashcards',
            icon: Icons.shuffle_rounded,
            onTap: () => GoRouter.of(context).go(AppRoutes.flashcards),
          ),
          const Gap(12),
          _buildStudyCard(
            context: context,
            title: 'Quizzes',
            subtitle: 'Test your knowledge',
            icon: Icons.quiz_rounded,
            onTap: () => GoRouter.of(context).go(AppRoutes.quiz),
          ),
          const Gap(12),
          _buildStudyCard(
            context: context,
            title: 'Notes',
            subtitle: 'Create and manage notes',
            icon: Icons.note_rounded,
            onTap: () => GoRouter.of(context).go(AppRoutes.notes),
          ),
          const Gap(12),
          _buildStudyCard(
            context: context,
            title: 'Doubts',
            subtitle: 'Ask AI to solve your doubts',
            icon: Icons.question_answer_rounded,
            onTap: () => GoRouter.of(context).go(AppRoutes.scanner),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Gap(4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const Gap(8),
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Design Preview'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Light'),
              Tab(text: 'Dark'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _DesignPreviewTab(isDark: false, theme: theme),
            _DesignPreviewTab(isDark: true, theme: theme),
          ],
        ),
      ),
    );
  }
}

class _DesignPreviewTab extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;

  const _DesignPreviewTab({required this.isDark, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Text Fields'),
        AppTextField(
          label: 'Full Name',
          hint: 'Enter your name',
          controller: TextEditingController(),
        ),
        const Gap(16),
        AppTextField(
          label: 'Email',
          hint: 'Enter your email',
          controller: TextEditingController(),
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        const Gap(16),
        AppTextField(
          label: 'Password',
          hint: 'Enter your password',
          controller: TextEditingController(),
          prefixIcon: Icons.lock,
          obscureText: true,
        ),
        const Gap(24),
        const SectionHeader(title: 'Chips'),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            AppChip(label: 'Mathematics'),
            AppChip(label: 'Physics'),
            AppChip(label: 'Chemistry'),
            AppChip(label: 'Biology'),
          ],
        ),
        const Gap(16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            AppChip(label: 'Easy', selected: true),
            AppChip(label: 'Medium'),
            AppChip(label: 'Hard'),
          ],
        ),
        const Gap(24),
        const SectionHeader(title: 'Buttons'),
        FilledButton(
          onPressed: () {},
          child: const Text('Primary Button'),
        ),
        const Gap(8),
        OutlinedButton(
          onPressed: () {},
          child: const Text('Outlined Button'),
        ),
        const Gap(8),
        FilledButton.tonal(
          onPressed: () {},
          child: const Text('Tonal Button'),
        ),
        const Gap(24),
        const SectionHeader(title: 'Badges'),
        const StreakBadge(streak: 5),
        const Gap(8),
        const StreakBadge(streak: 12),
        const Gap(8),
        const StreakBadge(streak: 1),
        const Gap(24),
        const SectionHeader(title: 'Progress'),
        ProgressRing(
          progress: 0.75,
          size: 80,
        ),
        const Gap(16),
        SizedBox(
          height: 100,
          child: ListView(
            children: [
              CircularStatTile(
                label: 'XP',
                value: '1250',
                progress: 0.75,
              ),
              CircularStatTile(
                label: 'Streak',
                value: '7 days',
                progress: 0.7,
              ),
              CircularStatTile(
                label: 'Cards',
                value: '42',
                progress: 0.85,
              ),
            ],
          ),
        ),
        const Gap(24),
        const SectionHeader(title: 'Progress Ring'),
        ProgressRing(
          progress: 1.0,
          size: 72,
          progressGradient: LinearGradient(
            colors: [Color(0xFF6C5CE7), Color(0xFF8E7BFF)],
          ),
        ),
      ],
    );
  }
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
