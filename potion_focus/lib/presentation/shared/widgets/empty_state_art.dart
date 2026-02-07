import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Types of empty state illustrations
enum EmptyStateType {
  cabinet,  // Empty cabinet with dust motes
  quests,   // Sleeping potion bottle
  grimoire, // Blank open book
  shop,     // Empty coin purse
  tags,     // Empty tag label
}

/// A charming pixel-art empty state illustration with message.
/// Adds visual warmth to empty screens.
class PixelEmptyState extends StatefulWidget {
  final EmptyStateType type;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const PixelEmptyState({
    super.key,
    required this.type,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<PixelEmptyState> createState() => _PixelEmptyStateState();
}

class _PixelEmptyStateState extends State<PixelEmptyState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pixel art illustration
              SizedBox(
                width: 120,
                height: 100,
                child: CustomPaint(
                  painter: _EmptyStatePainter(
                    type: widget.type,
                    animationValue: _controller.value,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Message
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
              ),

              // Optional action button
              if (widget.actionLabel != null && widget.onAction != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: widget.onAction,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(widget.actionLabel!),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Painter for pixel art empty state illustrations
class _EmptyStatePainter extends CustomPainter {
  final EmptyStateType type;
  final double animationValue;

  static const double _px = 4.0;

  _EmptyStatePainter({
    required this.type,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case EmptyStateType.cabinet:
        _paintEmptyCabinet(canvas, size);
        break;
      case EmptyStateType.quests:
        _paintSleepingPotion(canvas, size);
        break;
      case EmptyStateType.grimoire:
        _paintBlankBook(canvas, size);
        break;
      case EmptyStateType.shop:
        _paintEmptyPurse(canvas, size);
        break;
      case EmptyStateType.tags:
        _paintEmptyTag(canvas, size);
        break;
    }
  }

  double _snap(double v) => (v / _px).floor() * _px;

  /// Empty cabinet shelf with floating dust motes
  void _paintEmptyCabinet(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final cx = size.width / 2;
    final baseY = size.height * 0.8;

    // Shelf (wooden plank)
    paint.color = const Color(0xFF8B7355);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 50), _snap(baseY), 100, _px * 2),
      paint,
    );

    // Shelf highlight
    paint.color = const Color(0xFFA08060);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 50), _snap(baseY), 100, _px),
      paint,
    );

