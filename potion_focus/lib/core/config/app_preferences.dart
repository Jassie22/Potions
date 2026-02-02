import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyThemeMode = 'theme_mode'; // 'light', 'dark', 'system'
  static const String _keyDefaultDuration = 'default_duration';
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';
  static const String _keySoundsEnabled = 'sounds_enabled';
  static const String _keyHapticFeedbackEnabled = 'haptic_feedback_enabled';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Notifications
  static bool get notificationsEnabled =>
      _prefs?.getBool(_keyNotificationsEnabled) ?? true;

  static Future<bool> setNotificationsEnabled(bool value) async {
    return await _prefs?.setBool(_keyNotificationsEnabled, value) ?? false;
  }

  // Theme Mode
  static String get themeMode =>
      _prefs?.getString(_keyThemeMode) ?? 'system';

  static Future<bool> setThemeMode(String value) async {
    return await _prefs?.setString(_keyThemeMode, value) ?? false;
  }

  // Default Duration
  static int get defaultDuration =>
      _prefs?.getInt(_keyDefaultDuration) ?? 25; // Default 25 minutes

  static Future<bool> setDefaultDuration(int minutes) async {
    return await _prefs?.setInt(_keyDefaultDuration, minutes) ?? false;
  }

  // Onboarding
  static bool get hasCompletedOnboarding =>
      _prefs?.getBool(_keyHasCompletedOnboarding) ?? false;

  static Future<bool> setHasCompletedOnboarding(bool value) async {
    return await _prefs?.setBool(_keyHasCompletedOnboarding, value) ?? false;
  }

  // Sounds
  static bool get soundsEnabled =>
      _prefs?.getBool(_keySoundsEnabled) ?? true;

  static Future<bool> setSoundsEnabled(bool value) async {
    return await _prefs?.setBool(_keySoundsEnabled, value) ?? false;
  }

  // Haptic Feedback
  static bool get hapticFeedbackEnabled =>
      _prefs?.getBool(_keyHapticFeedbackEnabled) ?? true;

  static Future<bool> setHapticFeedbackEnabled(bool value) async {
    return await _prefs?.setBool(_keyHapticFeedbackEnabled, value) ?? false;
  }

  // Clear all preferences
  static Future<bool> clearAll() async {
    return await _prefs?.clear() ?? false;
  }
}



