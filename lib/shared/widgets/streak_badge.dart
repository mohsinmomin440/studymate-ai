import 'package:flutter/material.dart';
import 'app_svg_icon.dart';

class StreakBadge extends StatelessWidget {
  final int streak;
  final bool animated;

  const StreakBadge({
    super.key,
    required this.streak,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = streak >= 7
        ? const Color(0xFF00C853) // Green for 7+ day streak
        : streak >= 3
            ? const Color(0xFFFFAB00) // Amber for 3+ day streak
            : const Color(0xFFFF5722); // Deep orange for 1-2 day streak

    final badgeText = streak == 1 ? '1 Day' : '$streak Days';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvgIcon.streakFlame(size: 18),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
