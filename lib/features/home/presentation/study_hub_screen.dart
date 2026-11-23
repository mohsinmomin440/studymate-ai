import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/gap.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Study hub screen (placeholder for future Study feature)
class StudyHubScreen extends StatelessWidget {
  const StudyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.studyHub),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.menu_book_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
              const Gap(24),
              Text(
                l10n.studyHub,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Text(
                l10n.toolsDesc,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(32),
              FilledButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(l10n.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
