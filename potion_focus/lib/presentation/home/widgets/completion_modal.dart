import 'package:flutter/material.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';

/// Shown after a focus session completes. Reveals the brewed potion
/// with rarity, essence earned, and lore text.
class CompletionModal extends StatefulWidget {
  final PotionModel potion;
  final VoidCallback onDismiss;

  const CompletionModal({
    super.key,
    required this.potion,
    required this.onDismiss,
  });

  @override
  State<CompletionModal> createState() => _CompletionModalState();
}

class _CompletionModalState extends State<CompletionModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<double> _rarityFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _scaleIn = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut)),
    );

    _rarityFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8, curve: Curves.easeIn)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = VisualConfig.fromJson(widget.potion.visualConfig);
    final rarityColor = AppColors.getRarityColor(widget.potion.rarity);
    final rarityName = widget.potion.rarity[0].toUpperCase() + widget.potion.rarity.substring(1);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(_fadeIn.value * 0.6),
          child: SafeArea(
            child: Center(
              child: Opacity(
                opacity: _fadeIn.value,
                child: Transform.scale(
                  scale: _scaleIn.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(
                          color: rarityColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Potion Brewed!',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 24),

                            // Potion illustration
                            PotionRenderer(
                              config: config,
                              size: 160,
                              fillPercent: 1.0,
                            ),
                            const SizedBox(height: 20),

                            // Rarity reveal
                            Opacity(
                              opacity: _rarityFade.value,
                              child: Column(
                                children: [
                                  Text(
                                    '$rarityName Potion',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: rarityColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Essence earned
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        '+${widget.potion.essenceEarned} Essence',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Colors.amber[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Lore text
                                  Text(
                                    _getLoreText(widget.potion.rarity),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey[600],
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Dismiss button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: widget.onDismiss,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: rarityColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Collect Potion'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getLoreText(String rarity) {
    switch (rarity) {
      case 'legendary':
        return 'A brew of extraordinary power, crafted through unwavering focus and dedication.';
      case 'epic':
        return 'An exceptional potion that glimmers with potential. Truly special.';
      case 'rare':
        return 'A beautiful creation that speaks to consistent effort.';
      case 'uncommon':
        return 'A solid brew that reflects growing skill.';
      case 'muddy':
        return 'Even incomplete attempts become part of your story.';
      default:
        return 'Every potion is a memory of time you chose to focus.';
    }
  }
}
