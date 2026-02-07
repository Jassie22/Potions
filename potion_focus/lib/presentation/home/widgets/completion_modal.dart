import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/models/visual_config.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/data/models/potion_model.dart';
import 'package:potion_focus/presentation/shared/painting/potion_renderer.dart';
import 'package:potion_focus/presentation/shared/widgets/upgrade_prompt_modal.dart';
import 'package:potion_focus/services/feedback_service.dart';
import 'package:potion_focus/services/upgrade_prompt_service.dart';

/// Shown after a focus session completes. Reveals the brewed potion
/// with rarity, essence earned, and lore text.
class CompletionModal extends ConsumerStatefulWidget {
  final PotionModel potion;
  final VoidCallback onDismiss;

  const CompletionModal({
    super.key,
    required this.potion,
    required this.onDismiss,
  });

  @override
  ConsumerState<CompletionModal> createState() => _CompletionModalState();
}

class _CompletionModalState extends ConsumerState<CompletionModal>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _particleController;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late Animation<double> _rarityFade;

  // Celebration particles
  final List<_CelebrationParticle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
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

    // Generate celebration particles
    _generateParticles();

    _controller.forward();
    _particleController.forward();

    // Play success feedback when modal appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedbackServiceProvider).feedback(
            sound: SoundType.sessionComplete,
            haptic: HapticType.success,
          );
    });
  }

  void _generateParticles() {
    final rarityColor = AppColors.getRarityColor(widget.potion.rarity);

    // Create burst particles
    for (int i = 0; i < 20; i++) {
      _particles.add(_CelebrationParticle(
        angle: _random.nextDouble() * math.pi * 2,
        speed: 50 + _random.nextDouble() * 100,
        size: 3 + _random.nextDouble() * 5,
        color: i % 3 == 0
            ? AppColors.mysticalGold
            : i % 3 == 1
                ? rarityColor
                : Colors.white,
        delay: _random.nextDouble() * 0.2,
      ));
    }

    // Create rising essence particles
    for (int i = 0; i < 8; i++) {
      _particles.add(_CelebrationParticle(
        angle: -math.pi / 2 + (_random.nextDouble() - 0.5) * 0.5,
        speed: 30 + _random.nextDouble() * 40,
        size: 4 + _random.nextDouble() * 4,
        color: AppColors.mysticalGold.withValues(alpha: 0.8),
        delay: 0.3 + _random.nextDouble() * 0.3,
        isEssence: true,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _particleController.dispose();
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
          color: Colors.black.withValues(alpha: _fadeIn.value * 0.6),
          child: SafeArea(
            child: Center(
              child: Opacity(
                opacity: _fadeIn.value,
                child: Transform.scale(
                  scale: _scaleIn.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(
                          color: rarityColor.withValues(alpha: 0.5),
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

                            // Potion illustration with celebration particles
                            SizedBox(
                              width: 200,
                              height: 200,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Celebration particles behind the potion
                                  AnimatedBuilder(
                                    animation: _particleController,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: const Size(200, 200),
                                        painter: _CelebrationPainter(
                                          particles: _particles,
                                          progress: _particleController.value,
                                        ),
                                      );
                                    },
                                  ),
                                  // The potion
                                  PotionRenderer(
                                    config: config,
                                    size: 160,
                                    fillPercent: 1.0,
                                  ),
                                ],
                              ),
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
                                      const Icon(Icons.auto_awesome, color: AppColors.mysticalGold, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        '+${widget.potion.essenceEarned} Essence',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: AppColors.mysticalAmber,
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
                                          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
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
                                onPressed: () => _handleDismiss(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: rarityColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
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

  Future<void> _handleDismiss(BuildContext context) async {
    ref.read(feedbackServiceProvider).haptic(HapticType.light);

    // Check if we should show the upgrade prompt (every 3rd session for non-subscribers)
    final shouldShowPrompt =
        await ref.read(upgradePromptServiceProvider).shouldShowPostSessionPrompt();

    if (shouldShowPrompt && context.mounted) {
      // Record that we showed the prompt
      await ref
          .read(upgradePromptServiceProvider)
          .recordPromptShown(UpgradePromptType.postSession);

      // Show the upgrade prompt modal after dismissing completion modal
      widget.onDismiss();

      // Small delay to let the completion modal close first
      await Future.delayed(const Duration(milliseconds: 200));

      if (context.mounted) {
        showUpgradePromptModal(
          context,
          ref,
          type: UpgradePromptType.postSession,
        );
      }
    } else {
      widget.onDismiss();
    }
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

/// A single celebration particle with position, velocity, and appearance.
class _CelebrationParticle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  final double delay;
  final bool isEssence;

  _CelebrationParticle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
    this.delay = 0.0,
    this.isEssence = false,
  });
}

/// Paints celebration particles as pixel-style squares.
class _CelebrationPainter extends CustomPainter {
  final List<_CelebrationParticle> particles;
  final double progress;

  _CelebrationPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final particle in particles) {
      // Skip if particle hasn't started yet
      if (progress < particle.delay) continue;

      // Calculate particle progress (0 to 1) after delay
      final particleProgress = ((progress - particle.delay) / (1.0 - particle.delay)).clamp(0.0, 1.0);

      // Calculate position based on angle and speed
      double distance;
      double yOffset = 0;

      if (particle.isEssence) {
        // Essence particles float upward with slight wobble
        distance = particle.speed * particleProgress;
        yOffset = -distance; // Move up
        final wobble = math.sin(particleProgress * math.pi * 4) * 10;
        final x = center.dx + wobble;
        final y = center.dy + yOffset;

        // Fade out as they rise
        final opacity = (1.0 - particleProgress).clamp(0.0, 1.0);

        final paint = Paint()
          ..color = particle.color.withValues(alpha: opacity)
          ..isAntiAlias = false;

        // Draw as pixel square
        final pixelSize = particle.size * (1.0 - particleProgress * 0.3);
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: pixelSize, height: pixelSize),
          paint,
        );
      } else {
        // Burst particles explode outward then fade
        distance = particle.speed * particleProgress;
        final x = center.dx + math.cos(particle.angle) * distance;
        final y = center.dy + math.sin(particle.angle) * distance;

        // Fade out as they travel
        final opacity = (1.0 - particleProgress * 0.8).clamp(0.0, 1.0);

        final paint = Paint()
          ..color = particle.color.withValues(alpha: opacity)
          ..isAntiAlias = false;

        // Draw as pixel square
        final pixelSize = particle.size * (1.0 - particleProgress * 0.5);
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: pixelSize, height: pixelSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
