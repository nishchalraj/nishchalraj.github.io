import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/insights/presentation/insights_page.dart';
import '../../features/learn/presentation/learn_page.dart';
import '../../features/learn/presentation/article_page.dart';
import '../../features/mood/presentation/mood_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/plans/presentation/plans_page.dart';
import '../../features/plans/presentation/plan_detail_page.dart';
import '../../features/profile/data/prefs_provider.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/session/domain/technique.dart';
import '../../features/session/presentation/session_page.dart';
import '../../features/soundscapes/presentation/soundscapes_page.dart';
import '../../features/techniques/presentation/custom_builder_page.dart';
import '../../features/techniques/presentation/technique_detail_page.dart';
import '../../features/techniques/presentation/techniques_page.dart';
import 'shell_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, gs) {
      final prefs = ref.read(prefsProvider);
      final atOnboarding = gs.matchedLocation == '/onboarding';
      if (!prefs.onboarded && !atOnboarding) return '/onboarding';
      if (prefs.onboarded && atOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (_, __) => const NoTransitionPage(child: OnboardingPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(path: '/home',       pageBuilder: (_, __) => _fadePage(const HomePage())),
          GoRoute(path: '/techniques', pageBuilder: (_, __) => _fadePage(const TechniquesPage()),
            routes: [
              GoRoute(
                path: 'custom',
                pageBuilder: (_, __) => _fadePage(const CustomBuilderPage()),
              ),
              GoRoute(
                path: ':id',
                pageBuilder: (_, s) => _fadePage(TechniqueDetailPage(id: s.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(path: '/plans', pageBuilder: (_, __) => _fadePage(const PlansPage()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, s) => _fadePage(PlanDetailPage(planId: s.pathParameters['id']!)),
              ),
            ],
          ),
          GoRoute(path: '/sounds',   pageBuilder: (_, __) => _fadePage(const SoundscapesPage())),
          GoRoute(path: '/insights', pageBuilder: (_, __) => _fadePage(const InsightsPage())),
          GoRoute(path: '/learn',    pageBuilder: (_, __) => _fadePage(const LearnPage()),
            routes: [
              GoRoute(
                path: ':slug',
                pageBuilder: (_, s) => _fadePage(ArticlePage(slug: s.pathParameters['slug']!)),
              ),
            ],
          ),
          GoRoute(path: '/profile',  pageBuilder: (_, __) => _fadePage(const ProfilePage())),
          GoRoute(path: '/mood',     pageBuilder: (_, __) => _fadePage(const MoodPage())),
        ],
      ),
      GoRoute(
        path: '/session/:id',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final Technique? t = id == 'custom'
              ? _customFromQuery(state.uri.queryParameters)
              : TechniqueRegistry.byId(id);
          if (t == null) return const NoTransitionPage(child: _NotFound());
          return CustomTransitionPage(
            transitionDuration: const Duration(milliseconds: 420),
            child: SessionPage(technique: t),
            transitionsBuilder: (ctx, anim, _, child) {
              final fade = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
              final scale = Tween<double>(begin: 0.94, end: 1.0).animate(fade);
              return FadeTransition(
                opacity: fade,
                child: ScaleTransition(scale: scale, child: child),
              );
            },
          );
        },
      ),
    ],
  );
});

CustomTransitionPage<void> _fadePage(Widget child) => CustomTransitionPage(
  transitionDuration: const Duration(milliseconds: 320),
  child: child,
  transitionsBuilder: (ctx, anim, _, c) {
    final t = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
    final offset = Tween<Offset>(begin: const Offset(0, 0.025), end: Offset.zero).animate(t);
    return FadeTransition(opacity: t, child: SlideTransition(position: offset, child: c));
  },
);

Technique? _customFromQuery(Map<String, String> q) {
  int parse(String k, int def) => int.tryParse(q[k] ?? '') ?? def;
  return TechniqueRegistry.custom(
    inhale:  parse('i', 4),
    holdIn:  parse('h1', 4),
    exhale:  parse('e', 4),
    holdOut: parse('h2', 4),
    cycles:  parse('c', 8),
  );
}

class _NotFound extends StatelessWidget {
  const _NotFound();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: Text('Between breaths.')),
  );
}
