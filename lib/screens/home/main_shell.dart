import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _Tab(icon: Icons.home_rounded,          label: 'Home',    path: '/home'),
    _Tab(icon: Icons.mood_rounded,           label: 'Mood',    path: '/mood'),
    _Tab(icon: Icons.auto_awesome_rounded,   label: 'AI',      path: '/chat'),
    _Tab(icon: Icons.bookmark_rounded,       label: 'Library', path: '/watchlist'),
    _Tab(icon: Icons.person_rounded,         label: 'Profile', path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => t.path == loc).clamp(0, 4);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: child,
      extendBody: true,
      bottomNavigationBar: _BottomNav(currentIndex: idx, onTap: (i) => context.go(_tabs[i].path)),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppTheme.glassBorder)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(MainShell._tabs.length, (i) {
              final tab = MainShell._tabs[i];
              final sel = i == currentIndex;
              final isAI = i == 2;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: isAI
                    ? _AITab(selected: sel)
                    : AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.accent.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(tab.icon, size: 22,
                                color: sel ? AppTheme.accent : AppTheme.textSecondary),
                            const SizedBox(height: 3),
                            Text(tab.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                                  color: sel ? AppTheme.accent : AppTheme.textSecondary,
                                )),
                          ],
                        ),
                      ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _AITab extends StatelessWidget {
  final bool selected;
  const _AITab({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: selected ? AppTheme.primaryGradient : null,
        color: selected ? null : AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? Colors.transparent : AppTheme.glassBorder),
        boxShadow: selected ? [BoxShadow(color: AppTheme.accent.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome_rounded, size: 16, color: selected ? Colors.white : AppTheme.textSecondary),
          const SizedBox(width: 5),
          Text('AI', style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppTheme.textSecondary,
          )),
        ],
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final String label, path;
  const _Tab({required this.icon, required this.label, required this.path});
}
