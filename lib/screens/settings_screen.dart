import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../providers/app_provider.dart';
import '../providers/user_provider.dart';
import '../providers/ar_provider.dart';
import '../models/user_model.dart';
import '../services/voice_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final VoiceService _voiceService = VoiceService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Settings
          _buildSectionTitle('Appearance'),
          _buildThemeSettings(),
          const SizedBox(height: 24),

          // Voice Settings
          _buildSectionTitle('Voice & Audio'),
          _buildVoiceSettings(),
          const SizedBox(height: 24),

          // AR Settings
          _buildSectionTitle('Augmented Reality'),
          _buildARSettings(),
          const SizedBox(height: 24),

          // User Preferences
          _buildSectionTitle('Preferences'),
          _buildUserPreferences(),
          const SizedBox(height: 24),

          // App Settings
          _buildSectionTitle('App Settings'),
          _buildAppSettings(),
          const SizedBox(height: 24),

          // Account Actions
          _buildSectionTitle('Account'),
          _buildAccountActions(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildThemeSettings() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Use dark theme for better night viewing'),
                value: appProvider.isDarkMode,
                onChanged: (value) {
                  appProvider.toggleTheme();
                },
                secondary: Icon(
                  appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
              ListTile(
                title: const Text('Accent Color'),
                subtitle: const Text('Choose your preferred accent color'),
                leading: const Icon(Icons.palette),
                trailing: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                onTap: () {
                  _showColorPicker();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceSettings() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final preferences = userProvider.currentUser?.preferences;
        if (preferences == null) return const SizedBox.shrink();

        return Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('Voice Volume'),
                subtitle: Slider(
                  value: preferences.voiceVolume,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  label: '${(preferences.voiceVolume * 100).round()}%',
                  onChanged: (value) {
                    userProvider.updateVoiceVolume(value);
                    _voiceService.updateVoiceSettings(preferences);
                  },
                ),
                leading: const Icon(Icons.volume_up),
              ),
              ListTile(
                title: const Text('Voice Language'),
                subtitle: Text(preferences.voiceLanguage),
                leading: const Icon(Icons.language),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showLanguageSelector(preferences);
                },
              ),
              SwitchListTile(
                title: const Text('Auto-play AI Voice'),
                subtitle: const Text('Automatically speak AI responses'),
                value: preferences.autoPlayVoice,
                onChanged: (value) {
                  userProvider.updateAutoPlayVoice(value);
                },
                secondary: const Icon(Icons.record_voice_over),
              ),
              SwitchListTile(
                title: const Text('Voice Input'),
                subtitle: const Text('Enable speech-to-text input'),
                value: preferences.voiceInputEnabled,
                onChanged: (value) {
                  userProvider.updateVoiceInput(value);
                },
                secondary: const Icon(Icons.mic),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildARSettings() {
    return Consumer<ARProvider>(
      builder: (context, arProvider, child) {
        return Card(
          child: Column(
            children: [
              ListTile(
                title: const Text('AR Support'),
                subtitle: Text(
                  arProvider.isARSupported 
                    ? 'AR is supported on this device'
                    : 'AR is not supported on this device',
                ),
                leading: Icon(
                  arProvider.isARSupported ? Icons.check_circle : Icons.error,
                  color: arProvider.isARSupported ? Colors.green : Colors.red,
                ),
              ),
              if (arProvider.isARSupported) ...[
                ListTile(
                  title: const Text('Companion Scale'),
                  subtitle: Slider(
                    value: arProvider.companionScale,
                    min: 0.1,
                    max: 3.0,
                    divisions: 29,
                    label: '${arProvider.companionScale.toStringAsFixed(1)}x',
                    onChanged: (value) {
                      arProvider.updateCompanionScale(value);
                    },
                  ),
                  leading: const Icon(Icons.zoom_in),
                ),
                ListTile(
                  title: const Text('Test AR'),
                  subtitle: const Text('Check if AR camera works properly'),
                  leading: const Icon(Icons.camera_alt),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Get.toNamed('/ar-lobby');
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserPreferences() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final preferences = userProvider.currentUser?.preferences;
        if (preferences == null) return const SizedBox.shrink();

        return Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Receive app notifications'),
                value: preferences.notificationsEnabled,
                onChanged: (value) {
                  userProvider.updateNotifications(value);
                },
                secondary: const Icon(Icons.notifications),
              ),
              SwitchListTile(
                title: const Text('Haptic Feedback'),
                subtitle: const Text('Vibrate on interactions'),
                value: preferences.hapticsEnabled,
                onChanged: (value) {
                  userProvider.updateHaptics(value);
                },
                secondary: const Icon(Icons.vibration),
              ),
              SwitchListTile(
                title: const Text('Analytics'),
                subtitle: const Text('Help improve the app with usage data'),
                value: preferences.analyticsEnabled,
                onChanged: (value) {
                  userProvider.updateAnalytics(value);
                },
                secondary: const Icon(Icons.analytics),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppSettings() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('App Version'),
            subtitle: const Text('1.0.0+1'),
            leading: const Icon(Icons.info),
          ),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open privacy policy
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            leading: const Icon(Icons.description),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open terms of service
            },
          ),
          ListTile(
            title: const Text('Help & Support'),
            leading: const Icon(Icons.help),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Open help
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            leading: const Icon(Icons.storage),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showClearCacheDialog();
            },
          ),
          ListTile(
            title: const Text('Reset App'),
            subtitle: const Text('Reset all settings to default'),
            leading: const Icon(Icons.refresh, color: Colors.orange),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showResetDialog();
            },
          ),
          ListTile(
            title: const Text('Delete Account'),
            subtitle: const Text('Permanently delete your account'),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showColorPicker() {
    // Implement color picker dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Accent Color'),
        content: const Text('Color picker coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSelector(UserPreferences preferences) {
    final languages = ['en-US', 'es-ES', 'fr-FR', 'de-DE', 'it-IT', 'pt-BR'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) => ListTile(
            title: Text(_getLanguageName(lang)),
            onTap: () {
              Provider.of<UserProvider>(context, listen: false)
                  .updateVoiceLanguage(lang);
              Navigator.pop(context);
            },
            trailing: preferences.voiceLanguage == lang 
                ? const Icon(Icons.check) 
                : null,
          )).toList(),
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en-US': return 'English (US)';
      case 'es-ES': return 'Spanish';
      case 'fr-FR': return 'French';
      case 'de-DE': return 'German';
      case 'it-IT': return 'Italian';
      case 'pt-BR': return 'Portuguese (Brazil)';
      default: return code;
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will remove temporary files and free up storage space. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset App'),
        content: const Text('This will reset all settings to default values. This action cannot be undone. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement app reset
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('App reset successfully')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This will permanently delete your account and all data. This action cannot be undone. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion is not yet implemented')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}