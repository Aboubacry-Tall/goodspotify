import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Index de l'onglet sélectionné
  var selectedIndex = 0.obs;

  // Fonction pour changer d'onglet
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  // Getter pour l'index actuel
  int get currentIndex => selectedIndex.value;
}
