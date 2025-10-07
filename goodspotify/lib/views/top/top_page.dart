import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/top_controller.dart';
import '../details/details_page.dart';

class TopPage extends StatelessWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TopController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Charts'),
        backgroundColor: const Color(0xFF1DB954),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: controller.changeTimeRange,
            itemBuilder: (context) => [
              const PopupMenuItem(
              value: 'short_term',
              child: Text('Last 4 weeks'),
            ),
            const PopupMenuItem(
              value: 'medium_term',
              child: Text('Last 6 months'),
            ),
            const PopupMenuItem(
              value: 'long_term',
              child: Text('All time'),
              ),
            ],
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.filter_list),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Onglets
          Container(
            color: const Color(0xFF1DB954),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.changeTabIndex(0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: controller.selectedTabIndex.value == 0
                            ? const Border(bottom: BorderSide(color: Colors.white, width: 2))
                            : null,
                      ),
                      child: Text(
                        'Tracks',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: controller.selectedTabIndex.value == 0 
                              ? Colors.white 
                              : Colors.white70,
                          fontWeight: controller.selectedTabIndex.value == 0 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.changeTabIndex(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: controller.selectedTabIndex.value == 1
                            ? const Border(bottom: BorderSide(color: Colors.white, width: 2))
                            : null,
                      ),
                      child: Text(
                        'Artists',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: controller.selectedTabIndex.value == 1 
                              ? Colors.white 
                              : Colors.white70,
                          fontWeight: controller.selectedTabIndex.value == 1 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.changeTabIndex(2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: controller.selectedTabIndex.value == 2
                            ? const Border(bottom: BorderSide(color: Colors.white, width: 2))
                            : null,
                      ),
                      child: Text(
                        'Albums',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: controller.selectedTabIndex.value == 2 
                              ? Colors.white 
                              : Colors.white70,
                          fontWeight: controller.selectedTabIndex.value == 2 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu des onglets
          Expanded(
            child: Obx(() {
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
                child: IndexedStack(
                  index: controller.selectedTabIndex.value,
                  children: [
                    // Onglet Titres
                    _buildTracksTab(controller),
                    // Onglet Artistes
                    _buildArtistsTab(controller),
                    // Onglet Albums
                    _buildAlbumsTab(controller),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTracksTab(TopController controller) {
    if (controller.topTracks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No tracks found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Connect to Spotify to see your top tracks',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.topTracks.length,
      itemBuilder: (context, index) {
        final track = controller.topTracks[index];
        final artists = track['artists'] as List<dynamic>? ?? [];
        final album = track['album'] as Map<String, dynamic>? ?? {};
        final albumImages = album['images'] as List<dynamic>? ?? [];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF1DB954),
                  backgroundImage: albumImages.isNotEmpty 
                      ? NetworkImage(albumImages[0]['url'])
                      : null,
                  child: albumImages.isEmpty 
                      ? const Icon(Icons.music_note, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1DB954),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              track['name'] ?? 'Unknown Track',
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artists.map((a) => a['name']).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  album['name'] ?? 'Unknown Album',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_outline, color: Color(0xFF1DB954)),
                Text(
                  '${track['popularity'] ?? 0}%',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1DB954)),
                ),
              ],
            ),
            onTap: () {
              // Navigate to track details
              Get.to(() => DetailsPage(
                itemId: track['id'] ?? '',
                itemType: 'track',
                itemData: track,
              ));
            },
          ),
        );
      },
    );
  }

  Widget _buildArtistsTab(TopController controller) {
    if (controller.topArtists.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No artists found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Connect to Spotify to see your top artists',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.topArtists.length,
      itemBuilder: (context, index) {
        final artist = controller.topArtists[index];
        final images = artist['images'] as List<dynamic>? ?? [];
        final followers = artist['followers'] as Map<String, dynamic>? ?? {};
        final genres = artist['genres'] as List<dynamic>? ?? [];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF1DB954),
                  backgroundImage: images.isNotEmpty 
                      ? NetworkImage(images[0]['url'])
                      : null,
                  child: images.isEmpty 
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1DB954),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              artist['name'] ?? 'Unknown Artist',
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_formatFollowers(followers['total'] ?? 0)} followers',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (genres.isNotEmpty)
                  Text(
                    genres.take(2).join(', '),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Color(0xFF1DB954)),
                Text(
                  '${artist['popularity'] ?? 0}%',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1DB954)),
                ),
              ],
            ),
            onTap: () {
              // Navigate to artist details
              Get.to(() => DetailsPage(
                itemId: artist['id'] ?? '',
                itemType: 'artist',
                itemData: artist,
              ));
            },
          ),
        );
      },
    );
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }

  Widget _buildAlbumsTab(TopController controller) {
    if (controller.topAlbums.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.album_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No albums found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Save some albums on Spotify to see them here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.topAlbums.length,
      itemBuilder: (context, index) {
        final album = controller.topAlbums[index];
        final images = album['images'] as List<dynamic>? ?? [];
        final artists = album['artists'] as List<dynamic>? ?? [];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Stack(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF1DB954),
                  backgroundImage: images.isNotEmpty 
                      ? NetworkImage(images[0]['url'])
                      : null,
                  child: images.isEmpty 
                      ? const Icon(Icons.album, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1DB954),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              album['name'] ?? 'Unknown Album',
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artists.map((a) => a['name']).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${album['total_tracks'] ?? 0} tracks • ${album['release_date'] ?? 'Unknown year'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.album_outlined, color: Color(0xFF1DB954)),
                Text(
                  '${album['popularity'] ?? 0}%',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1DB954)),
                ),
              ],
            ),
            onTap: () {
              // Navigate to album details
              Get.to(() => DetailsPage(
                itemId: album['id'] ?? '',
                itemType: 'album',
                itemData: album,
              ));
            },
          ),
        );
      },
    );
  }
}
