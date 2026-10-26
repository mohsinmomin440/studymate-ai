import 'package:flutter/material.dart';

/// Official Google 4-color 'G' logo widget.
/// Renders the official asset from assets/icons/google.png,
/// with fallback to a CustomPainter vector.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({
    super.key,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/icons/google.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return CustomPaint(
            size: Size(size, size),
            painter: _GoogleLogoPainter(),
          );
        },
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width * 0.44;
    final strokeWidth = size.width * 0.2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius - strokeWidth / 2);

    // Red: Top arc (215° to 330°)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.75, 1.9, false, paint);

    // Yellow: Left arc (135° to 225°)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.35, 1.5, false, paint);

    // Green: Bottom arc (40° to 140°)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.7, 1.7, false, paint);

    // Blue: Right arc (-40° to 45°)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, 5.6, 1.3, false, paint);

    // Blue horizontal crossbar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final barRect = Rect.fromLTRB(cx - size.width * 0.05, cy - strokeWidth / 2, cx + radius, cy + strokeWidth / 2);
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
