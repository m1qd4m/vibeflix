import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../models/movie.dart';
import '../../services/firebase_service.dart';
import '../../widgets/home/movie_row.dart';
import '../../widgets/common/shimmer_loader.dart';

class MovieDetailScreen extends ConsumerStatefulWidget {
  final int movieId;
  const MovieDetailScreen({super.key, required this.movieId});

  @override
  ConsumerState<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends ConsumerState<MovieDetailScreen> {
  bool _inWatchlist     = false;
  bool _watchlistLoading = false;

  @override
  void initState() {
    super.initState();
    _checkWatchlist();
  }

  Future<void> _checkWatchlist() async {
    final result = await ref
        .read(firebaseServiceProvider)
        .isInWatchlist(widget.movieId);
    if (mounted) setState(() => _inWatchlist = result);
  }

  Future<void> _openTrailer(List<Video> videos) async {
    final trailer = videos.firstWhere(
      (v) => v.isYouTubeTrailer,
      orElse: () => videos.firstWhere(
        (v) => v.site == 'YouTube',
        orElse: () => const Video(id: '', key: '', name: '', site: '', type: ''),
      ),
    );
    if (trailer.key.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No trailer available')));
      }
      return;
    }
    final url = Uri.parse('https://www.youtube.com/watch?v=${trailer.key}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _toggleWatchlist(Movie movie) async {
    setState(() => _watchlistLoading = true);
    final fb = ref.read(firebaseServiceProvider);
    if (_inWatchlist) {
      await fb.removeFromWatchlist(movie.id);
    } else {
      await fb.addToWatchlist(movie);
    }
    setState(() { _inWatchlist = !_inWatchlist; _watchlistLoading = false; });
  }

  Future<void> _markWatched(Movie movie) async {
    await ref.read(firebaseServiceProvider).addToWatchHistory(movie);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to watch history'),
          backgroundColor: AppTheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movieAsync   = ref.watch(movieDetailProvider(widget.movieId));
    final videosAsync  = ref.watch(movieVideosProvider(widget.movieId));
    final similarAsync = ref.watch(similarMoviesProvider(widget.movieId));

    return Scaffold(
      backgroundColor: AppTheme.bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
        ),
        actions: [
          movieAsync.when(
            data: (movie) => IconButton(
              icon: _watchlistLoading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.accent))
                  : Icon(
                      _inWatchlist
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: _inWatchlist ? AppTheme.accent : Colors.white,
                    ),
              onPressed: () => _toggleWatchlist(movie),
            ),
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: movieAsync.when(
        data: (movie) => _buildContent(movie, videosAsync, similarAsync),
        loading: () => const _DetailShimmer(),
        error: (e, _) => Center(
          child: Text('Failed to load movie',
              style: Theme.of(context).textTheme.bodyLarge),
        ),
      ),
    );
  }

  Widget _buildContent(
    Movie movie,
    AsyncValue<List<Video>> videosAsync,
    AsyncValue<List<Movie>> similarAsync,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Backdrop
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie.backdropUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          Container(color: AppTheme.surface),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, AppTheme.bg],
                          ),
                        ),
                      ),
                    ),
                    // Play trailer button — opens YouTube
                    Center(
                      child: videosAsync.when(
                        data: (videos) => videos.any((v) => v.site == 'YouTube')
                            ? _PlayButton(onTap: () => _openTrailer(videos))
                            : const SizedBox(),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.w900,
                          height: 1.15)),
                    if (movie.tagline != null && movie.tagline!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('"${movie.tagline}"',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                            fontSize: 13)),
                    ],
                    const SizedBox(height: 14),
                    _MetaRow(movie: movie),
                    const SizedBox(height: 16),
                    if (movie.genres.isNotEmpty)
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: movie.genres
                            .map((g) => _GenreChip(label: g.name))
                            .toList(),
                      ),
                    const SizedBox(height: 20),
                    if (movie.overview != null &&
                        movie.overview!.isNotEmpty) ...[
                      const Text('Overview',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(movie.overview!,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14, height: 1.6)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity, height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _markWatched(movie),
                        icon: const Icon(
                            Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Mark as Watched'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: similarAsync.when(
            data: (movies) => movies.isEmpty
                ? const SizedBox()
                : MovieRow(title: 'You Might Also Like', movies: movies),
            loading: () => MovieRowShimmer(title: 'You Might Also Like'),
            error: (_, __) => const SizedBox(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _PlayButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PlayButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64, height: 64,
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: AppTheme.accent.withOpacity(0.5),
            blurRadius: 20, spreadRadius: 2,
          )],
        ),
        child: const Icon(Icons.play_arrow_rounded,
            size: 36, color: Colors.white),
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.elasticOut);
  }
}

class _MetaRow extends StatelessWidget {
  final Movie movie;
  const _MetaRow({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16, runSpacing: 8,
      children: [
        if (movie.voteAverage > 0)
          _MetaChip(icon: Icons.star_rounded,
              iconColor: AppTheme.gold,
              label: '${movie.ratingFormatted}/10'),
        if (movie.year.isNotEmpty)
          _MetaChip(icon: Icons.calendar_today_outlined, label: movie.year),
        if (movie.runtimeFormatted.isNotEmpty)
          _MetaChip(icon: Icons.schedule_rounded, label: movie.runtimeFormatted),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  const _MetaChip({required this.icon, required this.label, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  final String label;
  const _GenreChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
      ),
      child: Text(label,
        style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShimmerBox(height: 220, width: double.infinity),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 28, width: 240),
              const SizedBox(height: 12),
              ShimmerBox(height: 14, width: 180),
              const SizedBox(height: 20),
              ShimmerBox(height: 14, width: double.infinity),
              const SizedBox(height: 8),
              ShimmerBox(height: 14, width: double.infinity),
            ],
          ),
        ),
      ],
    );
  }
}
