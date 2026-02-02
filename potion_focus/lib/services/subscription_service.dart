import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/data/local/isar_helpers.dart';
import 'package:potion_focus/data/models/subscription_model.dart';

class SubscriptionService {
  Future<SubscriptionModel> getSubscription() async {
    final db = DatabaseHelper.instance;
    final all = await db.subscriptionModels.getAllItems();
    return all.firstOrNull ?? SubscriptionModel();
  }

  Future<String> getTier() async {
    final sub = await getSubscription();
    if (!sub.isActive) return 'none';
    return sub.tier;
  }

  Future<bool> hasFeature(String feature) async {
    final tier = await getTier();
    switch (tier) {
      case 'premium':
        return true; // Premium has everything
      case 'basic':
        return _basicFeatures.contains(feature);
      default:
        return false;
    }
  }

  /// Basic tier features.
  static const _basicFeatures = {
    'bonus_essence',
    'exclusive_bottles_basic',
    'all_backgrounds',
  };
}

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return SubscriptionService();
});

final subscriptionTierProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(subscriptionServiceProvider);
  return await service.getTier();
});
