import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../models/movie.dart';
import '../../services/firebase_service.dart';

class WatchlistScreen extends ConsumerStatefulWidget {
  const WatchlistScreen({super.key});

  @override
  ConsumerState<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends ConsumerState<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        automaticallyImplyLeading: false,
        title: const Text('My Library',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.accent,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: AppTheme.border,
          labelColor: AppTheme.textPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(text: 'Watchlist'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _WatchlistTab(),
          _HistoryTab(),
        ],
      ),
    );
  }
}

class _WatchlistTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(watchlistProvider);
    return state.when(
      data: (movies) => movies.isEmpty
          ? const _EmptyState(
              emoji: '🔖',
              title: 'Your watchlist is empty',
              subtitle: 'Bookmark movies to watch them later')
          : _MovieList(movies: movies, showRemove: true),
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent)),
      error: (_, __) => const Center(
          child: Text('Error loading watchlist',
              style: TextStyle(color: AppTheme.textSecondary))),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(watchHistoryProvider);
    return state.when(
      data: (movies) => movies.isEmpty
          ? const _EmptyState(
              emoji: '🎬',
              title: 'No watch history',
              subtitle: 'Movies you\'ve watched will appear here')
          : _MovieList(movies: movies, showRemove: false),
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent)),
      error: (_, __) => const Center(
          child: Text('Error loading history',
              style: TextStyle(color: AppTheme.textSecondary))),
    );
  }
}

class _MovieList extends ConsumerWidget {
  final List<Movie> movies;
  final bool showRemove;

  const _MovieList({required this.movies, required this.showRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: movies.length,
      itemBuilder: (context, i) {
        final movie = movies[i];
        return _MovieListTile(
          movie: movie,
          index: i,
          onRemove: showRemove
              ? () async {
                  await ref
                      .read(firebaseServiceProvider)
                      .removeFromWatchlist(movie.id);
                }
              : null,
        );
      },
    );
  }
}

class _MovieListTile extends StatelessWidget {
  final Movie movie;
  final int index;
  final VoidCallback? onRemove;

  const _MovieListTile({
    required this.movie,
    required this.index,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: movie.posterUrl,
                width: 56, height: 80,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(width: 56, height: 80, color: AppTheme.surface2),
                errorWidget: (_, __, ___) =>
                    Container(width: 56, height: 80, color: AppTheme.surface2,
                        child: const Icon(Icons.movie_outlined,
                            color: AppTheme.textSecondary, size: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(movie.title,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (movie.year.isNotEmpty) ...[
                        Text(movie.year,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                        const SizedBox(width: 8),
                      ],
                      const Icon(Icons.star_rounded,
                          color: AppTheme.gold, size: 12),
                      const SizedBox(width: 3),
                      Text(movie.ratingFormatted,
                        style: const TextStyle(
                            color: AppTheme.gold, fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded,
                    color: AppTheme.textSecondary, size: 20),
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 40)).fadeIn().slideX(begin: 0.1);
  }
}

class _EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            Text(title,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
