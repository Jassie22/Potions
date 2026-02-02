import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints rarity-based effects overlaid on a bottle.
///
/// Effect types: 'effect_glow', 'effect_sparkles', 'effect_smoke',
/// 'effect_legendary_glow', 'none'.
///
/// [animationValue] should be driven by an AnimationController (0.0-1.0, repeating).
class EffectPainter extends CustomPainter {
  final String effectType;
  final Color color;
  final double animationValue;

  EffectPainter({
    required this.effectType,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (effectType) {
      case 'effect_glow':
        _paintGlow(canvas, size);
        break;
      case 'effect_sparkles':
        _paintSparkles(canvas, size);
        break;
      case 'effect_smoke':
        _paintSmoke(canvas, size);
        break;
      case 'effect_legendary_glow':
        _paintLegendaryGlow(canvas, size);
        break;
      default:
        break; // 'none' -- nothing to paint
    }
  }

  /// Soft pulsing glow around the bottle (uncommon).
  void _paintGlow(Canvas canvas, Size size) {
    final opacity = 0.1 + animationValue * 0.15;
    final radius = size.width * 0.4 + animationValue * size.width * 0.08;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(opacity),
          color.withOpacity(0.0),
        ],
        stops: const [0.3, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height * 0.55),
          radius: radius,
        ),
      );

    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.55),
      radius,
      paint,
    );
  }

  /// Small sparkle dots that twinkle (rare).
  void _paintSparkles(Canvas canvas, Size size) {
    final rng = math.Random(42); // Fixed seed for consistent positions
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final x = size.width * (0.15 + rng.nextDouble() * 0.7);
      final y = size.height * (0.2 + rng.nextDouble() * 0.6);
      // Each sparkle has its own phase offset
      final phase = (animationValue + i * 0.125) % 1.0;
      final sparkleOpacity = (math.sin(phase * math.pi * 2) * 0.5 + 0.5) * 0.7;
      final sparkleSize = 1.5 + rng.nextDouble() * 2.0;

      paint.color = Colors.white.withOpacity(sparkleOpacity);
      canvas.drawCircle(Offset(x, y), sparkleSize, paint);
    }
  }

  /// Rising wisps of smoke above the bottle (epic).
  void _paintSmoke(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 4; i++) {
      final phase = (animationValue + i * 0.25) % 1.0;
      final x = size.width * (0.35 + i * 0.1) +
          math.sin(phase * math.pi * 2) * size.width * 0.05;
      final y = size.height * 0.15 - phase * size.height * 0.12;
      final opacity = (1.0 - phase) * 0.2;
      final radius = size.width * 0.04 + phase * size.width * 0.06;

      paint.color = color.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  /// Intense golden glow with rotating sparkle ring (legendary).
  void _paintLegendaryGlow(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.55;

    // Outer glow
    final glowRadius = size.width * 0.5 + animationValue * size.width * 0.05;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.2),
          color.withOpacity(0.05),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: glowRadius),
      );
    canvas.drawCircle(Offset(cx, cy), glowRadius, glowPaint);

    // Rotating sparkle ring
    final sparkPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final ringRadius = size.width * 0.35;
    for (int i = 0; i < 6; i++) {
      final angle = animationValue * math.pi * 2 + i * math.pi / 3;
      final sx = cx + math.cos(angle) * ringRadius;
      final sy = cy + math.sin(angle) * ringRadius * 0.6; // elliptical
      final sparkSize = 1.5 + math.sin(animationValue * math.pi * 2 + i) * 0.8;

      canvas.drawCircle(Offset(sx, sy), sparkSize, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(EffectPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.effectType != effectType ||
        oldDelegate.color != color;
  }
}
