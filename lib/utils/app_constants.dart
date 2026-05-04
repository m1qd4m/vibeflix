import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get tmdbApiKey => dotenv.env['TMDB_API_KEY'] ?? '';
  static String get tmdbBaseUrl => 'https://api.themoviedb.org/3';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static String posterUrl(String? path) =>
      path != null && path.isNotEmpty ? 'https://image.tmdb.org/t/p/w500$path' : '';
  static String backdropUrl(String? path) =>
      path != null && path.isNotEmpty ? 'https://image.tmdb.org/t/p/original$path' : '';

  // ── Mood → TMDB genre IDs ──────────────────────────────────────────────────
  // Each entry uses ONLY genres that truly represent the mood.
  // | = OR logic inside the same mood (e.g. Action OR Thriller for Thrilled).
  static const Map<String, List<int>> moodGenres = {
    'Happy':     [35, 10751],  // Comedy | Family
    'Thrilled':  [28, 53],     // Action | Thriller
    'Romantic':  [10749],      // Romance
    'Scared':    [27],         // Horror
    'Chill':     [16],         // Animation
    'Nostalgic': [36, 10752],  // History | War
  };

  // ── Minimum vote average per mood ─────────────────────────────────────────
  static const Map<String, double> moodMinRating = {
    'Happy':     6.5,
    'Thrilled':  6.5,
    'Romantic':  6.5,
    'Scared':    6.0,
    'Chill':     6.5,
    'Nostalgic': 6.8,
  };

  // ── Language name → TMDB language code ───────────────────────────────────
  static const Map<String, String> languageCodes = {
    'English': 'en-US',
    'Urdu':    'ur',
    'Arabic':  'ar',
    'Hindi':   'hi',
    'French':  'fr',
    'Spanish': 'es',
    'Korean':  'ko',
    'Japanese':'ja',
  };

  // ── Mood descriptions ──────────────────────────────────────────────────────
  static const Map<String, String> moodDescriptions = {
    'Happy':     'Feel-good comedies and family fun',
    'Thrilled':  'Edge-of-seat action and suspense',
    'Romantic':  'Love stories and heartfelt moments',
    'Scared':    'Horror films to keep you up at night',
    'Chill':     'Relaxing animated films to unwind',
    'Nostalgic': 'Epic historical and war classics',
  };

  // ── Mood emojis ────────────────────────────────────────────────────────────
  static const Map<String, String> moodEmojis = {
    'Happy':     '😄',
    'Thrilled':  '🤩',
    'Romantic':  '💕',
    'Scared':    '😱',
    'Chill':     '☕',
    'Nostalgic': '🎞️',
  };

  // ── Ordered mood list ──────────────────────────────────────────────────────
  static const List<String> moods = [
    'Happy', 'Thrilled', 'Romantic', 'Scared', 'Chill', 'Nostalgic',
  ];

  // ── Runtime filters ────────────────────────────────────────────────────────
  static const Map<String, Map<String, int>> runtimeFilters = {
    'Quick (<90m)':  {'min': 0,   'max': 90},
    'Standard':      {'min': 90,  'max': 120},
    'Epic (2h+)':    {'min': 120, 'max': 999},
  };
}
