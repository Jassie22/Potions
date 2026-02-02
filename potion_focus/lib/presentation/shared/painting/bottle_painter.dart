import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'bottle_shapes.dart';

/// Paints a bottle with liquid fill, glass outline, cork, and highlight.
///
/// [shapeId] selects which bottle shape to draw.
/// [fillPercent] drives the liquid level (0.0 = empty, 1.0 = full).
/// [liquidColor] is the color of the liquid inside.
/// [glassColor] tints the glass outline.
class BottlePainter extends CustomPainter {
  final String shapeId;
  final double fillPercent;
  final Color liquidColor;
  final Color glassColor;

  BottlePainter({
    required this.shapeId,
    required this.fillPercent,
    required this.liquidColor,
    this.glassColor = const Color(0x88FFFFFF),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paths = BottleShapes.getPaths(shapeId, size);

    _drawGlassBody(canvas, size, paths);
    _drawLiquid(canvas, size, paths);
    _drawNeck(canvas, size, paths);
    _drawCork(canvas, size, paths);
    _drawGlassOutline(canvas, size, paths);
    _drawHighlight(canvas, size, paths);
  }

  void _drawGlassBody(Canvas canvas, Size size, BottlePaths paths) {
    final paint = Paint()
      ..color = glassColor.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(paths.body, paint);
  }

  void _drawLiquid(Canvas canvas, Size size, BottlePaths paths) {
    if (fillPercent <= 0) return;

    // Get the bounding box of the body to know where liquid should fill from.
    final bodyBounds = paths.body.getBounds();
    final liquidHeight = bodyBounds.height * fillPercent.clamp(0.0, 1.0);
    final liquidTop = bodyBounds.bottom - liquidHeight;

    // Clip to the body shape and fill from the bottom up.
    canvas.save();
    canvas.clipPath(paths.body);

    // Liquid gradient (darker at bottom, lighter at top surface)
    final liquidPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(bodyBounds.center.dx, liquidTop),
        Offset(bodyBounds.center.dx, bodyBounds.bottom),
        [
          liquidColor.withOpacity(0.7),
          liquidColor,
        ],
      );

    canvas.drawRect(
      Rect.fromLTRB(bodyBounds.left, liquidTop, bodyBounds.right, bodyBounds.bottom),
      liquidPaint,
    );

    // Liquid surface line (subtle highlight at top of liquid)
    if (fillPercent < 0.98) {
      final surfacePaint = Paint()
        ..color = liquidColor.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTRB(
          bodyBounds.left,
          liquidTop,
          bodyBounds.right,
          liquidTop + 2,
        ),
        surfacePaint,
      );
    }

    // Also fill the neck if liquid is high enough
    if (fillPercent > 0.85) {
      final neckFillPercent = ((fillPercent - 0.85) / 0.15).clamp(0.0, 1.0);
      final neckHeight = paths.neckRect.height * neckFillPercent;
      final neckLiquidTop = paths.neckRect.bottom - neckHeight;

      // We're still clipped to body, so unclip first
      canvas.restore();
      canvas.save();

      final neckPaint = Paint()..color = liquidColor.withOpacity(0.8);
      canvas.drawRect(
        Rect.fromLTRB(
          paths.neckRect.left,
          neckLiquidTop,
          paths.neckRect.right,
          paths.neckRect.bottom,
        ),
        neckPaint,
      );
    }

    canvas.restore();
  }

  void _drawNeck(Canvas canvas, Size size, BottlePaths paths) {
    // Glass neck
    final neckPaint = Paint()
      ..color = glassColor.withOpacity(0.06)
      ..style = PaintingStyle.fill;
    canvas.drawRect(paths.neckRect, neckPaint);

    // Neck outline
    final neckStroke = Paint()
      ..color = glassColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(
      paths.neckRect.topLeft,
      paths.neckRect.bottomLeft,
      neckStroke,
    );
    canvas.drawLine(
      paths.neckRect.topRight,
      paths.neckRect.bottomRight,
      neckStroke,
    );
  }

  void _drawCork(Canvas canvas, Size size, BottlePaths paths) {
    if (paths.customCork != null) {
      // Custom cork shape (e.g., crown for legendary)
      final corkFill = Paint()
        ..color = const Color(0xFFB8860B)
        ..style = PaintingStyle.fill;
      canvas.drawPath(paths.customCork!, corkFill);

      final corkStroke = Paint()
        ..color = const Color(0xFFDAA520)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawPath(paths.customCork!, corkStroke);
    } else {
      // Standard cork
      final corkPaint = Paint()
        ..color = const Color(0xFFC49A6C)
        ..style = PaintingStyle.fill;
      final corkRect = RRect.fromRectAndRadius(
        paths.corkRect,
        const Radius.circular(3),
      );
      canvas.drawRRect(corkRect, corkPaint);

      // Cork texture lines
      final texturePaint = Paint()
        ..color = const Color(0xFFAA8050)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      final corkH = paths.corkRect.height;
      for (var i = 0.3; i < 0.8; i += 0.2) {
        final y = paths.corkRect.top + corkH * i;
        canvas.drawLine(
          Offset(paths.corkRect.left + 3, y),
          Offset(paths.corkRect.right - 3, y),
          texturePaint,
        );
      }
    }
  }

  void _drawGlassOutline(Canvas canvas, Size size, BottlePaths paths) {
    final outlinePaint = Paint()
      ..color = glassColor.withOpacity(0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(paths.body, outlinePaint);
  }

  void _drawHighlight(Canvas canvas, Size size, BottlePaths paths) {
    // Glass reflection: a thin white arc on the left side of the body.
    final bodyBounds = paths.body.getBounds();
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final highlightPath = Path();
    final hx = bodyBounds.left + bodyBounds.width * 0.22;
    final hy1 = bodyBounds.top + bodyBounds.height * 0.25;
    final hy2 = bodyBounds.top + bodyBounds.height * 0.65;
    highlightPath.moveTo(hx, hy1);
    highlightPath.quadraticBezierTo(
      hx - bodyBounds.width * 0.05,
      (hy1 + hy2) / 2,
      hx,
      hy2,
    );
    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(BottlePainter oldDelegate) {
    return oldDelegate.fillPercent != fillPercent ||
        oldDelegate.liquidColor != liquidColor ||
        oldDelegate.shapeId != shapeId ||
        oldDelegate.glassColor != glassColor;
  }
}
