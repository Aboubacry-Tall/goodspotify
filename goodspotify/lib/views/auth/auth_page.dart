import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1DB954), // Spotify Green
              Color(0xFF191414), // Spotify Black
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Title
                const Icon(
                  Icons.music_note,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 24),
                Text(
                  'GoodSpotify',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Spotify Statistics Dashboard',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 48),

                // Authentication Status
                Obx(() {
                  if (authController.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }

                  if (authController.isAuthenticated.value) {
                    return _buildAuthenticatedView(authController, context);
                  } else {
                    return _buildUnauthenticatedView(authController, context);
                  }
                }),

                const SizedBox(height: 32),

                // Features List
                _buildFeaturesList(context),

                const SizedBox(height: 32),

                // Footer
                Text(
                  'Connect your Spotify account to access your personalized statistics',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedView(AuthController authController, BuildContext context) {
    return Column(
      children: [
        // Success Icon
        const Icon(
          Icons.check_circle,
          size: 60,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        
        // Success Message
        Text(
          'Connected to Spotify!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        Text(
          'Welcome back! You can now access your Spotify data.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 24),

        // User Info
        if (authController.userProfile.value != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                if (authController.userProfileImageUrl != null)
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      authController.userProfileImageUrl!,
                    ),
                  )
                else
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  authController.userDisplayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (authController.userEmail != null)
                  Text(
                    authController.userEmail!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 24),

        // User Data Summary
        if (authController.userData.value != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Your Spotify Data',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDataItem('Artists', authController.topArtists.length.toString()),
                    _buildDataItem('Tracks', authController.topTracks.length.toString()),
                    _buildDataItem('Albums', authController.savedAlbums.length.toString()),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),

        // Refresh Data Button
        ElevatedButton(
          onPressed: authController.loadAllUserData,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            '🔄 Refresh Data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),

        // Disconnect Button
        ElevatedButton(
          onPressed: authController.disconnect,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Disconnect from Spotify',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedView(AuthController authController, BuildContext context) {
    return Column(
      children: [
        // Connect Button
        ElevatedButton(
          onPressed: authController.connectSpotify,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1DB954),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Connect to Spotify',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        
        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(
                'How to connect:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildInstructionStep('1', 'Click "Connect to Spotify"', Icons.touch_app),
              _buildInstructionStep('2', 'Login with your Spotify account', Icons.login),
              _buildInstructionStep('3', 'Click "Agree" to authorize the app', Icons.check_circle),
              _buildInstructionStep('4', 'Enjoy your Spotify data!', Icons.music_note),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Color(0xFF1DB954),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            color: Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    return const SizedBox();
  }

  Widget _buildDataItem(String label, String count) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