    // Shelf supports
    paint.color = const Color(0xFF6B5344);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 46), _snap(baseY + _px * 2), _px * 2, _px * 3),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx + 40), _snap(baseY + _px * 2), _px * 2, _px * 3),
      paint,
    );

    // Floating dust motes
    final rng = math.Random(42);
    paint.color = const Color(0xFFD4A574).withValues(alpha: 0.3);
    for (int i = 0; i < 6; i++) {
      final phase = (animationValue + i * 0.167) % 1.0;
      final x = _snap(cx - 30 + rng.nextDouble() * 60);
      final baseYPos = size.height * 0.3 + rng.nextDouble() * size.height * 0.4;
      final y = _snap(baseYPos + math.sin(phase * math.pi * 2) * 8);
      final opacity = (0.3 * math.sin(phase * math.pi)).abs();
      paint.color = const Color(0xFFD4A574).withValues(alpha: opacity);
      canvas.drawRect(Rect.fromLTWH(x, y, _px, _px), paint);
    }
  }

  /// Sleeping potion bottle with "zzz"
  void _paintSleepingPotion(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Bottle body (tilted, lying down)
    paint.color = const Color(0xFF88CCEE).withValues(alpha: 0.4);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 20), _snap(cy), _px * 10, _px * 6),
      paint,
    );

    // Bottle neck
    paint.color = const Color(0xFF88CCEE).withValues(alpha: 0.3);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx + 20), _snap(cy + _px), _px * 4, _px * 4),
      paint,
    );

    // Cork
    paint.color = const Color(0xFFC49A6C);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx + 24), _snap(cy + _px), _px * 3, _px * 4),
      paint,
    );

    // Bottle outline
    paint.color = Colors.black54;
    // Top edge
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 20), _snap(cy), _px * 10, 1),
      paint,
    );
    // Bottom edge
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 20), _snap(cy + _px * 6), _px * 10, 1),
      paint,
    );

    // Animated "zzz" - sleeping effect
    final zPhase = animationValue;
    paint.color = Colors.grey[400]!.withValues(alpha: 0.6);

    // First z (smallest, lowest)
    final z1Y = _snap(cy - 10 - math.sin(zPhase * math.pi * 2) * 4);
    _drawPixelZ(canvas, paint, _snap(cx + 30), z1Y, 0.6);

    // Second z (medium)
    final z2Y = _snap(cy - 20 - math.sin((zPhase + 0.3) * math.pi * 2) * 4);
    _drawPixelZ(canvas, paint, _snap(cx + 36), z2Y, 0.8);

    // Third z (largest, highest)
    final z3Y = _snap(cy - 32 - math.sin((zPhase + 0.6) * math.pi * 2) * 4);
    _drawPixelZ(canvas, paint, _snap(cx + 42), z3Y, 1.0);
  }

  void _drawPixelZ(Canvas canvas, Paint paint, double x, double y, double scale) {
    final s = _px * scale;
    // Top horizontal
    canvas.drawRect(Rect.fromLTWH(x, y, s * 3, s), paint);
    // Diagonal
    canvas.drawRect(Rect.fromLTWH(x + s * 2, y + s, s, s), paint);
    canvas.drawRect(Rect.fromLTWH(x + s, y + s * 2, s, s), paint);
    // Bottom horizontal
    canvas.drawRect(Rect.fromLTWH(x, y + s * 3, s * 3, s), paint);
  }

  /// Blank open book
  void _paintBlankBook(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Left page
    paint.color = const Color(0xFFF5E6C8);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 40), _snap(cy - 25), _px * 9, _px * 12),
      paint,
    );

    // Right page
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx + 4), _snap(cy - 25), _px * 9, _px * 12),
      paint,
    );

    // Book spine shadow
    paint.color = const Color(0xFFD4C4A0);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 4), _snap(cy - 25), _px * 2, _px * 12),
      paint,
    );

    // Page lines (faint)
    paint.color = const Color(0xFFCCBB99).withValues(alpha: 0.5);
    for (int i = 0; i < 4; i++) {
      // Left page lines
      canvas.drawRect(
        Rect.fromLTWH(_snap(cx - 36), _snap(cy - 18 + i * _px * 3), _px * 6, 1),
        paint,
      );
      // Right page lines
      canvas.drawRect(
        Rect.fromLTWH(_snap(cx + 8), _snap(cy - 18 + i * _px * 3), _px * 6, 1),
        paint,
      );
    }

    // Question mark in center (animated pulse)
    final pulse = 0.7 + 0.3 * math.sin(animationValue * math.pi * 2);
    paint.color = Colors.grey[400]!.withValues(alpha: pulse * 0.5);

    // Question mark dot
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx), _snap(cy + 10), _px, _px),
      paint,
    );
    // Question mark curve (simplified)
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - _px), _snap(cy - 8), _px * 3, _px),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx + _px), _snap(cy - 8), _px, _px * 3),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx), _snap(cy - 2), _px, _px * 2),
      paint,
    );
  }

  /// Empty coin purse
  void _paintEmptyPurse(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Purse body (deflated/empty look)
    paint.color = const Color(0xFF8B6914);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 24), _snap(cy - 8), _px * 12, _px * 8),
      paint,
    );

    // Purse top (drawstring opening - wider to show empty)
    paint.color = const Color(0xFFA07A18);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 28), _snap(cy - 12), _px * 14, _px * 3),
      paint,
    );

    // Drawstring
    paint.color = const Color(0xFF5D4E37);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 16), _snap(cy - 16), _px * 2, _px * 4),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx + 8), _snap(cy - 16), _px * 2, _px * 4),
      paint,
    );

    // Empty interior shadow
    paint.color = const Color(0xFF4A3728).withValues(alpha: 0.5);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 12), _snap(cy - 6), _px * 6, _px * 4),
      paint,
    );

    // Floating dust (to emphasize emptiness)
    final rng = math.Random(77);
    for (int i = 0; i < 3; i++) {
      final phase = (animationValue + i * 0.33) % 1.0;
      final x = _snap(cx - 10 + rng.nextDouble() * 20);
      final y = _snap(cy - 20 - phase * 20);
      paint.color = const Color(0xFFD4A574).withValues(alpha: (1 - phase) * 0.3);
      canvas.drawRect(Rect.fromLTWH(x, y, _px, _px), paint);
    }
  }

  /// Empty tag label
  void _paintEmptyTag(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Tag body
    paint.color = const Color(0xFFE8D5B0);
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 28), _snap(cy - 12), _px * 14, _px * 8),
      paint,
    );

    // Tag pointed end
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx + 28), _snap(cy - 8), _px * 2, _px * 4),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx + 24), _snap(cy - 10), _px * 2, _px * 2),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx + 24), _snap(cy + 4), _px * 2, _px * 2),
      paint,
    );

    // Tag hole
    paint.color = Colors.grey[600]!;
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx + 20), _snap(cy - 4), _px * 2, _px * 2),
      paint,
    );

    // Empty dashed lines (to show no text)
    paint.color = Colors.grey[400]!.withValues(alpha: 0.5);
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawRect(
          Rect.fromLTWH(
            _snap(cx - 24 + j * _px * 4),
            _snap(cy - 8 + i * _px * 4),
            _px * 2,
            _px,
          ),
          paint,
        );
      }
    }

    // Plus sign (add new)
    final pulse = 0.6 + 0.4 * math.sin(animationValue * math.pi * 2);
    paint.color = const Color(0xFF8B2FC9).withValues(alpha: pulse * 0.4);

    // Horizontal line of plus
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 20), _snap(cy + 20), _px * 5, _px),
      paint,
    );
    // Vertical line of plus
    canvas.drawRect(
      Rect.fromLTWH(_snap(cx - 10), _snap(cy + 16), _px, _px * 5),
      paint,
    );
  }

  @override
  bool shouldRepaint(_EmptyStatePainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.animationValue != animationValue;
  }
}
