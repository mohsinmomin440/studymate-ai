// Progress screen - XP, streak, badges, charts (real data from Firestore)

import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
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

// Quiz score trend data
class QuizScoreTrend {
  final List<QuizScorePoint> points;
  final double averageScore;

  QuizScoreTrend({
    required this.points,
    required this.averageScore,
  });

  factory QuizScoreTrend.empty() {
    return QuizScoreTrend(points: [], averageScore: 0.0);
  }
}

class QuizScorePoint {
  final DateTime date;
  final double percentage;
  final String label; // e.g., "Mon", "Tue"

  QuizScorePoint({
    required this.date,
    required this.percentage,
    required this.label,
  });
}

final quizScoreTrendProvider = FutureProvider<QuizScoreTrend>((ref) async {
  final repo = ref.read(progressRepositoryProvider);
  final attempts = await repo.getQuizAttempts();

  if (attempts.isEmpty) return QuizScoreTrend.empty();

  // Group attempts by day (last 7 days)
  final now = DateTime.now();
  final Map<DateTime, List<QuizAttempt>> attemptsByDay = {};

  for (int i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day - i);
    attemptsByDay[date] = [];
  }

  for (final attempt in attempts) {
    final attemptDate = DateTime(
      attempt.createdAt.year,
      attempt.createdAt.month,
      attempt.createdAt.day,
    );
    if (attemptsByDay.containsKey(attemptDate)) {
      attemptsByDay[attemptDate]!.add(attempt);
    }
  }

  final points = <QuizScorePoint>[];
  double totalPercentage = 0;
  int daysWithData = 0;

  for (int i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day - i);
    final dayAttempts = attemptsByDay[date] ?? [];

    double percentage = 0;
    if (dayAttempts.isNotEmpty) {
      int totalScore = 0;
      int totalQuestions = 0;
      for (final a in dayAttempts) {
        totalScore += a.score;
        totalQuestions += a.total;
      }
      percentage = totalQuestions > 0 ? (totalScore / totalQuestions) * 100 : 0;
      totalPercentage += percentage;
      daysWithData++;
    }

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    points.add(QuizScorePoint(
      date: date,
      percentage: percentage,
      label: weekdays[date.weekday - 1],
    ));
  }

  return QuizScoreTrend(
    points: points,
    averageScore: daysWithData > 0 ? totalPercentage / daysWithData : 0.0,
  );
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);
    final subjectStrengthAsync = ref.watch(subjectStrengthProvider);
    final weeklySummaryAsync = ref.watch(weeklySummaryProvider);
    final unlockedBadgesAsync = ref.watch(unlockedBadgesProvider);

    final quizScoreTrendAsync = ref.watch(quizScoreTrendProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(weeklyStatsProvider);
          ref.invalidate(subjectStrengthProvider);
          ref.invalidate(weeklySummaryProvider);
          ref.invalidate(unlockedBadgesProvider);
          ref.invalidate(quizScoreTrendProvider);
        },
        child: StreamBuilder<UserProgressData>(
          stream: ref.read(progressRepositoryProvider).getUserProgressStream(),
          builder: (context, snapshot) {
            final progress = snapshot.data ?? UserProgressData.empty();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeaderCard(context, progress),
                const Gap(16),
                _buildWeeklySummary(
                    context, weeklySummaryAsync, progress.streak, ref),
                const Gap(16),
                _buildSubjectStrength(context, subjectStrengthAsync, ref),
                const Gap(24),
                _buildWeeklyStatsSection(context, weeklyStatsAsync),
                const Gap(24),
                _buildQuizScoreTrend(context, quizScoreTrendAsync, ref),
                const Gap(24),
                _buildBadgesSection(
                    context, unlockedBadgesAsync, progress.badgesCount, ref),
              ],
            );
          },
        ),
      ),
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
      AsyncValue<WeeklySummary> weeklySummaryAsync, int streak, WidgetRef ref) {
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
              icon: Icons.local_fire_department_rounded,
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
      error: (e, st) => ErrorState(
        title: 'Error Loading Weekly Summary',
        message: e.toString(),
        onRetry: () {
          HapticFeedback.lightImpact();
          ref.invalidate(weeklySummaryProvider);
        },
      ),
    );
  }

  Widget _buildSubjectStrength(BuildContext context,
      AsyncValue<List<SubjectStrength>> async, WidgetRef ref) {
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
              return Semantics(
                label: 'Subject strengths for ${strengths.length} subjects',
                child: Column(
                  children: strengths.take(5).map((s) {
                    return Semantics(
                      label:
                          '${s.subject}: ${(s.accuracy * 100).round()}% accuracy',
                      child: Padding(
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
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
                      ),
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => SizedBox(
                height: 120, child: Center(child: CircularProgressIndicator())),
            error: (e, st) => ErrorState(
              title: 'Error Loading Subject Strength',
              message: e.toString(),
              onRetry: () {
                HapticFeedback.lightImpact();
                ref.invalidate(subjectStrengthProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatsSection(
      BuildContext context, AsyncValue<AggregatedWeeklyStats> weeklyStatsAsync,
      [WidgetRef? ref]) {
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
            return Semantics(
              label:
                  'Weekly study stats: ${stats.totalStudyMinutes} minutes, average ${stats.dailyStats.map((s) => s.studyMinutes).reduce((a, b) => a + b) / stats.dailyStats.length.round()} minutes per day',
              child: Column(
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
                                for (int i = 0;
                                    i < stats.dailyStats.length;
                                    i++)
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
              ),
            );
          },
          loading: () => GlassCard(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, st) => ErrorState(
            title: 'Error Loading Weekly Stats',
            message: e.toString(),
            onRetry: ref != null
                ? () {
                    HapticFeedback.lightImpact();
                    ref.invalidate(weeklyStatsProvider);
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizScoreTrend(BuildContext context,
      AsyncValue<QuizScoreTrend> quizScoreTrendAsync, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Quiz Score Trend'),
        const Gap(16),
        quizScoreTrendAsync.when(
          data: (trend) {
            if (trend.points.isEmpty ||
                trend.points.every((p) => p.percentage == 0)) {
              return EmptyState(
                icon: Icons.show_chart_rounded,
                title: 'No quiz scores yet',
                message: 'Complete quizzes to see your weekly score trend',
              );
            }
            return Semantics(
              label:
                  'Quiz score trend: average ${trend.averageScore.round()}% across ${trend.points.length} days',
              child: Column(
                children: [
                  GlassCard(
                    child: SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index < 0 ||
                                      index >= trend.points.length) {
                                    return const Text('');
                                  }
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      trend.points[index].label,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                interval: 25,
                                getTitlesWidget: (value, meta) {
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                      '${value.toInt()}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: trend.points.length.toDouble() - 1,
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                              spots: [
                                for (int i = 0; i < trend.points.length; i++)
                                  FlSpot(
                                      i.toDouble(), trend.points[i].percentage),
                              ],
                              isCurved: true,
                              color: const Color(0xFF2ED573),
                              barWidth: 4,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFF2ED573)
                                    .withValues(alpha: 0.1),
                              ),
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
                        label: 'Avg: ${trend.averageScore.round()}%',
                        color: const Color(0xFF2ED573),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => GlassCard(
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, st) => ErrorState(
            title: 'Error Loading Quiz Score Trend',
            message: e.toString(),
            onRetry: () {
              HapticFeedback.lightImpact();
              ref.invalidate(quizScoreTrendProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(
      BuildContext context,
      AsyncValue<List<badge_domain.Badge>> unlockedBadgesAsync,
      int badgeCount,
      WidgetRef ref) {
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

            return Semantics(
              label: '${unlockedBadges.length} badges unlocked',
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                ),
                itemCount: unlockedBadges.length,
                itemBuilder: (context, index) {
                  final badge = unlockedBadges[index];
                  return Semantics(
                    label: '${badge.title}: ${badge.description}',
                    child: _BadgeCard(badge: badge),
                  );
                },
              ),
            );
          },
          loading: () => SizedBox(
              height: 200, child: Center(child: CircularProgressIndicator())),
          error: (e, st) => ErrorState(
            title: 'Error Loading Badges',
            message: e.toString(),
            onRetry: () {
              HapticFeedback.lightImpact();
              ref.invalidate(unlockedBadgesProvider);
            },
          ),
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
