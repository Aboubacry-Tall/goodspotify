import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Authorization response model
class AuthorizationResponse {
  final String? code;
  final String? error;
  
  AuthorizationResponse({this.code, this.error});
}

// Access token response model
class AccessTokenResponse {
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final int? expiresIn;
  
  AccessTokenResponse({
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.expiresIn,
  });
}

// Custom OAuth2 Client for Spotify based on your example
class SpotifyOAuth2Client {
  final String customUriScheme;
  final String redirectUri;
  final String authorizeUrl = 'https://accounts.spotify.com/authorize';
  final String tokenUrl = 'https://accounts.spotify.com/api/token';

  SpotifyOAuth2Client({
    required this.customUriScheme,
    required this.redirectUri,
  });

  // Request authorization
  Future<AuthorizationResponse> requestAuthorization({
    required String clientId,
    Map<String, String>? customParams,
    List<String>? scopes,
  }) async {
    try {
      // Build authorization URL
      final params = {
        'client_id': clientId,
        'response_type': 'code',
        'redirect_uri': redirectUri,
        if (scopes != null) 'scope': scopes.join(' '),
        ...?customParams,
      };
      
      final query = params.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
      
      final authorizationUrl = '$authorizeUrl?$query';
      print('🔗 Authorization URL: $authorizationUrl');

      // Use flutter_web_auth_2 to open browser and get callback
      final result = await FlutterWebAuth2.authenticate(
        url: authorizationUrl,
        callbackUrlScheme: customUriScheme,
      );

      print('🔄 Authentication result received: $result');

      // Parse the authorization code from callback
      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      return AuthorizationResponse(code: code, error: error);
    } catch (e) {
      print('❌ Authorization error: $e');
      return AuthorizationResponse(error: e.toString());
    }
  }

  // Request access token
  Future<AccessTokenResponse> requestAccessToken({
    required String code,
    required String clientId,
    required String clientSecret,
  }) async {
    try {
      print('🔄 Exchanging code for access token...');

      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      print('📡 Token exchange response: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AccessTokenResponse(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          tokenType: data['token_type'],
          expiresIn: data['expires_in'],
        );
      } else {
        print('❌ Token exchange failed: ${response.statusCode}');
        return AccessTokenResponse();
      }
    } catch (e) {
      print('❌ Error exchanging code for token: $e');
      return AccessTokenResponse();
    }
  }

  // Refresh token
  Future<AccessTokenResponse> refreshToken({
    required String refreshToken,
    required String clientId,
    required String clientSecret,
  }) async {
    try {
      print('🔄 Refreshing access token...');
      
      final response = await http.post(
        Uri.parse(tokenUrl),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AccessTokenResponse(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'] ?? refreshToken,
          tokenType: data['token_type'],
          expiresIn: data['expires_in'],
        );
      } else {
        print('❌ Token refresh failed: ${response.statusCode}');
        return AccessTokenResponse();
      }
    } catch (e) {
      print('❌ Error refreshing token: $e');
      return AccessTokenResponse();
    }
  }
}

class SpotifyService extends GetxService {
  // Spotify Web API configuration (without SDK)
  static const String clientId = '8009dbccda7740a5a176d809ef5a5287';
  static const String clientSecret = '74a4898e9e1240d1b000c27fc92c25dd';
  static const String redirectUri = 'com.goodspotify.stream://callback';
  static const String scope = 'user-read-private user-read-email user-top-read user-read-recently-played playlist-read-private';
  
  String? _accessToken;
  String? _refreshToken;
  
  // OAuth2 Client for Spotify
  late SpotifyOAuth2Client _oauth2Client;
  
  // Getter to check if user is connected
  bool get isConnected => _accessToken != null;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    
    // Initialize OAuth2 Client for Spotify
    _oauth2Client = SpotifyOAuth2Client(
      customUriScheme: 'com.goodspotify.stream',
      redirectUri: redirectUri,
    );
    
