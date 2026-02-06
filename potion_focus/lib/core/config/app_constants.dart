class AppConstants {
  // App Info
  static const String appName = 'Potion Focus';
  static const String appVersion = '1.0.0';
  
  // Timer Presets (in minutes)
  static const List<int> timerPresets = [15, 25, 45, 60, 90];
  static const int minCustomDuration = 10;
  static const int maxCustomDuration = 120;
  
  // Tags
  static const int maxTagsPerSession = 5;
  static const List<String> defaultTags = [];
  
  // Essence
  static const int essencePerMinute = 1;
  static const int minutesPerEssence = 5; // 5 minutes = 1 essence base
  
  // Rarity
  static const Map<String, int> rarityLevels = {
    'common': 1,
    'uncommon': 2,
    'rare': 3,
    'epic': 4,
    'legendary': 5,
  };
  
  static const Map<String, String> rarityNames = {
    'common': 'Common',
    'uncommon': 'Uncommon',
    'rare': 'Rare',
    'epic': 'Epic',
    'legendary': 'Legendary',
  };
  
  // Quests
  static const int dailyQuestCount = 1;
  static const int weeklyQuestCount = 3;
  static const double dailyQuestDifficultyFactor = 0.8; // 80% of average
  static const double weeklyQuestDifficultyFactor = 1.1; // 110% of average
  static const double dailyQuestEssenceBonus = 1.5;
  static const double weeklyQuestEssenceBonus = 2.0;
  
  // Quest Type Weights
  static const Map<String, double> questTypeWeights = {
    'time_based': 0.6, // 60%
    'session_based': 0.3, // 30%
    'streak_based': 0.1, // 10%
  };
  
  // Sync
  static const Duration syncInterval = Duration(minutes: 5);
  static const Duration syncRetryDelay = Duration(seconds: 30);
  
  // Notifications
  static const String timerChannelId = 'potion_focus_timer';
  static const String timerChannelName = 'Focus Timer';
  static const String questChannelId = 'potion_focus_quests';
  static const String questChannelName = 'Focus Threads';
  
  // Database
  static const String databaseName = 'potion_focus';
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Animation Speed Multipliers (for background themes & effects)
  // These standardize the animation speeds across the app
  static const double animSpeedSlow = 0.5;    // Stars, ambient drifting
  static const double animSpeedMedium = 1.0;  // Bubbles, particles
  static const double animSpeedFast = 2.0;    // Sparkles, active effects

  // UI Transition Curves (for cozy feel)
  // easeOutCubic provides soft deceleration for satisfying feedback
  static const Duration uiTransitionFast = Duration(milliseconds: 100);
  static const Duration uiTransitionMedium = Duration(milliseconds: 150);
  static const Duration uiTransitionSlow = Duration(milliseconds: 250);
}



