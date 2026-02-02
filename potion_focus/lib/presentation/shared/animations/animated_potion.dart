import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedPotion extends StatefulWidget {
  final String rarity;
  final double size;
  final bool isBrewing;

  const AnimatedPotion({
    super.key,
    required this.rarity,
    this.size = 150,
    this.isBrewing = false,
  });

  @override
  State<AnimatedPotion> createState() => _AnimatedPotionState();
}

class _AnimatedPotionState extends State<AnimatedPotion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bubbleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _bubbleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRarityColor(widget.rarity);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(_glowAnimation.value),
                blurRadius: widget.isBrewing ? 20 : 12,
                spreadRadius: widget.isBrewing ? 8 : 4,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Bottle shape
              Container(
                width: widget.size * 0.7,
                height: widget.size * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: color.withOpacity(0.5),
                    width: 2,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      color.withOpacity(0.2),
                      color.withOpacity(0.4),
                    ],
                  ),
                ),
              ),

              // Liquid with bubbles
              if (widget.isBrewing)
                _buildBubblingLiquid(color)
              else
                _buildStaticLiquid(color),

              // Icon
              Icon(
                Icons.science,
                size: widget.size * 0.3,
                color: color,
              ),

              // Rarity indicator
              if (widget.rarity == 'legendary')
                _buildLegendaryEffect(color),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBubblingLiquid(Color color) {
    return Positioned(
      bottom: widget.size * 0.15,
      child: Container(
        width: widget.size * 0.5,
        height: widget.size * 0.4,
        child: CustomPaint(
          painter: BubblePainter(
            color: color,
            bubbleProgress: _bubbleAnimation.value,
          ),
        ),
      ),
    );
  }

  Widget _buildStaticLiquid(Color color) {
    return Positioned(
      bottom: widget.size * 0.15,
      child: Container(
        width: widget.size * 0.5,
        height: widget.size * 0.4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withOpacity(0.6),
              color.withOpacity(0.8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendaryEffect(Color color) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.3),
              color.withOpacity(0.0),
            ],
          ),
        ),
        child: Transform.rotate(
          angle: _bubbleAnimation.value * 2 * math.pi,
          child: Icon(
            Icons.auto_awesome,
            size: widget.size * 0.4,
            color: color.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case 'legendary':
        return const Color(0xFFFF9800);
      case 'epic':
        return const Color(0xFF9C27B0);
      case 'rare':
        return const Color(0xFF2196F3);
      case 'uncommon':
        return const Color(0xFF4CAF50);
      case 'muddy':
        return const Color(0xFF795548);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

class BubblePainter extends CustomPainter {
  final Color color;
  final double bubbleProgress;

  BubblePainter({
    required this.color,
    required this.bubbleProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Draw bubbles
    for (int i = 0; i < 5; i++) {
      final bubbleY = size.height - (bubbleProgress * size.height * (i / 5));
      final bubbleX = size.width * 0.2 + (i * size.width * 0.15);
      final bubbleSize = 8.0 + (math.sin(bubbleProgress * 2 * math.pi + i) * 4);

      if (bubbleY > 0 && bubbleY < size.height) {
        canvas.drawCircle(
          Offset(bubbleX, bubbleY),
          bubbleSize,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    return oldDelegate.bubbleProgress != bubbleProgress;
  }
}



