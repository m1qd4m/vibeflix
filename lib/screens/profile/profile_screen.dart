import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/app_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  // ── helpers ────────────────────────────────────────────────────────────────

  Color get _bg      => Theme.of(context).scaffoldBackgroundColor;
  Color get _surface => Theme.of(context).colorScheme.surface;
  Color get _text    => Theme.of(context).colorScheme.onSurface;
  Color get _textSec => Theme.of(context).textTheme.bodySmall!.color!;

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: _bg,
            automaticallyImplyLeading: false,
            pinned: true,
            title: Text(
              'Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _text),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ── Avatar ──────────────────────────────────────────────
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withAlpha(102),
                          blurRadius: 30, spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user?.initials ?? 'V',
                        style: const TextStyle(
                          fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                  ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 14),

                  Text(user?.displayName ?? 'VibeFlix User',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _text))
                      .animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 4),
                  Text(user?.email ?? '',
                      style: TextStyle(color: _textSec, fontSize: 13))
                      .animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: 28),

                  // ── Stats ───────────────────────────────────────────────
                  Row(
                    children: [
                      _Stat(label: 'Watchlist',  value: '${user?.watchlist.length ?? 0}',    icon: Icons.bookmark_rounded,    color: const Color(0xFF6C63FF)),
                      const SizedBox(width: 12),
                      _Stat(label: 'Watched',    value: '${user?.watchHistory.length ?? 0}', icon: Icons.check_circle_rounded, color: const Color(0xFF00D4FF)),
                    ],
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 20),

                  // ── Account ─────────────────────────────────────────────
                  _SectionTitle('Account'),
                  const SizedBox(height: 12),

                  _SettingsTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Edit Profile',
                    onTap: () => _showEditProfileDialog(),
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Change Password',
                    onTap: () => _showChangePasswordDialog(user?.email ?? ''),
                  ),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    label: 'About VibeFlix',
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'VibeFlix',
                      applicationVersion: '1.0.0',
                      applicationLegalese: 'AI-powered movie recommendations',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Sign Out ─────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) context.go('/login');
                      },
                      icon: const Icon(Icons.logout_rounded, color: Color(0xFFFF6B9D), size: 18),
                      label: const Text('Sign Out',
                          style: TextStyle(color: Color(0xFFFF6B9D), fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFF6B9D)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit Profile Dialog ──────────────────────────────────────────────────

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(
      text: ref.read(userProfileProvider).valueOrNull?.displayName ?? '',
    );

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Profile', style: TextStyle(color: _text, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update your display name below.',
                style: TextStyle(color: _textSec, fontSize: 13)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: _text),
              decoration: InputDecoration(
                hintText: 'Display name',
                prefixIcon: Icon(Icons.person_outline_rounded, color: _textSec, size: 18),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text('Cancel', style: TextStyle(color: _textSec)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              minimumSize: const Size(80, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              final name = nameCtrl.text.trim();
              Navigator.of(dialogCtx).pop(); // close dialog FIRST
              if (name.isNotEmpty) {
                try {
                  await ref.read(firebaseServiceProvider).updateDisplayName(name);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Profile updated!'),
                        backgroundColor: const Color(0xFF6C63FF),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Change Password Dialog ────────────────────────────────────────────────

  void _showChangePasswordDialog(String email) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        bool sending = false;
        return StatefulBuilder(
          builder: (_, setDs) => AlertDialog(
            backgroundColor: _surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('Change Password', style: TextStyle(color: _text, fontWeight: FontWeight.w800)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, color: const Color(0xFF6C63FF), size: 48),
                const SizedBox(height: 12),
                Text(
                  'A password reset link will be sent to:',
                  style: TextStyle(color: _textSec, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  email.isNotEmpty ? email : '(no email on file)',
                  style: TextStyle(
                    color: _text, fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(),
                child: Text('Cancel', style: TextStyle(color: _textSec)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  minimumSize: const Size(100, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: sending || email.isEmpty
                    ? null
                    : () async {
                        setDs(() => sending = true);
                        try {
                          await ref
                              .read(authServiceProvider)
                              .sendPasswordReset(email);
                          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Password reset email sent! Check your inbox.'),
                                backgroundColor: const Color(0xFF6C63FF),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        } catch (e) {
                          setDs(() => sending = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        }
                      },
                child: sending
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Send Link',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Section Title ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(
      title,
      style: TextStyle(
        fontSize: 13, fontWeight: FontWeight.w700,
        color: Theme.of(context).textTheme.bodySmall?.color,
        letterSpacing: 1,
      ),
    ),
  );
}

// ── Stat Card ──────────────────────────────────────────────────────────────

class _Stat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _Stat({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(38),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface)),
            Text(label,
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 11)),
          ]),
        ],
      ),
    ),
  );
}

// ── Settings Tile ──────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({required this.icon, required this.label, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
    leading: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Icon(icon, size: 18, color: Theme.of(context).textTheme.bodySmall?.color),
    ),
    title: Text(label,
        style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        )),
    trailing: trailing ??
        Icon(Icons.chevron_right_rounded,
            color: Theme.of(context).textTheme.bodySmall?.color, size: 20),
  );
}

// ── Dropdown Setting ───────────────────────────────────────────────────────

class _DropdownSetting extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownSetting({required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surface   = Theme.of(context).colorScheme.surface;

    return DropdownButton<String>(
      value: items.contains(value) ? value : items.first,
      items: items
          .map((i) => DropdownMenuItem(
                value: i,
                child: Text(i, style: TextStyle(fontSize: 13, color: textColor)),
              ))
          .toList(),
      onChanged: onChanged,
      dropdownColor: surface,
      underline: const SizedBox(),
      style: TextStyle(color: textColor, fontSize: 13),
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor, size: 18),
    );
  }
}
