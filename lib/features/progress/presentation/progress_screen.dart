// Progress screen - XP, streak, badges, charts

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../features/progress/data/progress_repository.dart';

class _ColoredStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ColoredStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return StatTile(
      label: label,
      value: value,
      icon: icon,
      iconGradient:
          LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
    );
  }
}

final weeklyStatsProvider = FutureProvider<List<WeeklyStat>>((ref) async {
  return ref.read(progressRepositoryProvider).getWeeklyStats();
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyStatsAsync = ref.watch(weeklyStatsProvider);

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
              _buildStatsRow(context, progress),
              const Gap(24),
              const SectionHeader(title: 'Weekly Stats'),
              const Gap(16),
              _buildWeeklyChart(weeklyStatsAsync, context),
              const Gap(16),
              _buildQuizScoresCard(weeklyStatsAsync, context),
              const Gap(24),
              const SectionHeader(title: 'Badges'),
              const Gap(16),
              _buildBadgesSection(progress),
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

  Widget _buildStatsRow(BuildContext context, UserProgressData progress) {
    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ColoredStatTile(
                label: 'Streak',
                value: '${progress.streak}',
                icon: Icons.local_fire_department_rounded,
                color: const Color(0xFFFFB020),
              ),
              const Gap(16),
              _ColoredStatTile(
                label: 'Today',
                value: '${progress.dailyGoalMin} min',
                icon: Icons.timer,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
          const Gap(16),
          Text(
            'Ready for review: ${progress.cardsDueToday} cards',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(
      AsyncValue<List<WeeklyStat>> weeklyStatsAsync, BuildContext context) {
    return GlassCard(
      child: SizedBox(
        height: 200,
        child: weeklyStatsAsync.when(
          data: (stats) => LineChart(
            LineChartData(
              gridData: FlGridData(show: false),
              titlesData: const FlTitlesData(
                show: false,
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: 60,
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (int i = 0; i < stats.length; i++)
                      FlSpot(i.toDouble(), stats[i].studyMinutes.toDouble()),
                  ],
                  isCurved: true,
                  color: const Color(0xFF6C5CE7),
                  barWidth: 3,
                  dotData: FlDotData(show: false),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildQuizScoresCard(
      AsyncValue<List<WeeklyStat>> weeklyStatsAsync, BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Scores',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Gap(8),
          SizedBox(
            height: 150,
            child: weeklyStatsAsync.when(
              data: (stats) => BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: [
                    for (int i = 0; i < stats.length ~/ 2; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: stats[i * 2].quizScore / 100 * 30,
                            width: 8,
                            color: const Color(0xFF00D4C8),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(UserProgressData progress) {
    if (progress.badgesCount == 0) {
      return const Center(
        child: Text('No badges yet. Start studying and earn badges!'),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 1),
      itemCount: progress.badgesCount,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(8),
          child: Chip(
            label: Text('Badge ${index + 1}'),
            backgroundColor: Colors.amber.withValues(alpha: 0.2),
            avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
          ),
        );
      },
    );
  }
}
