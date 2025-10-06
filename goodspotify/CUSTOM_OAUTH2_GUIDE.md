# Guide d'utilisation du Custom OAuth2 Client

Ce guide explique comment utiliser notre implémentation personnalisée OAuth2 pour l'authentification Spotify dans votre application GoodSpotify.

## Implémentation

Nous avons créé une classe personnalisée `SpotifyOAuth2Client` qui implémente le flow OAuth2 pour Spotify, basée sur votre exemple.

### Classes principales

#### 1. `AuthorizationResponse`
```dart
class AuthorizationResponse {
  final String? code;
  final String? error;
  
  AuthorizationResponse({this.code, this.error});
}
```

#### 2. `AccessTokenResponse`
```dart
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
```

#### 3. `SpotifyOAuth2Client`
```dart
class SpotifyOAuth2Client {
  final String customUriScheme;
  final String redirectUri;
  final String authorizeUrl = 'https://accounts.spotify.com/authorize';
  final String tokenUrl = 'https://accounts.spotify.com/api/token';

  SpotifyOAuth2Client({
    required this.customUriScheme,
    required this.redirectUri,
  });
}
```

## Méthodes disponibles

### 1. `requestAuthorization()`
```dart
Future<AuthorizationResponse> requestAuthorization({
  required String clientId,
  Map<String, String>? customParams,
  List<String>? scopes,
}) async
```

**Utilisation :**
```dart
var authResp = await _oauth2Client.requestAuthorization(
  clientId: clientId,
  customParams: {'show_dialog': 'true'},
  scopes: scope.split(' '),
);
```

### 2. `requestAccessToken()`
```dart
Future<AccessTokenResponse> requestAccessToken({
  required String code,
  required String clientId,
  required String clientSecret,
}) async
```

**Utilisation :**
```dart
var accessToken = await _oauth2Client.requestAccessToken(
  code: authResp.code.toString(),
  clientId: clientId,
  clientSecret: clientSecret,
);
```

### 3. `refreshToken()`
```dart
Future<AccessTokenResponse> refreshToken({
  required String refreshToken,
  required String clientId,
  required String clientSecret,
}) async
```

**Utilisation :**
```dart
var accessToken = await _oauth2Client.refreshToken(
  refreshToken: _refreshToken!,
  clientId: clientId,
  clientSecret: clientSecret,
);
```

## Flow d'authentification complet

```dart
// Exemple complet d'authentification
static Future<void> authenticateSpotify() async {
  AccessTokenResponse? accessToken;
SpotifyOAuth2Client client = SpotifyOAuth2Client(
  customUriScheme: 'com.goodspotify.stream',
  redirectUri: 'com.goodspotify.stream://callback',
);
  
  // Step 1: Request authorization
  var authResp = await client.requestAuthorization(
    clientId: CLIENT_ID,
    customParams: {'show_dialog': 'true'},
    scopes: ['user-read-private', 'user-read-email', 'user-top-read']
  );
  
  // Step 2: Check for authorization code
  if (authResp.code != null) {
    // Step 3: Exchange code for access token
    accessToken = await client.requestAccessToken(
      code: authResp.code.toString(),
      clientId: CLIENT_ID,
      clientSecret: CLIENT_SECRET
    );
    
    // Step 4: Use tokens
    if (accessToken != null && accessToken.accessToken != null) {
      String access_Token = accessToken.accessToken!;
      String refresh_Token = accessToken.refreshToken ?? '';
      
      print('✅ Authentication successful!');
      print('🔑 Access Token: ${access_Token.substring(0, 20)}...');
    }
  }
}
```

## Configuration requise

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="com.goodspotify.stream" android:host="callback" />
    </intent-filter>
</activity>
```

### iOS (ios/Runner/Info.plist)
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
            <key>CFBundleURLName</key>
            <string>com.goodspotify.stream.auth</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.goodspotify.stream</string>
            </array>
    </dict>
</array>
```

## Avantages de cette implémentation

### ✅ **Contrôle total**
- Code personnalisé adapté à vos besoins
- Pas de dépendance externe complexe
- Facile à déboguer et modifier

### ✅ **Simplicité**
- API claire et intuitive
- Basée sur votre exemple existant
- Méthodes bien définies

### ✅ **Flexibilité**
- Facilement extensible
- Support des paramètres personnalisés
- Gestion d'erreurs intégrée

### ✅ **Performance**
- Pas de surcharge de packages externes
- Code optimisé pour Spotify
- Logs de débogage intégrés

## Gestion des erreurs

L'implémentation inclut une gestion d'erreurs robuste :

```dart
try {
  var authResp = await client.requestAuthorization(
    clientId: clientId,
    customParams: {'show_dialog': 'true'},
    scopes: scope.split(' '),
  );
  
  if (authResp.error != null) {
    print('❌ Authorization error: ${authResp.error}');
    return false;
  }
  
  if (authResp.code == null) {
    print('❌ No authorization code received');
    return false;
  }
  
  // Continue with token exchange...
} catch (e) {
  print('❌ Authentication error: $e');
  return false;
}
```

## Logs de débogage

L'implémentation inclut des logs détaillés pour le débogage :

```
🎵 Starting Spotify authentication with oauth2_client...
🔗 Authorization URL: https://accounts.spotify.com/authorize?...
🔄 Authentication result received: com.goodspotify.stream://callback?code=...
📋 Auth code: AQDXr8k8...
🔄 Exchanging code for access token...
📡 Token exchange response: 200
🎉 Authentication completed successfully!
🔑 Access token: BQC6Z8k8...
🔄 Refresh token: AQDXr8k8...
```

Cette implémentation personnalisée vous donne un contrôle total sur le processus d'authentification OAuth2 avec Spotify, tout en gardant la simplicité et la flexibilité nécessaires pour votre application.
