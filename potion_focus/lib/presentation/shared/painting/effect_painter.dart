import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints pixel-art rarity effects overlaid on a bottle.
///
/// All effects use square pixels and no anti-aliasing for a retro game feel.
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
        break;
    }
  }

  /// Pulsing pixel border glow (uncommon).
  void _paintGlow(Canvas canvas, Size size) {
    final pixelSize = size.width / 16;
    final opacity = 0.15 + animationValue * 0.2;
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Draw a square halo of colored pixels around center
    final cx = size.width / 2;
    final cy = size.height * 0.55;
    final radius = size.width * 0.35 + animationValue * pixelSize * 2;

    // Draw pixel ring
    for (double angle = 0; angle < math.pi * 2; angle += math.pi / 8) {
      final x = cx + math.cos(angle) * radius;
      final y = cy + math.sin(angle) * radius * 0.8;
      canvas.drawRect(
        Rect.fromLTWH(
          (x / pixelSize).floor() * pixelSize,
          (y / pixelSize).floor() * pixelSize,
          pixelSize,
          pixelSize,
        ),
        paint,
      );
    }
  }

  /// Small pixel cross sparkles that twinkle (rare).
  void _paintSparkles(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final pixelSize = size.width / 20;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    for (int i = 0; i < 8; i++) {
      final x = size.width * (0.15 + rng.nextDouble() * 0.7);
      final y = size.height * (0.2 + rng.nextDouble() * 0.6);
      final phase = (animationValue + i * 0.125) % 1.0;
      final sparkleOpacity = (math.sin(phase * math.pi * 2) * 0.5 + 0.5) * 0.8;

      if (sparkleOpacity < 0.2) continue;

      paint.color = Colors.white.withOpacity(sparkleOpacity);

      // Snap to pixel grid
      final px = (x / pixelSize).floor() * pixelSize;
      final py = (y / pixelSize).floor() * pixelSize;

      // Draw cross/plus shape
      canvas.drawRect(Rect.fromLTWH(px, py, pixelSize, pixelSize), paint); // center
      canvas.drawRect(Rect.fromLTWH(px - pixelSize, py, pixelSize, pixelSize), paint); // left
      canvas.drawRect(Rect.fromLTWH(px + pixelSize, py, pixelSize, pixelSize), paint); // right
      canvas.drawRect(Rect.fromLTWH(px, py - pixelSize, pixelSize, pixelSize), paint); // top
      canvas.drawRect(Rect.fromLTWH(px, py + pixelSize, pixelSize, pixelSize), paint); // bottom
    }
  }

  /// Rising pixel smoke puffs (epic).
  void _paintSmoke(Canvas canvas, Size size) {
    final pixelSize = size.width / 16;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    for (int i = 0; i < 4; i++) {
      final phase = (animationValue + i * 0.25) % 1.0;
      final x = size.width * (0.35 + i * 0.1);
      final y = size.height * 0.15 - phase * size.height * 0.12;
      final opacity = (1.0 - phase) * 0.3;

      if (opacity < 0.05) continue;

      paint.color = color.withOpacity(opacity);

      // Snap to grid and draw 2x2 pixel block
      final px = (x / pixelSize).floor() * pixelSize;
      final py = (y / pixelSize).floor() * pixelSize;

      canvas.drawRect(Rect.fromLTWH(px, py, pixelSize * 2, pixelSize * 2), paint);
    }
  }

  /// Golden pixel glow with orbiting pixel squares (legendary).
  void _paintLegendaryGlow(Canvas canvas, Size size) {
    final pixelSize = size.width / 20;
    final cx = size.width / 2;
    final cy = size.height * 0.55;

    // Outer pixel glow ring
    final glowPaint = Paint()
      ..color = color.withOpacity(0.15 + animationValue * 0.08)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final radius = size.width * 0.4;
    for (double angle = 0; angle < math.pi * 2; angle += math.pi / 10) {
      final x = cx + math.cos(angle) * radius;
      final y = cy + math.sin(angle) * radius * 0.7;
      final px = (x / pixelSize).floor() * pixelSize;
      final py = (y / pixelSize).floor() * pixelSize;
      canvas.drawRect(Rect.fromLTWH(px, py, pixelSize, pixelSize), glowPaint);
    }

    // Orbiting pixel sparkles
    final sparkPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final ringRadius = size.width * 0.32;
    for (int i = 0; i < 6; i++) {
      final angle = animationValue * math.pi * 2 + i * math.pi / 3;
      final sx = cx + math.cos(angle) * ringRadius;
      final sy = cy + math.sin(angle) * ringRadius * 0.6;
      final px = (sx / pixelSize).floor() * pixelSize;
      final py = (sy / pixelSize).floor() * pixelSize;

      canvas.drawRect(Rect.fromLTWH(px, py, pixelSize, pixelSize), sparkPaint);
    }
  }

  @override
  bool shouldRepaint(EffectPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.effectType != effectType ||
        oldDelegate.color != color;
  }
}
