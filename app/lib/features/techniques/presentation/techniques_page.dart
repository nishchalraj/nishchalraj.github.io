import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../session/domain/technique.dart';

class TechniquesPage extends ConsumerStatefulWidget {
  const TechniquesPage({super.key});
  @override
  ConsumerState<TechniquesPage> createState() => _TechniquesPageState();
}

class _TechniquesPageState extends ConsumerState<TechniquesPage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Techniques'),
          floating: true,
          backgroundColor: Colors.transparent,
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _Tabs(
                value: _tab,
                onChange: (v) => setState(() => _tab = v),
              ),
              const SizedBox(height: 16),
              if (_tab == 0)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.82,
                  ),
                  itemCount: TechniqueRegistry.all.length,
                  itemBuilder: (_, i) {
                    final t = TechniqueRegistry.all[i];
                    return _TechniqueCard(technique: t)
                      .animate(delay: (i * 50).ms).fadeIn(duration: 400.ms);
                  },
                ),
              if (_tab == 1)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      children: [
                        Icon(Icons.tune, color: cs.primary, size: 36),
                        const SizedBox(height: 12),
                        const Text('Build your own', style: TextStyle(fontFamily: 'Fraunces', fontSize: 22, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Text(
                          'Slide your own inhale, hold, exhale, and second hold. Pick cycles. Run it.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () => context.go('/techniques/custom'),
                          child: const Text('Open builder'),
                        ),
                      ],
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChange});
  final int value;
  final ValueChanged<int> onChange;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tab('Guided', 0, cs),
          _tab('Custom', 1, cs),
        ],
      ),
    );
  }

  Widget _tab(String label, int idx, ColorScheme cs) {
    final selected = idx == value;
    return GestureDetector(
      onTap: () => onChange(idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected ? [BoxShadow(color: cs.shadow.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: selected ? cs.onSurface : cs.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  const _TechniqueCard({required this.technique});
  final Technique technique;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.go('/techniques/${technique.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(technique.category.name.toUpperCase(),
                    style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: cs.primary)),
                const Spacer(),
                Text(technique.pattern, style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: cs.onSurface.withValues(alpha: 0.6))),
              ]),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.7, end: 1.0),
                          duration: const Duration(seconds: 5),
                          curve: Curves.easeInOut,
                          builder: (_, v, __) => Container(
                            width: 70 + v * 14, height: 70 + v * 14,
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.18),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(technique.name, style: const TextStyle(fontFamily: 'Fraunces', fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -0.4)),
              const SizedBox(height: 2),
              Text(technique.tagline, style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }
}
