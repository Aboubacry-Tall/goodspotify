import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  // Animation controller
  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<double> scaleAnimation;
  late Animation<double> slideAnimation;

  // Observable variables
  var isLoading = true.obs;
  var progress = 0.0.obs;
  var loadingMessage = 'Initializing...'.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAnimations();
    _startSplashSequence();
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  // Initialize animations
  void _initializeAnimations() {
    animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    animationController.forward();
  }

  // Start splash sequence
  Future<void> _startSplashSequence() async {
    try {
      // Step 1: Initialize app
      await _updateProgress(0.2, 'Initializing GoodSpotify...');
      await Future.delayed(const Duration(milliseconds: 800));

      // Step 2: Check authentication
      await _updateProgress(0.4, 'Checking authentication...');
      await _checkAuthentication();

      // Step 3: Load cached data
      await _updateProgress(0.6, 'Loading cached data...');
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 4: Prepare app
      await _updateProgress(0.8, 'Preparing your music...');
      await Future.delayed(const Duration(milliseconds: 600));

      // Step 5: Complete
      await _updateProgress(1.0, 'Ready to rock!');
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate to appropriate page
      _navigateToNextPage();
    } catch (e) {
      print('❌ Error during splash sequence: $e');
      await _updateProgress(1.0, 'Something went wrong...');
      await Future.delayed(const Duration(milliseconds: 1000));
      _navigateToNextPage();
    }
  }

  // Update progress and message
  Future<void> _updateProgress(double newProgress, String message) async {
    progress.value = newProgress;
    loadingMessage.value = message;
    
    // Add a small delay for smooth progress animation
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // Check authentication status
  Future<void> _checkAuthentication() async {
    try {
      final authController = Get.find<AuthController>();
      
      // Check if user was previously connected
      final prefs = await SharedPreferences.getInstance();
      final wasConnected = prefs.getBool('spotifyConnected') ?? false;
      
      if (wasConnected) {
        loadingMessage.value = 'Restoring your session...';
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Trigger authentication check
        await authController.checkAuthenticationStatus();
      } else {
        loadingMessage.value = 'Ready to connect...';
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      print('❌ Error checking authentication: $e');
    }
  }

  // Navigate to next page
  void _navigateToNextPage() {
    try {
      final authController = Get.find<AuthController>();
      
      if (authController.isAuthenticated.value) {
        print('🎵 User is authenticated, navigating to home');
        Get.offAllNamed('/home');
      } else {
        print('🔐 User not authenticated, navigating to auth');
        Get.offAllNamed('/auth');
      }
    } catch (e) {
      print('❌ Error navigating: $e');
      // Fallback to auth page
      Get.offAllNamed('/auth');
    }
  }

  // Get loading percentage
  int get loadingPercentage => (progress.value * 100).round();

  // Get progress color based on progress
  String get progressColor {
    if (progress.value < 0.3) return '#FF6B6B'; // Red
    if (progress.value < 0.6) return '#FFD93D'; // Yellow
    if (progress.value < 0.8) return '#6BCF7F'; // Light Green
    return '#1DB954'; // Spotify Green
  }
}
