import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A pixel-art style loading spinner using animated square dots.
class PixelSpinner extends StatefulWidget {
  final double size;
  final Color? color;

  const PixelSpinner({
    super.key,
    this.size = 40,
    this.color,
  });

  @override
  State<PixelSpinner> createState() => _PixelSpinnerState();
}

class _PixelSpinnerState extends State<PixelSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _PixelSpinnerPainter(
            progress: _controller.value,
            color: color,
          ),
        );
      },
    );
  }
}

class _PixelSpinnerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PixelSpinnerPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final pixelSize = size.width / 10;
    final center = size.width / 2;
    final radius = size.width / 3;

    // 8 dots around a circle
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi - (math.pi / 2);
      final opacity = (1.0 - ((progress * 8 - i) % 8) / 8).clamp(0.3, 1.0);

      paint.color = color.withValues(alpha: opacity);

      final x = center + radius * math.cos(angle) - pixelSize / 2;
      final y = center + radius * math.sin(angle) - pixelSize / 2;

      // Snap to pixel grid
      final snappedX = (x / pixelSize).round() * pixelSize;
      final snappedY = (y / pixelSize).round() * pixelSize;

      canvas.drawRect(
        Rect.fromLTWH(snappedX, snappedY, pixelSize, pixelSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PixelSpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// A pixel-art potion bottle that fills up as a loading indicator.
class PixelPotionLoading extends StatefulWidget {
  final double size;
  final Color? liquidColor;
  final Color? bottleColor;

  const PixelPotionLoading({
    super.key,
    this.size = 60,
    this.liquidColor,
    this.bottleColor,
  });

  @override
  State<PixelPotionLoading> createState() => _PixelPotionLoadingState();
}

class _PixelPotionLoadingState extends State<PixelPotionLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liquidColor = widget.liquidColor ?? Theme.of(context).colorScheme.primary;
    final bottleColor = widget.bottleColor ?? Colors.grey[400]!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size * 1.3),
          painter: _PixelPotionLoadingPainter(
            progress: _controller.value,
            liquidColor: liquidColor,
            bottleColor: bottleColor,
          ),
        );
      },
    );
  }
}

class _PixelPotionLoadingPainter extends CustomPainter {
  final double progress;
  final Color liquidColor;
  final Color bottleColor;

  _PixelPotionLoadingPainter({
    required this.progress,
    required this.liquidColor,
    required this.bottleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final px = size.width / 9; // 9-pixel wide grid

    // Bottle outline (dark)
    paint.color = Colors.black87;

    // Cork (top)
    canvas.drawRect(Rect.fromLTWH(px * 3, 0, px * 3, px), paint);

    // Neck
    canvas.drawRect(Rect.fromLTWH(px * 3, px, px, px * 2), paint);
    canvas.drawRect(Rect.fromLTWH(px * 5, px, px, px * 2), paint);

    // Body outline
    canvas.drawRect(Rect.fromLTWH(px * 1, px * 3, px, px * 7), paint);
    canvas.drawRect(Rect.fromLTWH(px * 7, px * 3, px, px * 7), paint);
    canvas.drawRect(Rect.fromLTWH(px * 1, px * 10, px * 7, px), paint);

    // Shoulders
    canvas.drawRect(Rect.fromLTWH(px * 2, px * 3, px, px), paint);
    canvas.drawRect(Rect.fromLTWH(px * 6, px * 3, px, px), paint);

    // Bottle glass (light gray)
    paint.color = bottleColor.withValues(alpha: 0.4);
    canvas.drawRect(Rect.fromLTWH(px * 4, px, px, px * 2), paint);
    canvas.drawRect(Rect.fromLTWH(px * 2, px * 4, px * 5, px * 6), paint);
    canvas.drawRect(Rect.fromLTWH(px * 3, px * 3, px * 3, px), paint);

    // Liquid (animated fill)
    final fillHeight = (progress * 6).clamp(0.0, 6.0);
    paint.color = liquidColor;

    if (fillHeight > 0) {
      final liquidTop = px * (10 - fillHeight);
      final liquidHeight = px * fillHeight;
      canvas.drawRect(
        Rect.fromLTWH(px * 2, liquidTop, px * 5, liquidHeight),
        paint,
      );
    }

    // Cork color (brown)
    paint.color = const Color(0xFF8B5A2B);
    canvas.drawRect(Rect.fromLTWH(px * 3.5, px * 0.2, px * 2, px * 0.6), paint);

    // Highlight on bottle
    paint.color = Colors.white.withValues(alpha: 0.3);
    canvas.drawRect(Rect.fromLTWH(px * 2, px * 4, px, px * 3), paint);
  }

  @override
  bool shouldRepaint(_PixelPotionLoadingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.liquidColor != liquidColor ||
        oldDelegate.bottleColor != bottleColor;
  }
}

/// A shimmer skeleton loading effect with pixel-art edges.
class PixelSkeleton extends StatefulWidget {
  final double width;
  final double height;

  const PixelSkeleton({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  State<PixelSkeleton> createState() => _PixelSkeletonState();
}

class _PixelSkeletonState extends State<PixelSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: baseColor,
              width: 2,
            ),
          ),
          child: CustomPaint(
            painter: _PixelSkeletonPainter(
              progress: _controller.value,
              baseColor: baseColor,
              highlightColor: highlightColor,
            ),
          ),
        );
      },
    );
  }
}

class _PixelSkeletonPainter extends CustomPainter {
  final double progress;
  final Color baseColor;
  final Color highlightColor;

  _PixelSkeletonPainter({
    required this.progress,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Base fill
    paint.color = baseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Animated shimmer bar
    final shimmerWidth = size.width * 0.3;
    final shimmerX = (progress * (size.width + shimmerWidth)) - shimmerWidth;

    paint.color = highlightColor.withValues(alpha: 0.5);
    canvas.drawRect(
      Rect.fromLTWH(shimmerX, 0, shimmerWidth, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PixelSkeletonPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// A simple centered loading widget with pixel spinner and optional text.
class PixelLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const PixelLoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PixelSpinner(size: size, color: color),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
