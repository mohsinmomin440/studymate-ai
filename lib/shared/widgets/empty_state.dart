import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'gap.dart';
import 'gradient_button.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Empty state with illustration and action
class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final String? lottieAsset;
  final String? svgAsset;
  final IconData? icon;
  final Color? iconColor;
  final double iconSize;
  final Widget? action;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.lottieAsset,
    this.svgAsset,
    this.icon,
    this.iconColor,
    this.iconSize = 80,
    this.action,
    this.actionLabel,
    this.onAction,
    this.padding,
    this.mainAxisAlignment = MainAxisAlignment.center,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (svgAsset != null)
            SvgPicture.asset(
              svgAsset!,
              width: iconSize,
              height: iconSize,
            )
          else if (lottieAsset != null)
            Lottie.asset(
              lottieAsset!,
              width: iconSize * 2,
              height: iconSize * 2,
              fit: BoxFit.contain,
            )
          else if (icon != null)
            Container(
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: iconSize * 0.5,
                color: iconColor ?? theme.colorScheme.primary,
              ),
            )
          else
            const SizedBox.shrink(),
          const Gap(24),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null || (actionLabel != null && onAction != null)) ...[
            const Gap(24),
            SizedBox(
              width: 280,
              child: action ??
                  GradientButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
  }
}

/// Empty state for lists
class EmptyListState extends StatelessWidget {
  final String title;
  final String message;
  final String? lottieAsset;
  final String? svgAsset;
  final IconData? icon;
  final Widget? action;

  const EmptyListState({
    super.key,
    required this.title,
    required this.message,
    this.lottieAsset,
    this.svgAsset,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: title,
      message: message,
      lottieAsset: lottieAsset,
      icon: icon,
      action: action,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: const EdgeInsets.all(48),
    );
  }
}

/// Error state with retry
class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final String? lottieAsset;
  final String? svgAsset;
  final IconData? icon;

  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.lottieAsset,
    this.svgAsset,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return EmptyState(
      title: title,
      message: message,
      lottieAsset: lottieAsset ?? 'assets/lottie/error.json',
      icon: icon ?? Icons.error_outline_rounded,
      iconColor: theme.colorScheme.error,
      actionLabel: l10n.tryAgain,
      onAction: onRetry,
      padding: const EdgeInsets.all(48),
    );
  }
}

/// No internet state
class NoInternetState extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetState({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ErrorState(
      title: l10n.noInternet,
      message: l10n.noInternetMessage,
      onRetry: onRetry,
      lottieAsset: 'assets/lottie/no_internet.json',
      icon: Icons.wifi_off_rounded,
    );
  }
}

/// No data state (for search/filter results)
class NoDataState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const NoDataState({
    super.key,
    this.title = 'No Results Found',
    this.message = 'Try adjusting your search or filters.',
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return EmptyState(
      title: title,
      message: message,
      icon: icon ?? Icons.search_off_rounded,
      iconColor: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      actionLabel: actionLabel,
      onAction: onAction,
      padding: const EdgeInsets.all(48),
    );
  }
}
