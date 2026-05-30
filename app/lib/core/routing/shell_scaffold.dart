import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Persistent bottom-nav shell. Pages are passed in via go_router's ShellRoute.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});
  final Widget child;

  static const _tabs = <_Tab>[
    _Tab(label: 'Home',       icon: Icons.home_outlined,        active: Icons.home,                 path: '/home'),
    _Tab(label: 'Techniques', icon: Icons.auto_awesome_outlined, active: Icons.auto_awesome,         path: '/techniques'),
    _Tab(label: 'Sounds',     icon: Icons.graphic_eq,            active: Icons.graphic_eq,           path: '/sounds'),
    _Tab(label: 'Insights',   icon: Icons.show_chart,            active: Icons.show_chart,           path: '/insights'),
    _Tab(label: 'Profile',    icon: Icons.person_outline,        active: Icons.person,               path: '/profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    // Hide bottom nav for full-screen pages.
    final hideNav = loc.startsWith('/session') ||
                    loc.startsWith('/mood') ||
                    loc.startsWith('/learn/') ||
                    (loc.startsWith('/plans/') && loc != '/plans') ||
                    (loc.startsWith('/techniques/') && loc != '/techniques');
    return Scaffold(
      body: child,
      bottomNavigationBar: hideNav
          ? null
          : SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: _BottomNav(currentLoc: loc, tabs: _tabs),
            ),
    );
  }
}

class _Tab {
  const _Tab({required this.label, required this.icon, required this.active, required this.path});
  final String label;
  final IconData icon;
  final IconData active;
  final String path;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentLoc, required this.tabs});
  final String currentLoc;
  final List<_Tab> tabs;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
        boxShadow: [BoxShadow(
          color: cs.shadow.withValues(alpha: 0.12),
          blurRadius: 24, offset: const Offset(0, 8),
        )],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        children: tabs.map((t) {
          final isActive = currentLoc.startsWith(t.path);
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.go(t.path),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? cs.primary.withValues(alpha: 0.16) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? t.active : t.icon,
                      size: 22,
                      color: isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.label,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isActive ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
