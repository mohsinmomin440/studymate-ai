// Study tab routes - hub screen with quick access cards

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/gap.dart';
import '../../shared/widgets/glass_card.dart';
import '../../core/router/app_router.dart';

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
