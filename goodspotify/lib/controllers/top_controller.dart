import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'auth_controller.dart';

class TopController extends GetxController with GetSingleTickerProviderStateMixin {
  // Observable variables for Top page
  var isLoading = false.obs;
  var selectedTabIndex = 0.obs;
  var topTracks = <Map<String, dynamic>>[].obs;
  var topArtists = <Map<String, dynamic>>[].obs;
  var topAlbums = <Map<String, dynamic>>[].obs;
  var timeRange = 'medium_term'.obs; // short_term, medium_term, long_term
  
  late AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    loadTopData();
  }

  // Load top data from Spotify
  Future<void> loadTopData() async {
    try {
      isLoading.value = true;
      
      if (!_authController.isAuthenticated.value) {
        print('❌ User not authenticated');
        topTracks.clear();
        topArtists.clear();
        topAlbums.clear();
        return;
      }

      print('🎵 Loading top data for time range: ${timeRange.value}');
      
      // Get data from auth controller
      final topArtistsData = await _authController.getTopArtists(
        timeRange: timeRange.value,
        limit: 50,
      );
      
      final topTracksData = await _authController.getTopTracks(
        timeRange: timeRange.value,
        limit: 50,
      );
      
      final savedAlbumsData = _authController.savedAlbums;
      
      // Update observable lists
      topArtists.value = topArtistsData;
      topTracks.value = topTracksData;
      topAlbums.value = savedAlbumsData.take(50).toList();
      
      print('✅ Top data loaded:');
      print('   - Top artists: ${topArtists.length}');
      print('   - Top tracks: ${topTracks.length}');
      print('   - Top albums: ${topAlbums.length}');
      
    } catch (e) {
      print('❌ Error loading top data: $e');
      Get.snackbar(
        'Error',
        'Failed to load top data from Spotify',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Change selected tab
  void changeTabIndex(int index) {
    selectedTabIndex.value = index;
  }

  // Change time range
  void changeTimeRange(String range) {
    timeRange.value = range;
    loadTopData(); // Reload data with new time range
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadTopData();
  }
}
