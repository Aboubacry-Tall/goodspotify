import 'package:get/get.dart';

class TopController extends GetxController with GetSingleTickerProviderStateMixin {
  // Observable variables for Top page
  var isLoading = false.obs;
  var selectedTabIndex = 0.obs;
  var topTracks = <Map<String, dynamic>>[].obs;
  var topArtists = <Map<String, dynamic>>[].obs;
  var topAlbums = <Map<String, dynamic>>[].obs;
  var timeRange = 'short_term'.obs; // short_term, medium_term, long_term

  @override
  void onInit() {
    super.onInit();
    loadTopData();
  }

  // Load top data
  Future<void> loadTopData() async {
    try {
      isLoading.value = true;
      
      // Data loading simulation
      await Future.delayed(const Duration(seconds: 2));
      
      // Here you will integrate the Spotify API
      topTracks.value = [
        {'name': 'Top Track 1', 'artist': 'Artist 1', 'plays': 250},
        {'name': 'Top Track 2', 'artist': 'Artist 2', 'plays': 200},
        {'name': 'Top Track 3', 'artist': 'Artist 3', 'plays': 180},
      ];
      
      topArtists.value = [
        {'name': 'Top Artist 1', 'followers': 1000000, 'genre': 'Pop'},
        {'name': 'Top Artist 2', 'followers': 800000, 'genre': 'Rock'},
        {'name': 'Top Artist 3', 'followers': 600000, 'genre': 'Hip-Hop'},
      ];
      
      topAlbums.value = [
        {'name': 'Top Album 1', 'artist': 'Artist 1', 'year': 2024},
        {'name': 'Top Album 2', 'artist': 'Artist 2', 'year': 2023},
        {'name': 'Top Album 3', 'artist': 'Artist 3', 'year': 2023},
      ];
      
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
