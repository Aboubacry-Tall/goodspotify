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
    _loadCachedUserInfo();
    checkAuthenticationStatus();
  }

  // Load cached user info for quick display
  Future<void> _loadCachedUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final displayName = prefs.getString('userDisplayName');
      final email = prefs.getString('userEmail');
      final userId = prefs.getString('userId');
      final lastLoginTime = prefs.getString('lastLoginTime');
      
      if (displayName != null) {
        // Create a minimal profile from cached data
        userProfile.value = {
          'id': userId ?? '',
          'display_name': displayName,
          'email': email ?? '',
          'images': [],
          'followers': {'total': 0},
        };
        
        print('📱 Loaded cached user info: $displayName');
        if (lastLoginTime != null) {
          final lastLogin = DateTime.parse(lastLoginTime);
          final timeDiff = DateTime.now().difference(lastLogin);
          print('⏰ Last login: ${timeDiff.inHours} hours ago');
        }
      }
    } catch (e) {
      print('❌ Error loading cached user info: $e');
    }
  }

  // Check if user is already authenticated
  Future<void> checkAuthenticationStatus() async {
    try {
      isLoading.value = true;
      
      final spotifyService = Get.find<SpotifyService>();
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user was previously connected
      final wasConnected = prefs.getBool('spotifyConnected') ?? false;
      
      if (wasConnected && spotifyService.isConnected) {
        print('🔄 User was previously connected, verifying token...');
        
        // Check if session might be expired first
        final isExpired = await _isSessionExpired();
        if (isExpired) {
          print('⏰ Session expired (more than 24 hours old), attempting refresh...');
        }
        
        // Verify token is still valid by making a test API call
        final isValid = await _verifyTokenValidity();
        
        if (isValid) {
          print('✅ Token is valid, user is authenticated');
          isAuthenticated.value = true;
          await loadUserProfile();
          await loadAllUserData();
        } else {
          print('❌ Token expired, attempting refresh...');
          final refreshed = await spotifyService.refreshAccessToken();
          
          if (refreshed) {
            print('✅ Token refreshed successfully');
            isAuthenticated.value = true;
            await loadUserProfile();
            await loadAllUserData();
          } else {
            print('❌ Token refresh failed, user needs to reconnect');
            await _clearAuthData();
          }
        }
      } else {
        print('ℹ️ User not previously connected or tokens not found');
        isAuthenticated.value = false;
      }
    } catch (e) {
      print('❌ Error checking authentication status: $e');
      isAuthenticated.value = false;
      await _clearAuthData();
    } finally {
      isLoading.value = false;
    }
  }

  // Verify if the current token is still valid
  Future<bool> _verifyTokenValidity() async {
    try {
      final spotifyService = Get.find<SpotifyService>();
      final profile = await spotifyService.getUserProfile();
      return profile != null;
    } catch (e) {
      print('❌ Token verification failed: $e');
      return false;
    }
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    try {
      // Clear observable variables
      isAuthenticated.value = false;
      userProfile.value = null;
      userData.value = null;
      topArtists.clear();
      topTracks.clear();
      followedArtists.clear();
      savedAlbums.clear();
      savedTracks.clear();
      recentlyPlayed.clear();
      listeningStats.value = null;
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('spotifyConnected');
      await prefs.remove('user_data');
      await prefs.remove('lastLoginTime');
      await prefs.remove('userDisplayName');
      await prefs.remove('userEmail');
      await prefs.remove('userId');
      
      // Clear tokens from Spotify service
      final spotifyService = Get.find<SpotifyService>();
      await spotifyService.disconnect();
      
      print('🧹 All authentication data cleared from memory and storage');
    } catch (e) {
      print('❌ Error clearing auth data: $e');
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
      
      // Clear all authentication data
      await _clearAuthData();
      
      Get.snackbar(
        'Disconnected',
        'Successfully disconnected from Spotify',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      print('👋 User disconnected from Spotify');
    } catch (e) {
      print('❌ Disconnection error: $e');
      
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
        
        // Save connection status and user info
        await _saveAuthState();
        
        print('✅ User profile loaded and saved: ${profile['display_name']}');
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
    }
  }

  // Save authentication state to SharedPreferences
  Future<void> _saveAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save connection status
      await prefs.setBool('spotifyConnected', true);
      
      // Save login timestamp
      await prefs.setString('lastLoginTime', DateTime.now().toIso8601String());
      
      // Save user basic info for quick access
      if (userProfile.value != null) {
        await prefs.setString('userDisplayName', userProfile.value!['display_name'] ?? '');
        await prefs.setString('userEmail', userProfile.value!['email'] ?? '');
        await prefs.setString('userId', userProfile.value!['id'] ?? '');
      }
      
      print('💾 Authentication state saved to SharedPreferences');
    } catch (e) {
      print('❌ Error saving auth state: $e');
    }
  }

  // Check if session might be expired (more than 24 hours old)
  Future<bool> _isSessionExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginTime = prefs.getString('lastLoginTime');
      
      if (lastLoginTime != null) {
        final lastLogin = DateTime.parse(lastLoginTime);
        final timeDiff = DateTime.now().difference(lastLogin);
        return timeDiff.inHours > 24; // Consider expired after 24 hours
      }
      return true;
    } catch (e) {
      print('❌ Error checking session expiry: $e');
      return true;
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

  // Get recently played tracks
  Future<List<Map<String, dynamic>>> getRecentlyPlayed({
    int limit = 20,
  }) async {
    try {
      final spotifyService = Get.find<SpotifyService>();
      return await spotifyService.getRecentlyPlayed(limit: limit);
    } catch (e) {
      print('Error getting recently played tracks: $e');
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
