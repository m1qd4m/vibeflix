import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../models/movie.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _debounce = ValueNotifier('');

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_ctrl.text == _debounce.value) return;
        _debounce.value = _ctrl.text;
        ref.read(searchProvider.notifier).search(_ctrl.text);
      });
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _debounce.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextField(
            controller: _ctrl,
            autofocus: true,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search movies...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _ctrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _ctrl.clear();
                        ref.read(searchProvider.notifier).search('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
        ),
      ),
      body: results.when(
        data: (movies) {
          if (_ctrl.text.isEmpty) {
            return const _SearchPrompt();
          }
          if (movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎬', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text('No results for "${_ctrl.text}"',
                    style: const TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: movies.length,
            itemBuilder: (context, i) => _SearchCard(movie: movies[i], index: i),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent)),
        error: (_, __) => const Center(
          child: Text('Search failed', style: TextStyle(color: AppTheme.textSecondary))),
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  final Movie movie;
  final int index;
  const _SearchCard({required this.movie, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => Container(color: AppTheme.surface),
                errorWidget: (_, __, ___) =>
                    Container(color: AppTheme.surface,
                      child: const Icon(Icons.movie_outlined,
                          color: AppTheme.textSecondary)),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(movie.title,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 30)).fadeIn().scale(
      begin: const Offset(0.9, 0.9));
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔍', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Type to search movies',
            style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
