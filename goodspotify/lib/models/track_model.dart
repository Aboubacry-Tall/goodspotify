class TrackModel {
  final String id;
  final String name;
  final List<String> artists;
  final String albumName;
  final String? imageUrl;
  final int durationMs;
  final int? popularity;
  final DateTime? playedAt;

  TrackModel({
    required this.id,
    required this.name,
    required this.artists,
    required this.albumName,
    this.imageUrl,
    required this.durationMs,
    this.popularity,
    this.playedAt,
  });

  factory TrackModel.fromSpotifyJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      artists: (json['artists'] as List?)
          ?.map((artist) => artist['name'] as String)
          .toList() ?? [],
      albumName: json['album']?['name'] ?? '',
      imageUrl: json['album']?['images']?.isNotEmpty == true
          ? json['album']['images'][0]['url']
          : null,
      durationMs: json['duration_ms'] ?? 0,
      popularity: json['popularity'],
      playedAt: json['played_at'] != null 
          ? DateTime.parse(json['played_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'artists': artists,
      'album_name': albumName,
      'image_url': imageUrl,
      'duration_ms': durationMs,
      'popularity': popularity,
      'played_at': playedAt?.toIso8601String(),
    };
  }

  String get formattedDuration {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  String get artistsString => artists.join(', ');

  @override
  String toString() {
    return 'TrackModel(id: $id, name: $name, artists: $artistsString)';
  }
}
