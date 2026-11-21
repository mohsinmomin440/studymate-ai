import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'gap.dart';

/// App bottom sheet with consistent styling
class AppBottomSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final String? subtitle;
  final double? height;
  final bool showDragHandle;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry contentPadding;
  final bool isScrollControlled;

  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.height,
    this.showDragHandle = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.isScrollControlled = false,
  });

  /// Show bottom sheet with optional title and action buttons
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget builder,
    String? title,
    double? height,
    bool showDragHandle = true,
    EdgeInsetsGeometry? padding,
    bool isScrollControlled = false,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDragHandle)
              Container(
                width: 32,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            builder,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: DraggableScrollableSheet(
        initialChildSize: height ?? 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          return Container(
            padding: padding,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Scrollbar(
              controller: scrollController,
              thumbVisibility: true,
              child: ListView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                children: [
                  if (showDragHandle)
                    Center(
                      child: Container(
                        width: 32,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  if (title != null) ...[
                    Text(
                      title!,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const Gap(4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const Gap(16),
                  ],
                  Padding(
                    padding: contentPadding,
                    child: child,
                  ),
                ],
              ),
            ),
          );
        },
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0),
    );
  }
}
