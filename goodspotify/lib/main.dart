import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'bindings/main_binding.dart';
import 'views/splash/splash_page.dart';
import 'views/app_navigator.dart';
import 'views/auth/auth_page.dart';
import 'services/spotify_service.dart';
import 'controllers/auth_controller.dart';

late AppLinks _appLinks;
StreamSubscription<Uri>? _linkSubscription;
bool _hasHandledInitialLink = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Application utilise uniquement Spotify API et stockage local
  
  runApp(const GoodSpotifyApp());
}

// Initialize deep link handling
Future<void> initDeepLinkHandling() async {
  _appLinks = AppLinks();
  
  try {
    // Get initial link but don't handle it immediately
    // (it might be an old callback from a previous session)
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      print('📱 Initial link detected: $initialLink');
      print('⏭️ Skipping initial link - will only handle new callbacks');
      _hasHandledInitialLink = true;
    }
    
    // Listen for NEW links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      print('🔗 New deep link received: $uri');
      _handleDeepLink(uri);
    }, onError: (err) {
      print('❌ Error listening to deep links: $err');
    });
  } catch (e) {
    print('❌ Error initializing deep link handling: $e');
  }
}

// Handle deep link callback
void _handleDeepLink(Uri uri) async {
  print('🔗 Received deep link: $uri');
  
  if (uri.scheme == 'com.goodspotify.stream' && uri.host == 'callback') {
    try {
      // Wait a bit to ensure services are initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      final spotifyService = Get.find<SpotifyService>();
      final authController = Get.find<AuthController>();
      
      final success = await spotifyService.handleAuthorizationCallback(uri);
      
      if (success) {
        print('✅ OAuth callback handled successfully');
        
        // Mark as connected in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('spotifyConnected', true);
        
        await authController.loadUserProfile();
        await authController.loadAllUserData();
        
        Get.offAllNamed('/home');
      } else {
        print('❌ OAuth callback failed - grant may not be available');
        print('💡 Please try connecting again from the auth page');
      }
    } catch (e) {
      print('❌ Error handling OAuth callback: $e');
    }
  }
}

class GoodSpotifyApp extends StatefulWidget {
  const GoodSpotifyApp({super.key});

  @override
  State<GoodSpotifyApp> createState() => _GoodSpotifyAppState();
}

class _GoodSpotifyAppState extends State<GoodSpotifyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize deep link handling after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initDeepLinkHandling();
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GoodSpotify',
      debugShowCheckedModeBanner: false,
      
      // Theme configuration
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      
      // GetX configuration
      initialBinding: MainBinding(),
      
      // Routes configuration
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashPage(),
        ),
        GetPage(
          name: '/auth',
          page: () => const AuthPage(),
        ),
        GetPage(
          name: '/home',
          page: () => const AppNavigator(),
        ),
      ],
      
      // Initial route
      initialRoute: '/',
      
      // Locale configuration
      locale: const Locale('en', 'US'),
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
        backgroundColor: Color(0xFF191414), // Spotify black
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
      scaffoldBackgroundColor: const Color(0xFF121212), // Spotify dark background
    );
  }
}