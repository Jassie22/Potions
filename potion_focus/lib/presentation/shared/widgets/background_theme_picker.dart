import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/presentation/shared/painting/background_themes.dart';
import 'package:potion_focus/services/theme_service.dart';

/// Shows a modal bottom sheet with a grid of available background themes.
/// Shared between the home screen quick-access button and settings screen.
Future<void> showBackgroundThemePicker(BuildContext context, WidgetRef ref) async {
  final themeService = ref.read(themeServiceProvider);
  final available = await themeService.getAvailableThemes();
  final currentTheme = await themeService.getActiveThemeId();

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.zero),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.7,
        expand: false,
        builder: (context, scrollController) {
          final availableInfos = allThemeInfos
              .where((t) => available.contains(t.id))
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Background Theme',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: availableInfos.length,
                  itemBuilder: (context, index) {
                    final info = availableInfos[index];
                    final isSelected = info.id == currentTheme;
                    return GestureDetector(
                      onTap: () async {
                        await themeService.setActiveTheme(info.id);
                        ref.invalidate(activeThemeProvider);
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.zero,
                          border: isSelected
                              ? Border.all(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  width: 2,
                                )
                              : null,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: BackgroundThemePainter(
                                  themeId: info.id,
                                  animationValue: 0.3,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                  horizontal: 8,
                                ),
                                color: Colors.black54,
                                child: Text(
                                  info.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
