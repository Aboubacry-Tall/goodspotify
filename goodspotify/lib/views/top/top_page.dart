import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/top_controller.dart';

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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.topTracks.length,
      itemBuilder: (context, index) {
        final track = controller.topTracks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
              child: Text('${index + 1}'),
            ),
            title: Text(
              track['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(track['artist'] ?? ''),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.play_circle_outline),
                Text(
                  '${track['plays']} plays',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            onTap: () {
              // Play action
            },
          ),
        );
      },
    );
  }

  Widget _buildArtistsTab(TopController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.topArtists.length,
      itemBuilder: (context, index) {
        final artist = controller.topArtists[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
              child: Text('${index + 1}'),
            ),
            title: Text(
              artist['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('${artist['genre']} • ${artist['followers']} followers'),
            trailing: const Icon(Icons.person_outline),
            onTap: () {
              // Navigate to artist page
            },
          ),
        );
      },
    );
  }

  Widget _buildAlbumsTab(TopController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.topAlbums.length,
      itemBuilder: (context, index) {
        final album = controller.topAlbums[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF1DB954),
              foregroundColor: Colors.white,
              child: Text('${index + 1}'),
            ),
            title: Text(
              album['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text('${album['artist']} • ${album['year']}'),
            trailing: const Icon(Icons.album_outlined),
            onTap: () {
              // Navigate to album page
            },
          ),
        );
      },
    );
  }
}
