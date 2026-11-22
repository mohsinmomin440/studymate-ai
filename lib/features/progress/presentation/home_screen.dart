// Home Screen - Dashboard with real Firestore data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../features/progress/data/progress_repository.dart';
import '../../../features/planner/data/planner_repository.dart';
import '../../../features/flashcards/data/flashcard_repository.dart';
import '../../../core/router/app_router.dart';
import '../../progress/domain/aggregations.dart';

final homeDashboardProvider = FutureProvider<HomeDashboardData>((ref) async {
  final progressRepo = ref.read(progressRepositoryProvider);
  final plannerRepo = ref.read(plannerRepositoryProvider);
  final flashcardRepo = ref.read(flashcardRepositoryProvider);

  // Get user profile once
  final profile = await progressRepo.getUserProgressOnce();

  // Get today's daily stats
  final todayStats = await progressRepo.getTodayDailyStats();

  // Get due flashcards count
  final cardsDue = await flashcardRepo.getDueCardsCount();

  // Get today's tasks from active plans
  final activePlans = await plannerRepo.getActivePlans();
  final todayTasks = getTodaysTasks(activePlans);

  final greeting = getTimeOfDayGreeting(profile.name);

  return HomeDashboardData(
    streak: profile.streak,
    xp: profile.xp,
    level: profile.level,
    xpProgress: profile.xpProgress,
    dailyGoalMin: profile.dailyGoalMin,
    todayStudyMinutes: todayStats['studyMinutes'] as int? ?? 0,
    todayXpEarned: todayStats['xpEarned'] as int? ?? 0,
    cardsDueToday: cardsDue,
    todayTasks: todayTasks,
    greeting: greeting,
  );
});

// Quick action model
class _QuickAction {
  final String label;
  final IconData icon;
  final String route;
  final Color color;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.route,
    required this.color,
  });
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(homeDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('StudyMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (dashboard) => _buildDashboard(context, ref, dashboard),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _buildErrorState(context, e.toString()),
      ),
    );
  }

  Widget _buildDashboard(
      BuildContext context, WidgetRef ref, HomeDashboardData dashboard) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(homeDashboardProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGreetingCard(context, dashboard),
          const Gap(16),
          _buildStreakXPRow(context, dashboard),
          const Gap(24),
          _buildDailyGoalRing(context, dashboard),
          const Gap(24),
          _buildQuickActions(context),
          const Gap(24),
          _buildTodayTasks(context, dashboard),
          const Gap(24),
          _buildDueCardsSection(context, dashboard),
        ],
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context, HomeDashboardData dashboard) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dashboard.greeting,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Gap(8),
          Text(
            dashboard.streak > 0
                ? '🔥 ${dashboard.streak} day streak — keep it going!'
                : 'Start your study streak today!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakXPRow(BuildContext context, HomeDashboardData dashboard) {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            child: Column(
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  size: 32,
                  color: const Color(0xFFFFB020),
                ),
                const Gap(8),
                Text(
                  '${dashboard.streak}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'Day Streak',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: GlassCard(
            child: Column(
              children: [
                Text(
                  'Level ${dashboard.level}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Gap(4),
                Text(
                  '${dashboard.xp} XP',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const Gap(8),
                LinearProgressIndicator(
                  value: dashboard.xpProgress,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyGoalRing(
      BuildContext context, HomeDashboardData dashboard) {
    final progress = dashboard.dailyGoalMin > 0
        ? (dashboard.todayStudyMinutes / dashboard.dailyGoalMin).clamp(0.0, 1.0)
        : 0.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Goal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${dashboard.todayStudyMinutes} / ${dashboard.dailyGoalMin} min',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'XP Earned Today',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '+${dashboard.todayXpEarned} XP',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                    ),
                    const Gap(8),
                    if (progress >= 1.0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Goal achieved! 🎉',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    const actions = [
      _QuickAction(
        label: 'Ask AI',
        icon: Icons.chat_rounded,
        route: '/chat',
        color: Color(0xFF6C5CE7),
      ),
      _QuickAction(
        label: 'Scan Doubt',
        icon: Icons.camera_alt_rounded,
        route: '/scanner',
        color: Color(0xFF00D4C8),
      ),
      _QuickAction(
        label: 'New Note',
        icon: Icons.note_add_rounded,
        route: '/notes/new',
        color: Color(0xFF2ED573),
      ),
      _QuickAction(
        label: 'Quick Quiz',
        icon: Icons.quiz_rounded,
        route: '/quiz',
        color: Color(0xFFFFB020),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const Gap(12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () => context.go(action.route),
              borderRadius: BorderRadius.circular(16),
              child: GlassCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: action.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action.icon,
                        color: action.color,
                        size: 24,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      action.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodayTasks(BuildContext context, HomeDashboardData dashboard) {
    if (dashboard.todayTasks.isEmpty) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Tasks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.planner),
                  child: const Text('View All'),
                ),
              ],
            ),
            const Gap(8),
            EmptyState(
              icon: Icons.task_alt_rounded,
              title: 'No tasks for today',
              message: 'Create a study plan to see tasks here',
              actionLabel: 'Create Plan',
              onAction: () => context.go(AppRoutes.planner),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Tasks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.planner),
                child: const Text('View All'),
              ),
            ],
          ),
          const Gap(8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dashboard.todayTasks.length.clamp(0, 5),
            separatorBuilder: (_, __) => const Gap(8),
            itemBuilder: (context, index) {
              final task = dashboard.todayTasks[index];
              return _TaskTile(task: task);
            },
          ),
          if (dashboard.todayTasks.length > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => context.go(AppRoutes.planner),
                child: Text('+${dashboard.todayTasks.length - 5} more tasks'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDueCardsSection(
      BuildContext context, HomeDashboardData dashboard) {
    if (dashboard.cardsDueToday == 0) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Flashcards Due',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.flashcards),
                  child: const Text('View All'),
                ),
              ],
            ),
            const Gap(8),
            EmptyState(
              icon: Icons.menu_book_rounded,
              title: 'All caught up!',
              message: 'No cards due for review today',
              actionLabel: 'Browse Decks',
              onAction: () => context.go(AppRoutes.flashcards),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Flashcards Due',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.flashcards),
                child: const Text('View All'),
              ),
            ],
          ),
          const Gap(8),
          Row(
            children: [
              Icon(
                Icons.menu_book_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${dashboard.cardsDueToday} cards ready for review',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Spaced repetition will optimize your retention',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.flashcards),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Start Review'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const Gap(16),
            Text(
              'Failed to load dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Gap(8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            ElevatedButton.icon(
              onPressed: () {/* Will need ref to invalidate */},
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final PlannedTask task;

  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.done,
            onChanged: null, // Read-only from home screen
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Text(
              task.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: task.done
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.done
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
