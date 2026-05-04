import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/vibe_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _loading    = false;
  bool _obscure    = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() { _error = _friendlyError(e.toString()); });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleLogin() async {
    setState(() { _loading = true; _error = null; });
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (user != null && mounted) context.go('/home');
    } catch (e) {
      setState(() { _error = 'Google sign-in failed. Please try again.'; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(String raw) {
    if (raw.contains('user-not-found'))    return 'No account found with this email.';
    if (raw.contains('wrong-password'))    return 'Incorrect password. Try again.';
    if (raw.contains('invalid-email'))     return 'Please enter a valid email.';
    if (raw.contains('too-many-requests')) return 'Too many attempts. Try later.';
    return 'Sign-in failed. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://image.tmdb.org/t/p/original/628Dep6AxEtDxjZoGP78TsOxYbK.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xCC060810), Color(0xF5060810), Color(0xFF060810)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    ShaderMask(
                      shaderCallback: (b) => AppTheme.primaryGradient.createShader(b),
                      child: const Text('VIBEFLIX',
                        style: TextStyle(
                          fontSize: 36, fontWeight: FontWeight.w900,
                          letterSpacing: 6, color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.2),
                    const SizedBox(height: 8),
                    const Text(
                      'Your AI Movie Companion',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ).animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 60),
                    Text('Welcome back',
                      style: Theme.of(context).textTheme.displaySmall,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to continue your cinematic journey',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 40),
                    VibeTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      validator: (v) => (v != null && v.contains('@')) ? null : 'Enter a valid email',
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                    const SizedBox(height: 16),
                    VibeTextField(
                      controller: _passCtrl,
                      label: 'Password',
                      hint: '••••••••',
                      obscureText: _obscure,
                      prefixIcon: Icons.lock_outline_rounded,
                      suffixIcon: _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      onSuffixTap: () => setState(() => _obscure = !_obscure),
                      validator: (v) => (v != null && v.length >= 6) ? null : 'Min 6 characters',
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppTheme.accent, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(_error!,
                                style: const TextStyle(color: AppTheme.accent, fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    GradientButton(
                      label: 'Sign In',
                      loading: _loading,
                      onPressed: _login,
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppTheme.border.withOpacity(0.5))),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: AppTheme.border.withOpacity(0.5))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity, height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _googleLogin,
                        icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.white),
                        label: const Text('Continue with Google',
                          style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          backgroundColor: AppTheme.surface,
                        ),
                      ),
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 32),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Don't have an account? ",
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          GestureDetector(
                            onTap: () => context.go('/signup'),
                            child: const Text('Sign up',
                              style: TextStyle(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
