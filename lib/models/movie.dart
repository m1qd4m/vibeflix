import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final String? releaseDate;
  final List<int> genreIds;
  final List<Genre> genres;
  final int? runtime;
  final String? tagline;

  const Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0.0,
    this.releaseDate,
    this.genreIds = const [],
    this.genres = const [],
    this.runtime,
    this.tagline,
  });

  String get posterUrl => posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : 'https://via.placeholder.com/500x750/0D1117/E50914?text=VibeFlix';

  String get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/original$backdropPath'
      : 'https://via.placeholder.com/1920x1080/0D1117/E50914?text=VibeFlix';

  String get year => releaseDate != null && releaseDate!.length >= 4
      ? releaseDate!.substring(0, 4)
      : '';

  String get ratingFormatted => voteAverage.toStringAsFixed(1);

  String get runtimeFormatted {
    if (runtime == null) return '';
    final h = runtime! ~/ 60;
    final m = runtime! % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      releaseDate: json['release_date'] as String?,
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      runtime: json['runtime'] as int?,
      tagline: json['tagline'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'posterPath': posterPath,
      'backdropPath': backdropPath,
      'voteAverage': voteAverage,
      'releaseDate': releaseDate,
      'genreIds': genreIds,
      'runtime': runtime,
      'watchedAt': FieldValue.serverTimestamp(),
    };
  }

  factory Movie.fromFirestore(Map<String, dynamic> data) {
    return Movie(
      id: data['id'] as int,
      title: data['title'] as String? ?? '',
      overview: data['overview'] as String?,
      posterPath: data['posterPath'] as String?,
      backdropPath: data['backdropPath'] as String?,
      voteAverage: (data['voteAverage'] as num?)?.toDouble() ?? 0.0,
      releaseDate: data['releaseDate'] as String?,
      genreIds: (data['genreIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }
}

class Genre {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) =>
      Genre(id: json['id'] as int, name: json['name'] as String? ?? '');
}

class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;

  const Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: json['id'] as String? ?? '',
        key: json['key'] as String? ?? '',
        name: json['name'] as String? ?? '',
        site: json['site'] as String? ?? '',
        type: json['type'] as String? ?? '',
      );

  bool get isYouTubeTrailer => site == 'YouTube' && type == 'Trailer';
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<Movie>? suggestedMovies;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedMovies,
  });
}
