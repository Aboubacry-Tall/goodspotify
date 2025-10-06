import 'package:get/get.dart';

class HomeController extends GetxController {
  // Variables observables pour la page Home
  var isLoading = false.obs;
  var recentTracks = <Map<String, dynamic>>[].obs;
  var recommendations = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  // Charger les données de la page d'accueil
  Future<void> loadHomeData() async {
    try {
      isLoading.value = true;
      
      // Simulation de chargement de données
      await Future.delayed(const Duration(seconds: 2));
      
      // Ici vous intégrerez l'API Spotify
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

  // Rafraîchir les données
  Future<void> refreshData() async {
    await loadHomeData();
  }
}
