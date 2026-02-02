import 'dart:ui';

/// Generates Path objects for 8 distinct bottle shapes.
/// All paths are drawn within the given [size] bounding box.
/// Each method returns two paths:
///   - bodyPath: the interior (used for liquid clipping)
///   - outlinePath: the full outline including neck/stopper
class BottleShapes {
  BottleShapes._();

  /// Select the correct shape by its string ID.
  static BottlePaths getPaths(String shapeId, Size size) {
    switch (shapeId) {
      case 'bottle_tall':
        return tall(size);
      case 'bottle_flask':
        return flask(size);
      case 'bottle_potion':
        return potion(size);
      case 'bottle_heart':
        return heart(size);
      case 'bottle_diamond':
        return diamond(size);
      case 'bottle_gourd':
        return gourd(size);
      case 'bottle_legendary':
        return legendary(size);
      case 'bottle_round':
      default:
        return round(size);
    }
  }

  /// 1. Round Flask -- classic round-bottom, short neck.
  static BottlePaths round(Size size) {
    final w = size.width;
    final h = size.height;

    // Body: wide circle in bottom 70%
    final bodyPath = Path();
    final bodyCenter = Offset(w * 0.5, h * 0.6);
    final bodyRadius = w * 0.38;
    bodyPath.addOval(Rect.fromCircle(center: bodyCenter, radius: bodyRadius));

    // Neck
    final neckLeft = w * 0.4;
    final neckRight = w * 0.6;
    final neckTop = h * 0.12;
    final neckBottom = bodyCenter.dy - bodyRadius + bodyRadius * 0.3;

    // Full outline: neck + body
    final outline = Path();
    // Cork area
    final corkTop = h * 0.02;
    final corkLeft = w * 0.36;
    final corkRight = w * 0.64;
    outline.addRRect(RRect.fromLTRBR(
      corkLeft, corkTop, corkRight, neckTop + 2,
      const Radius.circular(3),
    ));
    // Neck
    outline.addRect(Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom));
    // Body
    outline.addOval(Rect.fromCircle(center: bodyCenter, radius: bodyRadius));

