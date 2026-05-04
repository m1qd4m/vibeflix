import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/tmdb_service.dart';
import '../services/ai_service.dart';
import '../services/firebase_service.dart';
import '../models/movie.dart';
import '../models/user_model.dart';

// ── Services ──
final authServiceProvider     = Provider<AuthService>((ref) => AuthService());
final aiServiceProvider       = Provider<AiService>((ref) => AiService());
final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

// ── Theme mode ──
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

// ── Language (reactive) ──
final selectedLanguageProvider = StateProvider<String>((ref) => 'en-US');

final tmdbServiceProvider = Provider<TmdbService>((ref) {
  final lang = ref.watch(selectedLanguageProvider);
  return TmdbService(language: lang);
});

// ── Auth ──
final authStateProvider = StreamProvider<User?>((ref) =>
    ref.watch(authServiceProvider).authStateChanges);

final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref.watch(firebaseServiceProvider).userProfileStream(user.uid);
});

// ── Home lists ──
final trendingProvider   = FutureProvider<List<Movie>>((ref) => ref.watch(tmdbServiceProvider).getTrending());
final popularProvider    = FutureProvider<List<Movie>>((ref) => ref.watch(tmdbServiceProvider).getPopular());
final topRatedProvider   = FutureProvider<List<Movie>>((ref) => ref.watch(tmdbServiceProvider).getTopRated());
final nowPlayingProvider = FutureProvider<List<Movie>>((ref) => ref.watch(tmdbServiceProvider).getNowPlaying());
final upcomingProvider   = FutureProvider<List<Movie>>((ref) => ref.watch(tmdbServiceProvider).getUpcoming());
final animeProvider      = FutureProvider<List<Movie>>((ref) => ref.watch(tmdbServiceProvider).getAnime());

final featuredMovieProvider = FutureProvider<Movie?>((ref) async {
  final list = await ref.watch(trendingProvider.future);
  return list.isNotEmpty ? list.first : null;
});

// ── Movie detail ──
final movieDetailProvider  = FutureProvider.family<Movie, int>((ref, id) => ref.watch(tmdbServiceProvider).getMovieDetails(id));
final movieVideosProvider  = FutureProvider.family<List<Video>, int>((ref, id) => ref.watch(tmdbServiceProvider).getMovieVideos(id));
final similarMoviesProvider = FutureProvider.family<List<Movie>, int>((ref, id) => ref.watch(tmdbServiceProvider).getSimilar(id));

// ── Watchlist / History ──
final watchlistProvider    = StreamProvider<List<Movie>>((ref) => ref.watch(firebaseServiceProvider).watchlistStream());
final watchHistoryProvider = StreamProvider<List<Movie>>((ref) => ref.watch(firebaseServiceProvider).watchHistoryStream());

// ── Personalized ──
final personalizedProvider = FutureProvider<List<Movie>>((ref) async {
  final fb   = ref.watch(firebaseServiceProvider);
  final tmdb = ref.watch(tmdbServiceProvider);
  final ids  = await fb.getWatchHistoryGenreIds();
  if (ids.isEmpty) return tmdb.getPopular();
  return tmdb.discoverByGenres(genreIds: ids);
});

// ── Mood state ──
class MoodState {
  final String? selectedMood;
  final String? selectedRuntime;
  final List<Movie> movies;
  final bool isLoading;
  final String? error;
  const MoodState({this.selectedMood, this.selectedRuntime, this.movies = const [], this.isLoading = false, this.error});
  MoodState copyWith({String? selectedMood, String? selectedRuntime, List<Movie>? movies, bool? isLoading, String? error}) =>
      MoodState(
        selectedMood: selectedMood ?? this.selectedMood,
        selectedRuntime: selectedRuntime ?? this.selectedRuntime,
        movies: movies ?? this.movies,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class MoodNotifier extends StateNotifier<MoodState> {
  final TmdbService _tmdb;
  MoodNotifier(this._tmdb) : super(const MoodState());

  void selectMood(String mood) {
    state = state.copyWith(selectedMood: mood);
    _fetch();
  }

  void selectRuntime(String rt) {
    state = state.copyWith(selectedRuntime: rt);
    _fetch();
  }

  Future<void> _fetch() async {
    if (state.selectedMood == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      int? minR, maxR;
      if (state.selectedRuntime == 'Quick (<90m)')  { minR = 0;   maxR = 90; }
      if (state.selectedRuntime == 'Standard')       { minR = 90;  maxR = 120; }
      if (state.selectedRuntime == 'Epic (2h+)')     { minR = 120; }
      final movies = await _tmdb.getByMood(state.selectedMood!, minRuntime: minR, maxRuntime: maxR);
      state = state.copyWith(movies: movies, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final moodProvider = StateNotifierProvider<MoodNotifier, MoodState>((ref) =>
    MoodNotifier(ref.watch(tmdbServiceProvider)));

// ── Chat ──
class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  const ChatState({this.messages = const [], this.isTyping = false});
  ChatState copyWith({List<ChatMessage>? messages, bool? isTyping}) =>
      ChatState(messages: messages ?? this.messages, isTyping: isTyping ?? this.isTyping);
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AiService _ai;
  final TmdbService _tmdb;
  ChatNotifier(this._ai, this._tmdb) : super(const ChatState());

  Future<void> sendMessage(String text) async {
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text, isUser: true, timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, userMsg], isTyping: true);

    try {
      final rec = await _ai.analyzeQuery(text);
      final kwIds = await _tmdb.searchKeywordIds(rec.keywords);
      final movies = await _tmdb.discoverByGenres(genreIds: rec.genreIds, keywordIds: kwIds);

      final botMsg = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_bot',
        text: rec.reasoning,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedMovies: movies.take(8).toList(),
      );
      state = state.copyWith(messages: [...state.messages, botMsg], isTyping: false);
    } catch (e) {
      final errMsg = ChatMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_err',
        text: 'Sorry, I had trouble finding recommendations. Please try again!',
        isUser: false, timestamp: DateTime.now(),
      );
      state = state.copyWith(messages: [...state.messages, errMsg], isTyping: false);
    }
  }

  void clearChat() => state = const ChatState();
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) =>
    ChatNotifier(ref.watch(aiServiceProvider), ref.watch(tmdbServiceProvider)));

// ── Search ──
class SearchNotifier extends StateNotifier<AsyncValue<List<Movie>>> {
  final TmdbService _tmdb;
  SearchNotifier(this._tmdb) : super(const AsyncValue.data([]));

  Future<void> search(String query) async {
    if (query.trim().isEmpty) { state = const AsyncValue.data([]); return; }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _tmdb.search(query));
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, AsyncValue<List<Movie>>>((ref) =>
    SearchNotifier(ref.watch(tmdbServiceProvider)));
