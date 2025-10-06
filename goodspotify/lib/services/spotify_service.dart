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

      if (accessToken != null && accessToken.accessToken != null) {
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

      if (accessToken != null && accessToken.accessToken != null) {
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
    if (!isConnected) return null;

    try {
      // User data simulation
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'id': 'user123',
        'display_name': 'Test User',
        'email': 'user@example.com',
        'followers': {'total': 10},
        'images': [],
      };
    } catch (e) {
      print('Error retrieving profile: $e');
      return null;
    }
  }

  // Get top tracks
  Future<List<Map<String, dynamic>>> getTopTracks({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    if (!isConnected) return [];

    try {
      // Data simulation
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
      print('Error retrieving top tracks: $e');
      return [];
    }
  }

  // Get top artists
  Future<List<Map<String, dynamic>>> getTopArtists({
    String timeRange = 'medium_term',
    int limit = 20,
  }) async {
    if (!isConnected) return [];

    try {
      // Data simulation
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
      print('Error retrieving top artists: $e');
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


}
