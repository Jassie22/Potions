import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'bottle_shapes.dart';

/// Paints a pixel-art bottle with liquid fill and rarity-based liquid styles.
///
/// Liquid styles:
///   - `flat` (common): solid single color
///   - `sheen` (uncommon): base + drifting highlight column
///   - `gradient` (rare): two-tone stepped bands
///   - `sparkle` (epic): gradient + twinkling bright pixels
///   - `luminous` (legendary): shifting gradient + sparkles + pulse
class BottlePainter extends CustomPainter {
  final String shapeId;
  final double fillPercent;
  final Color liquidColor;
  final Color? liquidSecondaryColor;
  final String liquidStyle;
  final double animationValue;
  final Color glassColor;
  final double tiltX; // -1.0 to 1.0, tilts liquid surface left/right
  final double tiltY; // -1.0 to 1.0, shifts liquid level up/down (forward/back tilt)

  BottlePainter({
    required this.shapeId,
    required this.fillPercent,
    required this.liquidColor,
    this.liquidSecondaryColor,
    this.liquidStyle = 'flat',
    this.animationValue = 0.0,
    this.glassColor = const Color(0x88FFFFFF),
    this.tiltX = 0.0,
    this.tiltY = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bottle = BottleShapes.getPixelBottle(shapeId);

    // Use floor for integer pixel dimensions to avoid grid line artifacts
    final pixelW = (size.width / bottle.gridWidth).floorToDouble();
    final pixelH = (size.height / bottle.gridHeight).floorToDouble();

    // Calculate centering offset for remaining pixels
    final effectiveWidth = pixelW * bottle.gridWidth;
    final effectiveHeight = pixelH * bottle.gridHeight;
    final offsetX = (size.width - effectiveWidth) / 2;
    final offsetY = (size.height - effectiveHeight) / 2;

    // Find the vertical range of body+neck cells for liquid fill calculation
    int bodyTopRow = bottle.gridHeight;
    int bodyBottomRow = 0;
    for (int row = 0; row < bottle.gridHeight; row++) {
      for (int col = 0; col < bottle.gridWidth; col++) {
        final cell = bottle.grid[row][col];
        if (cell == 1 || cell == 2) {
          if (row < bodyTopRow) bodyTopRow = row;
          if (row > bodyBottomRow) bodyBottomRow = row;
        }
      }
    }

    final totalBodyRows = bodyBottomRow - bodyTopRow + 1;
    final filledRows = (totalBodyRows * fillPercent.clamp(0.0, 1.0)).round();
    final liquidStartRow = bodyBottomRow - filledRows + 1;

    // Neck overflow: fill neck cells when fill > 85%
    final neckFill = fillPercent > 0.85
        ? ((fillPercent - 0.85) / 0.15).clamp(0.0, 1.0)
        : 0.0;

    // Find neck row range
    int neckTopRow = bottle.gridHeight;
    int neckBottomRow = 0;
    for (int row = 0; row < bottle.gridHeight; row++) {
      for (int col = 0; col < bottle.gridWidth; col++) {
        if (bottle.grid[row][col] == 2) {
          if (row < neckTopRow) neckTopRow = row;
          if (row > neckBottomRow) neckBottomRow = row;
        }
      }
    }
    final totalNeckRows = neckBottomRow - neckTopRow + 1;
    final filledNeckRows = (totalNeckRows * neckFill).round();
    final neckLiquidStartRow = neckBottomRow - filledNeckRows + 1;

    // Reusable paints — all with anti-alias OFF for crisp pixels
    final glassPaint = Paint()
      ..color = glassColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final corkPaint = Paint()
      ..color = const Color(0xFFC49A6C)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final corkDarkPaint = Paint()
      ..color = const Color(0xFFAA8050)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final decorPaint = Paint()
      ..color = glassColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Sheen column position (for uncommon style)
    final sheenCol = ((animationValue * bottle.gridWidth * 2) % (bottle.gridWidth + 2) - 1).floor();

    // Calculate tilt offset per column (slosh effect)
    // tiltX ranges from -1 to 1, maps to ±2 rows of offset at the edges
    const maxTiltRows = 2;
    final centerCol = bottle.gridWidth / 2.0;

    // Calculate vertical tilt offset (forward/back tilt shifts liquid level)
    // tiltY > 0 (tilting forward/up): liquid sloshes down, fewer rows visible
    // tiltY < 0 (tilting back/down): liquid sloshes up, more rows visible
    const maxVerticalTiltRows = 3;
    final verticalTiltOffset = (tiltY * maxVerticalTiltRows).round();

    // Draw each cell
    for (int row = 0; row < bottle.gridHeight; row++) {
      for (int col = 0; col < bottle.gridWidth; col++) {
        final cell = bottle.grid[row][col];
        if (cell == 0) continue;

        // Calculate per-column liquid start row based on tilt
        final colOffset = (col - centerCol) / centerCol; // -1 to 1
        final horizontalTiltOffset = (colOffset * tiltX * maxTiltRows).round();
        // Combine horizontal (per-column) and vertical (uniform) tilt offsets
        final totalTiltOffset = horizontalTiltOffset + verticalTiltOffset;
        final tiltedLiquidStartRow = (liquidStartRow + totalTiltOffset).clamp(bodyTopRow, bodyBottomRow + 1);
        final tiltedNeckLiquidStartRow = (neckLiquidStartRow + totalTiltOffset).clamp(neckTopRow, neckBottomRow + 1);

        final rect = Rect.fromLTWH(
          offsetX + col * pixelW,
          offsetY + row * pixelH,
          pixelW,
          pixelH,
        );

        switch (cell) {
          case 1: // Body
            if (fillPercent > 0 && row >= tiltedLiquidStartRow) {
              _drawLiquidPixel(canvas, rect, row, col, tiltedLiquidStartRow, bodyBottomRow, bottle, sheenCol);
            } else {
              canvas.drawRect(rect, glassPaint);
            }
            break;

          case 2: // Neck
            if (neckFill > 0 && row >= tiltedNeckLiquidStartRow) {
              _drawLiquidPixel(canvas, rect, row, col, tiltedLiquidStartRow, bodyBottomRow, bottle, sheenCol);
            } else {
              canvas.drawRect(rect, glassPaint);
            }
            break;

          case 3: // Cork
            if (row % 2 == 0) {
              canvas.drawRect(rect, corkPaint);
            } else {
              canvas.drawRect(rect, corkDarkPaint);
            }
            break;

          case 4: // Highlight
            if (fillPercent > 0 && row >= tiltedLiquidStartRow) {
              _drawLiquidPixel(canvas, rect, row, col, tiltedLiquidStartRow, bodyBottomRow, bottle, sheenCol);
            } else {
              canvas.drawRect(rect, glassPaint);
            }
            canvas.drawRect(rect, highlightPaint);
            break;

          case 5: // Decoration
            canvas.drawRect(rect, decorPaint);
            break;
        }
      }
    }

    // Draw outline: dark pixel border like Minecraft
    // Use a thicker outline for better visibility at all scales
    final outlineWidth = (pixelW * 0.3).clamp(2.0, 4.0);
    final outlineStroke = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    for (int row = 0; row < bottle.gridHeight; row++) {
      for (int col = 0; col < bottle.gridWidth; col++) {
        final cell = bottle.grid[row][col];
        if (cell == 0) continue;

        final x = offsetX + col * pixelW;
        final y = offsetY + row * pixelH;

        // Check if this is an external edge (borders empty space)
        final topIsEmpty = row == 0 || bottle.grid[row - 1][col] == 0;
        final bottomIsEmpty = row == bottle.gridHeight - 1 || bottle.grid[row + 1][col] == 0;
        final leftIsEmpty = col == 0 || bottle.grid[row][col - 1] == 0;
        final rightIsEmpty = col == bottle.gridWidth - 1 || bottle.grid[row][col + 1] == 0;

        // Only draw outlines on TRUE external edges (where adjacent cell is 0)
        if (topIsEmpty) {
          canvas.drawRect(Rect.fromLTWH(x, y, pixelW, outlineWidth), outlineStroke);
        }
        if (bottomIsEmpty) {
          canvas.drawRect(Rect.fromLTWH(x, y + pixelH - outlineWidth, pixelW, outlineWidth), outlineStroke);
        }
        if (leftIsEmpty) {
          canvas.drawRect(Rect.fromLTWH(x, y, outlineWidth, pixelH), outlineStroke);
        }
        if (rightIsEmpty) {
          canvas.drawRect(Rect.fromLTWH(x + pixelW - outlineWidth, y, outlineWidth, pixelH), outlineStroke);
        }
      }
    }
  }

  /// Draw a single liquid pixel with the appropriate style.
  void _drawLiquidPixel(
    Canvas canvas,
    Rect rect,
    int row,
    int col,
    int liquidStartRow,
    int bodyBottomRow,
    PixelBottle bottle,
    int sheenCol,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final totalLiquidRows = bodyBottomRow - liquidStartRow + 1;
    final rowInLiquid = row - liquidStartRow;
    final t = totalLiquidRows > 1 ? rowInLiquid / (totalLiquidRows - 1) : 0.0;

    switch (liquidStyle) {
      case 'sheen':
        // Base color + drifting highlight column
        paint.color = liquidColor;
        canvas.drawRect(rect, paint);
        if (col == sheenCol || col == sheenCol + 1) {
          final sheenPaint = Paint()
            ..color = (liquidSecondaryColor ?? Colors.white).withValues(alpha: 0.4)
            ..style = PaintingStyle.fill
            ..isAntiAlias = false;
          canvas.drawRect(rect, sheenPaint);
        }
        break;

      case 'gradient':
        // Stepped gradient from primary (top) to secondary (bottom)
        final secondary = liquidSecondaryColor ?? liquidColor;
        paint.color = Color.lerp(liquidColor, secondary, t)!;
        canvas.drawRect(rect, paint);
        break;

      case 'sparkle':
        // Gradient + twinkling pixels
        final secondary = liquidSecondaryColor ?? liquidColor;
        paint.color = Color.lerp(liquidColor, secondary, t)!;
        canvas.drawRect(rect, paint);
        // Sparkle: seeded pseudo-random positions that twinkle
        final hash = (row * 7 + col * 13 + 17) % 23;
        final sparklePhase = (animationValue * 3 + hash * 0.137) % 1.0;
        if (sparklePhase < 0.15) {
          final sparklePaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.7)
            ..style = PaintingStyle.fill
            ..isAntiAlias = false;
          canvas.drawRect(rect, sparklePaint);
        }
        break;

      case 'luminous':
        // Shifting gradient + sparkles + pulse
        final secondary = liquidSecondaryColor ?? liquidColor;
        final shift = math.sin(animationValue * math.pi * 2) * 0.3 + 0.5;
        final baseColor = Color.lerp(liquidColor, secondary, t)!;
        final shiftedColor = Color.lerp(baseColor, Colors.white, shift * 0.15)!;
        paint.color = shiftedColor;
        canvas.drawRect(rect, paint);
        // Sparkle pixels
        final hash = (row * 11 + col * 7 + 3) % 19;
        final sparklePhase = (animationValue * 4 + hash * 0.11) % 1.0;
        if (sparklePhase < 0.2) {
          final sparklePaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.8)
            ..style = PaintingStyle.fill
            ..isAntiAlias = false;
          canvas.drawRect(rect, sparklePaint);
        }
        break;

      case 'flat':
      default:
        // Simple flat fill with surface/bottom variation
        if (row == liquidStartRow) {
          paint.color = Color.lerp(liquidColor, Colors.white, 0.3)!;
        } else if (row >= bodyBottomRow - 1) {
          paint.color = Color.lerp(liquidColor, Colors.black, 0.2)!;
        } else {
          paint.color = liquidColor;
        }
        canvas.drawRect(rect, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(BottlePainter oldDelegate) {
    return oldDelegate.fillPercent != fillPercent ||
        oldDelegate.liquidColor != liquidColor ||
        oldDelegate.shapeId != shapeId ||
        oldDelegate.liquidStyle != liquidStyle ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.glassColor != glassColor ||
        oldDelegate.tiltX != tiltX ||
        oldDelegate.tiltY != tiltY;
  }
}
