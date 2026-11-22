// Progress screen - XP, streak, badges, charts (real data from Firestore)

import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../features/progress/data/progress_repository.dart';
import '../../../features/progress/domain/badges.dart' as badge_domain;
import '../../../features/progress/domain/aggregations.dart';

final weeklyStatsProvider = FutureProvider<AggregatedWeeklyStats>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final rawStats = await repo.getWeeklyStats();
  return aggregateWeeklyStats(rawStats);
});

final subjectStrengthProvider =
    FutureProvider<List<SubjectStrength>>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final attempts = await repo.getQuizAttempts();
  return calculateSubjectStrength(attempts);
});

final weeklySummaryProvider = FutureProvider<WeeklySummary>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final rawStats = await repo.getWeeklyStats();
  final streak = await repo.getCurrentStreak();
  return calculateWeeklySummary(rawStats, streak);
});

final unlockedBadgesProvider =
    FutureProvider<List<badge_domain.Badge>>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final unlockedIds = await repo.getUnlockedBadgeIds();
  return badge_domain.allBadges
      .where((b) => unlockedIds.contains(b.id))
      .toList();
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);
    final subjectStrengthAsync = ref.watch(subjectStrengthProvider);
    final weeklySummaryAsync = ref.watch(weeklySummaryProvider);
    final unlockedBadgesAsync = ref.watch(unlockedBadgesProvider);

    return StreamBuilder<UserProgressData>(
      stream: ref.read(progressRepositoryProvider).getUserProgressStream(),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? UserProgressData.empty();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Progress'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeaderCard(context, progress),
              const Gap(16),
              _buildWeeklySummary(context, weeklySummaryAsync, progress.streak),
              const Gap(16),
              _buildSubjectStrength(context, subjectStrengthAsync),
              const Gap(24),
              _buildWeeklyStatsSection(context, weeklyStatsAsync),
              const Gap(24),
              _buildBadgesSection(
                  context, unlockedBadgesAsync, progress.badgesCount),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context, UserProgressData progress) {
    return GlassCard(
      child: Column(
        children: [
          Text(
            'Level ${progress.level}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Gap(8),
          Text(
            '${progress.xp} XP',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(16),
          SizedBox(
            height: 120,
            width: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress.xpProgress,
                  strokeWidth: 6,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(progress.xpProgress * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'to next level',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(BuildContext context,
      AsyncValue<WeeklySummary> weeklySummaryAsync, int streak) {
    return weeklySummaryAsync.when(
      data: (summary) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  label: 'Study Days',
                  value: '${summary.studyDays}',
                  icon: Icons.calendar_today_rounded,
                  color: const Color(0xFF6C5CE7),
                ),
                _SummaryItem(
                  label: 'Minutes',
                  value: '${summary.totalMinutes} min',
                  icon: Icons.timer_rounded,
                  color: const Color(0xFF00D4C8),
                ),
                _SummaryItem(
                  label: 'Quizzes',
                  value: '${summary.quizzesTaken}',
                  icon: Icons.quiz_rounded,
                  color: const Color(0xFF2ED573),
                ),
              ],
            ),
            const Gap(16),
            _SummaryItem(
              label: summary.message,
              value: 'Streak: $streak days',
              icon: streak >= 7
                  ? Icons.local_fire_department_rounded
                  : Icons.local_fire_department_rounded,
              color: streak >= 7
                  ? const Color(0xFFFFB020)
                  : const Color(0xFFA3A9C7),
            ),
          ],
        ),
      ),
      loading: () => GlassCard(
        child: SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildSubjectStrength(
      BuildContext context, AsyncValue<List<SubjectStrength>> async) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Strength',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Gap(16),
          async.when(
            data: (strengths) {
              if (strengths.isEmpty) {
                return EmptyState(
                  icon: Icons.menu_book_rounded,
                  title: 'No quiz data yet',
                  message: 'Take some quizzes to see your subject strengths',
                );
              }
              return Column(
                children: strengths.take(5).map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(Icons.book_rounded,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary),
                        const Gap(12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.subject,
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              Text(
                                  '${(s.accuracy * 100).round()}% average accuracy',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => SizedBox(
                height: 120, child: Center(child: CircularProgressIndicator())),
            error: (e, st) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatsSection(BuildContext context,
      AsyncValue<AggregatedWeeklyStats> weeklyStatsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Weekly Stats'),
        const Gap(16),
        weeklyStatsAsync.when(
          data: (stats) {
            if (stats.totalStudyMinutes == 0) {
              return EmptyState(
                icon: Icons.show_chart_rounded,
                title: 'No stats yet',
                message: 'Start studying today to build your weekly stats',
              );
            }
            return Column(
              children: [
                GlassCard(
                  child: SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: stats.dailyStats.length.toDouble() - 1,
                        minY: 0,
                        maxY: stats.dailyStats.length > 0
                            ? stats.dailyStats
                                    .map((s) => s.studyMinutes)
                                    .reduce((a, b) => a > b ? a : b) +
                                10
                            : 60,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (int i = 0; i < stats.dailyStats.length; i++)
                                FlSpot(
                                    i.toDouble(),
                                    stats.dailyStats[i].studyMinutes
                                        .toDouble()),
                            ],
                            isCurved: true,
                            color: const Color(0xFF6C5CE7),
                            barWidth: 4,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Gap(12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ColorLegendDot(
                      label: 'Study Minutes',
                      color: const Color(0xFF6C5CE7),
                    ),
                    const Gap(24),
                    _ColorLegendDot(
                      label: 'XP Earned',
                      color: const Color(0xFF00D4C8),
                    ),
                  ],
                ),
              ],
            );
          },
          loading: () => GlassCard(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(
      BuildContext context,
      AsyncValue<List<badge_domain.Badge>> unlockedBadgesAsync,
      int badgeCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Badges ($badgeCount unlocked)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const Gap(16),
        unlockedBadgesAsync.when(
          data: (unlockedBadges) {
            if (unlockedBadges.isEmpty) {
              return EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'No badges yet',
                message: 'Complete activities to earn badges',
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
              ),
              itemCount: unlockedBadges.length,
              itemBuilder: (context, index) {
                final badge = unlockedBadges[index];
                return _BadgeCard(badge: badge);
              },
            );
          },
          loading: () => SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator())),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const Gap(4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      ],
    );
  }
}

class _ColorLegendDot extends StatelessWidget {
  final String label;
  final Color color;

  const _ColorLegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const Gap(8),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final badge_domain.Badge badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 32,
            color: Colors.amber.shade700,
          ),
          const Gap(4),
          Text(badge.title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const Gap(2),
          Text(badge.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
