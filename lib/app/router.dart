import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/ai_tutor/presentation/ai_tutor_screen.dart';
import '../features/analytics/presentation/analytics_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/onboarding_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/signup_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/planner/presentation/planner_screen.dart';
import '../features/profile/presentation/app_settings_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/quizzes/presentation/quiz_result_screen.dart';
import '../features/quizzes/presentation/quiz_screen.dart';
import '../features/subjects/presentation/add_subject_screen.dart';
import '../features/subjects/presentation/subjects_screen.dart';
import '../features/tasks/presentation/add_task_screen.dart';
import '../features/tasks/presentation/tasks_screen.dart';
import 'main_shell_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),

    // Bottom Navigation Shell
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShellScreen(navigationShell: navigationShell);
      },
      branches: [
        // 0: Home / Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),
        // 1: Planner
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/planner',
              builder: (context, state) => const PlannerScreen(),
            ),
          ],
        ),
        // 2: Subjects
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/subjects',
              builder: (context, state) => const SubjectsScreen(),
            ),
          ],
        ),
        // 3: Tasks
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              builder: (context, state) => const TasksScreen(),
            ),
          ],
        ),
        // 4: Analytics
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/analytics',
              builder: (context, state) => const AnalyticsScreen(),
            ),
          ],
        ),
      ],
    ),

    // Additional Detail & Action Screens
    GoRoute(
      path: '/subjects/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddSubjectScreen(),
    ),
    GoRoute(
      path: '/tasks/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddTaskScreen(),
    ),
    GoRoute(
      path: '/ai-tutor',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AiTutorScreen(),
    ),
    GoRoute(
      path: '/quiz',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const QuizScreen(),
    ),
    GoRoute(
      path: '/quiz/result',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final score = extra?['score'] as int? ?? 4;
        final total = extra?['total'] as int? ?? 5;
        return QuizResultScreen(score: score, total: total);
      },
    ),
    GoRoute(
      path: '/profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AppSettingsScreen(),
    ),
  ],
);
