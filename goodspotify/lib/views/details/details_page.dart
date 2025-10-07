import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';
import '../../controllers/details_controller.dart';

class DetailsPage extends StatelessWidget {
  final String itemId;
  final String itemType;
  final Map<String, dynamic>? itemData;

  const DetailsPage({
    super.key,
    required this.itemId,
    required this.itemType,
    this.itemData,
  });

  @override
  Widget build(BuildContext context) {
    final DetailsController controller = Get.put(DetailsController());

    // Initialize controller with data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadDetails(
        itemId: itemId,
        itemType: itemType,
        initialData: itemData,
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1DB954), Color(0xFF121212)],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        if (controller.itemData.value == null) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1DB954), Color(0xFF121212)],
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white70,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Unable to load details',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final data = controller.itemData.value!;
        
        return _buildDetailsView(context, data, controller);
      }),
    );
  }

  Widget _buildDetailsView(BuildContext context, Map<String, dynamic> data, DetailsController controller) {
    switch (itemType) {
      case 'artist':
        return _buildArtistDetailsView(context, data, controller);
      case 'track':
        return _buildTrackDetailsView(context, data, controller);
      case 'album':
        return _buildAlbumDetailsView(context, data, controller);
      default:
        return _buildArtistDetailsView(context, data, controller);
    }
  }

  Widget _buildArtistDetailsView(BuildContext context, Map<String, dynamic> data, DetailsController controller) {
    final imageUrl = data['images']?.isNotEmpty == true ? data['images'][0]['url'] : null;
    final name = data['name'] ?? 'Unknown Artist';
    final followers = data['followers']?['total'] ?? 0;
    final popularity = data['popularity'] ?? 0;
    final genres = data['genres'] as List<dynamic>? ?? [];

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 450,
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1DB954), Color(0xFF121212)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                        Color(0xFF121212),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.play_circle_filled, color: Colors.white, size: 30),
              onPressed: () {
                // Play functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white, size: 24),
              onPressed: () {
                // Share functionality
              },
            ),
          ],
          leading: const SizedBox.shrink(),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFF121212),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info and Stats tabs
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      Text(
                        'Info',
                        style: TextStyle(
                          color: Color(0xFF1DB954),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 40),
                      Text(
                        'Stats',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                // Stats section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          value: '${(popularity / 10).toStringAsFixed(1)}',
                          label: '0-10 popularity',
                          color: const Color(0xFF1DB954),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildStatCard(
                          value: _formatFollowers(followers),
                          label: 'followers',
                          color: const Color(0xFF1DB954),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Genres section
                if (genres.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Genres',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: genres.take(6).map((genre) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF282828),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          genre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
                // Top tracks section
                _buildTopTracksSection(controller),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String value, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTracksSection(DetailsController controller) {
    if (controller.relatedItems.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Your top tracks by ${controller.itemData.value?['name'] ?? 'this artist'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.relatedItems.length.clamp(0, 10),
          itemBuilder: (context, index) {
            final track = controller.relatedItems[index];
            final artists = track['artists'] as List<dynamic>? ?? [];
            final album = track['album'] as Map<String, dynamic>? ?? {};
            final albumImages = album['images'] as List<dynamic>? ?? [];
            final duration = track['duration_ms'] as int? ?? 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Track number
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1DB954),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Track image and info
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      color: const Color(0xFF1DB954),
                      child: albumImages.isNotEmpty
                          ? Image.network(
                              albumImages[0]['url'],
                              fit: BoxFit.cover,
                            )
                          : const Icon(
                              Icons.music_note,
                              color: Colors.white,
                              size: 30,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Track details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track['name'] ?? 'Unknown Track',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDuration(duration)} • ${(track['popularity'] ?? 0)} streams • ${artists.isNotEmpty ? artists[0]['name'] : 'Unknown Artist'}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Play button
                  IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      // Play track
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrackDetailsView(BuildContext context, Map<String, dynamic> data, DetailsController controller) {
    final imageUrl = data['album']?['images']?.isNotEmpty == true ? data['album']['images'][0]['url'] : null;
    final name = data['name'] ?? 'Unknown Track';
    final artists = data['artists'] as List<dynamic>? ?? [];
    final album = data['album'] as Map<String, dynamic>? ?? {};
    final duration = data['duration_ms'] as int? ?? 0;
    final popularity = data['popularity'] as int? ?? 0;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1DB954), Color(0xFF121212)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.music_note,
                        size: 120,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                        Color(0xFF121212),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artists.map((a) => a['name']).join(', '),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.play_circle_filled, color: Colors.white, size: 30),
              onPressed: () {
                // Play functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white, size: 24),
              onPressed: () {
                // Share functionality
              },
            ),
          ],
          leading: const SizedBox.shrink(),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFF121212),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          value: _formatDuration(duration),
                          label: 'duration',
                          color: const Color(0xFF1DB954),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildStatCard(
                          value: '$popularity%',
                          label: 'popularity',
                          color: const Color(0xFF1DB954),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Album',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        album['name'] ?? 'Unknown Album',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      if (album['release_date'] != null) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Release Date',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          album['release_date'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumDetailsView(BuildContext context, Map<String, dynamic> data, DetailsController controller) {
    final imageUrl = data['images']?.isNotEmpty == true ? data['images'][0]['url'] : null;
    final name = data['name'] ?? 'Unknown Album';
    final artists = data['artists'] as List<dynamic>? ?? [];
    final totalTracks = data['total_tracks'] as int? ?? 0;
    final popularity = data['popularity'] as int? ?? 0;
    final releaseDate = data['release_date'] ?? 'Unknown';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400,
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (imageUrl != null)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1DB954), Color(0xFF121212)],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.album,
                        size: 120,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black54,
                        Color(0xFF121212),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        artists.map((a) => a['name']).join(', '),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 30),
              onPressed: () => Get.back(),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.play_circle_filled, color: Colors.white, size: 30),
              onPressed: () {
                // Play functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white, size: 24),
              onPressed: () {
                // Share functionality
              },
            ),
          ],
          leading: const SizedBox.shrink(),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFF121212),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          value: totalTracks.toString(),
                          label: 'tracks',
                          color: const Color(0xFF1DB954),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildStatCard(
                          value: '$popularity%',
                          label: 'popularity',
                          color: const Color(0xFF1DB954),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Release Date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        releaseDate,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildAlbumTracksSection(controller),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlbumTracksSection(DetailsController controller) {
    if (controller.relatedItems.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Tracks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: controller.relatedItems.length,
          itemBuilder: (context, index) {
            final track = controller.relatedItems[index];
            final duration = track['duration_ms'] as int? ?? 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      track['name'] ?? 'Unknown Track',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      // Play track
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper methods
  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }
}
