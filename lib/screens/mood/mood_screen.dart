import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_constants.dart';
import '../../providers/app_providers.dart';
import '../../widgets/home/movie_row.dart';
import '../../widgets/common/shimmer_loader.dart';

class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.bg,
            pinned: true,
            automaticallyImplyLeading: false,
            expandedHeight: 0,
            title: const Text('What\'s your vibe?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pick a mood to get personalised picks',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 20),
                  // Mood grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.82,
                    ),
                    itemCount: AppConstants.moods.length,
                    itemBuilder: (context, i) {
                      final mood = AppConstants.moods[i];
                      final sel  = state.selectedMood == mood;
                      return GestureDetector(
                        onTap: () => ref.read(moodProvider.notifier).selectMood(mood),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: sel ? AppTheme.primaryGradient : null,
                            color: sel ? null : AppTheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: sel ? Colors.transparent : AppTheme.glassBorder,
                            ),
                            boxShadow: sel ? [BoxShadow(
                              color: AppTheme.accent.withOpacity(0.4),
                              blurRadius: 16, spreadRadius: 1,
                            )] : [],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppConstants.moodEmojis[mood] ?? '🎬',
                                  style: const TextStyle(fontSize: 26)),
                              const SizedBox(height: 6),
                              Text(mood,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: sel ? Colors.white : AppTheme.textSecondary,
                                  )),
                            ],
                          ),
                        ),
                      ).animate(delay: Duration(milliseconds: i * 40)).fadeIn().scale(begin: const Offset(0.8, 0.8));
                    },
                  ),
                  const SizedBox(height: 24),
                  // Runtime filter
                  if (state.selectedMood != null) ...[
                    const Text('How long do you have?',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 10),
                    Row(
                      children: AppConstants.runtimeFilters.keys.map((rt) {
                        final sel = state.selectedRuntime == rt;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => ref.read(moodProvider.notifier).selectRuntime(rt),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: sel ? AppTheme.primaryGradient : null,
                                  color: sel ? null : AppTheme.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: sel ? Colors.transparent : AppTheme.glassBorder,
                                  ),
                                ),
                                child: Text(rt,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10, fontWeight: FontWeight.w600,
                                      color: sel ? Colors.white : AppTheme.textSecondary,
                                    )),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Show mood description
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.glass,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.glassBorder),
                      ),
                      child: Row(
                        children: [
                          Text(AppConstants.moodEmojis[state.selectedMood] ?? '🎬',
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(state.selectedMood!,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                Text(AppConstants.moodDescriptions[state.selectedMood] ?? '',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),
                  ],
                ],
              ),
            ),
          ),
          // Results
          SliverToBoxAdapter(child: _MoodResults(state: state)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _MoodResults extends StatelessWidget {
  final MoodState state;
  const _MoodResults({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.selectedMood == null) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Text('🎭', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 16),
            const Text('Select a mood above',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('We\'ll find the perfect movie for how you feel',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
          ],
        ),
      );
    }
    if (state.isLoading) return MovieRowShimmer(title: 'Finding perfect picks...');
    if (state.error != null) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text('Could not load movies. Please try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    if (state.movies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Text('No movies found. Try a different mood!',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    final emoji = AppConstants.moodEmojis[state.selectedMood] ?? '🎬';
    return MovieRow(title: '$emoji ${state.selectedMood} picks', movies: state.movies);
  }
}
