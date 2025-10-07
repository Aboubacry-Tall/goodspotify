import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/auth_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find();
    final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('GoodSpotify'),
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: const Color(0xFF1DB954),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Bienvenue
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${authController.userDisplayName}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Discover your Spotify statistics',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Statistics Cards
                if (authController.isAuthenticated.value)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Top Artists',
                          '${authController.topArtists.length}',
                          Icons.person,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Top Tracks',
                          '${authController.topTracks.length}',
                          Icons.music_note,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),

                if (authController.isAuthenticated.value)
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Saved Albums',
                          '${authController.savedAlbums.length}',
                          Icons.album,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Followed Artists',
                          '${authController.followedArtists.length}',
                          Icons.favorite,
                          Colors.red,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Recently played section
                if (authController.isAuthenticated.value)
                  Text(
                    'Recently Played',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (authController.isAuthenticated.value)
                  const SizedBox(height: 16),
                
                if (authController.isAuthenticated.value)
                  controller.recentTracks.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No recent tracks found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.recentTracks.length,
                          itemBuilder: (context, index) {
                            final track = controller.recentTracks[index];
                            final trackData = track['track'] as Map<String, dynamic>? ?? track;
                            final artists = trackData['artists'] as List<dynamic>? ?? [];
                            final album = trackData['album'] as Map<String, dynamic>? ?? {};
                            final albumImages = album['images'] as List<dynamic>? ?? [];
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: albumImages.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(albumImages[0]['url']),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: albumImages.isEmpty
                                      ? Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1DB954).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.music_note,
                                            color: Color(0xFF1DB954),
                                          ),
                                        )
                                      : null,
                                ),
                                title: Text(
                                  trackData['name'] ?? 'Unknown Track',
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  artists.map((a) => a['name']).join(', '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: const Icon(Icons.play_circle_outline),
                                onTap: () {
                                  // Play action
                                  print('Playing track: ${trackData['name']}');
                                },
                              ),
                            );
                          },
                        ),

                const SizedBox(height: 24),

                // Top Tracks section (recommendations)
                if (authController.isAuthenticated.value)
                  Text(
                    'Your Top Tracks',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (authController.isAuthenticated.value)
                  const SizedBox(height: 16),
                
                if (authController.isAuthenticated.value)
                  SizedBox(
                    height: 200,
                    child: controller.recommendations.isEmpty
                        ? const Center(
                            child: Text(
                              'No top tracks found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.recommendations.length,
                            itemBuilder: (context, index) {
                              final track = controller.recommendations[index];
                              final artists = track['artists'] as List<dynamic>? ?? [];
                              final album = track['album'] as Map<String, dynamic>? ?? {};
                              final albumImages = album['images'] as List<dynamic>? ?? [];
                              
                              return Container(
                                width: 150,
                                margin: const EdgeInsets.only(right: 16),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: albumImages.isNotEmpty
                                                  ? DecorationImage(
                                                      image: NetworkImage(albumImages[0]['url']),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                            child: albumImages.isEmpty
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF1DB954).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Icon(
                                                      Icons.music_note,
                                                      size: 40,
                                                      color: Color(0xFF1DB954),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          track['name'] ?? 'Unknown Track',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          artists.map((a) => a['name']).join(', '),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
