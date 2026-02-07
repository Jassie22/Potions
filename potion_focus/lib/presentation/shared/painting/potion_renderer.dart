import 'package:flutter/material.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'bottle_painter.dart';
import 'effect_painter.dart';
import 'pixel_glow_painter.dart';

/// Renders a complete pixel-art potion: bottle + liquid + effects + bubbles.
///
/// [fillPercent] drives the liquid level:
///   - 0.0 = empty bottle (pre-brew ghost)
///   - 0.0-1.0 = filling during brew
///   - 1.0 = full (completed potion in cabinet)
///
/// [isBrewing] enables the bubble animation inside the liquid.
class PotionRenderer extends StatefulWidget {
  final VisualConfig config;
  final double size;
  final double fillPercent;
  final bool isBrewing;
  final bool showGlow;
  final double tiltX; // -1.0 to 1.0, affects liquid surface angle (left/right)
  final double tiltY; // -1.0 to 1.0, affects liquid level (forward/back tilt)

  const PotionRenderer({
    super.key,
    required this.config,
    this.size = 150,
    this.fillPercent = 1.0,
    this.isBrewing = false,
    this.showGlow = true,
    this.tiltX = 0.0,
    this.tiltY = 0.0,
  });

  @override
  State<PotionRenderer> createState() => _PotionRendererState();
}

class _PotionRendererState extends State<PotionRenderer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
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
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rarity glow shadow behind the bottle
              if (widget.showGlow && widget.fillPercent > 0)
                _buildGlow(),

              // The pixel-art bottle
              CustomPaint(
                size: Size(widget.size * 0.7, widget.size * 0.9),
                painter: BottlePainter(
                  shapeId: widget.config.bottleShape,
                  fillPercent: widget.fillPercent,
                  liquidColor: widget.config.liquidColor,
                  liquidSecondaryColor: widget.config.liquidPreset.secondaryColor,
                  liquidStyle: widget.config.liquidPreset.style,
                  animationValue: _controller.value,
                  tiltX: widget.tiltX,
                  tiltY: widget.tiltY,
                ),
              ),

              // Square bubbles during brewing
              if (widget.isBrewing && widget.fillPercent > 0.05)
                _buildBubbles(),

              // Rarity effect overlay
              if (widget.config.effectType != 'none' && widget.fillPercent > 0.3)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: EffectPainter(
                    effectType: widget.config.effectType,
                    color: widget.config.rarityColor,
                    animationValue: _controller.value,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlow() {
    // Use pixel-art style glow instead of blurred BoxShadow
    final glowSize = widget.size * 0.7;
    return CustomPaint(
      size: Size(glowSize, glowSize * 1.1),
      painter: PixelSoftGlowPainter(
        glowColor: widget.config.rarityColor,
        layers: widget.isBrewing ? 5 : 4,
        baseOpacity: widget.isBrewing ? 0.25 : 0.18,
        animationValue: _controller.value,
        pixelSize: 3.0,
      ),
    );
  }

  Widget _buildBubbles() {
    return CustomPaint(
      size: Size(widget.size * 0.5, widget.size * 0.5),
      painter: _PixelBubblePainter(
        color: widget.config.liquidColor,
        progress: _controller.value,
      ),
    );
  }
}

/// Square pixel bubbles for brewing animation.
class _PixelBubblePainter extends CustomPainter {
  final Color color;
  final double progress;

  _PixelBubblePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / 12;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    for (int i = 0; i < 6; i++) {
      final phase = (progress + i * 0.167) % 1.0;
      final x = size.width * (0.15 + (i % 3) * 0.3);
      final y = size.height * (1.0 - phase);

      if (y > 0 && y < size.height) {
        // Snap to pixel grid
        final px = (x / pixelSize).floor() * pixelSize;
        final py = (y / pixelSize).floor() * pixelSize;
        // Draw square bubble (1x1 or 2x2 pixel)
        final bSize = (i % 2 == 0) ? pixelSize : pixelSize * 2;
        canvas.drawRect(Rect.fromLTWH(px, py, bSize, bSize), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PixelBubblePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
