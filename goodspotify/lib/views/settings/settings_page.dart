import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/auth_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find();
    final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Account Section
            _buildSectionHeader('Account'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      authController.isAuthenticated.value
                          ? Icons.check_circle
                          : Icons.music_note,
                      color: authController.isAuthenticated.value
                          ? Colors.green
                          : const Color(0xFF1DB954),
                    ),
                    title: Text(authController.isAuthenticated.value
                        ? 'Connected to Spotify'
                        : 'Connect to Spotify'),
                    subtitle: Text(authController.isAuthenticated.value
                        ? 'Your data is synchronized'
                        : 'Connect to access your data'),
                    trailing: ElevatedButton(
                      onPressed: controller.toggleSpotifyConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: authController.isAuthenticated.value
                            ? Colors.red
                            : const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(authController.isAuthenticated.value
                          ? 'Disconnect'
                          : 'Connect'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Appearance Section
            _buildSectionHeader('Appearance'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark theme'),
                    value: controller.isDarkMode.value,
                    onChanged: (_) => controller.toggleDarkMode(),
                    activeColor: const Color(0xFF1DB954),
                    secondary: const Icon(Icons.dark_mode),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    subtitle: Text(_getLanguageName(controller.selectedLanguage.value)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(context, controller),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Audio Section
            _buildSectionHeader('Audio'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.high_quality),
                    title: const Text('Audio Quality'),
                    subtitle: Text(_getQualityName(controller.audioQuality.value)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showQualityDialog(context, controller),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Offline Mode'),
                    subtitle: const Text('Save for offline listening'),
                    value: controller.isOfflineMode.value,
                    onChanged: (_) => controller.toggleOfflineMode(),
                    activeColor: const Color(0xFF1DB954),
                    secondary: const Icon(Icons.offline_pin),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            Card(
              child: SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receive alerts and recommendations'),
                value: controller.isNotificationsEnabled.value,
                onChanged: (_) => controller.toggleNotifications(),
                activeColor: const Color(0xFF1DB954),
                secondary: const Icon(Icons.notifications),
              ),
            ),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About'),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info),
                    title: Text('Version'),
                    subtitle: Text('1.0.0'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Open privacy policy
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Open terms of service
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1DB954),
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'fr':
        return 'Français';
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }

  String _getQualityName(String quality) {
    switch (quality) {
      case 'low':
        return 'Low (96 kbps)';
      case 'normal':
        return 'Normal (160 kbps)';
      case 'high':
        return 'High (320 kbps)';
      default:
        return 'High (320 kbps)';
    }
  }

  void _showLanguageDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Français'),
              value: 'fr',
              groupValue: controller.selectedLanguage.value,
              onChanged: (value) {
                if (value != null) {
                  controller.changeLanguage(value);
                  Navigator.pop(context);
                }
              },
              activeColor: const Color(0xFF1DB954),
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: controller.selectedLanguage.value,
              onChanged: (value) {
                if (value != null) {
                  controller.changeLanguage(value);
                  Navigator.pop(context);
                }
              },
              activeColor: const Color(0xFF1DB954),
            ),
            RadioListTile<String>(
              title: const Text('Español'),
              value: 'es',
              groupValue: controller.selectedLanguage.value,
              onChanged: (value) {
                if (value != null) {
                  controller.changeLanguage(value);
                  Navigator.pop(context);
                }
              },
              activeColor: const Color(0xFF1DB954),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualityDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Low (96 kbps)'),
              subtitle: const Text('Saves bandwidth'),
              value: 'low',
              groupValue: controller.audioQuality.value,
              onChanged: (value) {
                if (value != null) {
                  controller.changeAudioQuality(value);
                  Navigator.pop(context);
                }
              },
              activeColor: const Color(0xFF1DB954),
            ),
            RadioListTile<String>(
              title: const Text('Normal (160 kbps)'),
              subtitle: const Text('Balanced quality/data'),
              value: 'normal',
              groupValue: controller.audioQuality.value,
              onChanged: (value) {
                if (value != null) {
                  controller.changeAudioQuality(value);
                  Navigator.pop(context);
                }
              },
              activeColor: const Color(0xFF1DB954),
            ),
            RadioListTile<String>(
              title: const Text('High (320 kbps)'),
              subtitle: const Text('Best quality'),
              value: 'high',
              groupValue: controller.audioQuality.value,
              onChanged: (value) {
                if (value != null) {
                  controller.changeAudioQuality(value);
                  Navigator.pop(context);
                }
              },
              activeColor: const Color(0xFF1DB954),
            ),
          ],
        ),
      ),
    );
  }
}
