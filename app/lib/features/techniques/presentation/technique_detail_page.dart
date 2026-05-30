import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../session/domain/phase.dart';
import '../../session/domain/technique.dart';

class TechniqueDetailPage extends ConsumerWidget {
  const TechniqueDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = TechniqueRegistry.byId(id);
    if (t == null) {
      return const Scaffold(body: Center(child: Text('Unknown technique')));
    }
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/techniques')),
        title: Text(t.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${t.category.name.toUpperCase()} · ${t.pattern}',
                style: TextStyle(fontSize: 11, letterSpacing: 1.4, color: cs.primary)),
            const SizedBox(height: 6),
            Text(t.name,
                style: const TextStyle(fontFamily: 'Fraunces', fontSize: 40, fontWeight: FontWeight.w500, letterSpacing: -0.8)),
            const SizedBox(height: 4),
            Text(t.tagline, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
            const SizedBox(height: 28),
            Center(
              child: SizedBox(
                width: 240, height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.7, end: 1),
                      duration: Duration(seconds: t.phases.fold<int>(0, (s, p) => s + p.seconds)),
                      curve: Curves.easeInOut,
                      builder: (_, v, __) => Container(
                        width: 200 * v, height: 200 * v,
                        decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
                      ),
                    ),
                    Container(
                      width: 110, height: 110,
                      decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.description, style: const TextStyle(height: 1.5)),
                    const SizedBox(height: 20),
                    Row(
                      children: t.phases.map((p) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(p.kind == PhaseKind.holdIn || p.kind == PhaseKind.holdOut
                                    ? 'HOLD' : p.kind.label.toUpperCase(),
                                  style: TextStyle(fontSize: 9, letterSpacing: 1.4, color: cs.onSurface.withValues(alpha: 0.7))),
                                const SizedBox(height: 4),
                                Text('${p.seconds}s', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text('${t.cycles} cycles · ~${(t.totalSeconds / 60).round()} min',
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/session/${t.id}'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Begin session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
