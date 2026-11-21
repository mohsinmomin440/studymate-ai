import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'gap.dart';

/// Custom chip with selection state
class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final IconData? icon;
  final Color? selectedColor;
  final Color? unselectedColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onDeleted,
    this.icon,
    this.selectedColor,
    this.unselectedColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(999);
    final selColor = selectedColor ?? theme.colorScheme.primary;
    final unselColor =
        unselectedColor ?? theme.colorScheme.surfaceContainerHighest;

    final chip = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? selColor : unselColor,
        borderRadius: radius,
        border: Border.all(
          color: selected ? selColor : theme.colorScheme.outlineVariant,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const Gap(6),
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (onDeleted != null) ...[
            const Gap(6),
            InkWell(
              onTap: onDeleted,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: selected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: chip,
        ),
      ).animate().fadeIn(duration: 200.ms).scale();
    }

    return chip.animate().fadeIn(duration: 200.ms).scale();
  }
}

/// Filter chip group for single selection
class AppChipGroup<T> extends StatelessWidget {
  final List<ChipOption<T>> options;
  final T? selectedValue;
  final ValueChanged<T>? onChanged;
  final bool allowDeselect;
  final WrapAlignment alignment;
  final double spacing;
  final double runSpacing;

  const AppChipGroup({
    super.key,
    required this.options,
    this.selectedValue,
    this.onChanged,
    this.allowDeselect = false,
    this.alignment = WrapAlignment.start,
    this.spacing = 8,
    this.runSpacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: alignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: options.map((option) {
        final isSelected = selectedValue == option.value;
        return AppChip(
          label: option.label,
          selected: isSelected,
          icon: option.icon,
          onTap: () {
            if (isSelected && allowDeselect) {
              onChanged?.call(option.value);
            } else if (!isSelected) {
              onChanged?.call(option.value);
            }
          },
        );
      }).toList(),
    );
  }
}

class ChipOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const ChipOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// Subject chip with color coding
class SubjectChip extends StatelessWidget {
  final String subject;
  final bool selected;
  final VoidCallback? onTap;

  const SubjectChip({
    super.key,
    required this.subject,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getSubjectColor(subject, theme);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: selected ? color : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? color : color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Text(
        subject,
        style: theme.textTheme.labelSmall?.copyWith(
          color: selected ? Colors.white : color,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).scale();
  }

  Color _getSubjectColor(String subject, ThemeData theme) {
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.primary.withValues(alpha: 0.7),
      theme.colorScheme.secondary.withValues(alpha: 0.7),
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.indigo,
    ];

    final index = subject.hashCode.abs() % colors.length;
    return colors[index];
  }
}

/// Difficulty chip
class DifficultyChip extends StatelessWidget {
  final String difficulty;
  final bool selected;
  final VoidCallback? onTap;

  const DifficultyChip({
    super.key,
    required this.difficulty,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (color, icon) = _getDifficultyStyle(difficulty, theme);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? color : color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected ? color : color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: selected ? Colors.white : color,
          ),
          const Gap(6),
          Text(
            difficulty,
            style: theme.textTheme.labelMedium?.copyWith(
              color: selected ? Colors.white : color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).scale();
  }

  (Color, IconData) _getDifficultyStyle(String difficulty, ThemeData theme) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return (
          theme.colorScheme.primary.withValues(alpha: 0.7),
          Icons.sentiment_very_satisfied_rounded
        );
      case 'medium':
        return (theme.colorScheme.secondary, Icons.sentiment_neutral_rounded);
      case 'hard':
        return (
          theme.colorScheme.error,
          Icons.sentiment_very_dissatisfied_rounded
        );
      default:
        return (theme.colorScheme.primary, Icons.help_rounded);
    }
  }
}
