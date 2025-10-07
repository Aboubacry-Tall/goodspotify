# 🎵 Spotify OAuth2 Setup Guide

## Overview
Your GoodSpotify app now has real Spotify OAuth2 authentication using `flutter_web_auth_2`. Follow these steps to set up proper authentication.

## 📋 Prerequisites

### 1. Spotify Developer Account
- Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
- Log in with your Spotify account
- Create a new app or use an existing one

### 2. App Configuration
In your Spotify app settings:

**Redirect URIs**: Add this exact URI:
```
goodspotify://auth/callback
```

**Scopes needed**: Your app requests these permissions:
- `user-read-private` - Access user's profile information
- `user-read-email` - Access user's email address  
- `user-top-read` - Access user's top tracks and artists
- `user-read-recently-played` - Access recently played tracks
- `playlist-read-private` - Access private playlists

## 🔧 Code Configuration

### 1. Update Spotify Credentials
Edit `lib/services/spotify_service.dart`:

```dart
static const String clientId = 'your_actual_client_id_here';
static const String clientSecret = 'your_actual_client_secret_here';
```

### 2. Authentication Methods Available

**Real OAuth2 Authentication:**
```dart
final spotifyService = Get.find<SpotifyService>();
final success = await spotifyService.authenticate(); // Real auth
```

**Simulated Authentication (for testing):**
```dart
final success = await spotifyService.authenticateSimulated(); // Fake auth
```

### 3. Android Configuration ✅ COMPLETED
The following configuration has been **automatically added** to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- flutter_web_auth_2 callback activity for Spotify OAuth -->
<activity
    android:name="com.linusu.flutter_web_auth_2.CallbackActivity"
    android:exported="true">
    <intent-filter android:label="flutter_web_auth_2">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="goodspotify" />
    </intent-filter>
</activity>
```

### 4. iOS Configuration ✅ COMPLETED
The following configuration has been **automatically added** to `ios/Runner/Info.plist`:

```xml
<!-- URL Schemes for flutter_web_auth_2 Spotify OAuth -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>goodspotify.auth</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>goodspotify</string>
        </array>
    </dict>
</array>
```

## 🚀 Usage Examples

### Switch Between Real and Simulated Auth

In your `SettingsController`, you can choose which authentication method to use:

```dart
// For development/testing - use simulated auth
final success = await spotifyService.authenticateSimulated();

// For production - use real OAuth2 auth
final success = await spotifyService.authenticate();
```

### Authentication Flow

1. **User taps "Connect to Spotify"**
2. **App opens Spotify authorization page** in web view
3. **User logs in and grants permissions**
4. **Spotify redirects back** to your app with authorization code
5. **App exchanges code** for access token automatically
6. **App can now make** authenticated Spotify API calls

### Token Management

The service automatically handles:
- ✅ **Token storage** in SharedPreferences
- ✅ **Token refresh** when expired
- ✅ **Secure storage** of refresh tokens
- ✅ **Error handling** for failed auth

## 🔍 Testing

### 1. Test Simulated Auth First
```dart
// This works without any setup
await spotifyService.authenticateSimulated();
```

### 2. Test Real Auth
```dart
// This requires proper Spotify app configuration
await spotifyService.authenticate();
```

### 3. Debug Authentication
Check the console logs for detailed authentication flow information:
- 🎵 Starting authentication...
- ✅ Authorization code received
- 🔄 Exchanging code for token...
- ✅ Access token obtained successfully

## ⚠️ Security Notes

- **Never commit** your Client Secret to version control
- **Use environment variables** or secure storage for credentials
- **Client Secret** should be stored securely in production
- **Redirect URI** must match exactly in Spotify dashboard

## 🐛 Troubleshooting

### Common Issues

**"Authorization code not received"**
- Check redirect URI matches exactly in Spotify dashboard
- Ensure app scheme is configured properly in Android/iOS

**"Token exchange failed"**
- Verify Client ID and Client Secret are correct
- Check redirect URI matches exactly

**"App doesn't redirect back"**
- Verify Android/iOS configuration for custom scheme
- Check callback activity/URL scheme setup

### Debug Steps

1. Enable verbose logging in SpotifyService
2. Check Spotify Developer Dashboard for app configuration
3. Verify platform-specific configuration (Android/iOS)
4. Test with simulated auth first to isolate issues

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android  | ✅ Full | Requires AndroidManifest.xml setup |
| iOS      | ✅ Full | Requires Info.plist setup |
| Web      | ✅ Full | Works out of the box |
| Desktop  | ⚠️ Limited | May require additional setup |

Your Spotify integration is now ready for real OAuth2 authentication! 🎉
