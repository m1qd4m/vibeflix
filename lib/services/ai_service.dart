import 'package:dio/dio.dart';
import 'dart:convert';
import '../utils/app_constants.dart';

class AiRecommendation {
  final List<int> genreIds;
  final List<String> keywords;
  final String reasoning;
  const AiRecommendation({required this.genreIds, required this.keywords, required this.reasoning});
}

class AiService {
  static const _geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  late final Dio _dio;

  static const Map<String, int> _genreMap = {
    'action': 28, 'adventure': 12, 'animation': 16, 'comedy': 35,
    'crime': 80, 'documentary': 99, 'drama': 18, 'family': 10751,
    'fantasy': 14, 'history': 36, 'horror': 27, 'music': 10402,
    'mystery': 9648, 'romance': 10749, 'science fiction': 878, 'sci-fi': 878,
    'thriller': 53, 'war': 10752, 'western': 37, 'anime': 16,
  };

  AiService() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  Future<AiRecommendation> analyzeQuery(String query) async {
    final key = AppConstants.geminiApiKey;
    if (key.isEmpty || key == 'your_gemini_api_key_here') return _fallback(query);

    const prompt = '''
You are a movie recommendation AI. Analyze the user request and extract movie genres and keywords.
Respond ONLY with valid JSON, no markdown:
{
  "genres": ["genre1", "genre2"],
  "keywords": ["keyword1", "keyword2"],
  "reasoning": "I found great picks for you based on your request!"
}
Available genres: Action, Adventure, Animation, Comedy, Crime, Documentary, Drama, Family, Fantasy, History, Horror, Music, Mystery, Romance, Science Fiction, Thriller, War, Western.
For anime requests use Animation genre.
Keep reasoning friendly, under 15 words.
''';

    try {
      final res = await _dio.post('$_geminiUrl?key=$key', data: {
        'contents': [{'parts': [{'text': '$prompt\nUser: $query'}]}],
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 200},
      });
      final text = (res.data['candidates'][0]['content']['parts'][0]['text'] as String)
          .replaceAll(RegExp(r'```json|```'), '').trim();
      final json = jsonDecode(text) as Map<String, dynamic>;
      final genreNames = (json['genres'] as List?)?.map((g) => g.toString().toLowerCase()).toList() ?? [];
      final genreIds = genreNames.map((n) => _genreMap[n]).whereType<int>().toList();
      final keywords = (json['keywords'] as List?)?.map((k) => k.toString()).toList() ?? [];
      return AiRecommendation(
        genreIds: genreIds.isNotEmpty ? genreIds : _fallbackGenres(query),
        keywords: keywords,
        reasoning: json['reasoning'] as String? ?? 'Here are some great picks for you!',
      );
    } catch (_) { return _fallback(query); }
  }

  AiRecommendation _fallback(String query) {
    final q = query.toLowerCase();
    final ids = <int>{};
    final kws = <String>[];
    _genreMap.forEach((name, id) { if (q.contains(name)) ids.add(id); });

    const patterns = <String, List<dynamic>>{
      'like inception':    [[878, 53], ['mind-bending', 'dreams']],
      'like interstellar': [[878, 18], ['space', 'time travel']],
      'like parasite':     [[53, 18],  ['class', 'dark thriller']],
      'anime':             [[16],      ['japanese', 'animated']],
      'scary':             [[27, 53],  ['horror', 'supernatural']],
      'funny':             [[35],      ['comedy', 'humor']],
      'romantic':          [[10749],   ['love', 'romance']],
      'superhero':         [[28, 878], ['superhero', 'powers']],
      'documentary':       [[99],      ['real', 'documentary']],
      'feel good':         [[35, 10751], ['uplifting', 'heartwarming']],
      'action':            [[28, 12],  ['action', 'adventure']],
      'horror':            [[27],      ['horror', 'scary']],
      'thriller':          [[53, 9648], ['suspense', 'mystery']],
      'drama':             [[18],      ['emotional', 'powerful']],
      'family':            [[10751, 16], ['family', 'kids']],
    };

    patterns.forEach((pattern, data) {
      if (q.contains(pattern)) {
        ids.addAll((data[0] as List).cast<int>());
        kws.addAll((data[1] as List).cast<String>());
      }
    });

    if (ids.isEmpty) ids.addAll([28, 18, 53]);
    return AiRecommendation(
      genreIds: ids.toList(),
      keywords: kws.toSet().toList(),
      reasoning: 'Here are some great picks based on what you described!',
    );
  }

  List<int> _fallbackGenres(String q) => _fallback(q).genreIds;
}
