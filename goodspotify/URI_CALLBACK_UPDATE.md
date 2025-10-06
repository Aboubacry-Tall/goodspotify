# Mise à jour de l'URI de callback

## Changement effectué

L'URI de callback a été changé de `goodspotify://callback` vers `com.goodspotify.stream://callback` pour correspondre au package name de l'application.

## Fichiers modifiés

### 1. Service Spotify (`lib/services/spotify_service.dart`)

**Avant :**
```dart
static const String redirectUri = 'goodspotify://callback';

_oauth2Client = SpotifyOAuth2Client(
  customUriScheme: 'goodspotify',
  redirectUri: redirectUri,
);
```

**Après :**
```dart
static const String redirectUri = 'com.goodspotify.stream://callback';

_oauth2Client = SpotifyOAuth2Client(
  customUriScheme: 'com.goodspotify.stream',
  redirectUri: redirectUri,
);
```

### 2. Configuration iOS (`ios/Runner/Info.plist`)

**Avant :**
```xml
<key>CFBundleURLName</key>
<string>goodspotify.auth</string>
<key>CFBundleURLSchemes</key>
<array>
    <string>goodspotify</string>
</array>
```

**Après :**
```xml
<key>CFBundleURLName</key>
<string>com.goodspotify.stream.auth</string>
<key>CFBundleURLSchemes</key>
<array>
    <string>com.goodspotify.stream</string>
</array>
```

### 3. Configuration Android (`android/app/src/main/AndroidManifest.xml`)

**Déjà configuré correctement :**
```xml
<data
    android:scheme="com.goodspotify.stream"
    android:host="callback" />
```

### 4. Documentation (`CUSTOM_OAUTH2_GUIDE.md`)

Mise à jour de tous les exemples pour utiliser le nouveau schéma d'URI.

## Configuration Spotify Dashboard

**Important :** Vous devez aussi mettre à jour l'URI de redirection dans votre application Spotify sur le [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/applications) :

1. Allez sur votre application Spotify
2. Cliquez sur "Edit Settings"
3. Dans "Redirect URIs", ajoutez : `com.goodspotify.stream://callback`
4. Supprimez l'ancien URI : `goodspotify://callback`
5. Sauvegardez les modifications

## Vérification

Pour vérifier que tout fonctionne :

1. **Lancez l'application**
2. **Testez l'authentification Spotify**
3. **Vérifiez les logs** - vous devriez voir :
   ```
   🔗 Authorization URL: https://accounts.spotify.com/authorize?...
   🔄 Authentication result received: com.goodspotify.stream://callback?code=...
   ```

## Cohérence des configurations

Maintenant, toutes les configurations sont cohérentes :

- **Package name Android** : `com.goodspotify.stream`
- **Bundle ID iOS** : `com.goodspotify.stream`
- **URI de callback** : `com.goodspotify.stream://callback`
- **Schéma personnalisé** : `com.goodspotify.stream`

Cette cohérence garantit que l'authentification OAuth2 fonctionnera correctement sur toutes les plateformes.
