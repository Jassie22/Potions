import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Paints a pixel-art wooden shelf background with stepped brown tones.
/// Uses banded gradients instead of smooth gradients per CLAUDE.md rules.
class WoodTexturePainter extends CustomPainter {
  final bool isShelfEdge;
  final double animationValue;

  WoodTexturePainter({
    this.isShelfEdge = false,
    this.animationValue = 0.0,
  });

  // Wooden color palette - stepped browns
  static const Color darkWood = Color(0xFF3D2B1F);
  static const Color mediumWood = Color(0xFF5C4033);
  static const Color lightWood = Color(0xFF8B7355);
  static const Color highlightWood = Color(0xFFA08060);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Pixel grid size
    const px = 4.0;

    if (isShelfEdge) {
      _paintShelfEdge(canvas, size, paint, px);
    } else {
      _paintWoodGrain(canvas, size, paint, px);
    }
  }

  /// Paints a wooden shelf surface with subtle grain pattern
  void _paintWoodGrain(Canvas canvas, Size size, Paint paint, double px) {
    // Base wood color
    paint.color = mediumWood;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Add horizontal grain lines (darker)
    paint.color = darkWood;
    final grainSpacing = px * 6;
    for (double y = 0; y < size.height; y += grainSpacing) {
      // Add some pseudo-random variation to grain position
      final offset = ((y * 7).floor() % 3) * px;
      canvas.drawRect(
        Rect.fromLTWH(offset, y, size.width - offset, px),
        paint,
      );
    }

    // Add subtle highlight streaks
    paint.color = lightWood;
    final random = math.Random(42); // Fixed seed for consistency
    for (int i = 0; i < 5; i++) {
      final y = random.nextDouble() * size.height;
      final x = random.nextDouble() * size.width * 0.3;
      final width = size.width * 0.4 + random.nextDouble() * size.width * 0.3;
      canvas.drawRect(
        Rect.fromLTWH(x, (y / px).floor() * px, width, px),
        paint,
      );
    }
  }

  /// Paints the front edge of a shelf (visible lip)
  void _paintShelfEdge(Canvas canvas, Size size, Paint paint, double px) {
    // Top highlight
    paint.color = highlightWood;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, px), paint);

    // Main shelf front
    paint.color = mediumWood;
    canvas.drawRect(Rect.fromLTWH(0, px, size.width, size.height - px * 2), paint);

    // Bottom shadow
    paint.color = darkWood;
    canvas.drawRect(Rect.fromLTWH(0, size.height - px, size.width, px), paint);

    // Add vertical wood grain on shelf edge
    paint.color = darkWood.withOpacity(0.5);
    for (double x = px * 3; x < size.width; x += px * 8) {
      canvas.drawRect(Rect.fromLTWH(x, px, px, size.height - px * 2), paint);
    }
  }

  @override
  bool shouldRepaint(WoodTexturePainter oldDelegate) {
    return oldDelegate.isShelfEdge != isShelfEdge ||
        oldDelegate.animationValue != animationValue;
  }
}

/// Paints a simple shelf shadow below the shelf
class ShelfShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    const px = 4.0;

    // Stepped shadow bands (3 levels of darkness)
    paint.color = Colors.black.withOpacity(0.3);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, px), paint);

    paint.color = Colors.black.withOpacity(0.15);
    canvas.drawRect(Rect.fromLTWH(0, px, size.width, px), paint);

    paint.color = Colors.black.withOpacity(0.05);
    canvas.drawRect(Rect.fromLTWH(0, px * 2, size.width, px), paint);
  }

  @override
  bool shouldRepaint(ShelfShadowPainter oldDelegate) => false;
}
