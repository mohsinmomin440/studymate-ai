import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Gradient button with loading state and animations
class GradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  final Color? foregroundColor;
  final double elevation;
  final Duration animationDuration;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 52,
    this.padding,
    this.borderRadius,
    this.gradientColors,
    this.foregroundColor,
    this.elevation = 0,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ??
        [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.8),
        ];
    final radius = borderRadius ?? BorderRadius.circular(16);
    final fgColor = foregroundColor ?? theme.colorScheme.onPrimary;

    final enabled = onPressed != null && !isLoading;

    return AnimatedContainer(
      duration: animationDuration,
      curve: Curves.easeOutCubic,
      width: isFullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: enabled
            ? LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  theme.colorScheme.outline.withValues(alpha: 0.5),
                  theme.colorScheme.outline.withValues(alpha: 0.3),
                ],
              ),
        boxShadow: enabled && elevation > 0
            ? [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: radius,
          splashColor: fgColor.withValues(alpha: 0.1),
          highlightColor: fgColor.withValues(alpha: 0.05),
          child: Container(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                    ),
                  ).animate().fadeIn(duration: 200.ms).scale()
                : DefaultTextStyle.merge(
                    style: TextStyle(
                      color: fgColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    child: child,
                  ).animate().fadeIn(duration: 200.ms),
          ),
        ),
      ),
    );
  }
}

/// Outline gradient button
class OutlineGradientButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<Color>? gradientColors;
  final double borderWidth;

  const OutlineGradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 52,
    this.padding,
    this.borderRadius,
    this.gradientColors,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ??
        [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.8),
        ];
    final radius = borderRadius ?? BorderRadius.circular(16);
    final enabled = onPressed != null && !isLoading;

    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          colors: enabled
              ? colors
              : [
                  theme.colorScheme.outline.withValues(alpha: 0.5),
                  theme.colorScheme.outline.withValues(alpha: 0.3),
                ],
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(radius.topLeft.x - borderWidth),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius.topLeft.x - borderWidth),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(radius.topLeft.x - borderWidth),
            child: Container(
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              alignment: Alignment.center,
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.first),
                      ),
                    )
                  : DefaultTextStyle.merge(
                      style: TextStyle(
                        color:
                            enabled ? colors.first : theme.colorScheme.outline,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      child: child,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon button with gradient background
class GradientIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final double size;
  final double iconSize;
  final List<Color>? gradientColors;
  final Color? iconColor;
  final BorderRadius? borderRadius;
  final String? tooltip;

  const GradientIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 44,
    this.iconSize = 22,
    this.gradientColors,
    this.iconColor,
    this.borderRadius,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ??
        [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.8),
        ];
    final radius = borderRadius ?? BorderRadius.circular(14);
    final enabled = onPressed != null;
    final fgColor = iconColor ?? theme.colorScheme.onPrimary;

    return Tooltip(
      message: tooltip ?? '',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: enabled
              ? LinearGradient(colors: colors)
              : LinearGradient(
                  colors: [
                    theme.colorScheme.outline.withValues(alpha: 0.3),
                    theme.colorScheme.outline.withValues(alpha: 0.1),
                  ],
                ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: radius,
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: enabled ? fgColor : theme.colorScheme.outline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
