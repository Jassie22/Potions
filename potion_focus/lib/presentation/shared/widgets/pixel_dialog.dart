import 'package:flutter/material.dart';
import 'pixel_button.dart';

/// Shows a pixel-styled dialog with scale + fade animation.
/// Features: 3px black outer border, 2px theme color inner border.
Future<T?> showPixelDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool barrierDismissible = true,
  Color? accentColor,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: PixelDialogContainer(
          accentColor: accentColor ?? Theme.of(context).colorScheme.primary,
          child: builder(context),
        ),
      );
    },
  );
}

/// A pixel-styled confirmation dialog with title, content, and action buttons.
Future<bool?> showPixelConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  Color? confirmColor,
  bool isDangerous = false,
}) {
  final effectiveConfirmColor = confirmColor ??
      (isDangerous ? const Color(0xFFFF3333) : Theme.of(context).colorScheme.primary);

  return showPixelDialog<bool>(
    context: context,
    accentColor: isDangerous ? const Color(0xFFFF3333) : null,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Message
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Buttons
        Row(
          children: [
            Expanded(
              child: PixelButtonOutlined(
                text: cancelText,
                borderColor: Colors.grey,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PixelButton(
                text: confirmText,
                color: effectiveConfirmColor,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

/// A pixel-styled alert dialog with title, content, and single dismiss button.
Future<void> showPixelAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = 'OK',
  Color? accentColor,
}) {
  return showPixelDialog(
    context: context,
    accentColor: accentColor,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        // Message
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Button
        PixelButton(
          text: buttonText,
          color: accentColor ?? Theme.of(context).colorScheme.primary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

/// The container widget for pixel dialogs.
/// Features a double border: 3px black outer + 2px accent inner.
class PixelDialogContainer extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final double maxWidth;

  const PixelDialogContainer({
    super.key,
    required this.child,
    required this.accentColor,
    this.maxWidth = 320,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          // Outer border (black)
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.zero,
        ),
        child: Container(
          decoration: BoxDecoration(
            // Inner border (accent color)
            border: Border.all(color: accentColor, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          padding: const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}

/// A pixel-styled dialog with a custom content widget.
class PixelDialog extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<Widget>? actions;
  final Color? accentColor;

  const PixelDialog({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
        content,
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions!
                .map((action) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: action,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }
}
