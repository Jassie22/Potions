import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPaint-based background themes for the home brew screen.
/// No image assets -- each theme is pure paint operations.
class BackgroundThemePainter extends CustomPainter {
  final String themeId;
  final double animationValue;

  BackgroundThemePainter({
    required this.themeId,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (themeId) {
      case 'theme_parchment':
        _paintParchment(canvas, size);
        break;
      case 'theme_forest':
        _paintForest(canvas, size);
        break;
      case 'theme_night_sky':
        _paintNightSky(canvas, size);
        break;
      case 'theme_alchemy_lab':
        _paintAlchemyLab(canvas, size);
        break;
      case 'theme_ocean_depths':
        _paintOceanDepths(canvas, size);
        break;
      case 'theme_default':
      default:
        _paintDefault(canvas, size);
        break;
    }
  }

  void _paintDefault(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _paintParchment(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF5E6C8), Color(0xFFE8D5B0), Color(0xFFD4C4A0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Subtle texture
    final rng = math.Random(42);
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 80; i++) {
      dotPaint.color = const Color(0xFF8B7355).withOpacity(rng.nextDouble() * 0.04);
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 2 + 1,
        dotPaint,
      );
    }
  }

  void _paintForest(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Subtle leaf silhouettes
    final leafPaint = Paint()
      ..color = const Color(0xFF52B788).withOpacity(0.08)
      ..style = PaintingStyle.fill;

    final rng = math.Random(17);
    for (int i = 0; i < 12; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final leafSize = 20.0 + rng.nextDouble() * 30;
      final angle = rng.nextDouble() * math.pi * 2;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(0, -leafSize / 2)
        ..quadraticBezierTo(leafSize / 3, 0, 0, leafSize / 2)
        ..quadraticBezierTo(-leafSize / 3, 0, 0, -leafSize / 2);
      canvas.drawPath(path, leafPaint);
      canvas.restore();
    }
  }

  void _paintNightSky(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.3),
        radius: 1.2,
        colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF0A0E17)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Stars
    final rng = math.Random(99);
    final starPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 40; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height * 0.7;
      final phase = (animationValue + i * 0.025) % 1.0;
      final twinkle = (math.sin(phase * math.pi * 2) * 0.4 + 0.6);
      starPaint.color = Colors.white.withOpacity(twinkle * 0.6);
      canvas.drawCircle(Offset(x, y), rng.nextDouble() * 1.5 + 0.5, starPaint);
    }
  }

  void _paintAlchemyLab(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2C1810), Color(0xFF3D2B1F), Color(0xFF4A3728)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Warm ambient glow at bottom
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, 0.8),
        radius: 0.8,
        colors: [
          const Color(0xFFD4A574).withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);

    // Shelf silhouettes at bottom
    final shelfPaint = Paint()
      ..color = const Color(0xFF1A0E08).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.85, size.width, size.height * 0.15),
      shelfPaint,
    );
    // Shelf line
    canvas.drawLine(
      Offset(0, size.height * 0.85),
      Offset(size.width, size.height * 0.85),
      Paint()
        ..color = const Color(0xFF5D4E37).withOpacity(0.4)
        ..strokeWidth = 2,
    );
  }

  void _paintOceanDepths(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF003459), Color(0xFF00171F), Color(0xFF001524)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Bubbles
    final rng = math.Random(33);
    final bubblePaint = Paint()..style = PaintingStyle.stroke;
    for (int i = 0; i < 15; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final phase = (animationValue + i * 0.067) % 1.0;
      final y = baseY - phase * size.height * 0.2;
      final radius = 3.0 + rng.nextDouble() * 8;
      bubblePaint
        ..color = const Color(0xFF00A8CC).withOpacity((1.0 - phase) * 0.15)
        ..strokeWidth = 0.8;
      canvas.drawCircle(Offset(x, y), radius, bubblePaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundThemePainter oldDelegate) {
    return oldDelegate.themeId != themeId ||
        oldDelegate.animationValue != animationValue;
  }
}
