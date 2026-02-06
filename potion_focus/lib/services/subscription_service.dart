import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:potion_focus/core/config/revenuecat_config.dart';

/// Represents the current subscription state
class SubscriptionState {
  final bool isPremium;
  final DateTime? expirationDate;
  final String? activeProductId;
  final bool isLoading;
  final String? error;

  const SubscriptionState({
    this.isPremium = false,
    this.expirationDate,
    this.activeProductId,
    this.isLoading = true,
    this.error,
  });

  SubscriptionState copyWith({
    bool? isPremium,
    DateTime? expirationDate,
    String? activeProductId,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      isPremium: isPremium ?? this.isPremium,
      expirationDate: expirationDate ?? this.expirationDate,
      activeProductId: activeProductId ?? this.activeProductId,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Manages subscription state using RevenueCat as source of truth.
///
/// This service handles:
/// - Checking current subscription status
/// - Fetching available offerings (products)
/// - Processing purchases
/// - Restoring purchases
class SubscriptionService extends StateNotifier<SubscriptionState> {
  SubscriptionService() : super(const SubscriptionState()) {
    _initialize();
  }

  /// Initialize and fetch current subscription status
  Future<void> _initialize() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _updateFromCustomerInfo(customerInfo);

      // Listen for subscription changes (e.g., from another device, renewal, etc.)
      Purchases.addCustomerInfoUpdateListener(_updateFromCustomerInfo);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update state from RevenueCat customer info
  void _updateFromCustomerInfo(CustomerInfo info) {
    final entitlement =
        info.entitlements.all[RevenueCatConfig.premiumEntitlement];
    final isPremium = entitlement?.isActive ?? false;

    DateTime? expirationDate;
    if (entitlement?.expirationDate != null) {
      expirationDate = DateTime.tryParse(entitlement!.expirationDate!);
    }

    state = SubscriptionState(
      isPremium: isPremium,
      expirationDate: expirationDate,
      activeProductId: entitlement?.productIdentifier,
      isLoading: false,
      error: null,
    );
  }

  /// Get available subscription packages from RevenueCat
  Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Purchase a subscription package
  ///
  /// Returns true if purchase was successful and user is now premium
  Future<bool> purchasePackage(Package package) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final customerInfo = await Purchases.purchasePackage(package);
      _updateFromCustomerInfo(customerInfo);
      return state.isPremium;
    } on PurchasesErrorCode catch (e) {
      // User cancelled is not really an error
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        state = state.copyWith(isLoading: false);
        return false;
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Restore previous purchases
  ///
  /// Returns true if a valid subscription was restored
  Future<bool> restorePurchases() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final info = await Purchases.restorePurchases();
      _updateFromCustomerInfo(info);
      return state.isPremium;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Legacy compatibility methods for existing code

  /// Get current tier name
  Future<String> getTier() async => state.isPremium ? 'premium' : 'none';

  /// Check if user has access to a feature
  Future<bool> hasFeature(String feature) async => state.isPremium;

  @override
  void dispose() {
    Purchases.removeCustomerInfoUpdateListener(_updateFromCustomerInfo);
    super.dispose();
  }
}

// Providers

/// Main subscription service provider (StateNotifier)
final subscriptionServiceProvider =
    StateNotifierProvider<SubscriptionService, SubscriptionState>((ref) {
  return SubscriptionService();
});

/// Convenience provider for checking if user is premium
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionServiceProvider).isPremium;
});

/// Legacy provider for subscription tier (for backwards compatibility)
final subscriptionTierProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(subscriptionServiceProvider.notifier);
  return await service.getTier();
});

/// Provider for subscription loading state
final subscriptionLoadingProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionServiceProvider).isLoading;
});
