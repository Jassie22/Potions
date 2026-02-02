import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/config/app_preferences.dart';
import 'package:potion_focus/presentation/settings/widgets/about_dialog.dart';
import 'package:potion_focus/presentation/settings/widgets/tag_management_screen.dart';

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
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.timer_outlined),
                  title: const Text('Default Duration'),
                  subtitle: Text('$_defaultDuration minutes'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDurationPicker(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance
          _buildSectionHeader('Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme'),
                  subtitle: Text(_getThemeModeLabel(_themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemePicker(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Preferences
          _buildSectionHeader('Preferences'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text('Session completion reminders'),
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    await AppPreferences.setNotificationsEnabled(value);
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined),
                  title: const Text('Sounds'),
                  subtitle: const Text('Audio feedback for actions'),
                  value: _soundsEnabled,
                  onChanged: (value) async {
                    await AppPreferences.setSoundsEnabled(value);
                    setState(() => _soundsEnabled = value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.vibration_outlined),
                  title: const Text('Haptic Feedback'),
                  subtitle: const Text('Vibration for interactions'),
                  value: _hapticEnabled,
                  onChanged: (value) async {
                    await AppPreferences.setHapticFeedbackEnabled(value);
                    setState(() => _hapticEnabled = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management
          _buildSectionHeader('Data'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.label_outlined),
                  title: const Text('Manage Tags'),
                  subtitle: const Text('Edit and organize your focus tags'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TagManagementScreen(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('Export Data'),
                  subtitle: const Text('Download your focus history'),
                  trailing: const Icon(Icons.chevron_right),
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
          ),
          const SizedBox(height: 24),

          // About
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outlined),
                  title: const Text('About Potion Focus'),
                  subtitle: const Text('Version 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('How we handle your data'),
                  trailing: const Icon(Icons.chevron_right),
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
      builder: (context) => AlertDialog(
        title: const Text('Default Duration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: durations.map((duration) {
            return RadioListTile<int>(
              title: Text('$duration minutes'),
              value: duration,
              groupValue: _defaultDuration,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
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
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themeModes.map((mode) {
            return RadioListTile<String>(
              title: Text(mode['label']!),
              value: mode['value']!,
              groupValue: _themeMode,
              onChanged: (value) => Navigator.pop(context, value),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      await AppPreferences.setThemeMode(selected);
      setState(() => _themeMode = selected);
      // TODO: Apply theme mode to app (requires theme provider)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Theme change will take effect after restart'),
        ),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AboutDialogWidget(),
    );
  }
}

