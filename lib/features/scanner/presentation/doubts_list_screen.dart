// Doubts List Screen - View and manage solved doubts from scanner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../../../core/router/app_router.dart';
import '../data/scanner_repository.dart';

final doubtsStreamProvider =
    StreamProvider.autoDispose<List<DoubtModel>>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  return repository.getDoubts();
});

class DoubtsListScreen extends ConsumerWidget {
  const DoubtsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doubts'),
        actions: [
          Semantics(
            label: 'Clear all doubts',
            child: IconButton(
              icon: const Icon(Icons.cleaning_services_rounded),
              tooltip: 'Clear All',
              onPressed: () {
                HapticFeedback.lightImpact();
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Doubts?'),
                    content: const Text(
                        'This will delete all saved doubts. Are you sure?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          HapticFeedback.mediumImpact();
                          // TODO: Implement clear all doubts
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Semantics(
            label: 'Add doubt',
            child: IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add Doubt',
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go(AppRoutes.scanner);
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(doubtsStreamProvider);
        },
        child: Consumer(
          builder: (context, ref, _) {
            final doubtsAsync = ref.watch(doubtsStreamProvider);

            return doubtsAsync.when(
              data: (doubts) {
                if (doubts.isEmpty) {
                  return EmptyState(
                    icon: Icons.help_outline_rounded,
                    title: 'No doubts saved yet',
                    message: 'Scan a problem with the scanner to save doubts',
                    actionLabel: 'Go to Scanner',
                    onAction: () {
                      HapticFeedback.lightImpact();
                      context.go(AppRoutes.scanner);
                    },
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doubts.length,
                  itemBuilder: (context, index) {
                    final doubt = doubts[index];
                    return Semantics(
                      label:
                          'Doubt from ${doubt.subject}, saved at ${_formatDate(doubt.createdAt)}',
                      child: GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        onTap: () {
                          // Navigate to view doubt details (future feature)
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  doubt.subject,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  _formatDate(doubt.createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            Text(
                              doubt.question.length > 100
                                  ? '${doubt.question.substring(0, 100)}...'
                                  : doubt.question,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap(8),
                            Text(
                              doubt.answer.length > 150
                                  ? '${doubt.answer.substring(0, 150)}...'
                                  : doubt.answer,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0);
                  },
                );
              },
              loading: () => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 6,
                itemBuilder: (context, index) => ShimmerCard(
                  height: 120,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              error: (error, stack) => ErrorState(
                title: 'Error Loading Doubts',
                message: error.toString(),
                onRetry: () {
                  HapticFeedback.lightImpact();
                  ref.invalidate(doubtsStreamProvider);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Today
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Yesterday
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      // This week
      return '${difference.inDays}d ago';
    } else {
      // Older
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
