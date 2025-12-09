class Anime {
  final String id;
  final String name;
  final String? image;
  final String? alias;
  final String? description;
  final List<String> genres;
  final String? status;
  final String? releaseDate;
  final int? totalEpisodes;
  final double? rating;
  final String? type; // TV, Movie, OVA, etc.
  final String? studio;
  final List<AnimeEpisode> episodes;

  const Anime({
    required this.id,
    required this.name,
    this.image,
    this.alias,
    this.description,
    this.genres = const <String>[],
    this.status,
    this.releaseDate,
    this.totalEpisodes,
    this.rating,
    this.type,
    this.studio,
    this.episodes = const <AnimeEpisode>[],
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
      alias: json['alias'] as String?,
      description: json['description'] as String?,
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? <String>[],
      status: json['status'] as String?,
      releaseDate: json['releaseDate'] as String?,
      totalEpisodes: json['totalEpisodes'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      type: json['type'] as String?,
      studio: json['studio'] as String?,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((dynamic e) => AnimeEpisode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <AnimeEpisode>[],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'image': image,
      'alias': alias,
      'description': description,
      'genres': genres,
      'status': status,
      'releaseDate': releaseDate,
      'totalEpisodes': totalEpisodes,
      'rating': rating,
      'type': type,
      'studio': studio,
      'episodes': episodes.map((AnimeEpisode e) => e.toJson()).toList(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Anime && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Anime(id: $id, name: $name, type: $type, episodes: ${episodes.length})';
  }
}

class AnimeEpisode {
  final String id;
  final String title;
  final int episodeNumber;
  final String? description;
  final String? thumbnail;
  final String? airDate;
  final Duration? duration;
  final String? url;

  const AnimeEpisode({
    required this.id,
    required this.title,
    required this.episodeNumber,
    this.description,
    this.thumbnail,
    this.airDate,
    this.duration,
    this.url,
  });

  factory AnimeEpisode.fromJson(Map<String, dynamic> json) {
    return AnimeEpisode(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      episodeNumber: json['episodeNumber'] as int? ?? 0,
      description: json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      airDate: json['airDate'] as String?,
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration'] as int)
          : null,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'episodeNumber': episodeNumber,
      'description': description,
      'thumbnail': thumbnail,
      'airDate': airDate,
      'duration': duration?.inSeconds,
      'url': url,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimeEpisode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AnimeEpisode(id: $id, title: $title, episodeNumber: $episodeNumber)';
  }
}