    return BottlePaths(
      body: bodyPath,
      outline: outline,
      neckRect: Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom),
      corkRect: Rect.fromLTRB(corkLeft, corkTop, corkRight, neckTop + 2),
    );
  }

  /// 2. Tall Vial -- narrow, tall test-tube style.
  static BottlePaths tall(Size size) {
    final w = size.width;
    final h = size.height;

    final bodyLeft = w * 0.3;
    final bodyRight = w * 0.7;
    final bodyTop = h * 0.2;
    final bodyBottom = h * 0.95;
    final cornerRadius = w * 0.12;

    final bodyPath = Path();
    bodyPath.addRRect(RRect.fromLTRBR(
      bodyLeft, bodyTop, bodyRight, bodyBottom,
      Radius.circular(cornerRadius),
    ));

    final neckLeft = w * 0.38;
    final neckRight = w * 0.62;
    final neckTop = h * 0.1;

    final corkLeft = w * 0.34;
    final corkRight = w * 0.66;
    final corkTop = h * 0.02;

    final outline = Path();
    outline.addRRect(RRect.fromLTRBR(
      corkLeft, corkTop, corkRight, neckTop + 2,
      const Radius.circular(3),
    ));
    outline.addRect(Rect.fromLTRB(neckLeft, neckTop, neckRight, bodyTop));
    outline.addRRect(RRect.fromLTRBR(
      bodyLeft, bodyTop, bodyRight, bodyBottom,
      Radius.circular(cornerRadius),
    ));

    return BottlePaths(
      body: bodyPath,
      outline: outline,
      neckRect: Rect.fromLTRB(neckLeft, neckTop, neckRight, bodyTop),
      corkRect: Rect.fromLTRB(corkLeft, corkTop, corkRight, neckTop + 2),
    );
  }

  /// 3. Erlenmeyer Flask -- wide base, tapered to narrow neck.
  static BottlePaths flask(Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPath = Path();
    bodyPath.moveTo(w * 0.42, h * 0.25);
    bodyPath.lineTo(w * 0.12, h * 0.9);
    bodyPath.quadraticBezierTo(w * 0.1, h * 0.98, w * 0.2, h * 0.98);
    bodyPath.lineTo(w * 0.8, h * 0.98);
    bodyPath.quadraticBezierTo(w * 0.9, h * 0.98, w * 0.88, h * 0.9);
    bodyPath.lineTo(w * 0.58, h * 0.25);
    bodyPath.close();

    final neckLeft = w * 0.42;
    final neckRight = w * 0.58;
    final neckTop = h * 0.12;
    final neckBottom = h * 0.25;

    final corkLeft = w * 0.38;
    final corkRight = w * 0.62;
    final corkTop = h * 0.02;

    final outline = Path();
    outline.addRRect(RRect.fromLTRBR(
      corkLeft, corkTop, corkRight, neckTop + 2,
      const Radius.circular(3),
    ));
    outline.addRect(Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom));
    outline.addPath(bodyPath, Offset.zero);

    return BottlePaths(
      body: bodyPath,
      outline: outline,
      neckRect: Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom),
      corkRect: Rect.fromLTRB(corkLeft, corkTop, corkRight, neckTop + 2),
    );
  }

  /// 4. Classic Potion -- bulbous body, thin neck, wide lip.
  static BottlePaths potion(Size size) {
    final w = size.width;
    final h = size.height;

    // Bulbous body
    final bodyPath = Path();
    final cx = w * 0.5;
    final cy = h * 0.65;
    final rx = w * 0.4;
    final ry = h * 0.3;
    bodyPath.addOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2));

    final neckLeft = w * 0.4;
    final neckRight = w * 0.6;
    final neckTop = h * 0.15;
    final neckBottom = cy - ry + ry * 0.25;

    // Wide lip
    final lipLeft = w * 0.32;
    final lipRight = w * 0.68;
    final lipTop = h * 0.12;

    final corkLeft = w * 0.36;
    final corkRight = w * 0.64;
    final corkTop = h * 0.02;

    final outline = Path();
    outline.addRRect(RRect.fromLTRBR(
      corkLeft, corkTop, corkRight, lipTop + 2,
      const Radius.circular(3),
    ));
    // Lip
    outline.addRRect(RRect.fromLTRBR(
      lipLeft, lipTop, lipRight, neckTop,
      const Radius.circular(2),
    ));
    outline.addRect(Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom));
    outline.addOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2));

    return BottlePaths(
      body: bodyPath,
      outline: outline,
      neckRect: Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom),
      corkRect: Rect.fromLTRB(corkLeft, corkTop, corkRight, lipTop + 2),
    );
  }

  /// 5. Heart Vial -- heart-shaped body.
  static BottlePaths heart(Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPath = Path();
    final topY = h * 0.35;
    final bottomY = h * 0.92;
    final cx = w * 0.5;

    bodyPath.moveTo(cx, bottomY);
    // Left curve
    bodyPath.cubicTo(
      w * 0.0, h * 0.65,
      w * 0.05, topY,
      cx, h * 0.45,
    );
    // Right curve
    bodyPath.cubicTo(
      w * 0.95, topY,
      w * 1.0, h * 0.65,
      cx, bottomY,
    );
    bodyPath.close();

    final neckLeft = w * 0.42;
    final neckRight = w * 0.58;
    final neckTop = h * 0.15;
    final neckBottom = h * 0.35;

    final corkLeft = w * 0.38;
    final corkRight = w * 0.62;
    final corkTop = h * 0.04;

    final outline = Path();
    outline.addRRect(RRect.fromLTRBR(
      corkLeft, corkTop, corkRight, neckTop + 2,
      const Radius.circular(3),
    ));
    outline.addRect(Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom));
    outline.addPath(bodyPath, Offset.zero);

    return BottlePaths(
      body: bodyPath,
      outline: outline,
      neckRect: Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom),
      corkRect: Rect.fromLTRB(corkLeft, corkTop, corkRight, neckTop + 2),
    );
  }

  /// 6. Diamond Flask -- angular diamond body.
  static BottlePaths diamond(Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPath = Path();
    final cx = w * 0.5;
    final cy = h * 0.6;
    final halfW = w * 0.4;
    final halfH = h * 0.32;

    bodyPath.moveTo(cx, cy - halfH); // top
    bodyPath.lineTo(cx + halfW, cy); // right
    bodyPath.lineTo(cx, cy + halfH); // bottom
    bodyPath.lineTo(cx - halfW, cy); // left
    bodyPath.close();

    final neckLeft = w * 0.42;
    final neckRight = w * 0.58;
    final neckTop = h * 0.1;
    final neckBottom = cy - halfH;

    final corkLeft = w * 0.38;
    final corkRight = w * 0.62;
    final corkTop = h * 0.02;

    final outline = Path();
    outline.addRRect(RRect.fromLTRBR(
      corkLeft, corkTop, corkRight, neckTop + 2,
      const Radius.circular(3),
    ));
    outline.addRect(Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom));
    outline.addPath(bodyPath, Offset.zero);

    return BottlePaths(
      body: bodyPath,
      outline: outline,
      neckRect: Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom),
      corkRect: Rect.fromLTRB(corkLeft, corkTop, corkRight, neckTop + 2),
    );
  }

  /// 7. Gourd -- double-bubble shape.
  static BottlePaths gourd(Size size) {
    final w = size.width;
    final h = size.height;

    // Lower large bubble
    final lowerCenter = Offset(w * 0.5, h * 0.72);
    final lowerRadius = w * 0.38;

    // Upper small bubble
    final upperCenter = Offset(w * 0.5, h * 0.4);
    final upperRadius = w * 0.24;

    final bodyPath = Path();
    bodyPath.addOval(Rect.fromCircle(center: lowerCenter, radius: lowerRadius));
    bodyPath.addOval(Rect.fromCircle(center: upperCenter, radius: upperRadius));

    final neckLeft = w * 0.42;
    final neckRight = w * 0.58;
    final neckTop = h * 0.1;
    final neckBottom = upperCenter.dy - upperRadius + upperRadius * 0.3;

    final corkLeft = w * 0.38;
    final corkRight = w * 0.62;
    final corkTop = h * 0.02;

    final outline = Path();
    outline.addRRect(RRect.fromLTRBR(
      corkLeft, corkTop, corkRight, neckTop + 2,
      const Radius.circular(3),
    ));
    outline.addRect(Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom));
    outline.addOval(Rect.fromCircle(center: upperCenter, radius: upperRadius));
    outline.addOval(Rect.fromCircle(center: lowerCenter, radius: lowerRadius));

    return BottlePaths(
      body: bodyPath,
      outline: outline,
      neckRect: Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom),
      corkRect: Rect.fromLTRB(corkLeft, corkTop, corkRight, neckTop + 2),
    );
  }

  /// 8. Ornate/Legendary -- decorative with flared base and crown stopper.
  static BottlePaths legendary(Size size) {
    final w = size.width;
    final h = size.height;

    // Main body: rounded rectangle with flared base
    final bodyPath = Path();
    bodyPath.moveTo(w * 0.35, h * 0.3);
    // Left side curves in then flares
    bodyPath.quadraticBezierTo(w * 0.2, h * 0.5, w * 0.15, h * 0.75);
    bodyPath.quadraticBezierTo(w * 0.12, h * 0.9, w * 0.25, h * 0.95);
    // Bottom
    bodyPath.lineTo(w * 0.75, h * 0.95);
    // Right side
    bodyPath.quadraticBezierTo(w * 0.88, h * 0.9, w * 0.85, h * 0.75);
    bodyPath.quadraticBezierTo(w * 0.8, h * 0.5, w * 0.65, h * 0.3);
    bodyPath.close();

    final neckLeft = w * 0.38;
    final neckRight = w * 0.62;
    final neckTop = h * 0.15;
    final neckBottom = h * 0.3;

    // Crown stopper (decorative)
    final corkLeft = w * 0.3;
    final corkRight = w * 0.7;
    final corkTop = h * 0.0;

    final crownPath = Path();
    crownPath.moveTo(corkLeft, neckTop);
    crownPath.lineTo(corkLeft, corkTop + h * 0.06);
    crownPath.lineTo(w * 0.38, corkTop);
    crownPath.lineTo(w * 0.5, corkTop + h * 0.05);
    crownPath.lineTo(w * 0.62, corkTop);
    crownPath.lineTo(corkRight, corkTop + h * 0.06);
    crownPath.lineTo(corkRight, neckTop);
    crownPath.close();

    final outline = Path();
    outline.addPath(crownPath, Offset.zero);
    outline.addRect(Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom));
    outline.addPath(bodyPath, Offset.zero);

    return BottlePaths(
      body: bodyPath,
      outline: outline,
      neckRect: Rect.fromLTRB(neckLeft, neckTop, neckRight, neckBottom),
      corkRect: Rect.fromLTRB(corkLeft, corkTop, corkRight, neckTop),
      customCork: crownPath,
    );
  }
}

/// Holds the paths needed to render a bottle.
class BottlePaths {
  /// The interior body shape (used for liquid clipping).
  final Path body;

  /// The full outline of the bottle including neck and cork.
  final Path outline;

  /// The neck rectangle connecting cork to body.
  final Rect neckRect;

  /// The cork/stopper rectangle (or bounding box for custom cork).
  final Rect corkRect;

  /// Optional custom cork path (e.g., crown for legendary).
  final Path? customCork;

  const BottlePaths({
    required this.body,
    required this.outline,
    required this.neckRect,
    required this.corkRect,
    this.customCork,
  });
}
