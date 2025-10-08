import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class SpotifyService extends GetxService {
  // Spotify Web API configuration
  static const String clientId = '8009dbccda7740a5a176d809ef5a5287';
  static const String clientSecret = '74a4898e9e1240d1b000c27fc92c25dd';
  static const String redirectUrl = 'com.goodspotify.stream://callback';
  static const List<String> scopes = [
    'user-read-private',
    'user-read-email',
    'user-top-read',
    'user-read-recently-played',
    'playlist-read-private',
    'user-library-read',
    'user-follow-read',
  ];
  
  // OAuth2 endpoints
  static final Uri authorizationEndpoint = Uri.parse('https://accounts.spotify.com/authorize');
  static final Uri tokenEndpoint = Uri.parse('https://accounts.spotify.com/api/token');
  
  oauth2.Client? _client;
  oauth2.AuthorizationCodeGrant? _grant;
  
  // Getter to check if user is connected
  bool get isConnected => _client != null && !_client!.credentials.isExpired;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    await _loadCredentialsFromStorage();
  }

  // Load credentials from local storage
  Future<void> _loadCredentialsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = prefs.getString('spotify_credentials');
      
      if (credentialsJson != null) {
        final credentials = oauth2.Credentials.fromJson(credentialsJson);
        _client = oauth2.Client(
          credentials,
          identifier: clientId,
          secret: clientSecret,
        );
        
        print('✅ Loaded credentials from storage');
        
        // Check if token is expired and refresh if needed
        if (_client!.credentials.isExpired) {
          print('🔄 Token expired, refreshing...');
          await refreshAccessToken();
        }
      }
    } catch (e) {
      print('❌ Error loading credentials: $e');
    }
  }

  // Save credentials to local storage
  Future<void> _saveCredentialsToStorage() async {
    try {
      if (_client != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('spotify_credentials', _client!.credentials.toJson());
        print('💾 Credentials saved to storage');
      }
    } catch (e) {
      print('❌ Error saving credentials: $e');
    }
  }

  // Spotify authentication using oauth2 package
  Future<bool> authenticate() async {
    try {
      print('🎵 Starting Spotify authentication with oauth2...');

      // Create authorization code grant
      _grant = oauth2.AuthorizationCodeGrant(
        clientId,
        authorizationEndpoint,
        tokenEndpoint,
        secret: clientSecret,
      );

      // Get authorization URL
      final authorizationUrl = _grant!.getAuthorizationUrl(
        Uri.parse(redirectUrl),
        scopes: scopes,
      );

      print('🔗 Authorization URL: $authorizationUrl');

      // Launch the authorization URL in browser
      final launched = await launchUrl(
        authorizationUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        print('❌ Could not launch authorization URL');
        return false;
      }

      print('✅ Browser opened, waiting for callback...');
      print('📱 Callback URL: $redirectUrl');
      
      // Return true to indicate browser was opened successfully
      // The actual token exchange will happen in handleAuthorizationCallback
      return true;
      
    } catch (e) {
      print('❌ Spotify authentication error: $e');
      return false;
    }
  }

  // Handle authorization callback (to be called from deep link handler)
  Future<bool> handleAuthorizationCallback(Uri callbackUri) async {
    try {
      print('🔄 Handling authorization callback...');
      print('📱 Callback URI: $callbackUri');
      print('📋 Query parameters: ${callbackUri.queryParameters}');
      
      if (_grant == null) {
        print('❌ No grant available - authentication not started');
        return false;
      }

      // Extract authorization code from callback
      final code = callbackUri.queryParameters['code'];
      final error = callbackUri.queryParameters['error'];
      
      if (error != null) {
        print('❌ Authorization error: $error');
        return false;
      }
      
      if (code == null) {
        print('❌ No authorization code in callback');
        return false;
      }

      print('✅ Authorization code received: ${code.substring(0, 20)}...');

      // Exchange authorization code for access token
      _client = await _grant!.handleAuthorizationResponse(callbackUri.queryParameters);
      
      // Clear the grant as it's no longer needed
      _grant = null;
      
      await _saveCredentialsToStorage();
      
      print('✅ Authentication completed successfully!');
      print('🔑 Access token: ${_client!.credentials.accessToken.substring(0, 20)}...');
      
      return true;
      
    } catch (e) {
      print('❌ Error handling authorization callback: $e');
      _grant = null;
      return false;
    }
  }

  // Refresh access token
  Future<bool> refreshAccessToken() async {
    if (_client == null) return false;

    try {
      print('🔄 Refreshing access token...');
      
      final newClient = await _client!.refreshCredentials();
      _client = newClient;
      
      await _saveCredentialsToStorage();
      
      print('✅ Access token refreshed successfully');
      return true;
    } catch (e) {
      print('❌ Error refreshing token: $e');
      return false;
    }
  }

  // Disconnect
  Future<void> disconnect() async {
    _client = null;
    _grant = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('spotify_credentials');
    
    print('👋 Disconnected from Spotify');
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return null;
    }

    try {
      print('👤 Fetching user profile from Spotify API...');
      
      final response = await _client!.get(
        Uri.parse('https://api.spotify.com/v1/me'),
      );

      print('📡 User profile API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Retrieved user profile: ${data['display_name']}');
        return data;
      } else {
        print('❌ Failed to fetch user profile: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error retrieving user profile: $e');
      
      // Try to refresh token if expired
      if (e.toString().contains('401') || e.toString().contains('expired')) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return await getUserProfile();
        }
      }
      return null;
    }
  }

  // Get top tracks
  Future<List<Map<String, dynamic>>> getTopTracks({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return [];
    }

    try {
      print('🎵 Fetching top tracks from Spotify API...');
      
      final response = await _client!.get(
        Uri.parse('https://api.spotify.com/v1/me/top/tracks?time_range=$timeRange&limit=$limit'),
      );

      print('📡 Top tracks API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['items'] ?? [];
        
        print('✅ Retrieved ${tracks.length} top tracks');
        
        return tracks.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch top tracks: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving top tracks: $e');
      
      if (e.toString().contains('401') || e.toString().contains('expired')) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return await getTopTracks(timeRange: timeRange, limit: limit);
        }
      }
      return [];
    }
  }

  // Get top artists
  Future<List<Map<String, dynamic>>> getTopArtists({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return [];
    }

    try {
      print('🎵 Fetching top artists from Spotify API...');
      
      final response = await _client!.get(
        Uri.parse('https://api.spotify.com/v1/me/top/artists?time_range=$timeRange&limit=$limit'),
      );

      print('📡 Top artists API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['items'] ?? [];
        
        print('✅ Retrieved ${artists.length} top artists');
        
        return artists.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch top artists: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving top artists: $e');
      
      if (e.toString().contains('401') || e.toString().contains('expired')) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return await getTopArtists(timeRange: timeRange, limit: limit);
        }
      }
      return [];
    }
  }

  // Get recently played tracks
  Future<List<Map<String, dynamic>>> getRecentlyPlayed({int limit = 20}) async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return [];
    }

    try {
      print('⏰ Fetching recently played tracks from Spotify API...');
      
      final response = await _client!.get(
        Uri.parse('https://api.spotify.com/v1/me/player/recently-played?limit=$limit'),
      );

      print('📡 Recently played API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['items'] ?? [];
        
        print('✅ Retrieved ${tracks.length} recently played tracks');
        
        return tracks.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch recently played tracks: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving recently played tracks: $e');
      
      if (e.toString().contains('401') || e.toString().contains('expired')) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return await getRecentlyPlayed(limit: limit);
        }
      }
      return [];
    }
  }

  // Get followed artists
  Future<List<Map<String, dynamic>>> getFollowedArtists({
    int limit = 20,
  }) async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return [];
    }

    try {
      print('👥 Fetching followed artists from Spotify API...');
      
      final response = await _client!.get(
        Uri.parse('https://api.spotify.com/v1/me/following?type=artist&limit=$limit'),
      );

      print('📡 Followed artists API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['artists']?['items'] ?? [];
        
        print('✅ Retrieved ${artists.length} followed artists');
        
        return artists.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch followed artists: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving followed artists: $e');
      
      if (e.toString().contains('401') || e.toString().contains('expired')) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return await getFollowedArtists(limit: limit);
        }
      }
      return [];
    }
  }

  // Get user's saved albums
  Future<List<Map<String, dynamic>>> getSavedAlbums({
    int limit = 20,
  }) async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return [];
    }

    try {
      print('💿 Fetching saved albums from Spotify API...');
      
      final response = await _client!.get(
        Uri.parse('https://api.spotify.com/v1/me/albums?limit=$limit'),
      );

      print('📡 Saved albums API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['items'] ?? [];
        
        final albumList = albums.map((item) => item['album'] as Map<String, dynamic>).toList();
        
        print('✅ Retrieved ${albumList.length} saved albums');
        
        return albumList.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch saved albums: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving saved albums: $e');
      
      if (e.toString().contains('401') || e.toString().contains('expired')) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return await getSavedAlbums(limit: limit);
        }
      }
      return [];
    }
  }

  // Get user's saved tracks
  Future<List<Map<String, dynamic>>> getSavedTracks({
    int limit = 20,
  }) async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return [];
    }

    try {
      print('🎵 Fetching saved tracks from Spotify API...');
      
      final response = await _client!.get(
        Uri.parse('https://api.spotify.com/v1/me/tracks?limit=$limit'),
      );

      print('📡 Saved tracks API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['items'] ?? [];
        
        final trackList = tracks.map((item) => item['track'] as Map<String, dynamic>).toList();
        
        print('✅ Retrieved ${trackList.length} saved tracks');
        
        return trackList.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch saved tracks: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving saved tracks: $e');
      
      if (e.toString().contains('401') || e.toString().contains('expired')) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return await getSavedTracks(limit: limit);
        }
      }
      return [];
    }
  }

  // Get listening statistics (computed from user data)
  Future<Map<String, dynamic>?> getListeningStats() async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return null;
    }

    try {
      print('📊 Computing listening statistics from user data...');
      
      final topArtists = await getTopArtists(limit: 50);
      final topTracks = await getTopTracks(limit: 50);
      final followedArtists = await getFollowedArtists(limit: 50);
      final savedAlbums = await getSavedAlbums(limit: 50);
      final savedTracks = await getSavedTracks(limit: 50);
      
      final genreCount = <String, int>{};
      for (final artist in topArtists) {
        final genres = artist['genres'] as List<dynamic>? ?? [];
        for (final genre in genres) {
          genreCount[genre] = (genreCount[genre] ?? 0) + 1;
        }
      }
      
      final favoriteGenres = genreCount.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));
      
      final topGenres = favoriteGenres.take(5).map((entry) => {
        'name': entry.key,
        'count': entry.value,
      }).toList();
      
      final estimatedTotalDuration = topTracks.fold<int>(0, (sum, track) {
        return sum + ((track['duration_ms'] as int?) ?? 180000);
      });
      
      final stats = {
        'total_listening_time': estimatedTotalDuration ~/ 1000,
        'total_tracks': topTracks.length + savedTracks.length,
        'total_artists': topArtists.length + followedArtists.length,
        'total_albums': savedAlbums.length,
        'favorite_genres': topGenres,
        'monthly_stats': List.generate(12, (index) => {
          'month': index + 1,
          'hours': (estimatedTotalDuration / 1000 / 3600 / 12).round() + (index * 2),
        }),
      };
      
      print('✅ Listening statistics computed');
      
      return stats;
    } catch (e) {
      print('❌ Error computing listening statistics: $e');
      return null;
    }
  }

  // Get all user's artists (top artists + followed artists)
  Future<Map<String, List<Map<String, dynamic>>>> getAllUserArtists({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return {'topArtists': [], 'followedArtists': []};
    }

    try {
      print('🎵 Fetching all user artists...');
      
      final results = await Future.wait([
        getTopArtists(timeRange: timeRange, limit: limit),
        getFollowedArtists(limit: limit),
      ]);

      final topArtists = results[0];
      final followedArtists = results[1];

      print('✅ Retrieved ${topArtists.length} top artists and ${followedArtists.length} followed artists');

      return {
        'topArtists': topArtists,
        'followedArtists': followedArtists,
      };
    } catch (e) {
      print('❌ Error retrieving all user artists: $e');
      return {'topArtists': [], 'followedArtists': []};
    }
  }

  // Load all user data automatically after authentication
  Future<Map<String, dynamic>> loadAllUserData({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return {};
    }

    try {
      print('🎵 Loading all user data from Spotify...');
      
      final results = await Future.wait([
        getUserProfile(),
        getTopArtists(timeRange: timeRange, limit: limit),
        getTopTracks(timeRange: timeRange, limit: limit),
        getFollowedArtists(limit: limit),
        getSavedAlbums(limit: limit),
        getSavedTracks(limit: limit),
        getRecentlyPlayed(limit: limit),
        getListeningStats(),
      ]);

      final userProfile = results[0];
      final topArtists = results[1] as List<Map<String, dynamic>>;
      final topTracks = results[2] as List<Map<String, dynamic>>;
      final followedArtists = results[3] as List<Map<String, dynamic>>;
      final savedAlbums = results[4] as List<Map<String, dynamic>>;
      final savedTracks = results[5] as List<Map<String, dynamic>>;
      final recentlyPlayed = results[6] as List<Map<String, dynamic>>;
      final listeningStats = results[7];

      print('✅ Successfully loaded all user data');

      await _saveUserDataToStorage({
        'userProfile': userProfile,
        'topArtists': topArtists,
        'topTracks': topTracks,
        'followedArtists': followedArtists,
        'savedAlbums': savedAlbums,
        'savedTracks': savedTracks,
        'recentlyPlayed': recentlyPlayed,
        'listeningStats': listeningStats,
        'lastUpdated': DateTime.now().toIso8601String(),
      });

      return {
        'userProfile': userProfile,
        'topArtists': topArtists,
        'topTracks': topTracks,
        'followedArtists': followedArtists,
        'savedAlbums': savedAlbums,
        'savedTracks': savedTracks,
        'recentlyPlayed': recentlyPlayed,
        'listeningStats': listeningStats,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('❌ Error loading all user data: $e');
      return {};
    }
  }

  // Save user data to local storage
  Future<void> _saveUserDataToStorage(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));
      print('💾 User data saved to local storage');
    } catch (e) {
      print('❌ Error saving user data to storage: $e');
    }
  }

  // Load user data from local storage
  Future<Map<String, dynamic>> loadUserDataFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = json.decode(userDataString) as Map<String, dynamic>;
        print('📱 User data loaded from local storage');
        return userData;
      }
    } catch (e) {
      print('❌ Error loading user data from storage: $e');
    }
    return {};
  }

  // Generic API call method
  Future<Map<String, dynamic>?> makeApiCall(String url) async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return null;
    }

    try {
      print('🌐 Making API call to: $url');
      
      final response = await _client!.get(Uri.parse(url));

      print('📡 API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        print('❌ API call failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error making API call: $e');
      
      if (e.toString().contains('401') || e.toString().contains('expired')) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          return await makeApiCall(url);
        }
      }
      return null;
    }
  }
}