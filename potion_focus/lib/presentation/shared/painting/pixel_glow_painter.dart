import 'package:flutter/material.dart';

/// Renders a pixel-art style glow using concentric rectangular outlines.
/// Unlike BoxShadow blur, this maintains crisp pixel edges.
///
/// The glow consists of [layers] concentric rectangles, each with
/// decreasing opacity as they expand outward.
class PixelGlowPainter extends CustomPainter {
  final Color glowColor;
  final int layers;
  final double baseOpacity;
  final double animationValue; // 0.0-1.0 for pulsing
  final double pixelSize;

  PixelGlowPainter({
    required this.glowColor,
    this.layers = 4,
    this.baseOpacity = 0.25,
    this.animationValue = 0.0,
    this.pixelSize = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Pulse the opacity slightly based on animation
    final pulseMultiplier = 0.85 + 0.15 * (0.5 + 0.5 * _smoothPulse(animationValue));

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Draw from outermost to innermost (so inner layers overlay outer)
    for (int i = layers - 1; i >= 0; i--) {
      // Calculate expansion for this layer (in pixels)
      final expansion = (i + 1) * pixelSize * 2;

      // Opacity decreases exponentially for outer layers
      final layerOpacity = baseOpacity * pulseMultiplier * _opacityFalloff(i, layers);
      paint.color = glowColor.withOpacity(layerOpacity.clamp(0.0, 1.0));

      // Draw the expanded rectangle
      final rect = Rect.fromLTWH(
        -expansion,
        -expansion,
        size.width + expansion * 2,
        size.height + expansion * 2,
      );

      // Snap to pixel grid for crisp edges
      final snappedRect = _snapToPixelGrid(rect);
      canvas.drawRect(snappedRect, paint);
    }
  }

  /// Smooth sinusoidal pulse for animation
  double _smoothPulse(double t) {
    return (1.0 - (2.0 * t - 1.0).abs());
  }

  /// Opacity falloff: inner layers are brighter, outer layers fade
  double _opacityFalloff(int layerIndex, int totalLayers) {
    // Exponential falloff: 1.0, 0.5, 0.25, 0.125...
    return 1.0 / (1 << layerIndex);
  }

  /// Snap rectangle to pixel grid
  Rect _snapToPixelGrid(Rect rect) {
    return Rect.fromLTRB(
      (rect.left / pixelSize).floor() * pixelSize,
      (rect.top / pixelSize).floor() * pixelSize,
      (rect.right / pixelSize).ceil() * pixelSize,
      (rect.bottom / pixelSize).ceil() * pixelSize,
    );
  }

  @override
  bool shouldRepaint(PixelGlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.baseOpacity != baseOpacity ||
        oldDelegate.layers != layers;
  }
}

/// A variant that renders a softer, more diffuse glow using corner-rounded
/// rectangles made of pixel blocks (still no blur).
class PixelSoftGlowPainter extends CustomPainter {
  final Color glowColor;
  final int layers;
  final double baseOpacity;
  final double animationValue;
  final double pixelSize;

  PixelSoftGlowPainter({
    required this.glowColor,
    this.layers = 5,
    this.baseOpacity = 0.2,
    this.animationValue = 0.0,
    this.pixelSize = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pulseMultiplier = 0.8 + 0.2 * (0.5 + 0.5 * _smoothPulse(animationValue));

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw from outermost to innermost
    for (int i = layers - 1; i >= 0; i--) {
      final expansion = (i + 1) * pixelSize * 1.5;
      final layerOpacity = baseOpacity * pulseMultiplier / (i + 1);
      paint.color = glowColor.withOpacity(layerOpacity.clamp(0.0, 0.4));

      // Draw a rounded rectangle using pixel blocks
      _drawPixelRoundedRect(
        canvas,
        paint,
        centerX,
        centerY,
        size.width / 2 + expansion,
        size.height / 2 + expansion,
        cornerRadius: (i + 1) * 2, // Pixel-based corner radius
      );
    }
  }

  void _drawPixelRoundedRect(
    Canvas canvas,
    Paint paint,
    double centerX,
    double centerY,
    double halfWidth,
    double halfHeight, {
    int cornerRadius = 2,
  }) {
    // Draw the main body (without corners)
    // Top edge
    canvas.drawRect(
      Rect.fromLTRB(
        centerX - halfWidth + cornerRadius * pixelSize,
        centerY - halfHeight,
        centerX + halfWidth - cornerRadius * pixelSize,
        centerY - halfHeight + pixelSize,
      ),
      paint,
    );
    // Bottom edge
    canvas.drawRect(
      Rect.fromLTRB(
        centerX - halfWidth + cornerRadius * pixelSize,
        centerY + halfHeight - pixelSize,
        centerX + halfWidth - cornerRadius * pixelSize,
        centerY + halfHeight,
      ),
      paint,
    );
    // Left edge
    canvas.drawRect(
      Rect.fromLTRB(
        centerX - halfWidth,
        centerY - halfHeight + cornerRadius * pixelSize,
        centerX - halfWidth + pixelSize,
        centerY + halfHeight - cornerRadius * pixelSize,
      ),
      paint,
    );
    // Right edge
    canvas.drawRect(
      Rect.fromLTRB(
        centerX + halfWidth - pixelSize,
        centerY - halfHeight + cornerRadius * pixelSize,
        centerX + halfWidth,
        centerY + halfHeight - cornerRadius * pixelSize,
      ),
      paint,
    );
    // Center fill
    canvas.drawRect(
      Rect.fromLTRB(
        centerX - halfWidth + pixelSize,
        centerY - halfHeight + pixelSize,
        centerX + halfWidth - pixelSize,
        centerY + halfHeight - pixelSize,
      ),
      paint,
    );

    // Draw stepped corners (1 pixel at a time)
    for (int step = 0; step < cornerRadius; step++) {
      final inset = (cornerRadius - step - 1) * pixelSize;
      // Top-left corner
      canvas.drawRect(
        Rect.fromLTWH(
          centerX - halfWidth + inset,
          centerY - halfHeight + step * pixelSize,
          pixelSize,
          pixelSize,
        ),
        paint,
      );
      // Top-right corner
      canvas.drawRect(
        Rect.fromLTWH(
          centerX + halfWidth - inset - pixelSize,
          centerY - halfHeight + step * pixelSize,
          pixelSize,
          pixelSize,
        ),
        paint,
      );
      // Bottom-left corner
      canvas.drawRect(
        Rect.fromLTWH(
          centerX - halfWidth + inset,
          centerY + halfHeight - step * pixelSize - pixelSize,
          pixelSize,
          pixelSize,
        ),
        paint,
      );
      // Bottom-right corner
      canvas.drawRect(
        Rect.fromLTWH(
          centerX + halfWidth - inset - pixelSize,
          centerY + halfHeight - step * pixelSize - pixelSize,
          pixelSize,
          pixelSize,
        ),
        paint,
      );
    }
  }

  double _smoothPulse(double t) {
    return (1.0 - (2.0 * t - 1.0).abs());
  }

  @override
  bool shouldRepaint(PixelSoftGlowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.baseOpacity != baseOpacity ||
        oldDelegate.layers != layers;
  }
}
