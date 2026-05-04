import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../models/movie.dart';
import '../../widgets/home/hero_banner.dart';
import '../../widgets/home/movie_row.dart';
import '../../widgets/common/shimmer_loader.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured    = ref.watch(featuredMovieProvider);
    final trending    = ref.watch(trendingProvider);
    final popular     = ref.watch(popularProvider);
    final topRated    = ref.watch(topRatedProvider);
    final nowPlaying  = ref.watch(nowPlayingProvider);
    final anime       = ref.watch(animeProvider);
    final personalized = ref.watch(personalizedProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      extendBodyBehindAppBar: true,
      appBar: _HomeAppBar(),
      body: RefreshIndicator(
        color: AppTheme.accent,
        backgroundColor: AppTheme.surface,
        onRefresh: () async {
          ref.invalidate(featuredMovieProvider);
          ref.invalidate(trendingProvider);
          ref.invalidate(popularProvider);
          ref.invalidate(animeProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Hero Banner
            SliverToBoxAdapter(
              child: featured.when(
                data: (m) => m != null ? HeroBanner(movie: m) : const ShimmerBox(height: 580, width: double.infinity, borderRadius: 0),
                loading: () => const ShimmerBox(height: 580, width: double.infinity, borderRadius: 0),
                error: (_, __) => const ShimmerBox(height: 580, width: double.infinity, borderRadius: 0),
              ),
            ),
            // Category tabs
            const SliverToBoxAdapter(child: _CategoryTabs()),
            // For You
            _row('✨ For You', personalized),
            // Trending
            _row('🔥 Trending Now', trending),
            // Now Playing
            _row('🎬 In Cinemas', nowPlaying),
            // Anime
            _row('⛩️ Anime', anime),
            // Popular
            _row('💫 Popular', popular),
            // Top Rated
            _row('⭐ Top Rated', topRated),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _row(String title, AsyncValue<List<Movie>> state) =>
      SliverToBoxAdapter(
        child: state.when(
          data: (m) => m.isEmpty ? const SizedBox() : MovieRow(title: title, movies: m),
          loading: () => MovieRowShimmer(title: title),
          error: (_, __) => const SizedBox(),
        ),
      );
}

class _CategoryTabs extends StatefulWidget {
  const _CategoryTabs();
  @override
  State<_CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<_CategoryTabs> {
  int _selected = 0;
  final _tabs = ['All', 'Movies', 'Series', 'Anime', 'Docs'];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _tabs.length,
        itemBuilder: (context, i) {
          final sel = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: sel ? AppTheme.primaryGradient : null,
                color: sel ? null : AppTheme.glass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? Colors.transparent : AppTheme.glassBorder),
                boxShadow: sel ? [BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : [],
              ),
              child: Text(_tabs[i],
                  style: TextStyle(
                    color: sel ? Colors.white : AppTheme.textSecondary,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  )),
            ),
          );
        },
      ),
    );
  }
}

class _HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider).valueOrNull;
    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xCC080C14), Colors.transparent],
          ),
        ),
      ),
      titleSpacing: 20,
      title: ShaderMask(
        shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
        child: const Text('VIBEFLIX',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, size: 26),
          onPressed: () => context.push('/search'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient, shape: BoxShape.circle),
              child: Center(child: Text(user?.initials ?? 'V',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
          ),
        ),
      ],
    );
  }
}
