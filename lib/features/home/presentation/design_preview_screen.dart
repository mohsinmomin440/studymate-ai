import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/streak_badge.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/app_chip.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/app_bottom_sheet.dart';
import '../../../shared/widgets/ai_message_bubble.dart';
import '../../../shared/widgets/typing_indicator.dart';

/// Design preview screen - shows all reusable components
class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System Preview'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Buttons',
            children: [
              const Gap(16),
              GradientButton(
                onPressed: () {},
                child: const Text('Gradient Button'),
              ),
              const Gap(12),
              OutlinedButton(
                onPressed: () {},
                child: const Text('Outlined Button'),
              ),
              const Gap(12),
              TextButton(
                onPressed: () {},
                child: const Text('Text Button'),
              ),
            ],
          ),
          const Gap(24),
          _SectionCard(
            title: 'Cards',
            children: [
              const Gap(16),
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Glass Card',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
              const Gap(12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Standard Card',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
          const Gap(24),
          _SectionCard(
            title: 'Chips & Badges',
            children: [
              const Gap(16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppChip(
                    label: 'Filter Chip',
                    onTap: () {},
                  ),
                  AppChip(
                    label: 'Selected Chip',
                    selected: true,
                    onTap: () {},
                  ),
                  AppChip(
                    label: 'Action Chip',
                    onTap: () {},
                    icon: Icons.add_rounded,
                  ),
                  const StreakBadge(streak: 7),
                  const StreakBadge(streak: 30),
                  const StreakBadge(streak: 100),
                ],
              ),
            ],
          ),
          const Gap(24),
          _SectionCard(
            title: 'Stats & Progress',
            children: [
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: ProgressRing(
                      progress: 0.65,
                      size: 80,
                      strokeWidth: 8,
                      child: Text(
                        '65%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ProgressRing(
                      progress: 0.3,
                      size: 80,
                      strokeWidth: 8,
                      child: Text(
                        '30%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Gap(24),
          _SectionCard(
            title: 'Section Headers',
            children: [
              const Gap(16),
              SectionHeader(
                title: "Today's Tasks",
                actionLabel: 'View All',
                onActionTap: () {},
              ),
              const Gap(8),
              SectionHeader(
                title: 'Flashcards Due',
                subtitle: '12 cards to review',
              ),
              const Gap(8),
              SectionHeader(title: 'Quick Actions'),
            ],
          ),
          const Gap(24),
          _SectionCard(
            title: 'Loading States',
            children: [
              const Gap(16),
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 20)),
                  const Gap(12),
                  Expanded(child: ShimmerBox(height: 20)),
                ],
              ),
              const Gap(12),
              ShimmerBox(height: 100, borderRadius: BorderRadius.circular(16)),
              const Gap(12),
              Column(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ShimmerBox(
                      height: 60,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Gap(24),
          _SectionCard(
            title: 'Empty & Error States',
            children: [
              const Gap(16),
              EmptyState(
                icon: Icons.folder_open_rounded,
                title: 'No Notes Yet',
                message: 'Create your first note to get started',
                actionLabel: 'Create Note',
                onAction: () {},
              ),
              const Gap(16),
              EmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Error',
                message: 'Failed to load data',
                actionLabel: 'Try Again',
                onAction: () {},
              ),
            ],
          ),
          const Gap(24),
          _SectionCard(
            title: 'Bottom Sheet',
            children: [
              const Gap(16),
              FilledButton(
                onPressed: () => AppBottomSheet.show(
                  context: context,
                  title: 'Bottom Sheet',
                  builder: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_rounded),
                        title: const Text('Edit'),
                        onTap: () => context.pop(),
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_rounded),
                        title: const Text('Delete'),
                        onTap: () => context.pop(),
                      ),
                    ],
                  ),
                ),
                child: const Text('Show Bottom Sheet'),
              ),
            ],
          ),
          const Gap(24),
          _SectionCard(
            title: 'AI Chat Components',
            children: [
              const Gap(16),
              AiMessageBubble(
                text: "Hello! I'm your AI study tutor. How can I help you today?",
                isUser: false,
                onCopy: () {},
                onSaveToNotes: () {},
                onRegenerate: () {},
              ),
              const Gap(12),
              AiMessageBubble(
                text: 'Can you explain photosynthesis?',
                isUser: true,
                onCopy: () {},
                onSaveToNotes: () {},
                onRegenerate: () {},
              ),
              const Gap(12),
              const TypingIndicator(),
            ],
          ),
          const Gap(24),
          _SectionCard(
            title: 'Form Fields',
            children: [
              const Gap(16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Standard Text Field',
                  prefixIcon: Icon(Icons.text_fields_rounded),
                ),
              ),
              const Gap(12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'With Helper Text',
                  helperText: 'This is helper text',
                  prefixIcon: Icon(Icons.help_outline_rounded),
                ),
              ),
              const Gap(12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'With Error',
                  errorText: 'This field is required',
                  prefixIcon: Icon(Icons.error_outline_rounded),
                ),
              ),
            ],
          ),
          const Gap(32),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}