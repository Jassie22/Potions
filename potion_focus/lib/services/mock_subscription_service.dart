import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/services/subscription_service.dart';

/// Mock subscription service for development and testing.
///
/// Allows toggling premium state without real purchases.
/// Use this during development to test premium features.
///
/// Example usage in debug/dev builds:
/// ```dart
/// // Override the real provider with mock
/// ProviderScope(
///   overrides: [
///     subscriptionServiceProvider.overrideWith((ref) => MockSubscriptionService()),
///   ],
///   child: MyApp(),
/// )
/// ```
class MockSubscriptionService extends StateNotifier<SubscriptionState> {
  MockSubscriptionService({bool startAsPremium = false})
      : super(SubscriptionState(
          isPremium: startAsPremium,
          isLoading: false,
          expirationDate: startAsPremium
              ? DateTime.now().add(const Duration(days: 30))
              : null,
          activeProductId: startAsPremium ? 'mock_premium' : null,
        ));

  /// Toggle premium status for testing.
  void togglePremium() {
    final newIsPremium = !state.isPremium;
    state = SubscriptionState(
      isPremium: newIsPremium,
      isLoading: false,
      expirationDate:
          newIsPremium ? DateTime.now().add(const Duration(days: 30)) : null,
      activeProductId: newIsPremium ? 'mock_premium' : null,
    );
  }

  /// Set premium status directly.
  void setPremium(bool isPremium) {
    state = SubscriptionState(
      isPremium: isPremium,
      isLoading: false,
      expirationDate:
          isPremium ? DateTime.now().add(const Duration(days: 30)) : null,
      activeProductId: isPremium ? 'mock_premium' : null,
    );
  }

  /// Simulate loading state.
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Simulate an error state.
  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Legacy compatibility methods
  Future<String> getTier() async => state.isPremium ? 'premium' : 'none';
  Future<bool> hasFeature(String feature) async => state.isPremium;
}

/// Provider for mock subscription service.
///
/// Use this in tests or dev builds by overriding [subscriptionServiceProvider]:
/// ```dart
/// subscriptionServiceProvider.overrideWith((ref) => MockSubscriptionService())
/// ```
final mockSubscriptionServiceProvider =
    StateNotifierProvider<MockSubscriptionService, SubscriptionState>((ref) {
  return MockSubscriptionService();
});

/// Convenience provider to check if using mock service (for debug UI).
final isUsingMockSubscriptionProvider = Provider<bool>((ref) {
  // This would be set by the app based on build configuration
  return false;
});
