import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/services/subscription_service.dart';
import 'package:potion_focus/services/daily_bonus_service.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  List<Package> _packages = [];
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final service = ref.read(subscriptionServiceProvider.notifier);
    final packages = await service.getOfferings();
    if (mounted) {
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionState = ref.watch(subscriptionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Premium',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : subscriptionState.isPremium
              ? _buildActiveSubscription(subscriptionState)
              : _buildPurchaseFlow(),
    );
  }

  Widget _buildActiveSubscription(SubscriptionState subscriptionState) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Active subscription badge
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.legendary.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.legendary, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          child: Column(
            children: [
              const Icon(Icons.workspace_premium,
                  color: AppColors.legendary, size: 48),
              const SizedBox(height: 12),
              Text(
                'POTION MASTER',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.legendary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subscriptionState.expirationDate == null
                    ? 'Lifetime access unlocked'
                    : 'Your premium access is active',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (subscriptionState.expirationDate != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Expires: ${_formatDate(subscriptionState.expirationDate!)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ] else ...[
                const SizedBox(height: 4),
                Text(
                  'Thank you for your support!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.legendary,
                      ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Daily bonus claim
        _buildDailyBonusCard(),
        const SizedBox(height: 24),

        // Benefits list
        _buildBenefitsList(unlocked: true),
        const SizedBox(height: 24),

        // Manage subscription button (only for recurring subscriptions)
        if (subscriptionState.expirationDate != null)
          OutlinedButton(
            onPressed: () => _openManageSubscriptions(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              side: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: const Text('Manage Subscription'),
          ),
      ],
    );
  }

  Widget _buildDailyBonusCard() {
    return FutureBuilder<bool>(
      future: ref.read(dailyBonusServiceProvider).canClaimToday(),
      builder: (context, snapshot) {
        final canClaim = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: canClaim
                  ? AppColors.mysticalGold
                  : AppColors.mysticalGold.withValues(alpha: 0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mysticalGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.zero,
                ),
                child: Icon(
                  Icons.monetization_on,
                  color: canClaim
                      ? AppColors.mysticalGold
                      : AppColors.mysticalGold.withValues(alpha: 0.5),
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Coin Bonus',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      canClaim
                          ? '+${DailyBonusService.dailyCoinBonus} coins available!'
                          : 'Already claimed today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: canClaim
                                ? AppColors.mysticalGold
                                : Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
              if (canClaim)
                ElevatedButton(
                  onPressed: () async {
                    final granted = await ref
                        .read(dailyBonusServiceProvider)
                        .checkAndGrantDailyBonus();
                    if (granted && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              '+${DailyBonusService.dailyCoinBonus} coins added!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                      setState(() {}); // Refresh UI
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mysticalGold,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text(
                    'Claim',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPurchaseFlow() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.legendary.withValues(alpha: 0.1),
            border: Border.all(color: AppColors.legendary, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          child: Column(
            children: [
              const Icon(Icons.auto_awesome,
                  color: AppColors.legendary, size: 40),
              const SizedBox(height: 12),
              Text(
                'BECOME A\nPOTION MASTER',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.legendary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock the full alchemist experience',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Benefits
        _buildBenefitsList(unlocked: false),
        const SizedBox(height: 24),

        // Plan selector
        if (_packages.isNotEmpty) _buildPlanSelector(),
        const SizedBox(height: 24),

        // Purchase button
        ElevatedButton(
          onPressed: _isPurchasing || _packages.isEmpty ? null : _handlePurchase,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.legendary,
            minimumSize: const Size(double.infinity, 50),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            side: const BorderSide(color: AppColors.legendary, width: 2),
          ),
          child: _isPurchasing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Purchase Now',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
        ),
        const SizedBox(height: 12),

        // Restore purchases
        TextButton(
          onPressed: _handleRestore,
          child: Text(
            'Restore Purchases',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        const SizedBox(height: 16),

        // Terms
        Text(
          'This is a one-time purchase. Payment will be charged to your Play Store or App Store account.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBenefitsList({required bool unlocked}) {
    final benefits = [
      ('Exclusive Bottles', 'Celestial Vessel, Starforged Vial'),
      ('Exclusive Backgrounds', 'Aurora Borealis, Cosmic Void & more'),
      ('Exclusive Effects', 'Cosmic Trail, Ethereal Glow'),
      ('+25% Bonus Essence', 'Earn more from every focus session'),
      ('Daily Coin Bonus', '${DailyBonusService.dailyCoinBonus} coins every day'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          unlocked ? 'Your Benefits' : 'Premium Benefits',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...benefits.map((b) => _buildBenefitItem(
              b.$1,
              b.$2,
              unlocked: unlocked,
            )),
      ],
    );
  }

  Widget _buildBenefitItem(String title, String subtitle,
      {bool unlocked = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: (unlocked ? AppColors.success : AppColors.legendary)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.zero,
              border: Border.all(
                color: unlocked ? AppColors.success : AppColors.legendary,
                width: 2,
              ),
            ),
            child: Icon(
              unlocked ? Icons.check : Icons.star,
              size: 16,
              color: unlocked ? AppColors.success : AppColors.legendary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanSelector() {
    // Find the lifetime package (or fall back to first available package)
    Package? lifetimePackage;
    for (final package in _packages) {
      if (package.packageType == PackageType.lifetime) {
        lifetimePackage = package;
        break;
      }
    }

    // If no lifetime package found, use the first available package
    lifetimePackage ??= _packages.isNotEmpty ? _packages.first : null;

    if (lifetimePackage == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.legendary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.legendary, width: 2),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.legendary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.zero,
                ),
                child: const Icon(
                  Icons.all_inclusive,
                  color: AppColors.legendary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lifetime Access',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'One-time purchase, forever yours',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.legendary,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                lifetimePackage.storeProduct.priceString,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.legendary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() => _isPurchasing = true);

    // Find the lifetime package (or fall back to first available package)
    Package? selectedPackage;
    for (final package in _packages) {
      if (package.packageType == PackageType.lifetime) {
        selectedPackage = package;
        break;
      }
    }
    // Fallback to first available package
    selectedPackage ??= _packages.isNotEmpty ? _packages.first : null;

    if (selectedPackage == null) {
      setState(() => _isPurchasing = false);
      return;
    }

    final service = ref.read(subscriptionServiceProvider.notifier);
    final success = await service.purchasePackage(selectedPackage);

    setState(() => _isPurchasing = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Welcome to Potion Master!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    final service = ref.read(subscriptionServiceProvider.notifier);
    final restored = await service.restorePurchases();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(restored ? 'Purchase restored!' : 'No purchase found'),
          backgroundColor: restored ? AppColors.success : AppColors.warning,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _openManageSubscriptions() async {
    // Open the platform's subscription management page
    final Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse('https://play.google.com/store/account/subscriptions');
    } else if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      return;
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
