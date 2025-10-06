import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Selected tab index
  var selectedIndex = 0.obs;

  // Function to change tab
  void changeTabIndex(int index) {
    selectedIndex.value = index;
  }

  // Getter for current index
  int get currentIndex => selectedIndex.value;
}
