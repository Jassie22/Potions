import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Draws a parchment/aged paper background via CustomPaint.
/// No image assets required.
class BookPageBackground extends StatelessWidget {
  final Widget child;

  const BookPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ParchmentPainter(),
      child: child,
    );
  }
}

class _ParchmentPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base parchment color
    final basePaint = Paint()..color = const Color(0xFFF5E6C8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), basePaint);

    // Subtle warm noise texture
    final rng = math.Random(17);
    final noisePaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 120; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final opacity = rng.nextDouble() * 0.06;
      noisePaint.color = const Color(0xFF8B7355).withValues(alpha: opacity);
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 3 + 1, noisePaint);
    }

    // Darker edges (vignette)
    final edgePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          Colors.transparent,
          const Color(0xFF8B7355).withValues(alpha: 0.12),
        ],
        stops: const [0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), edgePaint);

    // Top shadow edge (like a page fold)
    final topShadow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8B7355).withValues(alpha: 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.04));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.04),
      topShadow,
    );

    // Bottom shadow
    final bottomShadow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xFF8B7355).withValues(alpha: 0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.96, size.width, size.height * 0.04));
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.96, size.width, size.height * 0.04),
      bottomShadow,
    );

    // Decorative border line
    final borderPaint = Paint()
      ..color = const Color(0xFF8B7355).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(16, 16, size.width - 32, size.height - 32),
        const Radius.circular(4),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
