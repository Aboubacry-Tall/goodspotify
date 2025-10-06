import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/top_controller.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/spotify_service.dart';
import '../services/firebase_service.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Injecter les services d'abord
    Get.put<SpotifyService>(SpotifyService(), permanent: true);
    Get.put<FirebaseService>(FirebaseService(), permanent: true);
    
    // Injecter tous les contrôleurs principaux
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<TopController>(() => TopController());
    Get.lazyPut<StatsController>(() => StatsController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
