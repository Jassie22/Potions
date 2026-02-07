import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/presentation/subscription/subscription_screen.dart';
import 'package:potion_focus/services/daily_bonus_service.dart';
import 'package:potion_focus/services/upgrade_prompt_service.dart';

/// Shows the upgrade prompt modal.
///
/// Call this from completion_modal, shop_item_card, or home_screen
/// when appropriate conditions are met.
Future<void> showUpgradePromptModal(
  BuildContext context,
  WidgetRef ref, {
  UpgradePromptType type = UpgradePromptType.postSession,
  String? customTitle,
  String? customMessage,
}) async {
  // Record that we showed a prompt
  await ref.read(upgradePromptServiceProvider).recordPromptShown(type);

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.zero),
    ),
    builder: (context) => UpgradePromptContent(
      type: type,
      customTitle: customTitle,
      customMessage: customMessage,
    ),
  );
}

class UpgradePromptContent extends StatelessWidget {
  final UpgradePromptType type;
  final String? customTitle;
  final String? customMessage;

  const UpgradePromptContent({
    super.key,
    required this.type,
    this.customTitle,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.legendary.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.legendary, width: 2),
              borderRadius: BorderRadius.zero,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: AppColors.legendary,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            customTitle ?? _getTitleForType(type),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.legendary,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Message
          Text(
            customMessage ?? _getMessageForType(type),
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Benefits preview
          _buildBenefitsPreview(context),
          const SizedBox(height: 24),

          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.legendary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                side: const BorderSide(color: AppColors.legendary, width: 2),
              ),
              child: Text(
                'Become a Potion Master',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Dismiss button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBenefitsPreview(BuildContext context) {
    final benefits = [
      (Icons.star, 'Exclusive cosmetics'),
      (Icons.auto_awesome, '+25% bonus essence'),
      (Icons.monetization_on, '${DailyBonusService.dailyCoinBonus} daily coins'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: benefits.map((b) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.legendary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.zero,
                border: Border.all(
                  color: AppColors.legendary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                b.$1,
                color: AppColors.legendary,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 80,
              child: Text(
                b.$2,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getTitleForType(UpgradePromptType type) {
    switch (type) {
      case UpgradePromptType.postSession:
        return 'Boost Your Progress';
      case UpgradePromptType.weeklyReminder:
        return 'Unlock Premium';
      case UpgradePromptType.exclusiveItem:
        return 'Exclusive Item';
    }
  }

  String _getMessageForType(UpgradePromptType type) {
    switch (type) {
      case UpgradePromptType.postSession:
        return 'Great focus session! Earn 25% more essence and unlock exclusive rewards with Potion Master.';
      case UpgradePromptType.weeklyReminder:
        return 'Enhance your focus journey with exclusive bottles, backgrounds, and daily coin bonuses.';
      case UpgradePromptType.exclusiveItem:
        return 'This item is exclusive to Potion Master subscribers. Unlock it along with other premium benefits.';
    }
  }
}
