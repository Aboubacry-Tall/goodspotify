# GoodSpotify

Une application Flutter qui utilise GetX pour récupérer et afficher les statistiques Spotify avec Firebase comme backend.

## Fonctionnalités

### Navigation Bottom (4 onglets)
- **Accueil** : Vue d'ensemble des morceaux récents et recommandations
- **Top** : Classements des titres, artistes et albums avec filtrage par période
- **Stats** : Statistiques détaillées d'écoute avec graphiques
- **Paramètres** : Configuration de l'application et connexion Spotify

### Intégrations
- **GetX** : Gestion d'état réactive et navigation
- **Spotify Web API** : Récupération des données d'écoute (sans SDK, via HTTP)
- **Firebase** : Backend et base de données
- **Material Design 3** : Interface moderne avec thème clair/sombre

## Configuration

### 1. Installation de Flutter
```bash
# Ubuntu/Linux
sudo snap install flutter

# Ou téléchargez depuis https://docs.flutter.dev/get-started/install
```

### 2. Vérification de l'installation
```bash
flutter doctor
```

### 3. Installation des dépendances
```bash
cd goodspotify
flutter pub get
```

### 4. Configuration Spotify
1. Créez une application sur [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Obtenez votre Client ID et Client Secret
3. Modifiez `lib/services/spotify_service.dart` :
```dart
static const String clientId = 'VOTRE_CLIENT_ID_SPOTIFY';
static const String clientSecret = 'VOTRE_CLIENT_SECRET_SPOTIFY';
```
4. **Note** : Le SDK Spotify a été retiré pour éviter les conflits de build. L'intégration se fait via l'API Web Spotify uniquement.

### 5. Configuration Firebase
1. Créez un projet Firebase
2. Ajoutez votre application Android/iOS
3. Téléchargez les fichiers de configuration :
   - `android/app/google-services.json` (Android)
   - `ios/Runner/GoogleService-Info.plist` (iOS)
4. Décommentez les imports Firebase dans `lib/main.dart`

## Lancement

### Mode développement
```bash
flutter run
```

### Mode debug
```bash
flutter run --debug
```

### Mode release
```bash
flutter run --release
```

## Architecture

```
lib/
├── main.dart                 # Point d'entrée de l'application
├── bindings/
│   └── main_binding.dart     # Injection de dépendances GetX
├── controllers/
│   ├── navigation_controller.dart
│   ├── home_controller.dart
│   ├── top_controller.dart
│   ├── stats_controller.dart
│   └── settings_controller.dart
├── views/
│   ├── main_page.dart        # Page principale avec bottom navigation
│   ├── home/
│   │   └── home_page.dart
│   ├── top/
│   │   └── top_page.dart
│   ├── stats/
│   │   └── stats_page.dart
│   └── settings/
│       └── settings_page.dart
├── services/
│   ├── spotify_service.dart  # Service d'intégration Spotify
│   └── firebase_service.dart # Service Firebase
└── models/
    ├── user_model.dart
    ├── track_model.dart
    └── artist_model.dart
```

## Fonctionnalités implémentées

### ✅ Complété
- [x] Architecture GetX avec contrôleurs et bindings
- [x] Bottom navigation avec 4 pages
- [x] Interface utilisateur complète pour toutes les pages
- [x] Thèmes clair/sombre compatibles Spotify
- [x] Services Spotify et Firebase (structure de base)
- [x] Modèles de données
- [x] Gestion des paramètres avec SharedPreferences

### 🚧 À développer
- [ ] Authentification Spotify réelle (OAuth2 flow avec url_launcher)
- [ ] Intégration Firebase complète
- [ ] API calls Spotify fonctionnels (remplacer les simulations)
- [ ] Graphiques interactifs pour les statistiques
- [ ] Mode hors ligne
- [ ] Notifications push
- [ ] Tests unitaires

### ⚠️ Notes importantes
- **Spotify SDK retiré** : Pour éviter les problèmes de build, le SDK Spotify a été retiré. L'intégration se fait uniquement via l'API Web Spotify.
- **Simulation** : Pour l'instant, toutes les données Spotify sont simulées pour permettre les tests de l'interface.

## Personnalisation

### Couleurs Spotify
- Vert principal : `#1DB954`
- Noir : `#191414`
- Fond sombre : `#121212`

### Polices
Utilise Google Fonts (Inter) pour une apparence moderne.

## Contribution

1. Fork le projet
2. Créez votre branche (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commitez vos changements (`git commit -am 'Ajout nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrez une Pull Request

## Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.

## Support

Pour toute question ou problème, ouvrez une issue dans le repository.