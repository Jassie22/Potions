import 'package:flutter/material.dart';
import 'package:potion_focus/presentation/shared/widgets/pixel_loading.dart';

/// Primary filled pixel-styled button with solid black border.
/// Uses darken effect on press instead of Material ripple.
class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final double? width;
  final EdgeInsets? padding;
  final bool isLoading;

  const PixelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.width,
    this.padding,
    this.isLoading = false,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final baseColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final textColor = widget.textColor ?? Colors.white;

    // Calculate pressed color (darken by 15%)
    final pressedColor = Color.lerp(baseColor, Colors.black, 0.15)!;
    final displayColor = _isPressed && !isDisabled ? pressedColor : baseColor;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isDisabled ? 0.4 : 1.0,
        // Press depth effect: translate down + slight scale reduction
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isPressed && !isDisabled ? 2.0 : 0.0)
            ..scale(_isPressed && !isDisabled ? 0.98 : 1.0),
          transformAlignment: Alignment.center,
          width: widget.width,
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: displayColor,
            border: Border.all(color: Colors.black87, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            mainAxisSize: widget.width != null ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                PixelSpinner(size: 16, color: textColor),
              ] else ...[
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: textColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Secondary outlined pixel-styled button with colored border.
/// Uses darken effect on press instead of Material ripple.
class PixelButtonOutlined extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? borderColor;
  final double? width;
  final EdgeInsets? padding;
  final bool isLoading;

  const PixelButtonOutlined({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.borderColor,
    this.width,
    this.padding,
    this.isLoading = false,
  });

  @override
  State<PixelButtonOutlined> createState() => _PixelButtonOutlinedState();
}

class _PixelButtonOutlinedState extends State<PixelButtonOutlined> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final borderColor = widget.borderColor ?? Theme.of(context).colorScheme.primary;

    // Pressed state shows a subtle fill
    final fillColor = _isPressed && !isDisabled
        ? borderColor.withValues(alpha: 0.1)
        : Colors.transparent;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isDisabled ? 0.4 : 1.0,
        // Press depth effect: translate down + slight scale reduction
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isPressed && !isDisabled ? 2.0 : 0.0)
            ..scale(_isPressed && !isDisabled ? 0.98 : 1.0),
          transformAlignment: Alignment.center,
          width: widget.width,
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: fillColor,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            mainAxisSize: widget.width != null ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading) ...[
                PixelSpinner(size: 16, color: borderColor),
              ] else ...[
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: borderColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: borderColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A small icon-only pixel button for compact actions.
class PixelIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? iconColor;
  final double size;
  final String? tooltip;

  const PixelIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.iconColor,
    this.size = 40,
    this.tooltip,
  });

  @override
  State<PixelIconButton> createState() => _PixelIconButtonState();
}

class _PixelIconButtonState extends State<PixelIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null;
    final baseColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final iconColor = widget.iconColor ?? Colors.white;

    final pressedColor = Color.lerp(baseColor, Colors.black, 0.15)!;
    final displayColor = _isPressed && !isDisabled ? pressedColor : baseColor;

    Widget button = GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isDisabled ? 0.4 : 1.0,
        // Press depth effect: translate down + slight scale reduction
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()
            ..translate(0.0, _isPressed && !isDisabled ? 2.0 : 0.0)
            ..scale(_isPressed && !isDisabled ? 0.98 : 1.0),
          transformAlignment: Alignment.center,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: displayColor,
            border: Border.all(color: Colors.black87, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: iconColor,
              size: widget.size * 0.5,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
