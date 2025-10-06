import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_controller.dart';

class SettingsController extends GetxController {
  // Observable variables for Settings page
  var isDarkMode = false.obs;
  var isNotificationsEnabled = true.obs;
  var selectedLanguage = 'en'.obs;
  var audioQuality = 'high'.obs;
  var isOfflineMode = false.obs;

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
    final authController = Get.find<AuthController>();
    
    if (authController.isAuthenticated.value) {
      // Disconnect from Spotify
      await authController.disconnect();
    } else {
      // Connect to Spotify
      await authController.connectSpotify();
    }
  }

  // Connect to Spotify
  Future<void> connectSpotify() async {
    final authController = Get.find<AuthController>();
    await authController.connectSpotify();
  }

  // Disconnect from Spotify
  Future<void> disconnectSpotify() async {
    final authController = Get.find<AuthController>();
    await authController.disconnect();
  }
}
