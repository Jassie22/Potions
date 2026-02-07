import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/config/app_preferences.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/main.dart';
import 'package:potion_focus/presentation/settings/widgets/about_dialog.dart';
import 'package:potion_focus/presentation/settings/widgets/tag_management_screen.dart';
import 'package:potion_focus/presentation/shared/widgets/background_theme_picker.dart';
import 'package:potion_focus/presentation/shared/widgets/pixel_loading.dart';
import 'package:potion_focus/presentation/subscription/subscription_screen.dart';
import 'package:potion_focus/services/feedback_service.dart';
import 'package:potion_focus/services/subscription_service.dart';
import 'package:potion_focus/services/theme_service.dart';
import 'package:potion_focus/services/essence_service.dart';
import 'package:potion_focus/services/coin_service.dart';
import 'package:potion_focus/services/quest_generation_service.dart';
import 'package:potion_focus/services/recipe_service.dart';
import 'package:potion_focus/data/repositories/potion_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundsEnabled = true;
  bool _hapticEnabled = true;
  String _themeMode = 'system';
  int _defaultDuration = 25;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await AppPreferences.init();
    setState(() {
      _notificationsEnabled = AppPreferences.notificationsEnabled;
      _soundsEnabled = AppPreferences.soundsEnabled;
      _hapticEnabled = AppPreferences.hapticFeedbackEnabled;
      _themeMode = AppPreferences.themeMode;
      _defaultDuration = AppPreferences.defaultDuration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Timer Settings
          _buildSectionHeader('Timer'),
          _buildPixelCard(
            children: [
              _buildPixelListTile(
                icon: Icons.timer_outlined,
                title: 'Default Duration',
                subtitle: '$_defaultDuration minutes',
                onTap: () => _showDurationPicker(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Appearance
          _buildSectionHeader('Appearance'),
          _buildPixelCard(
            children: [
              _buildPixelListTile(
                icon: Icons.palette_outlined,
                title: 'Theme',
                subtitle: _getThemeModeLabel(_themeMode),
                onTap: () => _showThemePicker(context),
              ),
              Container(height: 2, color: Colors.black26),
              _buildPixelListTile(
                icon: Icons.wallpaper_outlined,
                title: 'Background Theme',
                subtitle: 'Change your brew screen backdrop',
                onTap: () => _showBackgroundThemePicker(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Subscription
          _buildSubscriptionSection(),
          const SizedBox(height: 24),

          // Preferences
          _buildSectionHeader('Preferences'),
          _buildPixelCard(
            children: [
              _buildPixelToggle(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Session completion reminders',
                value: _notificationsEnabled,
                onChanged: (value) async {
                  await AppPreferences.setNotificationsEnabled(value);
                  setState(() => _notificationsEnabled = value);
                },
              ),
              Container(height: 2, color: Colors.black26),
              _buildPixelToggle(
                icon: Icons.volume_up_outlined,
                title: 'Sounds',
                subtitle: 'Audio feedback for actions',
                value: _soundsEnabled,
                onChanged: (value) async {
                  await AppPreferences.setSoundsEnabled(value);
                  setState(() => _soundsEnabled = value);
                },
              ),
              Container(height: 2, color: Colors.black26),
              _buildPixelToggle(
                icon: Icons.vibration_outlined,
                title: 'Haptic Feedback',
                subtitle: 'Vibration for interactions',
                value: _hapticEnabled,
                onChanged: (value) async {
                  await AppPreferences.setHapticFeedbackEnabled(value);
                  setState(() => _hapticEnabled = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Data Management
          _buildSectionHeader('Data'),
          _buildPixelCard(
            children: [
              _buildPixelListTile(
                icon: Icons.sync,
                title: 'Sync Data',
                subtitle: 'Refresh all cached data',
                trailing: _isSyncing
                    ? const PixelSpinner(size: 20)
                    : null,
                onTap: _isSyncing ? null : _performSync,
              ),
              Container(height: 2, color: Colors.black26),
              _buildPixelListTile(
                icon: Icons.label_outlined,
                title: 'Manage Tags',
                subtitle: 'Edit and organize your focus tags',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TagManagementScreen(),
                    ),
                  );
                },
              ),
              Container(height: 2, color: Colors.black26),
              _buildPixelListTile(
                icon: Icons.file_download_outlined,
                title: 'Export Data',
                subtitle: 'Download your focus history',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data export feature coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // About
          _buildSectionHeader('About'),
          _buildPixelCard(
            children: [
              _buildPixelListTile(
                icon: Icons.info_outlined,
                title: 'About Potion Focus',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              Container(height: 2, color: Colors.black26),
              _buildPixelListTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Privacy policy coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
      ),
    );
  }

  /// Pixel-art styled card replacement (no rounded corners, no elevation)
  Widget _buildPixelCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.black54, width: 2),
      ),
      child: Column(children: children),
    );
  }

  /// Pixel-art styled list tile (no Material ripple)
  Widget _buildPixelListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }

  /// Pixel-art styled toggle switch replacement
  Widget _buildPixelToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                        ),
                  ),
                ],
              ),
            ),
            // Pixel toggle
            GestureDetector(
              onTap: () => onChanged(!value),
              child: Container(
                width: 44,
                height: 24,
                decoration: BoxDecoration(
                  color: value
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade600,
                  border: Border.all(color: Colors.black87, width: 2),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 120),
                  alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection() {
    final subscriptionState = ref.watch(subscriptionServiceProvider);
    final isPremium = subscriptionState.isPremium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Subscription'),
        _buildPixelCard(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionScreen(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      isPremium ? Icons.workspace_premium : Icons.star_border,
                      color: isPremium ? AppColors.legendary : null,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPremium ? 'Potion Master' : 'Free',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isPremium
                                ? 'Premium benefits active'
                                : 'Upgrade for exclusive items & bonuses',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    isPremium
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.legendary.withValues(alpha: 0.2),
                              border: Border.all(color: AppColors.legendary),
                              borderRadius: BorderRadius.zero,
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: AppColors.legendary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          )
                        : const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
              ),
            ),
            if (isPremium) ...[
              Container(height: 2, color: Colors.black26),
              _buildPixelListTile(
                icon: Icons.settings_outlined,
                title: 'Manage Subscription',
                subtitle: 'View or cancel via app store',
                onTap: () => _openManageSubscriptions(),
              ),
            ],
          ],
        ),
      ],
    );
  }

  String _getThemeModeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System Default';
    }
  }

  Future<void> _showDurationPicker(BuildContext context) async {
    final durations = [15, 25, 45, 60, 90];
    final selected = await showDialog<int>(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.black87, width: 2),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Default Duration', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...durations.map((duration) {
                final isSelected = _defaultDuration == duration;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, duration),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 4),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    child: Text(
                      '$duration minutes',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      await AppPreferences.setDefaultDuration(selected);
      setState(() => _defaultDuration = selected);
    }
  }

  Future<void> _showThemePicker(BuildContext context) async {
    final themeModes = [
      {'value': 'system', 'label': 'System Default'},
      {'value': 'light', 'label': 'Light'},
      {'value': 'dark', 'label': 'Dark'},
    ];

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(color: Colors.black87, width: 2),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...themeModes.map((mode) {
                final isSelected = _themeMode == mode['value'];
                return GestureDetector(
                  onTap: () => Navigator.pop(context, mode['value']),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 4),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    child: Text(
                      mode['label']!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      await ref.read(themeModeProvider.notifier).setThemeMode(selected);
      ref.read(feedbackServiceProvider).haptic(HapticType.light);
      setState(() => _themeMode = selected);
    }
  }

  Future<void> _showBackgroundThemePicker(BuildContext context) async {
    await showBackgroundThemePicker(context, ref);
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AboutDialogWidget(),
    );
  }

  Future<void> _openManageSubscriptions() async {
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

  Future<void> _performSync() async {
    setState(() => _isSyncing = true);
    try {
      ref.invalidate(allPotionsProvider);
      ref.invalidate(essenceBalanceProvider);
      ref.invalidate(coinBalanceProvider);
      ref.invalidate(activeQuestsProvider);
      ref.invalidate(allRecipesProvider);
      ref.invalidate(activeThemeProvider);

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        ref.read(feedbackServiceProvider).haptic(HapticType.success);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
}
