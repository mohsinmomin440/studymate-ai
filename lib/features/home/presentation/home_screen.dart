// Home screen - Dashboard with greeting, streak, XP, and quick actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/progress_utils.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/streak_badge.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../features/progress/data/progress_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<UserProgressData>(
      stream: ref.read(progressRepositoryProvider).getUserProgressStream(),
      builder: (context, snapshot) {
        final progress = snapshot.data ?? UserProgressData.empty();
        final hour = DateTime.now().hour;
        final greeting = _getGreeting(hour);

        return Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(16),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildHeaderCard(context, progress, greeting),
              const Gap(16),
              _buildQuickStatsCard(context, progress),
              const Gap(16),
              _buildContinueStudyingCard(context),
              const Gap(16),
              _buildQuickActions(context),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildHeaderCard(
      BuildContext context, UserProgressData progress, String greeting) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, ${progress.name.isEmpty ? 'Student' : progress.name}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Text(
            _getMotivationalQuote(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(16),
          Row(
            children: [
              StreakBadge(streak: progress.streak),
              const Gap(16),
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ProgressRing(
                        progress: calculateXpProgress(progress.xp),
                        size: 60,
                        strokeWidth: 6,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Level ${progress.level}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${progress.xp} XP',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMotivationalQuote() {
    final quotes = [
      "The expert in anything was once a beginner.",
      "Success is the sum of small efforts repeated day in and day out.",
      "Learning never exhausts the mind.",
      "Your only limit is you.",
      "Start where you are. Use what you have. Do what you can.",
    ];
    // Use a simple day-based index
    final dayIndex = DateTime.now().day % 5;
    return quotes[dayIndex];
  }

  Widget _buildQuickStatsCard(BuildContext context, UserProgressData progress) {
    final theme = Theme.of(context);

    return GlassCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatTile(
                context: context,
                label: 'Cards Due',
                value: '${progress.cardsDueToday}',
                icon: Icons.flash_on,
                color: const Color(0xFF00D4C8),
              ),
              const Gap(16),
              _buildStatTile(
                context: context,
                label: 'Today',
                value: '60 min',
                icon: Icons.timer,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          const Gap(16),
          Text(
            'Daily Goal: ${progress.dailyGoalMin} min',
            style: theme.textTheme.bodyMedium,
          ),
          const Gap(8),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSubjectCircle(context, 'Math', 0.85),
                const Gap(12),
                _buildSubjectCircle(context, 'Science', 0.75),
                const Gap(12),
                _buildSubjectCircle(context, 'English', 0.65),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return StatTile(
      label: label,
      value: value,
      icon: icon,
      iconGradient:
          LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
    );
  }

  Widget _buildSubjectCircle(
      BuildContext context, String subject, double prog) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 80,
      width: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: prog,
            strokeWidth: 4,
            backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconForSubject(subject),
                  size: 16, color: theme.primaryColor),
              const Gap(4),
              Text(subject.split(' ').first,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  IconData iconForSubject(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'maths':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'english':
        return Icons.book;
      case 'hindi':
        return Icons.translate;
      case 'gujarati':
        return Icons.language;
      default:
        return Icons.book;
    }
  }

  Widget _buildContinueStudyingCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Continue Studying'),
          const Gap(16),
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF8E7BFF)],
                ),
              ),
              child: const Icon(Icons.flash_on, size: 24, color: Colors.white),
            ),
            title: const Text('Review Flashcards',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('5 cards due today, 2 new to learn'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to flashcards
            },
          ),
          const Gap(12),
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4C8), Color(0xFF00BFA5)],
                ),
              ),
              child: const Icon(Icons.question_answer,
                  size: 24, color: Colors.white),
            ),
            title: const Text('AI Chat',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Ask a question or get help with doubts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to chat
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.chat,
        'label': 'Ask AI',
        'onTap': () {
          // Navigate to chat
        },
      },
      {
        'icon': Icons.camera_alt,
        'label': 'Scan Doubt',
        'onTap': () {
          // Navigate to scanner
        },
      },
      {
        'icon': Icons.note_add,
        'label': 'New Note',
        'onTap': () {
          // Navigate to notes
        },
      },
      {
        'icon': Icons.quiz,
        'label': 'Quick Quiz',
        'onTap': () {
          // Navigate to quiz
        },
      },
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: actions.map<Widget>((action) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 32) / 2 - 6,
          child: GlassCard(
            onTap: action['onTap'] as VoidCallback,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C5CE7), Color(0xFF8E7BFF)],
                    ),
                  ),
                  child: Icon(action['icon'] as IconData,
                      size: 28, color: Colors.white),
                ),
                const Gap(12),
                Text(
                  action['label'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
