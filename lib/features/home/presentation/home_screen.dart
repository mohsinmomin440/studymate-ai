// Home screen - Dashboard with greeting, streak, XP, and quick actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../features/progress/data/progress_repository.dart';
import '../../../features/planner/data/planner_repository.dart';
import '../../../features/flashcards/data/flashcard_repository.dart';
import '../../../core/router/app_router.dart';
import '../../progress/domain/aggregations.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/utils/extensions.dart';

// Motivational quotes (local list, no Remote Config needed)
const List<String> _motivationalQuotes = [
  'The journey of a thousand miles begins with a single step.',
  'Small progress is still progress. Keep going!',
  "Your future self will thank you for studying today.",
  'Consistency beats intensity. One day at a time.',
  'Every expert was once a beginner. Keep learning.',
  "The only bad study session is the one you didn't do.",
  'Knowledge compounds. Invest in yourself daily.',
  'Difficult roads often lead to beautiful destinations.',
  "You don't have to be great to start, but you have to start to be great.",
  'Study while others are sleeping; work while others are loafing.',
];

// Simple seeded random for quote selection (deterministic per day)
String _getDailyQuote(DateTime date) {
  final seed = date.year * 10000 + date.month * 100 + date.day;
  return _motivationalQuotes[seed % _motivationalQuotes.length];
}

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
  final dailyQuote = _getDailyQuote(DateTime.now());

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
    dailyQuote: dailyQuote,
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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.studyHub),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: dashboardAsync.when(
        data: (dashboard) => _buildDashboard(context, ref, dashboard, l10n),
        loading: () => Center(child: Text(l10n.loadingStats)),
        error: (e, st) => _buildErrorState(context, e.toString(), l10n),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref,
      HomeDashboardData dashboard, AppLocalizations l10n) {
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
          _buildDailyGoalRing(context, dashboard, l10n),
          const Gap(24),
          _buildQuickActions(context, l10n),
          const Gap(24),
          _buildContinueStudyingCard(context, dashboard, l10n),
          const Gap(16),
          _buildMotivationalQuoteCard(context, dashboard, l10n),
          const Gap(24),
          _buildTodayTasks(context, dashboard, l10n),
          const Gap(24),
          _buildDueCardsSection(context, dashboard, l10n),
        ],
      ),
    );
  }

  Widget _buildGreetingCard(BuildContext context, HomeDashboardData dashboard) {
    final l10n = AppLocalizations.of(context)!;

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
                ? '🔥 ${dashboard.streak} day ${l10n.streak.toLowerCase()} — keep it going!'
                : 'Start your study ${l10n.streak.toLowerCase()} today!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakXPRow(BuildContext context, HomeDashboardData dashboard) {
    final l10n = AppLocalizations.of(context)!;

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
                  dashboard.streak == 1
                      ? '${dashboard.streak} day ${l10n.streak.toLowerCase()}'
                      : 'Day Streak',
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
                  '${dashboard.xp} ${l10n.xp}',
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

  Widget _buildDailyGoalRing(BuildContext context, HomeDashboardData dashboard,
      AppLocalizations l10n) {
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
                l10n.todaysGoal,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                '${dashboard.todayStudyMinutes} / ${dashboard.dailyGoalMin} ${l10n.min}',
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
                      l10n.xpEarned,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    Text(
                      '+${dashboard.todayXpEarned} ${l10n.xp}',
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
                          l10n.goalAchieved,
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

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    final actions = [
      _QuickAction(
        label: l10n.askAI,
        icon: Icons.chat_rounded,
        route: '/chat',
        color: const Color(0xFF6C5CE7),
      ),
      _QuickAction(
        label: l10n.scanDoubt,
        icon: Icons.camera_alt_rounded,
        route: '/scanner',
        color: const Color(0xFF00D4C8),
      ),
      _QuickAction(
        label: l10n.newNote,
        icon: Icons.note_add_rounded,
        route: '/notes/new',
        color: const Color(0xFF2ED573),
      ),
      _QuickAction(
        label: l10n.quickQuiz,
        icon: Icons.quiz_rounded,
        route: '/quiz',
        color: const Color(0xFFFFB020),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
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

  Widget _buildContinueStudyingCard(BuildContext context,
      HomeDashboardData dashboard, AppLocalizations l10n) {
    // Show continue studying if there are due cards or tasks
    final hasDueCards = dashboard.cardsDueToday > 0;
    final hasTasks = dashboard.todayTasks.isNotEmpty;

    if (!hasDueCards && !hasTasks) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dashboard.cardsDueToday > 0
                    ? l10n.reviewFlashcards
                    : l10n.studyHub,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (hasDueCards)
                TextButton(
                  onPressed: () => context.go(AppRoutes.flashcards),
                  child: Text(l10n.startReview),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
            ],
          ),
          const Gap(12),
          if (hasDueCards)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dashboard.cardsDueToday} cards (${l10n.cardsDueToday.toLowerCase()})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        'Spaced repetition review',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.task_alt_rounded,
                    color: Color(0xFF6C5CE7),
                    size: 24,
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dashboard.todayTasks.length} ${dashboard.todayTasks.length == 1 ? 'task' : 'tasks'} today',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      Text(
                        'From your study plan',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color:
                                  Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMotivationalQuoteCard(BuildContext context,
      HomeDashboardData dashboard, AppLocalizations l10n) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB020).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_quote_rounded,
              color: Color(0xFFFFB020),
              size: 22,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyStats,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const Gap(4),
                Text(
                  '"${dashboard.dailyQuote}"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0);
  }

  Widget _buildTodayTasks(BuildContext context, HomeDashboardData dashboard,
      AppLocalizations l10n) {
    if (dashboard.todayTasks.isEmpty) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.today,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.planner),
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const Gap(8),
            EmptyState(
              icon: Icons.task_alt_rounded,
              title: l10n.noTasksToday,
              message: l10n.createPlanForTasks,
              actionLabel: l10n.createPlan,
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
                dashboard.todayTasks.length == 1
                    ? 'Today\'s Task'
                    : 'Today\'s Tasks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.planner),
                child: Text(l10n.viewAll),
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

  Widget _buildDueCardsSection(BuildContext context,
      HomeDashboardData dashboard, AppLocalizations l10n) {
    if (dashboard.cardsDueToday == 0) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.flashcards,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.flashcards),
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const Gap(8),
            EmptyState(
              icon: Icons.menu_book_rounded,
              title: l10n.allCaughtUp,
              message: l10n.noCardsDueToday,
              actionLabel: l10n.browseDecks,
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
                l10n.flashcards,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.flashcards),
                child: Text(l10n.viewAll),
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
                label: Text(l10n.startReview),
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

  Widget _buildErrorState(
      BuildContext context, String error, AppLocalizations l10n) {
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
              label: Text(l10n.tryAgain),
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
                    decoration:
                        task.done ? TextDecoration.lineThrough : null,
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