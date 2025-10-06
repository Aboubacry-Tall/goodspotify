import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/spotify_service.dart';

class SettingsController extends GetxController {
  // Observable variables for Settings page
  var isDarkMode = false.obs;
  var isNotificationsEnabled = true.obs;
  var selectedLanguage = 'en'.obs;
  var audioQuality = 'high'.obs;
  var isOfflineMode = false.obs;
  var isSpotifyConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  // Load saved settings
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    isDarkMode.value = prefs.getBool('darkMode') ?? false;
    isNotificationsEnabled.value = prefs.getBool('notifications') ?? true;
    selectedLanguage.value = prefs.getString('language') ?? 'en';
    audioQuality.value = prefs.getString('audioQuality') ?? 'high';
    isOfflineMode.value = prefs.getBool('offlineMode') ?? false;
    isSpotifyConnected.value = prefs.getBool('spotifyConnected') ?? false;
  }

  // Toggle dark mode
  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDarkMode.value);
    
    // Change application theme
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Toggle notifications
  Future<void> toggleNotifications() async {
    isNotificationsEnabled.value = !isNotificationsEnabled.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', isNotificationsEnabled.value);
  }

  // Change language
  Future<void> changeLanguage(String language) async {
    selectedLanguage.value = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', language);
    
    // Change application locale
    Get.updateLocale(Locale(language));
  }

  // Change audio quality
  Future<void> changeAudioQuality(String quality) async {
    audioQuality.value = quality;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audioQuality', quality);
  }

  // Toggle offline mode
  Future<void> toggleOfflineMode() async {
    isOfflineMode.value = !isOfflineMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offlineMode', isOfflineMode.value);
  }

  // Connect/Disconnect Spotify
  Future<void> toggleSpotifyConnection() async {
    if (isSpotifyConnected.value) {
      // Disconnect from Spotify
      await disconnectSpotify();
    } else {
      // Connect to Spotify
      await connectSpotify();
    }
  }

  // Connect to Spotify
  Future<void> connectSpotify() async {
    try {
      // Use Spotify service for authentication
      final spotifyService = Get.find<SpotifyService>();
      final success = await spotifyService.authenticate();
      
      if (success) {
        isSpotifyConnected.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('spotifyConnected', true);
        
        Get.snackbar(
          'Success',
          'Connected to Spotify successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1DB954),
          colorText: Colors.white,
        );
      } else {
        throw Exception('Authentication failed');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Unable to connect to Spotify',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Disconnect from Spotify
  Future<void> disconnectSpotify() async {
    try {
      // Use Spotify service for disconnection
      final spotifyService = Get.find<SpotifyService>();
      await spotifyService.disconnect();
      
      isSpotifyConnected.value = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('spotifyConnected', false);
      
      Get.snackbar(
        'Disconnected',
        'Disconnected from Spotify successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error during disconnection',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
