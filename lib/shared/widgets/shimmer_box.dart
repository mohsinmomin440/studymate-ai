import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'gap.dart';

/// Shimmer loading placeholder
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final bool isCircular;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
    this.isCircular = false,
  });

  ShimmerBox.circular({
    super.key,
    required double size,
    this.margin,
  })  : width = size,
        height = size,
        borderRadius = BorderRadius.circular(size / 2),
        isCircular = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.grey[300]!;
    final highlightColor = theme.brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: isCircular
              ? BorderRadius.circular(width! / 2)
              : (borderRadius ?? BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

/// Shimmer list item
class ShimmerListItem extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int subtitleLines;
  final EdgeInsetsGeometry? padding;

  const ShimmerListItem({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.subtitleLines = 1,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (hasLeading) ...[
            ShimmerBox.circular(size: 48),
            const Gap(12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: double.infinity, height: 16),
                const Gap(6),
                ...List.generate(
                    subtitleLines,
                    (index) => Padding(
                          padding: EdgeInsets.only(
                              bottom: index < subtitleLines - 1 ? 4 : 0),
                          child: ShimmerBox(width: 120.0, height: 12),
                        )),
              ],
            ),
          ),
          if (hasTrailing) ...[
            const Gap(12),
            const ShimmerBox(width: 60, height: 20),
          ],
        ],
      ),
    );
  }
}

/// Shimmer card
class ShimmerCard extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.padding,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerBox(width: 100, height: 20),
          const Gap(12),
          const ShimmerBox(width: 180, height: 14),
          const Gap(6),
          const ShimmerBox(width: 140, height: 14),
          const Spacer(),
          Row(
            children: [
              const ShimmerBox(width: 60, height: 20),
              const Gap(8),
              const ShimmerBox(width: 60, height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer grid item
class ShimmerGridItem extends StatelessWidget {
  final double aspectRatio;
  final BorderRadius? borderRadius;

  const ShimmerGridItem({
    super.key,
    this.aspectRatio = 1.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(borderRadius?.topLeft.x ?? 16),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 80, height: 16),
                  const Gap(6),
                  const ShimmerBox(width: 60, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer chat message
class ShimmerChatMessage extends StatelessWidget {
  final bool isUser;

  const ShimmerChatMessage({super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            ShimmerBox.circular(size: 32),
            const Gap(8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBox(width: 120, height: 16),
                  const Gap(8),
                  const ShimmerBox(width: 180, height: 16),
                  const Gap(4),
                  const ShimmerBox(width: 90, height: 16),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const Gap(8),
            ShimmerBox.circular(size: 32),
          ],
        ],
      ),
    );
  }
}
