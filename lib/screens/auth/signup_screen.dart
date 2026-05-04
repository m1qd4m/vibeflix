import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_providers.dart';
import '../../widgets/common/gradient_button.dart';
import '../../widgets/common/vibe_text_field.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _loading    = false;
  bool _obscure    = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signUpWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        name: _nameCtrl.text.trim(),
      );
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() { _error = e.toString().contains('email-already-in-use')
          ? 'This email is already registered.'
          : 'Sign-up failed. Please try again.'; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
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
                    const SizedBox(height: 24),
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    ),
                    const SizedBox(height: 24),
                    Text('Create account',
                        style: Theme.of(context).textTheme.displaySmall)
                        .animate().fadeIn().slideY(begin: 0.3),
                    const SizedBox(height: 6),
                    const Text('Join VibeFlix and discover your next favourite film',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 14))
                        .animate().fadeIn(delay: 100.ms),
                    const SizedBox(height: 36),
                    VibeTextField(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      hint: 'John Doe',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (v) => v!.trim().length >= 2 ? null : 'Enter your name',
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    const SizedBox(height: 14),
                    VibeTextField(
                      controller: _emailCtrl,
                      label: 'Email',
                      hint: 'your@email.com',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      validator: (v) => v!.contains('@') ? null : 'Enter a valid email',
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    const SizedBox(height: 14),
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
                      validator: (v) => v!.length >= 6 ? null : 'Min 6 characters',
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Text(_error!,
                            style: const TextStyle(color: AppTheme.accent, fontSize: 12)),
                      ),
                    ],
                    const SizedBox(height: 28),
                    GradientButton(
                      label: 'Create Account',
                      loading: _loading,
                      onPressed: _signUp,
                    ).animate().fadeIn(delay: 500.ms),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Already have an account? ',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text('Sign in',
                                style: TextStyle(
                                    color: AppTheme.accent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14)),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 600.ms),
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
