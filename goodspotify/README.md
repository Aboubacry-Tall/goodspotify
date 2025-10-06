# GoodSpotify

A Flutter application that uses GetX to retrieve and display Spotify statistics with Firebase as backend.

## Features

### Bottom Navigation (4 tabs)
- **Home** : Overview of recent tracks and recommendations  
- **Top** : Rankings of tracks, artists and albums with time period filtering
- **Stats** : Detailed listening statistics with charts
- **Settings** : Application configuration and Spotify connection

### Integrations
- **GetX** : Reactive state management and navigation
- **Spotify Web API** : Listening data retrieval (without SDK, via HTTP)
- **Firebase** : Backend and database
- **Material Design 3** : Modern interface with light/dark theme

## Setup

### 1. Flutter Installation
```bash
# Ubuntu/Linux
sudo snap install flutter

# Or download from https://docs.flutter.dev/get-started/install
```

### 2. Installation Verification
```bash
flutter doctor
```

### 3. Dependencies Installation
```bash
cd goodspotify
flutter pub get
```

### 4. Spotify Configuration
1. Create an application on [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Get your Client ID and Client Secret
3. Edit `lib/services/spotify_service.dart`:
```dart
static const String clientId = 'YOUR_SPOTIFY_CLIENT_ID';
static const String clientSecret = 'YOUR_SPOTIFY_CLIENT_SECRET';
```
4. **Note**: Spotify SDK has been removed to avoid build conflicts. Integration is done via Spotify Web API only.

### 5. Firebase Configuration
1. Create a Firebase project
2. Add your Android/iOS application
3. Download configuration files:
   - `android/app/google-services.json` (Android)
   - `ios/Runner/GoogleService-Info.plist` (iOS)
4. Uncomment Firebase imports in `lib/main.dart`

## Running

### Development mode
```bash
flutter run
```

### Debug mode
```bash
flutter run --debug
```

### Release mode
```bash
flutter run --release
```

## Architecture

```
lib/
├── main.dart                 # Application entry point
├── bindings/
│   └── main_binding.dart     # GetX dependency injection
├── controllers/
│   ├── navigation_controller.dart
│   ├── home_controller.dart
│   ├── top_controller.dart
│   ├── stats_controller.dart
│   └── settings_controller.dart
├── views/
│   ├── main_page.dart        # Main page with bottom navigation
│   ├── home/
│   │   └── home_page.dart
│   ├── top/
│   │   └── top_page.dart
│   ├── stats/
│   │   └── stats_page.dart
│   └── settings/
│       └── settings_page.dart
├── services/
│   ├── spotify_service.dart  # Spotify integration service
│   └── firebase_service.dart # Firebase service
└── models/
    ├── user_model.dart
    ├── track_model.dart
    └── artist_model.dart
```

## Implemented Features

### ✅ Completed
- [x] GetX architecture with controllers and bindings
- [x] Bottom navigation with 4 pages
- [x] Complete user interface for all pages
- [x] Spotify-compatible light/dark themes
- [x] Spotify and Firebase services (basic structure)
- [x] Data models
- [x] Settings management with SharedPreferences

### 🚧 To Develop
- [ ] Real Spotify authentication (OAuth2 flow with url_launcher)
- [ ] Complete Firebase integration
- [ ] Functional Spotify API calls (replace simulations)
- [ ] Interactive charts for statistics
- [ ] Offline mode
- [ ] Push notifications
- [ ] Unit tests

### ⚠️ Important Notes
- **Spotify SDK removed**: To avoid build problems, the Spotify SDK has been removed. Integration is done only via Spotify Web API.
- **Simulation**: Currently, all Spotify data is simulated to allow interface testing.

## Customization

### Spotify Colors
- Primary green: `#1DB954`
- Black: `#191414`
- Dark background: `#121212`

### Fonts
Uses Google Fonts (Inter) for a modern appearance.

## Contributing

1. Fork the project
2. Create your branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Support

For any questions or issues, open an issue in the repository.