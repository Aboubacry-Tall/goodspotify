import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'auth_controller.dart';

class HomeController extends GetxController {
  // Observable variables for Home page
  var isLoading = false.obs;
  var recentTracks = <Map<String, dynamic>>[].obs;
  var recommendations = <Map<String, dynamic>>[].obs;
  
  late AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    loadHomeData();
  }

  // Load home page data from Spotify
  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      
      if (!_authController.isAuthenticated.value) {
        print('❌ User not authenticated');
        recentTracks.clear();
        recommendations.clear();
        return;
      }

      print('🏠 Loading home page data...');
      
      // Get recently played tracks from Spotify API
      final recentlyPlayedData = await _authController.getRecentlyPlayed(limit: 10);
      recentTracks.value = recentlyPlayedData;
      
      // Get top tracks as recommendations (first 10)
      recommendations.value = _authController.topTracks.take(10).toList();
      
      print('✅ Home data loaded:');
      print('   - Recent tracks: ${recentTracks.length}');
      print('   - Recommendations: ${recommendations.length}');
      
    } catch (e) {
      print('❌ Error loading home data: $e');
      Get.snackbar(
        'Error',
        'Failed to load home data from Spotify',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadHomeData();
  }
}
