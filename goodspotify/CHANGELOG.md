# Changelog

## [1.0.1] - 2024-10-06

### Supprimé
- **Spotify SDK** : Suppression de la dépendance `spotify_sdk: ^3.0.0` qui causait des problèmes de build
  - Erreur résolue : "Project with path ':spotify-app-remote' could not be found"

### Modifié
- **SpotifyService** : Adaptation pour fonctionner sans SDK
  - Authentification simulée en attendant l'implémentation OAuth2
  - Ajout de la méthode `getAuthorizationUrl()` pour préparer l'intégration future
  - Messages de debug améliorés avec emojis
- **SettingsController** : Meilleure intégration avec SpotifyService
  - Gestion d'erreur améliorée
  - Messages de snackbar avec couleurs appropriées

### Ajouté
- Documentation sur l'absence du SDK dans README.md
- Notes sur l'utilisation de l'API Web Spotify uniquement
- CHANGELOG.md pour suivre les modifications

### Technique
- Configuration Spotify adaptée pour OAuth2 Web flow
- Client Secret ajouté dans la configuration (pour usage futur)
- Redirect URI changé vers localhost pour le développement

## [1.0.0] - 2024-10-06

### Première version
- Application Flutter complète avec GetX
- Bottom navigation avec 4 pages (Accueil, Top, Stats, Paramètres)
- Architecture MVC avec contrôleurs GetX
- Services Spotify et Firebase (structure de base)
- Interface Material Design 3 avec thèmes clair/sombre
- Couleurs officielles Spotify
- Simulation de données pour les tests
