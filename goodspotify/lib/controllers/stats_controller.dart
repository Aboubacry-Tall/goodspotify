import 'package:get/get.dart';

class StatsController extends GetxController {
  // Observable variables for Stats page
  var isLoading = false.obs;
  var listeningTime = 0.obs;
  var totalTracks = 0.obs;
  var totalArtists = 0.obs;
  var favoriteGenres = <Map<String, dynamic>>[].obs;
  var monthlyStats = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStatsData();
  }

  // Load statistics
  Future<void> loadStatsData() async {
    try {
      isLoading.value = true;
      
      // Data loading simulation
      await Future.delayed(const Duration(seconds: 2));
      
      // Here you will integrate Spotify API and local storage
      listeningTime.value = 12450; // minutes
      totalTracks.value = 1250;
      totalArtists.value = 150;
      
      favoriteGenres.value = [
        {'genre': 'Pop', 'percentage': 35.5, 'color': 0xFF1DB954},
        {'genre': 'Rock', 'percentage': 28.2, 'color': 0xFF191414},
        {'genre': 'Hip-Hop', 'percentage': 20.1, 'color': 0xFF1ED760},
        {'genre': 'Electronic', 'percentage': 16.2, 'color': 0xFF535353},
      ];
      
      monthlyStats.value = [
        {'month': 'Jan', 'hours': 45},
        {'month': 'Feb', 'hours': 52},
        {'month': 'Mar', 'hours': 38},
        {'month': 'Apr', 'hours': 61},
        {'month': 'May', 'hours': 47},
        {'month': 'Jun', 'hours': 55},
      ];
      
    } finally {
      isLoading.value = false;
    }
  }

  // Calculate listening time in readable format
  String get formattedListeningTime {
    int hours = listeningTime.value ~/ 60;
    int minutes = listeningTime.value % 60;
    return '${hours}h ${minutes}min';
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadStatsData();
  }
}
