// Progress screen - XP, streak, badges, charts

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';

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

// User progress state
class UserProgressState {
  final int xp;
  final int level;
  final int streak;
  final int dailyGoalMinutes;
  final int todayMinutes;
  final double xpProgress;

  UserProgressState({
    required this.xp,
    required this.level,
    required this.streak,
    required this.dailyGoalMinutes,
    required this.todayMinutes,
    required this.xpProgress,
  });

  UserProgressState copyWith({
    int? xp,
    int? level,
    int? streak,
    int? dailyGoalMinutes,
    int? todayMinutes,
    double? xpProgress,
  }) {
    return UserProgressState(
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      todayMinutes: todayMinutes ?? this.todayMinutes,
      xpProgress: xpProgress ?? this.xpProgress,
    );
  }
}

class UserProgressNotifier extends StateNotifier<UserProgressState> {
  UserProgressNotifier()
      : super(UserProgressState(
          xp: 0,
          level: 1,
          streak: 0,
          dailyGoalMinutes: AppConstants.defaultDailyGoal,
          todayMinutes: 0,
          xpProgress: 0.0,
        ));

  void addXP(int amount) {
    var newXp = state.xp + amount;
    var newLevel = state.level;
    var levelXpRequired = AppConstants.xpPerLevelBase;

    // Check for level up
    while (newXp >= levelXpRequired) {
      newXp -= levelXpRequired;
      newLevel++;
      levelXpRequired =
          (levelXpRequired * AppConstants.xpLevelMultiplier).round();
    }

    state = state.copyWith(
      xp: newXp,
      level: newLevel,
      xpProgress: newXp / levelXpRequired,
    );
  }

  void addStudyMinutes(int minutes) {
    state = state.copyWith(todayMinutes: state.todayMinutes + minutes);
  }

  void updateStreak(int streak) {
    state = state.copyWith(streak: streak);
  }

  void setDailyGoal(int minutes) {
    state = state.copyWith(dailyGoalMinutes: minutes);
  }
}

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgressState>((ref) {
  return UserProgressNotifier();
});

// Weekly stats for charts
final weeklyStatsProvider = Provider<List<DailyStat>>((ref) {
  // Demo data - in production, fetch from Firestore
  return List.generate(7, (index) {
    final date = DateTime.now().subtract(Duration(days: 6 - index));
    return DailyStat(
      date: DateTime(date.year, date.month, date.day),
      studyMinutes: 25 + (index * 8),
      quizScore: 75 + (index * 3),
    );
  });
});

class DailyStat {
  final DateTime date;
  final int studyMinutes;
  final int quizScore;

  DailyStat({
    required this.date,
    required this.studyMinutes,
    required this.quizScore,
  });
}

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);
    final weeklyStats = ref.watch(weeklyStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GlassCard(
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
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          Text(
                            'to next level',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          GlassCard(
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
                      value: '${progress.todayMinutes} min',
                      icon: Icons.timer,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
                const Gap(16),
                Text(
                  'Goal: ${progress.dailyGoalMinutes} min/day',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Gap(24),
          const SectionHeader(title: 'Weekly Stats'),
          const Gap(16),
          GlassCard(
            child: SizedBox(
              height: 200,
              child: LineChart(
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
                        for (int i = 0; i < weeklyStats.length; i++)
                          FlSpot(i.toDouble(),
                              weeklyStats[i].studyMinutes.toDouble()),
                      ],
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Gap(16),
          GlassCard(
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
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(show: false),
                      gridData: FlGridData(show: false),
                      barGroups: [
                        for (int i = 0; i < weeklyStats.length ~/ 2; i++)
                          BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: weeklyStats[i * 2].quizScore / 100 * 30,
                                width: 8,
                                color: const Color(0xFF00D4C8),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(24),
          const SectionHeader(title: 'Badges'),
          const Gap(16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 1),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(8),
                child: Chip(
                  label: Text('Badge ${index + 1}'),
                  backgroundColor: Colors.amber.withValues(alpha: 0.2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
