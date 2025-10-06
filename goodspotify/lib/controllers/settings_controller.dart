import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/spotify_service.dart';

class SettingsController extends GetxController {
  // Variables observables pour la page Settings
  var isDarkMode = false.obs;
  var isNotificationsEnabled = true.obs;
  var selectedLanguage = 'fr'.obs;
  var audioQuality = 'high'.obs;
  var isOfflineMode = false.obs;
  var isSpotifyConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Charger les paramètres sauvegardés
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    isDarkMode.value = prefs.getBool('darkMode') ?? false;
    isNotificationsEnabled.value = prefs.getBool('notifications') ?? true;
    selectedLanguage.value = prefs.getString('language') ?? 'fr';
    audioQuality.value = prefs.getString('audioQuality') ?? 'high';
    isOfflineMode.value = prefs.getBool('offlineMode') ?? false;
    isSpotifyConnected.value = prefs.getBool('spotifyConnected') ?? false;
  }

  // Changer le mode sombre
  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode.value);
    
    // Changer le thème de l'application
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Changer les notifications
  Future<void> toggleNotifications() async {
    isNotificationsEnabled.value = !isNotificationsEnabled.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', isNotificationsEnabled.value);
  }

  // Changer la langue
  Future<void> changeLanguage(String language) async {
    selectedLanguage.value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    
    // Changer la locale de l'application
    Get.updateLocale(Locale(language));
  }

  // Changer la qualité audio
  Future<void> changeAudioQuality(String quality) async {
    audioQuality.value = quality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audioQuality', quality);
  }

  // Mode hors ligne
  Future<void> toggleOfflineMode() async {
    isOfflineMode.value = !isOfflineMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offlineMode', isOfflineMode.value);
  }

  // Connexion/Déconnexion Spotify
  Future<void> toggleSpotifyConnection() async {
    if (isSpotifyConnected.value) {
      // Déconnecter de Spotify
      await disconnectSpotify();
    } else {
      // Connecter à Spotify
      await connectSpotify();
    }
  }

  // Connecter à Spotify
  Future<void> connectSpotify() async {
    try {
      // Utiliser le service Spotify pour l'authentification
      final spotifyService = Get.find<SpotifyService>();
      final success = await spotifyService.authenticate();
      
      if (success) {
        isSpotifyConnected.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('spotifyConnected', true);
        
        Get.snackbar(
          'Succès',
          'Connecté à Spotify avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1DB954),
          colorText: Colors.white,
        );
      } else {
        throw Exception('Échec de l\'authentification');
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de se connecter à Spotify',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Déconnecter de Spotify
  Future<void> disconnectSpotify() async {
    try {
      // Utiliser le service Spotify pour la déconnexion
      final spotifyService = Get.find<SpotifyService>();
      await spotifyService.disconnect();
      
      isSpotifyConnected.value = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('spotifyConnected', false);
      
      Get.snackbar(
        'Déconnecté',
        'Déconnecté de Spotify avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la déconnexion',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
