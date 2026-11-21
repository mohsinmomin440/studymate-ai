import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'gap.dart';

/// Circular stat tile (for streak, level, etc.)
class CircularStatTile extends StatelessWidget {
  final String label;
  final String value;
  final double progress;
  final Color? progressColor;
  final double size;
  final double strokeWidth;
  final bool showLabel;

  const CircularStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.progress,
    this.progressColor,
    this.size = 80,
    this.strokeWidth = 8,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = progressColor ?? theme.colorScheme.primary;
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: clampedProgress,
                strokeWidth: strokeWidth,
                backgroundColor: theme.colorScheme.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            if (showLabel)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const Gap(8),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).scale();
  }
}

/// XP/Level progress ring
class LevelProgressRing extends StatelessWidget {
  final int currentXP;
  final int xpForNextLevel;
  final int level;
  final double size;
  final double strokeWidth;
  final bool showLevel;

  const LevelProgressRing({
    super.key,
    required this.currentXP,
    required this.xpForNextLevel,
    required this.level,
    this.size = 72,
    this.strokeWidth = 6,
    this.showLevel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (currentXP / xpForNextLevel).clamp(0.0, 1.0);
    final xpColor = theme.colorScheme.secondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: strokeWidth,
                backgroundColor: theme.colorScheme.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(xpColor),
              ),
            ),
            if (showLevel)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Level $level',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$currentXP / $xpForNextLevel XP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).scale();
  }
}
