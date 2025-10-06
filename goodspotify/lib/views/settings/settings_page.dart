import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Section Compte
            _buildSectionHeader('Compte'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      controller.isSpotifyConnected.value
                          ? Icons.check_circle
                          : Icons.music_note,
                      color: controller.isSpotifyConnected.value
                          ? Colors.green
                          : const Color(0xFF1DB954),
                    ),
                    title: Text(controller.isSpotifyConnected.value
                        ? 'Connecté à Spotify'
                        : 'Connecter à Spotify'),
                    subtitle: Text(controller.isSpotifyConnected.value
                        ? 'Vos données sont synchronisées'
                        : 'Connectez-vous pour accéder à vos données'),
                    trailing: ElevatedButton(
                      onPressed: controller.toggleSpotifyConnection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isSpotifyConnected.value
                            ? Colors.red
                            : const Color(0xFF1DB954),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(controller.isSpotifyConnected.value
                          ? 'Déconnecter'
                          : 'Connecter'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Apparence
            _buildSectionHeader('Apparence'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Mode sombre'),
                    subtitle: const Text('Activer le thème sombre'),
                    value: controller.isDarkMode.value,
                    onChanged: (_) => controller.toggleDarkMode(),
                    activeColor: const Color(0xFF1DB954),
                    secondary: const Icon(Icons.dark_mode),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Langue'),
                    subtitle: Text(_getLanguageName(controller.selectedLanguage.value)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showLanguageDialog(context, controller),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Audio
            _buildSectionHeader('Audio'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.high_quality),
                    title: const Text('Qualité audio'),
                    subtitle: Text(_getQualityName(controller.audioQuality.value)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showQualityDialog(context, controller),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Mode hors ligne'),
                    subtitle: const Text('Sauvegarder pour écoute hors ligne'),
                    value: controller.isOfflineMode.value,
                    onChanged: (_) => controller.toggleOfflineMode(),
                    activeColor: const Color(0xFF1DB954),
                    secondary: const Icon(Icons.offline_pin),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Section Notifications
            _buildSectionHeader('Notifications'),
            Card(
              child: SwitchListTile(
                title: const Text('Notifications push'),
                subtitle: const Text('Recevoir des alertes et recommandations'),
                value: controller.isNotificationsEnabled.value,
                onChanged: (_) => controller.toggleNotifications(),
                activeColor: const Color(0xFF1DB954),
                secondary: const Icon(Icons.notifications),
              ),
            ),

            const SizedBox(height: 24),

            // Section À propos
            _buildSectionHeader('À propos'),
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
                    title: const Text('Politique de confidentialité'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Ouvrir la politique de confidentialité
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Conditions d\'utilisation'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Ouvrir les conditions d'utilisation
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
        return 'Français';
    }
  }

  String _getQualityName(String quality) {
    switch (quality) {
      case 'low':
        return 'Basse (96 kbps)';
      case 'normal':
        return 'Normale (160 kbps)';
      case 'high':
        return 'Haute (320 kbps)';
      default:
        return 'Haute (320 kbps)';
    }
  }

  void _showLanguageDialog(BuildContext context, SettingsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
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
        title: const Text('Qualité audio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Basse (96 kbps)'),
              subtitle: const Text('Économise la bande passante'),
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
              title: const Text('Normale (160 kbps)'),
              subtitle: const Text('Équilibre qualité/data'),
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
              title: const Text('Haute (320 kbps)'),
              subtitle: const Text('Meilleure qualité'),
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
