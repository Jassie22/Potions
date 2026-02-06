import 'dart:io';

/// Configuration for RevenueCat in-app purchases.
///
/// API keys should be replaced with actual values from RevenueCat dashboard.
/// Product IDs must match those configured in Google Play Console / App Store Connect.
class RevenueCatConfig {
  // API Keys - Replace with actual keys from RevenueCat dashboard
  // These are public keys (safe to include in app)
  static const String androidApiKey = 'YOUR_REVENUECAT_ANDROID_API_KEY';
  static const String iosApiKey = 'YOUR_REVENUECAT_IOS_API_KEY';

  /// Returns the appropriate API key for the current platform
  static String get apiKey {
    if (Platform.isAndroid) {
      return androidApiKey;
    } else if (Platform.isIOS) {
      return iosApiKey;
    }
    throw UnsupportedError('RevenueCat is only supported on Android and iOS');
  }

  // Entitlement identifier - grants access to premium features
  static const String premiumEntitlement = 'premium';

  // Product identifiers - must match Play Store / App Store products
  // Lifetime (one-time purchase) is the primary option
  static const String lifetimeProductId = 'potion_master_lifetime';

  // Legacy subscription IDs (kept for migration support)
  static const String monthlyProductId = 'potion_master_monthly';
  static const String yearlyProductId = 'potion_master_yearly';

  // Offering identifier (optional - uses default if not specified)
  static const String defaultOfferingId = 'default';
}
