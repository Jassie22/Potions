import 'package:flutter/material.dart';

/// Utility class for creating pixel-art style stepped gradients.
/// Instead of smooth transitions, these gradients use distinct color bands.
class PixelGradients {
  /// Creates a stepped gradient with distinct color bands (no smooth blending).
  /// [baseColor] is the primary color.
  /// [bands] is the number of distinct color bands (default 3).
  /// [startOpacity] and [endOpacity] define the opacity range.
  static LinearGradient stepped({
    required Color baseColor,
    int bands = 3,
    double startOpacity = 0.15,
    double endOpacity = 0.03,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    final colors = <Color>[];
    final stops = <double>[];

    final opacityStep = (startOpacity - endOpacity) / bands;

    for (int i = 0; i < bands; i++) {
      final opacity = startOpacity - (opacityStep * i);
      colors.add(baseColor.withValues(alpha: opacity));
      // Each color appears twice to create hard edges
      if (i > 0) {
        colors.add(baseColor.withValues(alpha: opacity));
      }

      final stop = i / bands;
      if (i > 0) {
        stops.add(stop);
      }
      stops.add(stop);
    }

    // Add final color
    colors.add(baseColor.withValues(alpha: endOpacity));
    stops.add(1.0);

    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
      stops: stops,
    );
  }

  /// Creates a simple two-band stepped gradient (common use case).
  static LinearGradient twoBand({
    required Color baseColor,
    double topOpacity = 0.12,
    double bottomOpacity = 0.04,
    Alignment begin = Alignment.topCenter,
    Alignment end = Alignment.bottomCenter,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [
        baseColor.withValues(alpha: topOpacity),
        baseColor.withValues(alpha: topOpacity),
        baseColor.withValues(alpha: bottomOpacity),
        baseColor.withValues(alpha: bottomOpacity),
      ],
      stops: const [0.0, 0.5, 0.5, 1.0],
    );
  }

  /// Creates a horizontal stepped gradient with 3 bands.
  static LinearGradient horizontal({
    required Color baseColor,
    double startOpacity = 0.15,
    double midOpacity = 0.08,
    double endOpacity = 0.03,
  }) {
    return LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        baseColor.withValues(alpha: startOpacity),
        baseColor.withValues(alpha: startOpacity),
        baseColor.withValues(alpha: midOpacity),
        baseColor.withValues(alpha: midOpacity),
        baseColor.withValues(alpha: endOpacity),
        baseColor.withValues(alpha: endOpacity),
      ],
      stops: const [0.0, 0.33, 0.33, 0.66, 0.66, 1.0],
    );
  }

  /// Creates a radial stepped gradient (for card highlights).
  static RadialGradient radialStepped({
    required Color baseColor,
    double centerOpacity = 0.15,
    double edgeOpacity = 0.03,
    int bands = 3,
    Alignment center = Alignment.center,
    double radius = 0.8,
  }) {
    final colors = <Color>[];
    final stops = <double>[];
    final opacityStep = (centerOpacity - edgeOpacity) / bands;

    for (int i = 0; i < bands; i++) {
      final opacity = centerOpacity - (opacityStep * i);
      colors.add(baseColor.withValues(alpha: opacity));
      if (i > 0) {
        colors.add(baseColor.withValues(alpha: opacity));
      }

      final stop = i / bands;
      if (i > 0) {
        stops.add(stop);
      }
      stops.add(stop);
    }

    colors.add(baseColor.withValues(alpha: edgeOpacity));
    stops.add(1.0);

    return RadialGradient(
      center: center,
      radius: radius,
      colors: colors,
      stops: stops,
    );
  }
}
