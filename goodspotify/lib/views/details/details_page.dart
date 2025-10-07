import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
            ),
          );
        }

        if (controller.itemData.value == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'Unable to load details',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        final data = controller.itemData.value!;
        
        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(data, controller),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainInfo(context, data, controller),
                  const SizedBox(height: 24),
                  _buildRelatedSection(context, controller),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(Map<String, dynamic> data, DetailsController controller) {
    String title = '';
    String? imageUrl;
    
    switch (itemType) {
      case 'track':
        title = data['name'] ?? 'Unknown Track';
        imageUrl = data['album']?['images']?.isNotEmpty == true
            ? data['album']['images'][0]['url']
            : null;
        break;
      case 'artist':
        title = data['name'] ?? 'Unknown Artist';
        imageUrl = data['images']?.isNotEmpty == true
            ? data['images'][0]['url']
            : null;
        break;
      case 'album':
        title = data['name'] ?? 'Unknown Album';
        imageUrl = data['images']?.isNotEmpty == true
            ? data['images'][0]['url']
            : null;
        break;
    }

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: const Color(0xFF1DB954),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                color: const Color(0xFF1DB954),
                child: const Center(
                  child: Icon(
                    Icons.music_note,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {
            // Share functionality
            print('Share $itemType: $title');
          },
        ),
        IconButton(
          icon: const Icon(Icons.favorite_border, color: Colors.white),
          onPressed: () {
            // Add to favorites
            print('Add to favorites: $title');
          },
        ),
      ],
    );
  }

  Widget _buildMainInfo(BuildContext context, Map<String, dynamic> data, DetailsController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(context, data, controller),
          const SizedBox(height: 16),
          _buildStats(data, controller),
          const SizedBox(height: 16),
          _buildDescription(context, data, controller),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(BuildContext context, Map<String, dynamic> data, DetailsController controller) {
    switch (itemType) {
      case 'track':
        return _buildTrackInfo(context, data);
      case 'artist':
        return _buildArtistInfo(context, data, controller);
      case 'album':
        return _buildAlbumInfo(context, data);
      default:
        return const SizedBox();
    }
  }

  Widget _buildTrackInfo(BuildContext context, Map<String, dynamic> data) {
    final artists = data['artists'] as List<dynamic>? ?? [];
    final album = data['album'] as Map<String, dynamic>? ?? {};
    final duration = data['duration_ms'] as int? ?? 0;
    final popularity = data['popularity'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Track Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Artists', artists.map((a) => a['name']).join(', ')),
        _buildInfoRow('Album', album['name'] ?? 'Unknown'),
        _buildInfoRow('Duration', _formatDuration(duration)),
        _buildInfoRow('Popularity', '$popularity%'),
        if (album['release_date'] != null)
          _buildInfoRow('Release Date', album['release_date']),
      ],
    );
  }

  Widget _buildArtistInfo(BuildContext context, Map<String, dynamic> data, DetailsController controller) {
    final followers = data['followers']?['total'] ?? 0;
    final genres = data['genres'] as List<dynamic>? ?? [];
    final popularity = data['popularity'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Artist Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Followers', _formatFollowers(followers)),
        _buildInfoRow('Popularity', '$popularity%'),
        if (genres.isNotEmpty)
          _buildInfoRow('Genres', genres.take(3).join(', ')),
      ],
    );
  }

  Widget _buildAlbumInfo(BuildContext context, Map<String, dynamic> data) {
    final artists = data['artists'] as List<dynamic>? ?? [];
    final totalTracks = data['total_tracks'] as int? ?? 0;
    final popularity = data['popularity'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Album Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Artists', artists.map((a) => a['name']).join(', ')),
        _buildInfoRow('Total Tracks', totalTracks.toString()),
        _buildInfoRow('Popularity', '$popularity%'),
        if (data['release_date'] != null)
          _buildInfoRow('Release Date', data['release_date']),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(Map<String, dynamic> data, DetailsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Popularity', '${data['popularity'] ?? 0}%'),
        if (itemType == 'artist')
          _buildStatItem('Followers', _formatFollowers(data['followers']?['total'] ?? 0)),
        if (itemType == 'track')
          _buildStatItem('Duration', _formatDuration(data['duration_ms'] ?? 0)),
          if (itemType == 'album')
            _buildStatItem('Tracks', '${data['total_tracks'] ?? 0}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1DB954),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context, Map<String, dynamic> data, DetailsController controller) {
    if (itemType == 'artist' && data['genres'] != null) {
      final genres = data['genres'] as List<dynamic>;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genres',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: genres.map((genre) => Chip(
              label: Text(genre),
              backgroundColor: const Color(0xFF1DB954).withOpacity(0.1),
              labelStyle: const TextStyle(color: Color(0xFF1DB954)),
            )).toList(),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget _buildRelatedSection(BuildContext context, DetailsController controller) {
    if (controller.relatedItems.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getRelatedSectionTitle(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.relatedItems.length,
            itemBuilder: (context, index) {
              final item = controller.relatedItems[index];
              return _buildRelatedItem(item);
            },
          ),
        ],
      ),
    );
  }

  String _getRelatedSectionTitle() {
    switch (itemType) {
      case 'track':
        return 'More from this artist';
      case 'artist':
        return 'Top tracks & albums';
      case 'album':
        return 'Album tracks';
      default:
        return 'Related items';
    }
  }

  Widget _buildRelatedItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1DB954),
          backgroundImage: _getItemImage(item) != null
              ? NetworkImage(_getItemImage(item)!)
              : null,
          child: _getItemImage(item) == null
              ? const Icon(Icons.music_note, color: Colors.white)
              : null,
        ),
        title: Text(
          item['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _getItemSubtitle(item),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.play_circle_outline, color: Color(0xFF1DB954)),
        onTap: () {
          // Navigate to item details
          String itemType = 'track'; // Default
          if (item['artists'] != null) {
            itemType = 'track';
          } else if (item['total_tracks'] != null) {
            itemType = 'album';
          }
          
          Get.to(() => DetailsPage(
            itemId: item['id'] ?? '',
            itemType: itemType,
            itemData: item,
          ));
        },
      ),
    );
  }

  String? _getItemImage(Map<String, dynamic> item) {
    if (item['images'] != null && (item['images'] as List).isNotEmpty) {
      return item['images'][0]['url'];
    }
    if (item['album']?['images'] != null && (item['album']['images'] as List).isNotEmpty) {
      return item['album']['images'][0]['url'];
    }
    return null;
  }

  String _getItemSubtitle(Map<String, dynamic> item) {
    if (item['artists'] != null) {
      return (item['artists'] as List).map((a) => a['name']).join(', ');
    }
    if (item['album'] != null) {
      return item['album']['name'];
    }
    return '';
  }

  // Format duration
  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  // Format followers
  String _formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }
}
