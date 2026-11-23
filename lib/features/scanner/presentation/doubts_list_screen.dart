// Doubts List Screen - View and manage solved doubts from scanner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/gap.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_box.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/extensions.dart';
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
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.doubtsTitle),
        actions: [
          Semantics(
            label: l10n.clearAllTooltip,
            child: IconButton(
              icon: const Icon(Icons.cleaning_services_rounded),
              tooltip: l10n.clearAllTooltip,
              onPressed: () {
                // Show confirmation dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(l10n.clearAllDoubtsDialogTitle),
                    content: Text(l10n.clearAllDoubtsDialogContent),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancelButton),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implement clear all doubts
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: Text(l10n.clearButton),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Semantics(
            label: l10n.addDoubtTooltip,
            child: IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: l10n.addDoubtTooltip,
              onPressed: () {
                context.go(AppRoutes.scanner);
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
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
                    title: l10n.noDoubtsSavedTitle,
                    message: l10n.scanProblemMessage,
                    actionLabel: l10n.goToScannerAction,
                    onAction: () {
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
                          '${l10n.doubtsTitle} ${doubt.subject}, ${_formatDate(doubt.createdAt)}',
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
                itemBuilder: (context, index) => ShimmerBox(
                  height: 120,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              error: (error, stack) => ErrorState(
                title: l10n.errorLoadingDoubtsTitle,
                message: error.toString(),
                onRetry: () => ref.invalidate(doubtsStreamProvider),
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
      return 'Yesterday'; // This should also be localized if needed
    } else if (difference.inDays < 7) {
      // This week
      return '${difference.inDays}d ago';
    } else {
      // Older
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
