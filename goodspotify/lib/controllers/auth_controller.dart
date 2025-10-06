import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/spotify_service.dart';

class AuthController extends GetxController {
  // Observable variables for authentication
  var isLoading = false.obs;
  var isAuthenticated = false.obs;
  var userProfile = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    checkAuthenticationStatus();
  }

  // Check if user is already authenticated
  Future<void> checkAuthenticationStatus() async {
    try {
      isLoading.value = true;
      
      final spotifyService = Get.find<SpotifyService>();
      isAuthenticated.value = spotifyService.isConnected;
      
      if (isAuthenticated.value) {
        await loadUserProfile();
      }
    } catch (e) {
      print('Error checking authentication status: $e');
      isAuthenticated.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  // Connect to Spotify using flutter_web_auth_2
  Future<void> connectSpotify() async {
    try {
      isLoading.value = true;
      
      print('🎵 Starting Spotify authentication from controller...');
      
      final spotifyService = Get.find<SpotifyService>();
      final success = await spotifyService.authenticate();
      
      print('🎯 Authentication result: $success');
      
      if (success) {
        print('✅ Authentication successful, updating UI...');
        
        // Force UI update
        isAuthenticated.value = true;
        
        // Load user profile
        await loadUserProfile();
        
        // Verify authentication state
        if (isAuthenticated.value) {
          print('🎉 UI updated successfully, showing success message...');
          
          Get.snackbar(
            'Success',
            'Connected to Spotify successfully!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1DB954),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          
          print('🎵 Authentication flow completed successfully!');
        } else {
          print('❌ UI update failed - authentication state not set');
          throw Exception('Failed to update authentication state');
        }
      } else {
        print('⚠️ Authentication failed or canceled');
        // User canceled or authentication failed
        Get.snackbar(
          'Authentication Canceled',
          'Please try again. Make sure to click "Agree" on Spotify.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      print('❌ Spotify connection error: $e');
      
      String errorMessage = 'Unable to connect to Spotify. Please try again.';
      Color backgroundColor = Colors.red;
      
      if (e.toString().contains('User denied access')) {
        errorMessage = 'You denied access to Spotify. Please try again and click "Agree".';
        backgroundColor = Colors.orange;
      } else if (e.toString().contains('User canceled')) {
        errorMessage = 'Authentication was canceled. Please try again.';
        backgroundColor = Colors.orange;
      }
      
      Get.snackbar(
        'Connection Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      print('🔄 Setting loading to false...');
      isLoading.value = false;
    }
  }

  // Disconnect from Spotify
  Future<void> disconnect() async {
    try {
      isLoading.value = true;
      
      final spotifyService = Get.find<SpotifyService>();
      await spotifyService.disconnect();
      
      isAuthenticated.value = false;
      userProfile.value = null;
      
      // Clear saved preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('spotifyConnected');
      
      Get.snackbar(
        'Disconnected',
        'Successfully disconnected from Spotify',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Disconnection error: $e');
      
      Get.snackbar(
        'Disconnection Error',
        'Error during disconnection. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load user profile from Spotify
  Future<void> loadUserProfile() async {
    try {
      final spotifyService = Get.find<SpotifyService>();
      final profile = await spotifyService.getUserProfile();
      
      if (profile != null) {
        userProfile.value = profile;
        
        // Save connection status
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('spotifyConnected', true);
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Refresh authentication status
  Future<void> refreshAuthStatus() async {
    await checkAuthenticationStatus();
  }

  // Get user display name
  String get userDisplayName {
    if (userProfile.value != null) {
      return userProfile.value!['display_name'] ?? 'User';
    }
    return 'User';
  }

  // Get user email
  String? get userEmail {
    if (userProfile.value != null) {
      return userProfile.value!['email'];
    }
    return null;
  }

  // Get user profile image URL
  String? get userProfileImageUrl {
    if (userProfile.value != null && 
        userProfile.value!['images'] != null &&
        (userProfile.value!['images'] as List).isNotEmpty) {
      return userProfile.value!['images'][0]['url'];
    }
    return null;
  }
}
