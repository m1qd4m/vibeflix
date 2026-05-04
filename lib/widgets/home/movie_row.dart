import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../models/movie.dart';
import '../../utils/app_theme.dart';
import '../common/shimmer_loader.dart';

class MovieRow extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final bool large;
  const MovieRow({super.key, required this.title, required this.movies, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.glass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: const Text('See all',
                    style: TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: large ? 220 : 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: movies.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: MovieCard(movie: movies[i], index: i, large: large),
            ),
          ),
        ),
      ],
    );
  }
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  final int index;
  final bool large;
  const MovieCard({super.key, required this.movie, this.index = 0, this.large = false});

  @override
  Widget build(BuildContext context) {
    final w = large ? 150.0 : 130.0;
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}'),
      child: SizedBox(
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie.posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppTheme.surface),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.surface,
                        child: const Icon(Icons.movie_outlined, color: AppTheme.textSecondary),
                      ),
                    ),
                    // Gradient bottom
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, AppTheme.bg.withOpacity(0.9)],
                          ),
                        ),
                      ),
                    ),
                    // Rating badge
                    Positioned(
                      top: 8, right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: AppTheme.gold, size: 10),
                            const SizedBox(width: 2),
                            Text(movie.ratingFormatted,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(movie.year, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
          ],
        ),
      )
          .animate(delay: Duration(milliseconds: index * 50))
          .fadeIn(duration: 400.ms)
          .slideX(begin: 0.1, end: 0),
    );
  }
}

class MovieRowShimmer extends StatelessWidget {
  final String title;
  const MovieRowShimmer({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
          child: ShimmerBox(height: 20, width: 160),
        ),
        SizedBox(
          height: 195,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: ShimmerBox(height: 195, width: 130, borderRadius: 16),
            ),
          ),
        ),
      ],
    );
  }
}
