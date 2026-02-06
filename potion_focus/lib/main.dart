import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:potion_focus/core/config/app_preferences.dart';
import 'package:potion_focus/core/config/revenuecat_config.dart';
import 'package:potion_focus/core/theme/app_theme.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/presentation/shared/app_navigation.dart';
import 'package:potion_focus/presentation/onboarding/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:potion_focus/core/config/supabase_config.dart';

/// StateNotifier for reactive theme mode switching
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(_getInitialThemeMode());

  static ThemeMode _getInitialThemeMode() {
    final mode = AppPreferences.themeMode;
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(String mode) async {
    await AppPreferences.setThemeMode(mode);
    switch (mode) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        state = ThemeMode.system;
    }
  }
}

/// Provider for the theme mode notifier
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize preferences
  await AppPreferences.init();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Initialize local database
  await DatabaseHelper.initialize();

  // Initialize RevenueCat for in-app purchases
  if (Platform.isAndroid || Platform.isIOS) {
    await Purchases.configure(
      PurchasesConfiguration(RevenueCatConfig.apiKey),
    );
  }

  // Start background sync (optional - app works offline)
  // SyncService will handle authentication and sync when online

  runApp(
    const ProviderScope(
      child: PotionFocusApp(),
    ),
  );
}

class PotionFocusApp extends ConsumerWidget {
  const PotionFocusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme mode for live updates
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Potion Focus',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: _getHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  Widget _getHomeScreen() {
    if (!AppPreferences.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }
    return const AppNavigation();
  }
}

