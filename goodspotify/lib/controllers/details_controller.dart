import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/spotify_service.dart';

class DetailsController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var itemData = Rxn<Map<String, dynamic>>();
  var itemType = Rxn<String>(); // 'track', 'artist', 'album'
  var relatedItems = <Map<String, dynamic>>[].obs;
  
  late SpotifyService _spotifyService;

  @override
  void onInit() {
    super.onInit();
    _spotifyService = Get.find<SpotifyService>();
  }

  // Load details for different item types
  Future<void> loadDetails({
    required String itemId,
    required String itemType,
    Map<String, dynamic>? initialData,
  }) async {
    try {
      isLoading.value = true;
      this.itemType.value = itemType;
      
      // If we have initial data, use it
      if (initialData != null) {
        itemData.value = initialData;
        await loadRelatedItems(itemId, itemType);
        return;
      }

      // Otherwise, fetch from API
      switch (itemType) {
        case 'track':
          await loadTrackDetails(itemId);
          break;
        case 'artist':
          await loadArtistDetails(itemId);
          break;
        case 'album':
          await loadAlbumDetails(itemId);
          break;
      }
      
      await loadRelatedItems(itemId, itemType);
    } catch (e) {
      print('❌ Error loading details: $e');
      Get.snackbar(
        'Error',
        'Failed to load details',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load track details
  Future<void> loadTrackDetails(String trackId) async {
    try {
      print('🎵 Loading track details for: $trackId');
      
      final response = await _spotifyService.makeApiCall(
        'https://api.spotify.com/v1/tracks/$trackId',
      );
      
      if (response != null) {
        itemData.value = response;
        print('✅ Track details loaded');
      }
    } catch (e) {
      print('❌ Error loading track details: $e');
    }
  }

  // Load artist details
  Future<void> loadArtistDetails(String artistId) async {
    try {
      print('👤 Loading artist details for: $artistId');
      
      final response = await _spotifyService.makeApiCall(
        'https://api.spotify.com/v1/artists/$artistId',
      );
      
      if (response != null) {
        itemData.value = response;
        print('✅ Artist details loaded');
      }
    } catch (e) {
      print('❌ Error loading artist details: $e');
    }
  }

  // Load album details
  Future<void> loadAlbumDetails(String albumId) async {
    try {
      print('💿 Loading album details for: $albumId');
      
      final response = await _spotifyService.makeApiCall(
        'https://api.spotify.com/v1/albums/$albumId',
      );
      
      if (response != null) {
        itemData.value = response;
        print('✅ Album details loaded');
      }
    } catch (e) {
      print('❌ Error loading album details: $e');
    }
  }

  // Load related items
  Future<void> loadRelatedItems(String itemId, String itemType) async {
    try {
      switch (itemType) {
        case 'track':
          // Load artist's other tracks
          final trackData = itemData.value;
          if (trackData != null && trackData['artists'] != null) {
            final artistId = trackData['artists'][0]['id'];
            await loadArtistTopTracks(artistId);
          }
          break;
        case 'artist':
          // Load artist's top tracks and albums
          await loadArtistTopTracks(itemId);
          await loadArtistAlbums(itemId);
          break;
        case 'album':
          // Load album tracks
          await loadAlbumTracks(itemId);
          break;
      }
    } catch (e) {
      print('❌ Error loading related items: $e');
    }
  }

  // Load artist's top tracks
  Future<void> loadArtistTopTracks(String artistId) async {
    try {
      final response = await _spotifyService.makeApiCall(
        'https://api.spotify.com/v1/artists/$artistId/top-tracks?market=US',
      );
      
      if (response != null && response['tracks'] != null) {
        relatedItems.addAll((response['tracks'] as List).cast<Map<String, dynamic>>());
        print('✅ Artist top tracks loaded: ${response['tracks'].length}');
      }
    } catch (e) {
      print('❌ Error loading artist top tracks: $e');
    }
  }

  // Load artist's albums
  Future<void> loadArtistAlbums(String artistId) async {
    try {
      final response = await _spotifyService.makeApiCall(
        'https://api.spotify.com/v1/artists/$artistId/albums?limit=10',
      );
      
      if (response != null && response['items'] != null) {
        relatedItems.addAll((response['items'] as List).cast<Map<String, dynamic>>());
        print('✅ Artist albums loaded: ${response['items'].length}');
      }
    } catch (e) {
      print('❌ Error loading artist albums: $e');
    }
  }

  // Load album tracks
  Future<void> loadAlbumTracks(String albumId) async {
    try {
      final response = await _spotifyService.makeApiCall(
        'https://api.spotify.com/v1/albums/$albumId/tracks',
      );
      
      if (response != null && response['items'] != null) {
        relatedItems.addAll((response['items'] as List).cast<Map<String, dynamic>>());
        print('✅ Album tracks loaded: ${response['items'].length}');
      }
    } catch (e) {
      print('❌ Error loading album tracks: $e');
    }
  }

  // Format duration
  String formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  // Format followers
  String formatFollowers(int followers) {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }

  // Clear data when leaving page
  void clearData() {
    itemData.value = null;
    itemType.value = null;
    relatedItems.clear();
  }
}
