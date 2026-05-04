import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../models/movie.dart';
import '../../utils/app_theme.dart';

class HeroBanner extends StatelessWidget {
  final Movie movie;
  const HeroBanner({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}'),
      child: SizedBox(
        height: 580,
        child: Stack(
          children: [
            // Full HD backdrop
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: movie.backdropUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppTheme.surface),
                errorWidget: (_, __, ___) => Container(color: AppTheme.surface),
              ),
            ),
            // Multi-layer gradient for cinematic feel
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.0, 0.2, 0.6, 1.0],
                    colors: [
                      AppTheme.bg.withOpacity(0.3),
                      Colors.transparent,
                      AppTheme.bg.withOpacity(0.7),
                      AppTheme.bg,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Colors.transparent, AppTheme.bg.withOpacity(0.5)],
                  ),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 28, left: 20, right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text('TRENDING NOW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.w900,
                      height: 1.1, color: AppTheme.textPrimary,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 20)],
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                  const SizedBox(height: 10),
                  // Meta
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppTheme.gold, size: 16),
                      const SizedBox(width: 4),
                      Text(movie.ratingFormatted,
                          style: const TextStyle(color: AppTheme.gold, fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(width: 16),
                      if (movie.year.isNotEmpty) ...[
                        Text(movie.year, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                        const SizedBox(width: 16),
                      ],
                      if (movie.runtimeFormatted.isNotEmpty)
                        Text(movie.runtimeFormatted, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 10),
                  // Overview
                  Text(
                    movie.overview ?? '',
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                  ).animate().fadeIn(delay: 250.ms),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _HeroBtn(
                          icon: Icons.play_arrow_rounded,
                          label: 'Watch Now',
                          gradient: AppTheme.primaryGradient,
                          onTap: () => context.push('/movie/${movie.id}'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _HeroOutlineBtn(
                        icon: Icons.add_rounded,
                        label: 'Watchlist',
                        onTap: () => context.push('/movie/${movie.id}'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;
  const _HeroBtn({required this.icon, required this.label, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _HeroOutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HeroOutlineBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
        decoration: BoxDecoration(
          color: AppTheme.glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.glassBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
