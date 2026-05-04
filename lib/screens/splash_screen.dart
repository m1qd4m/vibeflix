import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import '../providers/app_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  void _navigate() {
    final user = ref.read(authStateProvider).valueOrNull;
    if (mounted) {
      context.go(user != null ? '/home' : '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [Color(0xFF1A0810), AppTheme.bg],
              ),
            ),
          ),
          // Logo center
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      size: 52, color: Colors.white),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 20),
                // App name
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppTheme.primaryGradient.createShader(bounds),
                  child: const Text(
                    'VIBEFLIX',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                      color: Colors.white,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0),
                const SizedBox(height: 8),
                const Text(
                  'Your AI Movie Companion',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    letterSpacing: 2,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 500.ms),
              ],
            ),
          ),
          // Bottom loader
          Positioned(
            bottom: 60,
            left: 0, right: 0,
            child: Column(
              children: [
                SizedBox(
                  width: 160,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: const LinearProgressIndicator(
                      backgroundColor: Color(0xFF1E2736),
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accent),
                      minHeight: 2,
                    ),
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 800.ms),
          ),
        ],
      ),
    );
  }
}
