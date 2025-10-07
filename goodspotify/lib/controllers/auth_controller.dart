import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/spotify_service.dart';

class AuthController extends GetxController {
  // Observable variables for authentication
  var isLoading = false.obs;
  var isAuthenticated = false.obs;
  var userProfile = Rxn<Map<String, dynamic>>();
  
  // Observable variables for user data
  var userData = Rxn<Map<String, dynamic>>();
  var topArtists = <Map<String, dynamic>>[].obs;
  var topTracks = <Map<String, dynamic>>[].obs;
  var followedArtists = <Map<String, dynamic>>[].obs;
  var savedAlbums = <Map<String, dynamic>>[].obs;
  var savedTracks = <Map<String, dynamic>>[].obs;
  var recentlyPlayed = <Map<String, dynamic>>[].obs;
  var listeningStats = Rxn<Map<String, dynamic>>();

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
        await loadAllUserData();
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
        
        // Load user profile and all data
        await loadUserProfile();
        await loadAllUserData();
        
        // Verify authentication state
        if (isAuthenticated.value) {
          print('🎉 UI updated successfully, showing success message...');
          
          Get.snackbar(
            'Success',
            'Connected to Spotify! Loading your music data...',
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
      
      // Clear all user data
      userData.value = null;
      topArtists.clear();
      topTracks.clear();
      followedArtists.clear();
      savedAlbums.clear();
      savedTracks.clear();
      recentlyPlayed.clear();
      listeningStats.value = null;
      
      // Clear saved preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('spotifyConnected');
      await prefs.remove('user_data');
      
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

  // Load all user data from Spotify
  Future<void> loadAllUserData() async {
    try {
      print('🎵 Loading all user data...');
      
      final spotifyService = Get.find<SpotifyService>();
      final allData = await spotifyService.loadAllUserData(limit: 50);
      
      if (allData.isNotEmpty) {
        userData.value = allData;
        
        // Update observable variables
        topArtists.value = List<Map<String, dynamic>>.from(allData['topArtists'] ?? []);
        topTracks.value = List<Map<String, dynamic>>.from(allData['topTracks'] ?? []);
        followedArtists.value = List<Map<String, dynamic>>.from(allData['followedArtists'] ?? []);
        savedAlbums.value = List<Map<String, dynamic>>.from(allData['savedAlbums'] ?? []);
        savedTracks.value = List<Map<String, dynamic>>.from(allData['savedTracks'] ?? []);
        recentlyPlayed.value = List<Map<String, dynamic>>.from(allData['recentlyPlayed'] ?? []);
        listeningStats.value = allData['listeningStats'];
        
        print('✅ All user data loaded successfully:');
        print('   - Top artists: ${topArtists.length}');
        print('   - Top tracks: ${topTracks.length}');
        print('   - Followed artists: ${followedArtists.length}');
        print('   - Saved albums: ${savedAlbums.length}');
        print('   - Saved tracks: ${savedTracks.length}');
        print('   - Recently played: ${recentlyPlayed.length}');
        
        // Show success message
        Get.snackbar(
          'Data Loaded',
          'Successfully loaded ${topArtists.length + topTracks.length + savedAlbums.length} items from Spotify!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1DB954),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print('❌ Error loading all user data: $e');
      Get.snackbar(
        'Error',
        'Failed to load some data from Spotify',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
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

  // Get top artists
  Future<List<Map<String, dynamic>>> getTopArtists({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    try {
      final spotifyService = Get.find<SpotifyService>();
      return await spotifyService.getTopArtists(
        timeRange: timeRange,
        limit: limit,
      );
    } catch (e) {
      print('Error getting top artists: $e');
      return [];
    }
  }

  // Get top tracks
  Future<List<Map<String, dynamic>>> getTopTracks({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    try {
      final spotifyService = Get.find<SpotifyService>();
      return await spotifyService.getTopTracks(
        timeRange: timeRange,
        limit: limit,
      );
    } catch (e) {
      print('Error getting top tracks: $e');
      return [];
    }
  }

  // Get followed artists
  Future<List<Map<String, dynamic>>> getFollowedArtists({
    int limit = 20,
  }) async {
    try {
      final spotifyService = Get.find<SpotifyService>();
      return await spotifyService.getFollowedArtists(limit: limit);
    } catch (e) {
      print('Error getting followed artists: $e');
      return [];
    }
  }

  // Get all user's artists
  Future<Map<String, List<Map<String, dynamic>>>> getAllUserArtists({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    try {
      final spotifyService = Get.find<SpotifyService>();
      return await spotifyService.getAllUserArtists(
        timeRange: timeRange,
        limit: limit,
      );
    } catch (e) {
      print('Error getting all user artists: $e');
      return {'topArtists': [], 'followedArtists': []};
    }
  }

  // Test method to demonstrate artist retrieval
  Future<void> testArtistRetrieval() async {
    if (!isAuthenticated.value) {
      Get.snackbar(
        'Not Connected',
        'Please connect to Spotify first',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      print('🎵 Testing artist retrieval...');
      
      // Test getting top artists
      final topArtists = await getTopArtists(limit: 5);
      print('✅ Top artists: ${topArtists.length}');
      
      // Test getting followed artists
      final followedArtists = await getFollowedArtists(limit: 5);
      print('✅ Followed artists: ${followedArtists.length}');
      
      // Show results
      Get.snackbar(
        'Artists Retrieved',
        'Top: ${topArtists.length}, Followed: ${followedArtists.length}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1DB954),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
    } catch (e) {
      print('❌ Error testing artist retrieval: $e');
      Get.snackbar(
        'Error',
        'Failed to retrieve artists: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
