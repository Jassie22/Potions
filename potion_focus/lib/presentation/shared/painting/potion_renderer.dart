import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'bottle_painter.dart';
import 'effect_painter.dart';

/// Renders a complete potion: bottle + liquid + effects + bubbles.
///
/// Replaces the old AnimatedPotion widget. Reads a [VisualConfig] to
/// determine which bottle shape, liquid color, and effect to draw.
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

  const PotionRenderer({
    super.key,
    required this.config,
    this.size = 150,
    this.fillPercent = 1.0,
    this.isBrewing = false,
    this.showGlow = true,
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

              // The bottle itself
              CustomPaint(
                size: Size(widget.size * 0.7, widget.size * 0.9),
                painter: BottlePainter(
                  shapeId: widget.config.bottleShape,
                  fillPercent: widget.fillPercent,
                  liquidColor: widget.config.liquidColor,
                ),
              ),

              // Bubbles during brewing
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
    final glowOpacity = 0.15 + _controller.value * 0.1;
    return Container(
      width: widget.size * 0.8,
      height: widget.size * 0.8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: widget.config.rarityColor.withOpacity(glowOpacity),
            blurRadius: widget.isBrewing ? 24 : 16,
            spreadRadius: widget.isBrewing ? 6 : 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBubbles() {
    return CustomPaint(
      size: Size(widget.size * 0.5, widget.size * 0.5),
      painter: _BubblePainter(
        color: widget.config.liquidColor,
        progress: _controller.value,
      ),
    );
  }
}

/// Simple rising bubble animation for brewing state.
class _BubblePainter extends CustomPainter {
  final Color color;
  final double progress;

  _BubblePainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final phase = (progress + i * 0.167) % 1.0;
      final x = size.width * (0.15 + (i % 3) * 0.3) +
          math.sin(phase * math.pi * 2) * size.width * 0.05;
      final y = size.height * (1.0 - phase);
      final r = 2.0 + math.sin(phase * math.pi) * 2.5;

      if (y > 0 && y < size.height) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
