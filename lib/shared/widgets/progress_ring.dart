import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

/// Animated progress ring with customizable appearance
class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final LinearGradient? progressGradient;
  final Widget? child;
  final bool animate;
  final Duration animationDuration;
  final StrokeCap strokeCap;
  final double gapDegree; // For segmented rings

  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 60,
    this.strokeWidth = 6,
    this.progressColor,
    this.backgroundColor,
    this.progressGradient,
    this.child,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.strokeCap = StrokeCap.round,
    this.gapDegree = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = progressColor ?? theme.colorScheme.primary;
    final bgColor = backgroundColor ?? theme.colorScheme.outlineVariant;
    final clampedProgress = progress.clamp(0.0, 1.0);

    final ring = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: 1.0,
              strokeWidth: strokeWidth,
              color: bgColor,
              strokeCap: strokeCap,
              gapDegree: gapDegree,
            ),
          ),
          // Progress arc
          if (progressGradient != null)
            CustomPaint(
              size: Size(size, size),
              painter: _GradientProgressRingPainter(
                progress: clampedProgress,
                strokeWidth: strokeWidth,
                gradient: progressGradient!,
                strokeCap: strokeCap,
                gapDegree: gapDegree,
              ),
            )
          else
            CustomPaint(
              size: Size(size, size),
              painter: _ProgressRingPainter(
                progress: clampedProgress,
                strokeWidth: strokeWidth,
                color: color,
                strokeCap: strokeCap,
                gapDegree: gapDegree,
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );

    if (animate) {
      return ring
          .animate()
          .scale(duration: animationDuration, curve: Curves.elasticOut);
    }
    return ring;
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final StrokeCap strokeCap;
  final double gapDegree;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.strokeCap,
    this.gapDegree = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;

    final startAngle = -3.14159 / 2; // Start from top
    final sweepAngle = 2 * 3.14159 * progress;

    if (gapDegree > 0) {
      final gapRadians = gapDegree * 3.14159 / 180;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gapRadians / 2,
        2 * 3.14159 - gapRadians,
        false,
        paint,
      );
    } else {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _ProgressRingPainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.color != color ||
            oldDelegate.strokeWidth != strokeWidth);
  }
}

class _GradientProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final LinearGradient gradient;
  final StrokeCap strokeCap;
  final double gapDegree;

  _GradientProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
    required this.strokeCap,
    this.gapDegree = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;

    final startAngle = -3.14159 / 2;
    final sweepAngle = 2 * 3.14159 * progress;

    if (gapDegree > 0) {
      final gapRadians = gapDegree * 3.14159 / 180;
      canvas.drawArc(
        rect,
        startAngle + gapRadians / 2,
        sweepAngle,
        false,
        paint,
      );
    } else {
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _GradientProgressRingPainter &&
        (oldDelegate.progress != progress ||
            oldDelegate.gradient != gradient ||
            oldDelegate.strokeWidth != strokeWidth);
  }
}

/// Segmented progress ring (for multiple values)
class SegmentedProgressRing extends StatelessWidget {
  final List<Segment> segments;
  final double size;
  final double strokeWidth;
  final double gapDegree;
  final Widget? child;

  const SegmentedProgressRing({
    super.key,
    required this.segments,
    this.size = 80,
    this.strokeWidth = 8,
    this.gapDegree = 2,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final total = segments.fold(0.0, (sum, s) => sum + s.value);
    if (total <= 0) {
      return SizedBox(width: size, height: size, child: child);
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background
          CustomPaint(
            size: Size(size, size),
            painter: _ProgressRingPainter(
              progress: 1.0,
              strokeWidth: strokeWidth,
              color: Theme.of(context).colorScheme.outlineVariant,
              strokeCap: StrokeCap.butt,
              gapDegree: gapDegree,
            ),
          ),
          // Segments
          ...segments.asMap().entries.map((entry) {
            final index = entry.key;
            final segment = entry.value;
            final startProgress =
                segments.take(index).fold(0.0, (sum, s) => sum + s.value) /
                    total;
            final endProgress = (startProgress * total + segment.value) / total;

            return CustomPaint(
              size: Size(size, size),
              painter: _SegmentPainter(
                startProgress: startProgress,
                endProgress: endProgress,
                strokeWidth: strokeWidth,
                color: segment.color,
                strokeCap: StrokeCap.butt,
                gapDegree: gapDegree,
              ),
            );
          }),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class Segment {
  final double value;
  final Color color;
  final String? label;

  const Segment({required this.value, required this.color, this.label});
}

class _SegmentPainter extends CustomPainter {
  final double startProgress;
  final double endProgress;
  final double strokeWidth;
  final Color color;
  final StrokeCap strokeCap;
  final double gapDegree;

  _SegmentPainter({
    required this.startProgress,
    required this.endProgress,
    required this.strokeWidth,
    required this.color,
    required this.strokeCap,
    this.gapDegree = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = strokeCap;

    final startAngle = -3.14159 / 2 + (2 * 3.14159 * startProgress);
    final sweepAngle = 2 * 3.14159 * (endProgress - startProgress);

    final gapRadians = gapDegree * 3.14159 / 180;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + gapRadians / 2,
      sweepAngle - gapRadians,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _SegmentPainter &&
        (oldDelegate.startProgress != startProgress ||
            oldDelegate.endProgress != endProgress ||
            oldDelegate.color != color);
  }
}

/// Linear progress bar with gradient
class GradientProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final BorderRadius? borderRadius;
  final LinearGradient? gradient;
  final Color? backgroundColor;
  final bool animate;
  final Duration animationDuration;

  const GradientProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.borderRadius,
    this.gradient,
    this.backgroundColor,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clampedProgress = progress.clamp(0.0, 1.0);
    final radius = borderRadius ?? BorderRadius.circular(height / 2);
    final bgColor = backgroundColor ?? theme.colorScheme.outlineVariant;
    final grad = gradient ?? theme.gradients.primary;

    return ClipRRect(
      borderRadius: radius,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radius,
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: clampedProgress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: grad,
                  borderRadius: radius,
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .scaleX(alignment: Alignment.centerLeft, duration: animationDuration);
  }
}