    await _loadTokensFromStorage();
  }

  // Load tokens from local storage
  Future<void> _loadTokensFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('spotify_access_token');
    _refreshToken = prefs.getString('spotify_refresh_token');
  }

  // Save tokens to local storage
  Future<void> _saveTokensToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString('spotify_access_token', _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString('spotify_refresh_token', _refreshToken!);
    }
  }

  // Spotify Web API authentication using oauth2_client
  Future<bool> authenticate() async {
    try {
      print('🎵 Starting Spotify authentication with oauth2_client...');

      // Step 1: Request authorization
      var authResp = await _oauth2Client.requestAuthorization(
        clientId: clientId,
        customParams: {'show_dialog': 'true'},
        scopes: scope.split(' '),
      );

      print('🔄 Authorization response received');
      print('📋 Auth code: ${authResp.code != null ? '${authResp.code!.substring(0, 10)}...' : 'null'}');

      if (authResp.code == null) {
        print('❌ No authorization code received');
        return false;
      }

      // Step 2: Exchange authorization code for access token
      var accessToken = await _oauth2Client.requestAccessToken(
        code: authResp.code.toString(),
        clientId: clientId,
        clientSecret: clientSecret,
      );

      if (accessToken.accessToken != null) {
        _accessToken = accessToken.accessToken;
        _refreshToken = accessToken.refreshToken;
        
        await _saveTokensToStorage();
        
        print('🎉 Authentication completed successfully!');
        print('🔑 Access token: ${_accessToken?.substring(0, 20)}...');
        print('🔄 Refresh token: ${_refreshToken?.substring(0, 20)}...');
        return true;
      } else {
        print('❌ Token exchange failed');
        return false;
      }

    } catch (e) {
      print('❌ Spotify authentication error: $e');
      return false;
    }
  }





  // Refresh access token using oauth2_client
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      print('🔄 Refreshing access token with oauth2_client...');
      
      var accessToken = await _oauth2Client.refreshToken(
        refreshToken: _refreshToken!,
        clientId: clientId,
        clientSecret: clientSecret,
      );

      if (accessToken.accessToken != null) {
        _accessToken = accessToken.accessToken;
        
        // Update refresh token if a new one is provided
        if (accessToken.refreshToken != null) {
          _refreshToken = accessToken.refreshToken;
        }
        
        await _saveTokensToStorage();
        
        print('✅ Access token refreshed successfully with oauth2_client');
        return true;
      } else {
        print('❌ Token refresh failed with oauth2_client');
        return false;
      }
    } catch (e) {
      print('❌ Error refreshing token with oauth2_client: $e');
      return false;
    }
  }

  // Disconnect
  Future<void> disconnect() async {
    _accessToken = null;
    _refreshToken = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('spotify_access_token');
    await prefs.remove('spotify_refresh_token');
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (!isConnected) {
      print('❌ Not connected to Spotify');
      return null;
    }

    try {
      print('👤 Fetching user profile from Spotify API...');
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 User profile API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Retrieved user profile: ${data['display_name']}');
        return data;
      } else if (response.statusCode == 401) {
        print('🔑 Token expired, attempting refresh...');
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Retry the request with new token
          return await getUserProfile();
        }
        return null;
      } else {
        print('❌ Failed to fetch user profile: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error retrieving user profile: $e');
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
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/top/tracks?time_range=$timeRange&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Top tracks API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['items'] ?? [];
        
        print('✅ Retrieved ${tracks.length} top tracks');
        
        return tracks.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        print('🔑 Token expired, attempting refresh...');
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Retry the request with new token
          return await getTopTracks(timeRange: timeRange, limit: limit);
        }
        return [];
      } else {
        print('❌ Failed to fetch top tracks: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving top tracks: $e');
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
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/top/artists?time_range=$timeRange&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Top artists API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['items'] ?? [];
        
        print('✅ Retrieved ${artists.length} top artists');
        
        return artists.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        print('🔑 Token expired, attempting refresh...');
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Retry the request with new token
          return await getTopArtists(timeRange: timeRange, limit: limit);
        }
        return [];
      } else {
        print('❌ Failed to fetch top artists: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving top artists: $e');
      return [];
    }
  }

  // Get recently played tracks
  Future<List<Map<String, dynamic>>> getRecentlyPlayed({int limit = 20}) async {
    if (!isConnected) return [];

    try {
      // Data simulation
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
      print('Error retrieving recent tracks: $e');
      return [];
    }
  }

  // Get listening statistics
  Future<Map<String, dynamic>?> getListeningStats() async {
    if (!isConnected) return null;

    try {
      // Statistics simulation
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'total_listening_time': 125400, // in seconds
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
      print('Error retrieving statistics: $e');
      return null;
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
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/following?type=artist&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Followed artists API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> artists = data['artists']?['items'] ?? [];
        
        print('✅ Retrieved ${artists.length} followed artists');
        
        return artists.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        print('🔑 Token expired, attempting refresh...');
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Retry the request with new token
          return await getFollowedArtists(limit: limit);
        }
        return [];
      } else {
        print('❌ Failed to fetch followed artists: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving followed artists: $e');
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
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/albums?limit=$limit'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Saved albums API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> albums = data['items'] ?? [];
        
        // Extract album data from the nested structure
        final albumList = albums.map((item) => item['album'] as Map<String, dynamic>).toList();
        
        print('✅ Retrieved ${albumList.length} saved albums');
        
        return albumList.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        print('🔑 Token expired, attempting refresh...');
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Retry the request with new token
          return await getSavedAlbums(limit: limit);
        }
        return [];
      } else {
        print('❌ Failed to fetch saved albums: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving saved albums: $e');
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
      
      final response = await http.get(
        Uri.parse('https://api.spotify.com/v1/me/tracks?limit=$limit'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Saved tracks API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> tracks = data['items'] ?? [];
        
        // Extract track data from the nested structure
        final trackList = tracks.map((item) => item['track'] as Map<String, dynamic>).toList();
        
        print('✅ Retrieved ${trackList.length} saved tracks');
        
        return trackList.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        print('🔑 Token expired, attempting refresh...');
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Retry the request with new token
          return await getSavedTracks(limit: limit);
        }
        return [];
      } else {
        print('❌ Failed to fetch saved tracks: ${response.statusCode}');
        print('Response: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error retrieving saved tracks: $e');
      return [];
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
      
      // Fetch both top artists and followed artists in parallel
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
      
      // Load all data in parallel for better performance
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

      print('✅ Successfully loaded all user data:');
      print('   - User profile: ${userProfile != null ? "✅" : "❌"}');
      print('   - Top artists: ${topArtists.length}');
      print('   - Top tracks: ${topTracks.length}');
      print('   - Followed artists: ${followedArtists.length}');
      print('   - Saved albums: ${savedAlbums.length}');
      print('   - Saved tracks: ${savedTracks.length}');
      print('   - Recently played: ${recentlyPlayed.length}');
      print('   - Listening stats: ${listeningStats != null ? "✅" : "❌"}');

      // Save data to local storage
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


}
