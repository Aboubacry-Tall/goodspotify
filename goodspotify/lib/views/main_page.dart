import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import 'home/home_page.dart';
import 'top/top_page.dart';
import 'stats/stats_page.dart';
import 'settings/settings_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();

    return Scaffold(
      body: Obx(() {
        // Afficher la page correspondant à l'index sélectionné
        switch (navController.selectedIndex.value) {
          case 0:
            return const HomePage();
          case 1:
            return const TopPage();
          case 2:
            return const StatsPage();
          case 3:
            return const SettingsPage();
          default:
            return const HomePage();
        }
      }),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: navController.selectedIndex.value,
          onTap: navController.changeTabIndex,
          selectedItemColor: const Color(0xFF1DB954), // Spotify green
          unselectedItemColor: Colors.white70,
          backgroundColor: const Color(0xFF282828),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: 'Top',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        );
      }),
    );
  }
}
