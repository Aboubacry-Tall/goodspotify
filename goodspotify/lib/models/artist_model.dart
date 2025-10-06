class ArtistModel {
  final String id;
  final String name;
  final List<String> genres;
  final int followers;
  final String? imageUrl;
  final int? popularity;

  ArtistModel({
    required this.id,
    required this.name,
    required this.genres,
    required this.followers,
    this.imageUrl,
    this.popularity,
  });

  factory ArtistModel.fromSpotifyJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      followers: json['followers']?['total'] ?? 0,
      imageUrl: json['images']?.isNotEmpty == true
          ? json['images'][0]['url']
          : null,
      popularity: json['popularity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'genres': genres,
      'followers': followers,
      'image_url': imageUrl,
      'popularity': popularity,
    };
  }

  String get formattedFollowers {
    if (followers >= 1000000) {
      return '${(followers / 1000000).toStringAsFixed(1)}M';
    } else if (followers >= 1000) {
      return '${(followers / 1000).toStringAsFixed(1)}K';
    }
    return followers.toString();
  }

  String get genresString => genres.join(', ');

  @override
  String toString() {
    return 'ArtistModel(id: $id, name: $name, followers: $formattedFollowers)';
  }
}
