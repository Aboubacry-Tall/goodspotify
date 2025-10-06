import 'package:get/get.dart';

class HomeController extends GetxController {
  // Observable variables for Home page
  var isLoading = false.obs;
  var recentTracks = <Map<String, dynamic>>[].obs;
  var recommendations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  // Load home page data
  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      
      // Data loading simulation
      await Future.delayed(const Duration(seconds: 2));
      
      // Here you will integrate the Spotify API
      recentTracks.value = [
        {'title': 'Track 1', 'artist': 'Artist 1', 'album': 'Album 1'},
        {'title': 'Track 2', 'artist': 'Artist 2', 'album': 'Album 2'},
      ];
      
      recommendations.value = [
        {'title': 'Recommended 1', 'artist': 'Artist A', 'album': 'Album A'},
        {'title': 'Recommended 2', 'artist': 'Artist B', 'album': 'Album B'},
      ];
      
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadHomeData();
  }
}
