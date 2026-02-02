import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/config/app_preferences.dart';
import 'package:potion_focus/core/theme/app_theme.dart';
import 'package:potion_focus/data/local/database.dart';
import 'package:potion_focus/presentation/shared/app_navigation.dart';
import 'package:potion_focus/presentation/onboarding/onboarding_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:potion_focus/core/config/supabase_config.dart';

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
  
  // Start background sync (optional - app works offline)
  // SyncService will handle authentication and sync when online
  
  runApp(
    const ProviderScope(
      child: PotionFocusApp(),
    ),
  );
}

class PotionFocusApp extends StatelessWidget {
  const PotionFocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = _getThemeMode();
    
    return MaterialApp(
      title: 'Potion Focus',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: _getHomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeMode _getThemeMode() {
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

  Widget _getHomeScreen() {
    if (!AppPreferences.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }
    return const AppNavigation();
  }
}

