import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/core/utils/extensions.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/data/models/session_model.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';
import 'package:potion_focus/presentation/shared/widgets/pixel_button.dart';

class PotionDetailModal extends ConsumerWidget {
  final PotionModel potion;

  const PotionDetailModal({
    super.key,
    required this.potion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rarityColor = AppColors.getRarityColor(potion.rarity);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.zero),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Potion visual (larger)
              Center(
                child: PotionRenderer(
                  config: VisualConfig.fromJson(potion.visualConfig),
                  size: 150,
                ),
              ),
              const SizedBox(height: 24),

              // Rarity title
              Text(
                '${potion.rarity[0].toUpperCase()}${potion.rarity.substring(1)} Potion',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: rarityColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Stats card (pixel-art styled container)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Colors.black54, width: 2),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      context,
                      'Essence Earned',
                      '${potion.essenceEarned}',
                      Icons.auto_awesome,
                    ),
                    Container(height: 2, color: Colors.black26, margin: const EdgeInsets.symmetric(vertical: 8)),
                    _buildStatRow(
                      context,
                      'Brewed On',
                      potion.createdAt.toFormattedDateTime(),
                      Icons.access_time,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Session details
              FutureBuilder<SessionModel?>(
                future: _getSession(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  final session = snapshot.data!;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(color: Colors.black54, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Session Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        _buildStatRow(
                          context,
                          'Duration',
                          '${session.durationMinutes} minutes',
                          Icons.timer,
                        ),
                        if (session.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: session.tags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: rarityColor.withOpacity(0.1),
                                        border: Border.all(color: rarityColor.withOpacity(0.4), width: 2),
                                      ),
                                      child: Text(
                                        '#$tag',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: rarityColor,
                                            ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Lore/flavor text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border.all(color: Colors.black54, width: 2),
                ),
                child: Text(
                  _getLoreText(potion.rarity),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Close button (pixel-art styled)
              PixelButton(
                text: 'Close',
                onPressed: () => Navigator.pop(context),
                color: rarityColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Future<SessionModel?> _getSession() async {
    final db = DatabaseHelper.instance;
    final allSessions = await db.sessionModels.getAllItems();
    return allSessions.where((s) => s.sessionId == potion.sessionId).firstOrNull;
  }

  String _getLoreText(String rarity) {
    switch (rarity) {
      case 'legendary':
        return 'A brew of extraordinary power, crafted through unwavering focus and dedication. Few achieve this mastery.';
      case 'epic':
        return 'An exceptional potion that glimmers with potential. Your focus has created something truly special.';
      case 'rare':
        return 'A beautiful creation that speaks to consistent effort. This potion holds meaningful power.';
      case 'uncommon':
        return 'A solid brew that reflects growing skill. Each potion teaches you something new.';
      case 'muddy':
        return 'Even incomplete attempts become part of your story. This muddy brew is proof you tried.';
      default:
        return 'Every potion is a memory of time you chose to focus. This one is no exception.';
    }
  }
}
