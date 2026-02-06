import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Pixel-art styled background themes for the home brew screen.
/// All rendering uses isAntiAlias=false and grid-snapped positions.
class BackgroundThemePainter extends CustomPainter {
  final String themeId;
  final double animationValue;

  BackgroundThemePainter({
    required this.themeId,
    this.animationValue = 0.0,
  });

  // Pixel grid size for snapping
  static const double _px = 4.0;

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
      case 'theme_crystal_cave':
        _paintCrystalCave(canvas, size);
        break;
      case 'theme_mystic_garden':
        _paintMysticGarden(canvas, size);
        break;
      case 'theme_starfall':
        _paintStarfall(canvas, size);
        break;
      case 'theme_ancient_library':
        _paintAncientLibrary(canvas, size);
        break;
      // Subscriber-exclusive themes
      case 'theme_aurora':
        _paintAurora(canvas, size);
        break;
      case 'theme_cosmic_void':
        _paintCosmicVoid(canvas, size);
        break;
      case 'theme_enchanted_hearth':
        _paintEnchantedHearth(canvas, size);
        break;
      case 'theme_default':
      default:
        _paintDefault(canvas, size);
        break;
    }
  }

  /// Helper: draw stepped gradient (horizontal color bands instead of smooth gradient)
  void _drawBandedGradient(Canvas canvas, Size size, List<Color> colors, {int bands = 8}) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final bandHeight = size.height / bands;
    for (int i = 0; i < bands; i++) {
      final t = i / (bands - 1);
      // Lerp between colors
      Color c;
      if (colors.length == 2) {
        c = Color.lerp(colors[0], colors[1], t)!;
      } else {
        final segment = t * (colors.length - 1);
        final idx = segment.floor().clamp(0, colors.length - 2);
        c = Color.lerp(colors[idx], colors[idx + 1], segment - idx)!;
      }
      paint.color = c;
      canvas.drawRect(
        Rect.fromLTWH(0, (i * bandHeight).floorToDouble(), size.width, bandHeight + 1),
        paint,
      );
    }
  }

  /// Helper: snap to pixel grid
  double _snap(double v) => (v / _px).floor() * _px;

  void _paintDefault(Canvas canvas, Size size) {
    _drawBandedGradient(canvas, size, [
      const Color(0xFF1A1A2E),
      const Color(0xFF16213E),
      const Color(0xFF0F3460),
    ]);
  }

  void _paintParchment(Canvas canvas, Size size) {
    _drawBandedGradient(canvas, size, [
      const Color(0xFFF5E6C8),
      const Color(0xFFE8D5B0),
      const Color(0xFFD4C4A0),
    ], bands: 6);

    // Pixel texture dots
    final rng = math.Random(42);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 60; i++) {
      paint.color = const Color(0xFF8B7355).withOpacity(rng.nextDouble() * 0.06);
      canvas.drawRect(
        Rect.fromLTWH(
          _snap(rng.nextDouble() * size.width),
          _snap(rng.nextDouble() * size.height),
          _px, _px,
        ),
        paint,
      );
    }
  }

  void _paintForest(Canvas canvas, Size size) {
    _drawBandedGradient(canvas, size, [
      const Color(0xFF0F2419),
      const Color(0xFF1B4332),
      const Color(0xFF2D6A4F),
      const Color(0xFF40916C),
    ], bands: 10);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Ground vegetation at bottom
    final groundRng = math.Random(12);
    paint.color = const Color(0xFF143D2B).withOpacity(0.25);
    for (int i = 0; i < 30; i++) {
      final gx = _snap(groundRng.nextDouble() * size.width);
      final gh = _px * (2 + groundRng.nextInt(4));
      canvas.drawRect(Rect.fromLTWH(gx, size.height - gh, _px, gh), paint);
    }

    // Pixel tree silhouettes at bottom (multiple layers for depth)
    final rng = math.Random(17);
    for (int layer = 0; layer < 2; layer++) {
      final layerOpacity = layer == 0 ? 0.15 : 0.3;
      final treePaint = Paint()
        ..color = const Color(0xFF143D2B).withOpacity(layerOpacity)
        ..style = PaintingStyle.fill
        ..isAntiAlias = false;

      final treeCount = layer == 0 ? 6 : 10;
      for (int i = 0; i < treeCount; i++) {
        final x = _snap(rng.nextDouble() * size.width);
        final trunkH = (layer == 0 ? 15.0 : 20.0) + rng.nextDouble() * (layer == 0 ? 20 : 30);
        final crownW = (layer == 0 ? 12.0 : 16.0) + rng.nextDouble() * (layer == 0 ? 16 : 24);
        final crownH = (layer == 0 ? 15.0 : 20.0) + rng.nextDouble() * (layer == 0 ? 20 : 30);
        final baseY = size.height - (layer == 0 ? _px * 3 : 0);

        // Trunk
        canvas.drawRect(
          Rect.fromLTWH(x - _px, baseY - trunkH, _px * 2, trunkH),
          treePaint,
        );
        // Crown (pyramid)
        for (int row = 0; row < (crownH / _px).floor(); row++) {
          final rowWidth = crownW * (1 - row / (crownH / _px));
          canvas.drawRect(
            Rect.fromLTWH(x - rowWidth / 2, baseY - trunkH - row * _px, rowWidth, _px),
            treePaint,
          );
        }
      }
    }

    // Animated fireflies
    final fireflyPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    final fireflyRng = math.Random(42);
    for (int i = 0; i < 12; i++) {
      final baseX = fireflyRng.nextDouble() * size.width;
      final baseY = size.height * 0.3 + fireflyRng.nextDouble() * size.height * 0.5;
      final phase = (animationValue * 0.8 + i * 0.083) % 1.0;
      final glowPhase = (animationValue * 2 + i * 0.1) % 1.0;
      final glow = (math.sin(glowPhase * math.pi * 2) * 0.5 + 0.5);

      final driftX = math.sin(phase * math.pi * 2) * _px * 4;
      final driftY = math.cos(phase * math.pi * 3) * _px * 3;
      final x = _snap(baseX + driftX);
      final y = _snap(baseY + driftY);

      // Glow halo
      if (glow > 0.3) {
        fireflyPaint.color = const Color(0xFFFFFF00).withOpacity(glow * 0.15);
        canvas.drawRect(Rect.fromLTWH(x - _px, y - _px, _px * 3, _px * 3), fireflyPaint);
      }
      // Core
      fireflyPaint.color = const Color(0xFFFFFF66).withOpacity(glow * 0.8);
      canvas.drawRect(Rect.fromLTWH(x, y, _px, _px), fireflyPaint);
    }
  }

  void _paintNightSky(Canvas canvas, Size size) {
    _drawBandedGradient(canvas, size, [
      const Color(0xFF0D1B2A),
      const Color(0xFF1B2838),
      const Color(0xFF0A0E17),
    ], bands: 10);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Pixel moon (top right)
    final moonX = _snap(size.width * 0.78);
    final moonY = _snap(size.height * 0.12);
    final moonSize = _px * 6;
    paint.color = const Color(0xFFF5F5DC).withOpacity(0.8);
    canvas.drawRect(Rect.fromLTWH(moonX, moonY, moonSize, moonSize), paint);
    paint.color = const Color(0xFFFFFFE0).withOpacity(0.6);
    canvas.drawRect(Rect.fromLTWH(moonX - _px, moonY + _px, _px, moonSize - _px * 2), paint);
    canvas.drawRect(Rect.fromLTWH(moonX + moonSize, moonY + _px, _px, moonSize - _px * 2), paint);
    // Moon glow
    paint.color = const Color(0xFFF5F5DC).withOpacity(0.08);
    for (int ring = 1; ring <= 3; ring++) {
      final r = ring * _px * 2;
      canvas.drawRect(Rect.fromLTWH(moonX - r, moonY - r, moonSize + r * 2, moonSize + r * 2), paint);
    }

    // Pixel stars with twinkling (more stars)
    final rng = math.Random(99);
    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 70; i++) {
      final x = _snap(rng.nextDouble() * size.width);
      final y = _snap(rng.nextDouble() * size.height * 0.75);
      final phase = (animationValue + i * 0.014) % 1.0;
      final twinkle = (math.sin(phase * math.pi * 2) * 0.4 + 0.6);
      final brightness = 0.3 + rng.nextDouble() * 0.5;
      starPaint.color = Colors.white.withOpacity(twinkle * brightness);
      final starSize = rng.nextDouble() < 0.15 ? _px * 2 : _px;
      canvas.drawRect(Rect.fromLTWH(x, y, starSize, starSize), starPaint);
    }

    // Shooting stars (animated)
    final trailPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 2; i++) {
      final phase = (animationValue * 1.2 + i * 0.5) % 1.0;
      if (phase > 0.5) continue;
      final progress = phase / 0.5;
      final startX = size.width * (0.1 + i * 0.5);
      final startY = size.height * 0.05;
      final x = startX + progress * size.width * 0.35;
      final y = startY + progress * size.height * 0.4;

      for (int t = 0; t < 10; t++) {
        final opacity = (1.0 - t / 10.0) * (1.0 - progress) * 0.7;
        trailPaint.color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0));
        canvas.drawRect(
          Rect.fromLTWH(_snap(x - t * _px * 1.8), _snap(y - t * _px), _px, _px),
          trailPaint,
        );
      }
    }
  }

  void _paintAlchemyLab(Canvas canvas, Size size) {
    _drawBandedGradient(canvas, size, [
      const Color(0xFF2C1810),
      const Color(0xFF3D2B1F),
      const Color(0xFF4A3728),
    ]);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Shelf at bottom
    paint.color = const Color(0xFF1A0E08).withOpacity(0.3);
    canvas.drawRect(
      Rect.fromLTWH(0, _snap(size.height * 0.85), size.width, size.height * 0.15),
      paint,
    );
    // Shelf line (2px thick)
    paint.color = const Color(0xFF5D4E37).withOpacity(0.4);
    canvas.drawRect(
      Rect.fromLTWH(0, _snap(size.height * 0.85), size.width, _px / 2),
      paint,
    );

    // Warm glow pixel cluster at center-bottom
    paint.color = const Color(0xFFD4A574).withOpacity(0.06);
    final cx = _snap(size.width * 0.5);
    final cy = _snap(size.height * 0.7);
    for (int dx = -3; dx <= 3; dx++) {
      for (int dy = -2; dy <= 2; dy++) {
        final dist = dx.abs() + dy.abs();
        if (dist > 4) continue;
        paint.color = const Color(0xFFD4A574).withOpacity(0.08 - dist * 0.015);
        canvas.drawRect(
          Rect.fromLTWH(cx + dx * _px * 3, cy + dy * _px * 3, _px * 3, _px * 3),
          paint,
        );
      }
    }
  }

  void _paintOceanDepths(Canvas canvas, Size size) {
    _drawBandedGradient(canvas, size, [
      const Color(0xFF00496B),
      const Color(0xFF003459),
      const Color(0xFF00171F),
      const Color(0xFF001524),
    ], bands: 12);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Kelp/seaweed swaying at bottom
    final kelpRng = math.Random(55);
    for (int i = 0; i < 8; i++) {
      final baseX = kelpRng.nextDouble() * size.width;
      final kelpHeight = 40 + kelpRng.nextDouble() * 80;
      paint.color = const Color(0xFF006644).withOpacity(0.25);

      for (double dy = 0; dy < kelpHeight; dy += _px * 2) {
        final swayPhase = (animationValue + i * 0.1 + dy / 100) % 1.0;
        final sway = math.sin(swayPhase * math.pi * 2) * _px * 2 * (dy / kelpHeight);
        final x = _snap(baseX + sway);
        final y = _snap(size.height - dy);
        canvas.drawRect(Rect.fromLTWH(x, y, _px, _px * 2), paint);
      }
    }

    // Small fish silhouettes swimming
    final fishRng = math.Random(77);
    for (int i = 0; i < 6; i++) {
      final baseY = size.height * 0.2 + fishRng.nextDouble() * size.height * 0.6;
      final phase = (animationValue * 0.5 + i * 0.167) % 1.0;
      final x = _snap(phase * size.width * 1.2 - size.width * 0.1);
      final y = _snap(baseY + math.sin(phase * math.pi * 4) * _px * 3);

      // Simple pixel fish (body + tail)
      paint.color = const Color(0xFF006688).withOpacity(0.3);
      canvas.drawRect(Rect.fromLTWH(x, y, _px * 3, _px * 2), paint); // body
      canvas.drawRect(Rect.fromLTWH(x - _px, y + _px / 2, _px, _px), paint); // tail
    }

    // Pixel bubbles (square) - more bubbles
    final rng = math.Random(33);
    for (int i = 0; i < 20; i++) {
      final x = _snap(rng.nextDouble() * size.width);
      final baseY = rng.nextDouble() * size.height;
      final phase = (animationValue + i * 0.05) % 1.0;
      final y = _snap(baseY - phase * size.height * 0.25);
      paint.color = const Color(0xFF00A8CC).withOpacity((1.0 - phase) * 0.25);
      final bSize = rng.nextDouble() < 0.3 ? _px * 3 : _px * 2;
      // Draw hollow pixel square (outline only)
      canvas.drawRect(Rect.fromLTWH(x, y, bSize, _px), paint);
      canvas.drawRect(Rect.fromLTWH(x, y + bSize - _px, bSize, _px), paint);
      canvas.drawRect(Rect.fromLTWH(x, y, _px, bSize), paint);
      canvas.drawRect(Rect.fromLTWH(x + bSize - _px, y, _px, bSize), paint);
    }

    // Bioluminescent particles
    final bioRng = math.Random(88);
    final bioPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 15; i++) {
      final x = _snap(bioRng.nextDouble() * size.width);
      final y = _snap(bioRng.nextDouble() * size.height);
      final phase = (animationValue * 1.5 + i * 0.067) % 1.0;
      final glow = math.sin(phase * math.pi * 2) * 0.5 + 0.5;
      bioPaint.color = const Color(0xFF00FFFF).withOpacity(glow * 0.3);
      canvas.drawRect(Rect.fromLTWH(x, y, _px, _px), bioPaint);
    }
  }

  void _paintCrystalCave(Canvas canvas, Size size) {
    _drawBandedGradient(canvas, size, [
      const Color(0xFF0F051A),
      const Color(0xFF1A0A2E),
      const Color(0xFF2D1B4E),
      const Color(0xFF16082A),
    ], bands: 10);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Crystal colors (rainbow variety)
    final crystalColors = [
      const Color(0xFF9B59B6), // Purple
      const Color(0xFF3498DB), // Blue
      const Color(0xFF1ABC9C), // Teal
      const Color(0xFFE74C9E), // Pink
      const Color(0xFFF1C40F), // Gold
    ];

    // Pixel crystal shards from bottom (more variety)
    final rng = math.Random(55);
    for (int i = 0; i < 12; i++) {
      final x = _snap(rng.nextDouble() * size.width);
      final height = (50.0 + rng.nextDouble() * 100).floorToDouble();
      final width = (_px * 2 + rng.nextInt(5) * _px);
      final crystalColor = crystalColors[i % crystalColors.length];

      // Draw pixel crystal column
      for (double dy = 0; dy < height; dy += _px) {
        final rowWidth = width * (1 - dy / height);
        final brightness = 0.08 + (1 - dy / height) * 0.1;
        paint.color = crystalColor.withOpacity(brightness);
        canvas.drawRect(
          Rect.fromLTWH(x - rowWidth / 2, size.height - dy - _px, rowWidth, _px),
          paint,
        );
      }
      // Crystal tip highlight
      paint.color = crystalColor.withOpacity(0.4);
      canvas.drawRect(Rect.fromLTWH(x - _px / 2, size.height - height - _px, _px, _px), paint);
    }

    // Stalactites from ceiling
    for (int i = 0; i < 8; i++) {
      final x = _snap(rng.nextDouble() * size.width);
      final height = (30.0 + rng.nextDouble() * 50).floorToDouble();
      final crystalColor = crystalColors[(i + 2) % crystalColors.length];

      for (double dy = 0; dy < height; dy += _px) {
        final rowWidth = (_px * 2) * (1 - dy / height);
        paint.color = crystalColor.withOpacity(0.08 + (1 - dy / height) * 0.06);
        canvas.drawRect(
          Rect.fromLTWH(x - rowWidth / 2, dy, rowWidth, _px),
          paint,
        );
      }
    }

    // Rainbow light refractions (animated light beams)
    final refractionColors = [
      const Color(0xFFFF0000),
      const Color(0xFFFF7F00),
      const Color(0xFFFFFF00),
      const Color(0xFF00FF00),
      const Color(0xFF0000FF),
      const Color(0xFF9400D3),
    ];
    for (int i = 0; i < 3; i++) {
      final beamX = _snap(size.width * (0.2 + i * 0.3));
      final phase = (animationValue + i * 0.33) % 1.0;

      for (int c = 0; c < refractionColors.length; c++) {
        final colorPhase = (phase + c * 0.1) % 1.0;
        final opacity = math.sin(colorPhase * math.pi) * 0.12;
        paint.color = refractionColors[c].withOpacity(opacity.clamp(0.0, 0.15));

        // Draw diagonal light beam
        for (int step = 0; step < 8; step++) {
          canvas.drawRect(
            Rect.fromLTWH(
              _snap(beamX + step * _px * 2 + c * _px),
              _snap(size.height * 0.3 + step * _px * 4),
              _px * 2,
              _px * 2,
            ),
            paint,
          );
        }
      }
    }

    // Shimmer pixels (more sparkles)
    final shimPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 25; i++) {
      final sx = _snap(rng.nextDouble() * size.width);
      final sy = _snap(rng.nextDouble() * size.height);
      final phase = (animationValue * 1.5 + i * 0.04) % 1.0;
      final twinkle = (math.sin(phase * math.pi * 2) * 0.5 + 0.5);
      final sparkleColor = crystalColors[i % crystalColors.length];
      shimPaint.color = sparkleColor.withOpacity(twinkle * 0.35);
      canvas.drawRect(Rect.fromLTWH(sx, sy, _px, _px), shimPaint);
    }

    // Water droplets falling
    final dropPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 6; i++) {
      final dropX = _snap(rng.nextDouble() * size.width);
      final phase = (animationValue * 2 + i * 0.167) % 1.0;
      final dropY = _snap(phase * size.height);
      dropPaint.color = const Color(0xFF88CCFF).withOpacity((1.0 - phase) * 0.4);
      canvas.drawRect(Rect.fromLTWH(dropX, dropY, _px, _px * 2), dropPaint);
    }
  }

  void _paintMysticGarden(Canvas canvas, Size size) {
    _drawBandedGradient(canvas, size, [
      const Color(0xFF1A2F1A),
      const Color(0xFF2D4A2D),
      const Color(0xFF1E3A1E),
    ]);

    // Floating pixel petals (small colored squares)
    final rng = math.Random(77);
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 18; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final phase = (animationValue + i * 0.056) % 1.0;
      final driftX = math.sin(phase * math.pi * 2) * 8;
      final driftY = math.cos(phase * math.pi * 2) * 4 - phase * 20;
      final x = _snap(baseX + driftX);
      final y = _snap(baseY + driftY);
      final opacity = (math.sin(phase * math.pi) * 0.2).clamp(0.0, 0.2);

      paint.color = Color.lerp(
        const Color(0xFFFFB6C1),
        const Color(0xFFFFC0CB),
        rng.nextDouble(),
      )!.withOpacity(opacity);

      // Small pixel petal (2x1 or 1x2)
      if (rng.nextBool()) {
        canvas.drawRect(Rect.fromLTWH(x, y, _px * 2, _px), paint);
      } else {
        canvas.drawRect(Rect.fromLTWH(x, y, _px, _px * 2), paint);
      }
    }

    // Pink glow pixels at center
    final glowPaint = Paint()
      ..color = const Color(0xFFFF69B4).withOpacity(0.04)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    final cx = _snap(size.width * 0.5);
    final cy = _snap(size.height * 0.5);
    for (int dx = -4; dx <= 4; dx++) {
      for (int dy = -3; dy <= 3; dy++) {
        if (dx.abs() + dy.abs() > 5) continue;
        canvas.drawRect(
          Rect.fromLTWH(cx + dx * _px * 4, cy + dy * _px * 4, _px * 4, _px * 4),
          glowPaint,
        );
      }
    }
  }

  void _paintStarfall(Canvas canvas, Size size) {
    _drawBandedGradient(canvas, size, [
      const Color(0xFF1A1145),
      const Color(0xFF120B30),
      const Color(0xFF0D0A1E),
      const Color(0xFF06040F),
    ], bands: 12);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Distant spiral galaxy (top left)
    final galaxyX = _snap(size.width * 0.2);
    final galaxyY = _snap(size.height * 0.15);
    paint.color = const Color(0xFF9966FF).withOpacity(0.08);
    for (int ring = 0; ring < 4; ring++) {
      final r = ring * _px * 3;
      for (double angle = 0; angle < math.pi * 2; angle += 0.5) {
        final spiralAngle = angle + animationValue * 0.5 + ring * 0.3;
        final x = galaxyX + math.cos(spiralAngle) * r;
        final y = galaxyY + math.sin(spiralAngle) * r * 0.6;
        canvas.drawRect(Rect.fromLTWH(_snap(x), _snap(y), _px, _px), paint);
      }
    }
    // Galaxy core
    paint.color = const Color(0xFFDDCCFF).withOpacity(0.2);
    canvas.drawRect(Rect.fromLTWH(galaxyX - _px, galaxyY - _px, _px * 3, _px * 3), paint);

    // Static pixel stars (more stars)
    final rng = math.Random(88);
    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 80; i++) {
      final x = _snap(rng.nextDouble() * size.width);
      final y = _snap(rng.nextDouble() * size.height * 0.85);
      final phase = (animationValue + i * 0.0125) % 1.0;
      final twinkle = (math.sin(phase * math.pi * 2) * 0.3 + 0.7);
      starPaint.color = Colors.white.withOpacity((0.15 + rng.nextDouble() * 0.35) * twinkle);
      canvas.drawRect(Rect.fromLTWH(x, y, _px, _px), starPaint);
    }

    // Shooting star trails (more frequent)
    final trailPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 5; i++) {
      final phase = (animationValue * 1.0 + i * 0.2) % 1.0;
      if (phase > 0.6) continue;
      final progress = phase / 0.6;
      final startX = size.width * (0.1 + (i % 3) * 0.35);
      final startY = size.height * (0.05 + (i % 2) * 0.1);
      final x = startX + progress * size.width * 0.45;
      final y = startY + progress * size.height * 0.55;

      // Draw pixel trail (longer trail)
      for (int t = 0; t < 12; t++) {
        final opacity = (1.0 - t / 12.0) * (1.0 - progress) * 0.6;
        trailPaint.color = Colors.white.withOpacity(opacity.clamp(0.0, 1.0));
        canvas.drawRect(
          Rect.fromLTWH(_snap(x - t * _px * 2), _snap(y - t * _px), _px, _px),
          trailPaint,
        );
      }
    }

    // Comet with glowing tail (larger, slower moving)
    final cometPhase = (animationValue * 0.3) % 1.0;
    final cometX = _snap(size.width * 0.9 - cometPhase * size.width * 1.1);
    final cometY = _snap(size.height * 0.2 + cometPhase * size.height * 0.4);

    // Comet tail (glowing)
    for (int t = 0; t < 20; t++) {
      final tailOpacity = (1.0 - t / 20.0) * 0.35;
      final tailColor = t < 8 ? const Color(0xFFFFFFCC) : const Color(0xFF99CCFF);
      trailPaint.color = tailColor.withOpacity(tailOpacity.clamp(0.0, 0.4));
      canvas.drawRect(
        Rect.fromLTWH(_snap(cometX + t * _px * 2.5), _snap(cometY - t * _px * 0.8), _px * 2, _px * 2),
        trailPaint,
      );
    }
    // Comet head (bright)
    paint.color = const Color(0xFFFFFFFF).withOpacity(0.9);
    canvas.drawRect(Rect.fromLTWH(cometX, cometY, _px * 3, _px * 3), paint);
    paint.color = const Color(0xFF99DDFF).withOpacity(0.5);
    canvas.drawRect(Rect.fromLTWH(cometX - _px, cometY - _px, _px * 5, _px * 5), paint);
  }

  void _paintAncientLibrary(Canvas canvas, Size size) {
    _drawBandedGradient(canvas, size, [
      const Color(0xFF2A1F14),
      const Color(0xFF3D2E1E),
      const Color(0xFF1F1610),
    ]);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Shelf lines
    for (final shelfY in [_snap(size.height * 0.75), _snap(size.height * 0.88)]) {
      paint.color = const Color(0xFF5D4E37).withOpacity(0.3);
      canvas.drawRect(Rect.fromLTWH(0, shelfY, size.width, _px), paint);

      // Pixel book rectangles on shelf
      final rng = math.Random(44 + shelfY.toInt());
      double x = _px * 2;
      while (x < size.width - _px * 2) {
        final bookWidth = _px * (2 + rng.nextInt(3));
        final bookHeight = _px * (5 + rng.nextInt(6));
        paint.color = Color.lerp(
          const Color(0xFF4A3728),
          const Color(0xFF6B5B4A),
          rng.nextDouble(),
        )!.withOpacity(0.2 + rng.nextDouble() * 0.1);

        canvas.drawRect(
          Rect.fromLTWH(x, shelfY - bookHeight, bookWidth, bookHeight),
          paint,
        );
        x += bookWidth + _px;
      }
    }

    // Warm glow pixel cluster
    paint.color = const Color(0xFFD4A574).withOpacity(0.06);
    final cx = _snap(size.width * 0.6);
    final cy = _snap(size.height * 0.3);
    for (int dx = -2; dx <= 2; dx++) {
      for (int dy = -2; dy <= 2; dy++) {
        if (dx.abs() + dy.abs() > 3) continue;
        canvas.drawRect(
          Rect.fromLTWH(cx + dx * _px * 4, cy + dy * _px * 4, _px * 4, _px * 4),
          paint,
        );
      }
    }

    // Dust mote pixel particles
    final rng2 = math.Random(66);
    for (int i = 0; i < 10; i++) {
      final bx = _snap(rng2.nextDouble() * size.width);
      final by = _snap(rng2.nextDouble() * size.height * 0.7);
      final phase = (animationValue + i * 0.1) % 1.0;
      final drift = _snap(math.sin(phase * math.pi * 2) * 4);
      paint.color = const Color(0xFFD4A574).withOpacity(
        (math.sin(phase * math.pi) * 0.12).clamp(0.0, 0.12),
      );
      canvas.drawRect(Rect.fromLTWH(bx + drift, by, _px, _px), paint);
    }
  }

  // ========== SUBSCRIBER-EXCLUSIVE THEMES ==========

  /// Aurora Borealis - shimmering green/purple bands with dancing lights
  void _paintAurora(Canvas canvas, Size size) {
    // Dark night sky base
    _drawBandedGradient(canvas, size, [
      const Color(0xFF0A0E17),
      const Color(0xFF0D1B2A),
      const Color(0xFF1B2838),
    ]);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Aurora bands (horizontal wavy bands of color)
    for (int band = 0; band < 5; band++) {
      final baseY = size.height * (0.15 + band * 0.12);
      final bandColor = band % 2 == 0
          ? const Color(0xFF00FF7F) // Green
          : const Color(0xFF9B30FF); // Purple

      // Draw wavy pixel band
      for (double x = 0; x < size.width; x += _px * 2) {
        final phase = (animationValue * 2 + x / size.width + band * 0.2) % 1.0;
        final waveOffset = math.sin(phase * math.pi * 4) * _px * 4;
        final intensity = math.sin(phase * math.pi * 2 + band) * 0.5 + 0.5;

        paint.color = bandColor.withOpacity(intensity * 0.15);

        // Draw vertical streak
        for (int dy = 0; dy < 8; dy++) {
          final fadeOpacity = (1.0 - dy / 8.0) * intensity * 0.12;
          paint.color = bandColor.withOpacity(fadeOpacity.clamp(0.0, 0.15));
          canvas.drawRect(
            Rect.fromLTWH(
              _snap(x),
              _snap(baseY + waveOffset + dy * _px * 2),
              _px * 2,
              _px * 2,
            ),
            paint,
          );
        }
      }
    }

    // Twinkling stars behind aurora
    final rng = math.Random(111);
    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 30; i++) {
      final x = _snap(rng.nextDouble() * size.width);
      final y = _snap(rng.nextDouble() * size.height * 0.4);
      final phase = (animationValue + i * 0.033) % 1.0;
      final twinkle = (math.sin(phase * math.pi * 2) * 0.4 + 0.5);
      starPaint.color = Colors.white.withOpacity(twinkle * 0.4);
      canvas.drawRect(Rect.fromLTWH(x, y, _px, _px), starPaint);
    }
  }

  /// Cosmic Void - deep space with distant star clusters and nebula wisps
  void _paintCosmicVoid(Canvas canvas, Size size) {
    // Deep void gradient
    _drawBandedGradient(canvas, size, [
      const Color(0xFF000005),
      const Color(0xFF05010F),
      const Color(0xFF0A0215),
      const Color(0xFF050008),
    ], bands: 12);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Distant nebula wisps (purple/blue haze)
    final rng = math.Random(222);
    for (int i = 0; i < 8; i++) {
      final cx = _snap(rng.nextDouble() * size.width);
      final cy = _snap(rng.nextDouble() * size.height);
      final nebulaColor = i % 2 == 0
          ? const Color(0xFF4B0082) // Indigo
          : const Color(0xFF191970); // Midnight blue

      // Draw pixel cluster for nebula
      for (int dx = -3; dx <= 3; dx++) {
        for (int dy = -3; dy <= 3; dy++) {
          final dist = (dx * dx + dy * dy).toDouble();
          if (dist > 9) continue;
          final opacity = (1.0 - dist / 10) * 0.08;
          paint.color = nebulaColor.withOpacity(opacity.clamp(0.0, 0.1));
          canvas.drawRect(
            Rect.fromLTWH(
              cx + dx * _px * 4,
              cy + dy * _px * 4,
              _px * 4,
              _px * 4,
            ),
            paint,
          );
        }
      }
    }

    // Star clusters (groups of tiny stars)
    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Main star field
    for (int i = 0; i < 80; i++) {
      final x = _snap(rng.nextDouble() * size.width);
      final y = _snap(rng.nextDouble() * size.height);
      final brightness = rng.nextDouble();
      final phase = (animationValue * 0.5 + i * 0.0125) % 1.0;
      final twinkle = (math.sin(phase * math.pi * 2) * 0.3 + 0.7);
      starPaint.color = Colors.white.withOpacity(brightness * twinkle * 0.5);
      canvas.drawRect(Rect.fromLTWH(x, y, _px, _px), starPaint);
    }

    // Bright distant galaxies (larger glow spots)
    for (int i = 0; i < 3; i++) {
      final gx = _snap(size.width * (0.2 + i * 0.3) + rng.nextDouble() * 40);
      final gy = _snap(size.height * (0.3 + rng.nextDouble() * 0.4));
      final phase = (animationValue + i * 0.33) % 1.0;
      final pulse = math.sin(phase * math.pi * 2) * 0.2 + 0.8;

      // Galaxy glow
      for (int dx = -2; dx <= 2; dx++) {
        for (int dy = -2; dy <= 2; dy++) {
          final dist = (dx.abs() + dy.abs());
          if (dist > 3) continue;
          final opacity = (1.0 - dist / 4) * pulse * 0.15;
          paint.color = const Color(0xFFE0E0FF).withOpacity(opacity.clamp(0.0, 0.2));
          canvas.drawRect(
            Rect.fromLTWH(gx + dx * _px * 2, gy + dy * _px * 2, _px * 2, _px * 2),
            paint,
          );
        }
      }
    }
  }

  /// Enchanted Hearth - cozy warm fireplace with orange/amber glow
  void _paintEnchantedHearth(Canvas canvas, Size size) {
    // Warm interior gradient
    _drawBandedGradient(canvas, size, [
      const Color(0xFF2C1810),
      const Color(0xFF3D2314),
      const Color(0xFF4A2E1C),
      const Color(0xFF2A1A10),
    ]);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Fireplace opening at bottom center
    final fireplaceWidth = size.width * 0.5;
    final fireplaceX = (size.width - fireplaceWidth) / 2;
    final fireplaceY = size.height * 0.65;
    final fireplaceHeight = size.height * 0.35;

    // Dark fireplace interior
    paint.color = const Color(0xFF0A0505);
    canvas.drawRect(
      Rect.fromLTWH(fireplaceX, fireplaceY, fireplaceWidth, fireplaceHeight),
      paint,
    );

    // Fireplace arch (pixel blocks)
    paint.color = const Color(0xFF4A3728).withOpacity(0.8);
    for (double x = fireplaceX - _px * 2; x < fireplaceX + fireplaceWidth + _px * 2; x += _px * 2) {
      canvas.drawRect(
        Rect.fromLTWH(_snap(x), fireplaceY - _px * 2, _px * 2, _px * 4),
        paint,
      );
    }

    // Fire glow (animated orange/amber pixels)
    final rng = math.Random(333);
    final fireColors = [
      const Color(0xFFFF4500), // Orange red
      const Color(0xFFFF6B00), // Orange
      const Color(0xFFFFAA00), // Amber
      const Color(0xFFFFDD00), // Yellow
    ];

    // Fire base (pixel flames)
    for (int i = 0; i < 20; i++) {
      final baseX = fireplaceX + rng.nextDouble() * fireplaceWidth;
      final phase = (animationValue * 3 + i * 0.05) % 1.0;
      final flameHeight = 30 + rng.nextDouble() * 50 + math.sin(phase * math.pi * 2) * 15;

      for (double dy = 0; dy < flameHeight; dy += _px * 2) {
        final t = dy / flameHeight;
        final colorIdx = (t * (fireColors.length - 1)).floor().clamp(0, fireColors.length - 2);
        final flameColor = Color.lerp(fireColors[colorIdx], fireColors[colorIdx + 1], (t * (fireColors.length - 1)) - colorIdx)!;
        final wobble = math.sin(phase * math.pi * 4 + dy / 10) * _px * 2;
        final opacity = (1.0 - t) * 0.7;

        paint.color = flameColor.withOpacity(opacity.clamp(0.0, 0.8));
        canvas.drawRect(
          Rect.fromLTWH(
            _snap(baseX + wobble),
            _snap(size.height - _px * 4 - dy),
            _px * 2,
            _px * 2,
          ),
          paint,
        );
      }
    }

    // Warm ambient glow spreading from fire
    for (int ring = 0; ring < 6; ring++) {
      final glowOpacity = (0.08 - ring * 0.012).clamp(0.0, 0.1);
      paint.color = const Color(0xFFFF6B00).withOpacity(glowOpacity);

      final ringRadius = (ring + 1) * _px * 8;
      final cx = size.width / 2;
      final cy = size.height - _px * 10;

      for (double angle = 0; angle < math.pi; angle += 0.2) {
        final x = cx + math.cos(angle + math.pi) * ringRadius;
        final y = cy + math.sin(angle + math.pi) * ringRadius * 0.5;
        canvas.drawRect(
          Rect.fromLTWH(_snap(x), _snap(y), _px * 4, _px * 4),
          paint,
        );
      }
    }

    // Floating ember pixels
    final emberPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;
    for (int i = 0; i < 12; i++) {
      final phase = (animationValue * 1.5 + i * 0.083) % 1.0;
      final startX = fireplaceX + rng.nextDouble() * fireplaceWidth;
      final x = _snap(startX + math.sin(phase * math.pi * 3) * 20);
      final y = _snap(size.height - phase * size.height * 0.4);
      final opacity = (1.0 - phase) * 0.6;
      emberPaint.color = const Color(0xFFFF6B00).withOpacity(opacity.clamp(0.0, 0.7));
      canvas.drawRect(Rect.fromLTWH(x, y, _px, _px), emberPaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundThemePainter oldDelegate) {
    return oldDelegate.themeId != themeId ||
        oldDelegate.animationValue != animationValue;
  }
}
