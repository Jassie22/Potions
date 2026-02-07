import 'package:flutter/material.dart';
import 'package:potion_focus/core/theme/app_colors.dart';

/// Square slider thumb for pixel-art aesthetic
class PixelSliderThumbShape extends SliderComponentShape {
  final double thumbSize;

  const PixelSliderThumbShape({this.thumbSize = 16});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbSize, thumbSize);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    // Main thumb square
    paint.color = sliderTheme.thumbColor ?? Colors.white;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: thumbSize, height: thumbSize),
      paint,
    );

    // Dark border (pixel-art style)
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = Colors.black87;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: thumbSize, height: thumbSize),
      paint,
    );
  }
}

/// Square slider track for pixel-art aesthetic
class PixelSliderTrackShape extends SliderTrackShape {
  const PixelSliderTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 6;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final canvas = context.canvas;
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    // Inactive track (right side)
    paint.color = sliderTheme.inactiveTrackColor ?? Colors.grey;
    canvas.drawRect(trackRect, paint);

    // Active track (left side up to thumb)
    paint.color = sliderTheme.activeTrackColor ?? Colors.blue;
    canvas.drawRect(
      Rect.fromLTRB(trackRect.left, trackRect.top, thumbCenter.dx, trackRect.bottom),
      paint,
    );

    // Border
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    paint.color = Colors.black54;
    canvas.drawRect(trackRect, paint);
  }
}

class AppTheme {
  // Local font families (bundled in assets/fonts/)
  static const String _pixelHeader = 'PressStart2P';
  static const String _pixelBody = 'Silkscreen';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _textTheme(AppColors.textLight),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          side: BorderSide(
            color: AppColors.primaryLight.withValues(alpha: 0.4),
            width: 2,
          ),
          textStyle: const TextStyle(
            fontFamily: _pixelBody,
            fontSize: 12,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        side: BorderSide(
          color: AppColors.primaryLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      segmentedButtonTheme: const SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.15),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: _pixelBody,
            fontSize: 9,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        thumbShape: const PixelSliderThumbShape(thumbSize: 16),
        trackShape: const PixelSliderTrackShape(),
        trackHeight: 6,
        thumbColor: AppColors.primaryLight,
        activeTrackColor: AppColors.primaryLight,
        inactiveTrackColor: AppColors.primaryLight.withValues(alpha: 0.2),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _textTheme(AppColors.textDark),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: AppColors.mysticalGold.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          side: BorderSide(
            color: AppColors.mysticalGold.withValues(alpha: 0.5),
            width: 2,
          ),
          textStyle: const TextStyle(
            fontFamily: _pixelBody,
            fontSize: 12,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        side: BorderSide(
          color: AppColors.mysticalGold.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      segmentedButtonTheme: const SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(
            color: AppColors.mysticalGold.withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primaryDark.withValues(alpha: 0.25),
        indicatorShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontFamily: _pixelBody,
            fontSize: 9,
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        thumbShape: const PixelSliderThumbShape(thumbSize: 16),
        trackShape: const PixelSliderTrackShape(),
        trackHeight: 6,
        thumbColor: AppColors.primaryDark,
        activeTrackColor: AppColors.primaryDark,
        inactiveTrackColor: AppColors.primaryDark.withValues(alpha: 0.2),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color textColor) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _pixelHeader,
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displayMedium: TextStyle(
        fontFamily: _pixelHeader,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontFamily: _pixelHeader,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: _pixelHeader,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: _pixelBody,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: _pixelBody,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: _pixelBody,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: _pixelBody,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: _pixelBody,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontFamily: _pixelBody,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }
}
