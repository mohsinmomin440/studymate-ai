import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'gap.dart';

/// Glassmorphism card with subtle glow/border
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? shadows;
  final bool animate;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1,
    this.shadows,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(20);

    final defaultShadows = isDark
        ? [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ];

    final card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(
          color: borderColor ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : theme.colorScheme.outlineVariant),
          width: borderWidth,
        ),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.white.withValues(alpha: 0.05),
                  Colors.white.withValues(alpha: 0.02),
                ]
              : [
                  Colors.white.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.4),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: shadows ?? defaultShadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: radius,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.white.withValues(alpha: 0.5),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: animate
              ? card
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .slideY(begin: 0.1, end: 0)
              : card,
        ),
      );
    }

    return animate
        ? card.animate().fadeIn(duration: 200.ms).slideY(begin: 0.1, end: 0)
        : card;
  }
}

/// Stat card for dashboard metrics
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final LinearGradient? iconGradient;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconGradient,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = iconGradient ??
        LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary]);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface,
                theme.colorScheme.surface.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                width: 1),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: gradient,
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const Gap(12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          value,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}
