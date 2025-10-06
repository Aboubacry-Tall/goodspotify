import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bindings/main_binding.dart';
import 'views/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Ici vous initialiserez Firebase
  // await Firebase.initializeApp();
  
  runApp(const GoodSpotifyApp());
}

class GoodSpotifyApp extends StatelessWidget {
  const GoodSpotifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GoodSpotify',
      debugShowCheckedModeBanner: false,
      
      // Configuration des thèmes
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      
      // Configuration GetX
      initialBinding: MainBinding(),
      
      // Page d'accueil
      home: const MainPage(),
      
      // Configuration des locales
      locale: const Locale('fr', 'FR'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1DB954), // Vert Spotify
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF1DB954),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1DB954), // Vert Spotify
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF191414), // Noir Spotify
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Color(0xFF1DB954),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Color(0xFF191414),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212), // Fond sombre Spotify
    );
  }
}