class UserModel {
  final String id;
  final String? displayName;
  final String? email;
  final String? imageUrl;
  final bool isSpotifyConnected;
  final DateTime? lastSync;
  final Map<String, dynamic>? preferences;

  UserModel({
    required this.id,
    this.displayName,
    this.email,
    this.imageUrl,
    this.isSpotifyConnected = false,
    this.lastSync,
    this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      displayName: json['display_name'],
      email: json['email'],
      imageUrl: json['image_url'],
      isSpotifyConnected: json['is_spotify_connected'] ?? false,
      lastSync: json['last_sync'] != null 
          ? DateTime.parse(json['last_sync']) 
          : null,
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'image_url': imageUrl,
      'is_spotify_connected': isSpotifyConnected,
      'last_sync': lastSync?.toIso8601String(),
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? imageUrl,
    bool? isSpotifyConnected,
    DateTime? lastSync,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      isSpotifyConnected: isSpotifyConnected ?? this.isSpotifyConnected,
      lastSync: lastSync ?? this.lastSync,
      preferences: preferences ?? this.preferences,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, displayName: $displayName, email: $email, isSpotifyConnected: $isSpotifyConnected)';
  }
}
