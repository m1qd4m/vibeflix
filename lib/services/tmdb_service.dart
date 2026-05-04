import 'package:dio/dio.dart';
import '../models/movie.dart';
import '../utils/app_constants.dart';

class TmdbService {
  late final Dio _dio;

  TmdbService({String language = 'en-US'}) {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.tmdbBaseUrl,
      queryParameters: {'api_key': AppConstants.tmdbApiKey, 'language': language},
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  Future<List<Movie>> getTrending({int page = 1}) async {
    final res = await _dio.get('/trending/movie/week', queryParameters: {'page': page});
    return _parse(res.data);
  }

  Future<List<Movie>> getPopular({int page = 1}) async {
    final res = await _dio.get('/movie/popular', queryParameters: {'page': page});
    return _parse(res.data);
  }

  Future<List<Movie>> getTopRated({int page = 1}) async {
    final res = await _dio.get('/movie/top_rated', queryParameters: {'page': page});
    return _parse(res.data);
  }

  Future<List<Movie>> getNowPlaying({int page = 1}) async {
    final res = await _dio.get('/movie/now_playing', queryParameters: {'page': page});
    return _parse(res.data);
  }

  Future<List<Movie>> getUpcoming({int page = 1}) async {
    final res = await _dio.get('/movie/upcoming', queryParameters: {'page': page});
    return _parse(res.data);
  }

  // ANIME — uses animation genre + Japanese language
  Future<List<Movie>> getAnime({int page = 1}) async {
    final res = await _dio.get('/discover/movie', queryParameters: {
      'page': page,
      'with_genres': '16',
      'with_original_language': 'ja',
      'sort_by': 'popularity.desc',
      'vote_count.gte': 50,
    });
    return _parse(res.data);
  }

  // Anime TV series
  Future<List<Movie>> getAnimeSeries({int page = 1}) async {
    final res = await _dio.get('/discover/tv', queryParameters: {
      'page': page,
      'with_genres': '16',
      'with_original_language': 'ja',
      'sort_by': 'popularity.desc',
      'vote_count.gte': 50,
    });
    return _parseTv(res.data);
  }

  Future<Movie> getMovieDetails(int id) async {
    final res = await _dio.get('/movie/$id');
    return Movie.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<Video>> getMovieVideos(int id) async {
    final res = await _dio.get('/movie/$id/videos');
    final results = (res.data['results'] as List<dynamic>?) ?? [];
    return results.map((v) => Video.fromJson(v as Map<String, dynamic>)).toList();
  }

  Future<List<Movie>> getSimilar(int id) async {
    final res = await _dio.get('/movie/$id/similar');
    return _parse(res.data);
  }

  // Mood-based discovery — strict genre + popularity sort for recognisable picks
  Future<List<Movie>> getByMood(String mood, {int? minRuntime, int? maxRuntime, int page = 1}) async {
    final genres    = AppConstants.moodGenres[mood] ?? [35];
    final minRating = AppConstants.moodMinRating[mood] ?? 6.5;

    final params = <String, dynamic>{
      'page':             page,
      'with_genres':      genres.join('|'),  // OR between genres in same bucket
      'sort_by':          'popularity.desc', // Popular = recognisable, not obscure
      'vote_count.gte':   200,               // Must have enough votes to be trustworthy
      'vote_average.gte': minRating,         // Must meet per-mood quality bar
    };
    if (minRuntime != null && minRuntime > 0)   params['with_runtime.gte'] = minRuntime;
    if (maxRuntime != null && maxRuntime < 999) params['with_runtime.lte'] = maxRuntime;
    final res = await _dio.get('/discover/movie', queryParameters: params);
    return _parse(res.data);
  }

  // AI-driven discovery
  Future<List<Movie>> discoverByGenres({required List<int> genreIds, List<int>? keywordIds, int page = 1}) async {
    final params = <String, dynamic>{
      'page': page,
      'sort_by': 'popularity.desc',
      'vote_count.gte': 100,
    };
    if (genreIds.isNotEmpty) params['with_genres'] = genreIds.join('|');
    if (keywordIds != null && keywordIds.isNotEmpty) params['with_keywords'] = keywordIds.join('|');
    final res = await _dio.get('/discover/movie', queryParameters: params);
    return _parse(res.data);
  }

  Future<List<Movie>> search(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];
    final res = await _dio.get('/search/multi', queryParameters: {
      'query': query, 'page': page, 'include_adult': false,
    });
    return _parseMulti(res.data);
  }

  Future<List<int>> searchKeywordIds(List<String> keywords) async {
    final ids = <int>[];
    for (final kw in keywords.take(3)) {
      try {
        final res = await _dio.get('/search/keyword', queryParameters: {'query': kw});
        final results = (res.data['results'] as List<dynamic>?) ?? [];
        if (results.isNotEmpty) ids.add(results.first['id'] as int);
      } catch (_) {}
    }
    return ids;
  }

  Future<List<Genre>> getGenres() async {
    final res = await _dio.get('/genre/movie/list');
    final list = (res.data['genres'] as List<dynamic>?) ?? [];
    return list.map((g) => Genre.fromJson(g as Map<String, dynamic>)).toList();
  }

  List<Movie> _parse(dynamic data) {
    final results = (data['results'] as List<dynamic>?) ?? [];
    return results
        .map((m) => Movie.fromJson(m as Map<String, dynamic>))
        .where((m) => m.posterPath != null && m.backdropPath != null && m.voteAverage > 0)
        .toList();
  }

  List<Movie> _parseTv(dynamic data) {
    final results = (data['results'] as List<dynamic>?) ?? [];
    return results.map((m) {
      final map = m as Map<String, dynamic>;
      return Movie(
        id: map['id'] as int,
        title: map['name'] as String? ?? map['title'] as String? ?? '',
        overview: map['overview'] as String?,
        posterPath: map['poster_path'] as String?,
        backdropPath: map['backdrop_path'] as String?,
        voteAverage: (map['vote_average'] as num?)?.toDouble() ?? 0,
        releaseDate: map['first_air_date'] as String?,
        genreIds: (map['genre_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      );
    }).where((m) => m.posterPath != null).toList();
  }

  List<Movie> _parseMulti(dynamic data) {
    final results = (data['results'] as List<dynamic>?) ?? [];
    final movies = <Movie>[];
    for (final item in results) {
      final map = item as Map<String, dynamic>;
      final type = map['media_type'] as String?;
      if (type == 'movie' || type == 'tv') {
        try {
          movies.add(Movie(
            id: map['id'] as int,
            title: map['title'] as String? ?? map['name'] as String? ?? '',
            overview: map['overview'] as String?,
            posterPath: map['poster_path'] as String?,
            backdropPath: map['backdrop_path'] as String?,
            voteAverage: (map['vote_average'] as num?)?.toDouble() ?? 0,
            releaseDate: map['release_date'] as String? ?? map['first_air_date'] as String?,
            genreIds: (map['genre_ids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
          ));
        } catch (_) {}
      }
    }
    return movies.where((m) => m.posterPath != null).toList();
  }
}
