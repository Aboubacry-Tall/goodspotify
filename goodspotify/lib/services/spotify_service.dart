import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpotifyService extends GetxService {
  // Configuration Spotify Web API (sans SDK)
  static const String clientId = 'VOTRE_CLIENT_ID_SPOTIFY';
  static const String clientSecret = 'VOTRE_CLIENT_SECRET_SPOTIFY';
  static const String redirectUri = 'http://localhost:8888/callback';
  static const String scope = 'user-read-private user-read-email user-top-read user-read-recently-played playlist-read-private';
  
  String? _accessToken;
  String? _refreshToken;
  
  // Getter pour vérifier si l'utilisateur est connecté
  bool get isConnected => _accessToken != null;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadTokensFromStorage();
  }

  // Charger les tokens depuis le stockage local
  Future<void> _loadTokensFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('spotify_access_token');
    _refreshToken = prefs.getString('spotify_refresh_token');
  }

  // Sauvegarder les tokens dans le stockage local
  Future<void> _saveTokensToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString('spotify_access_token', _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString('spotify_refresh_token', _refreshToken!);
    }
  }

  // Authentification Spotify Web API (sans SDK)
  Future<bool> authenticate() async {
    try {
      // Pour l'instant, simulation d'une authentification réussie
      // Dans une vraie implémentation, vous utiliseriez l'OAuth2 flow
      // avec url_launcher pour ouvrir le navigateur
      
      print('🎵 Simulation de l\'authentification Spotify...');
      await Future.delayed(const Duration(seconds: 2));
      
      _accessToken = 'fake_access_token_${DateTime.now().millisecondsSinceEpoch}';
      _refreshToken = 'fake_refresh_token_${DateTime.now().millisecondsSinceEpoch}';
      
      await _saveTokensToStorage();
      
      print('✅ Authentification Spotify simulée avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur d\'authentification Spotify: $e');
      return false;
    }
  }

  // Obtenir l'URL d'autorisation Spotify (pour usage futur)
  String getAuthorizationUrl() {
    final params = {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'scope': scope,
      'show_dialog': 'true',
    };
    
    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return 'https://accounts.spotify.com/authorize?$query';
  }

  // Déconnexion
  Future<void> disconnect() async {
    _accessToken = null;
    _refreshToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('spotify_access_token');
    await prefs.remove('spotify_refresh_token');
  }

  // Obtenir le profil utilisateur
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isConnected) return null;

    try {
      // Simulation de données utilisateur
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'id': 'user123',
        'display_name': 'Utilisateur Test',
        'email': 'user@example.com',
        'followers': {'total': 10},
        'images': [],
      };
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }

  // Obtenir les top tracks
  Future<List<Map<String, dynamic>>> getTopTracks({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    if (!isConnected) return [];

    try {
      // Simulation de données
      await Future.delayed(const Duration(seconds: 1));
      
      return List.generate(limit, (index) => {
        'id': 'track_$index',
        'name': 'Track ${index + 1}',
        'artists': [{'name': 'Artist ${index + 1}'}],
        'album': {
          'name': 'Album ${index + 1}',
          'images': [],
        },
        'popularity': 90 - index,
        'duration_ms': 180000 + (index * 1000),
      });
    } catch (e) {
      print('Erreur lors de la récupération des top tracks: $e');
      return [];
    }
  }

  // Obtenir les top artistes
  Future<List<Map<String, dynamic>>> getTopArtists({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    if (!isConnected) return [];

    try {
      // Simulation de données
      await Future.delayed(const Duration(seconds: 1));
      
      return List.generate(limit, (index) => {
        'id': 'artist_$index',
        'name': 'Artist ${index + 1}',
        'genres': ['pop', 'rock'][index % 2],
        'followers': {'total': 1000000 - (index * 10000)},
        'images': [],
        'popularity': 95 - index,
      });
    } catch (e) {
      print('Erreur lors de la récupération des top artistes: $e');
      return [];
    }
  }

  // Obtenir les morceaux récents
  Future<List<Map<String, dynamic>>> getRecentlyPlayed({int limit = 20}) async {
    if (!isConnected) return [];

    try {
      // Simulation de données
      await Future.delayed(const Duration(seconds: 1));
      
      return List.generate(limit, (index) => {
        'track': {
          'id': 'recent_track_$index',
          'name': 'Recent Track ${index + 1}',
          'artists': [{'name': 'Recent Artist ${index + 1}'}],
          'album': {
            'name': 'Recent Album ${index + 1}',
            'images': [],
          },
        },
        'played_at': DateTime.now().subtract(Duration(hours: index)).toIso8601String(),
      });
    } catch (e) {
      print('Erreur lors de la récupération des morceaux récents: $e');
      return [];
    }
  }

  // Obtenir les statistiques d'écoute
  Future<Map<String, dynamic>?> getListeningStats() async {
    if (!isConnected) return null;

    try {
      // Simulation de statistiques
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'total_listening_time': 125400, // en secondes
        'total_tracks': 1250,
        'total_artists': 150,
        'favorite_genres': [
          {'name': 'Pop', 'count': 450},
          {'name': 'Rock', 'count': 300},
          {'name': 'Hip-Hop', 'count': 250},
          {'name': 'Electronic', 'count': 150},
        ],
        'monthly_stats': List.generate(12, (index) => {
          'month': index + 1,
          'hours': 40 + (index * 2),
        }),
      };
    } catch (e) {
      print('Erreur lors de la récupération des statistiques: $e');
      return null;
    }
  }


}
