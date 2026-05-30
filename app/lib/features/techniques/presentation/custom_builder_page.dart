import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CustomBuilderPage extends ConsumerStatefulWidget {
  const CustomBuilderPage({super.key});
  @override
  ConsumerState<CustomBuilderPage> createState() => _CustomBuilderPageState();
}

class _CustomBuilderPageState extends ConsumerState<CustomBuilderPage> {
  int inhale = 4, hold1 = 4, exhale = 4, hold2 = 4, cycles = 8;

  int get totalMin => (((inhale + hold1 + exhale + hold2) * cycles) / 60).round();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cycleSec = inhale + hold1 + exhale + hold2;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/techniques')),
        title: const Text('Custom pattern'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          children: [
            Center(
              child: SizedBox(
                width: 200, height: 200,
                child: Stack(alignment: Alignment.center, children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.7, end: 1.0),
                    duration: Duration(seconds: cycleSec),
                    curve: Curves.easeInOut,
                    builder: (_, v, __) => Container(
                      width: 170 * v, height: 170 * v,
                      decoration: BoxDecoration(color: cs.primary.withValues(alpha: 0.3), shape: BoxShape.circle),
                    ),
                  ),
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$inhale-$hold1-$exhale-$hold2',
                          style: TextStyle(color: cs.onPrimary, fontFamily: 'monospace', fontSize: 11)),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            Text('~$totalMin min · $cycles cycles',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  _slider('Inhale', inhale, 1, 12, (v) => setState(() => inhale = v)),
                  _slider('Hold',   hold1,  0, 12, (v) => setState(() => hold1 = v)),
                  _slider('Exhale', exhale, 1, 16, (v) => setState(() => exhale = v)),
                  _slider('Hold',   hold2,  0, 12, (v) => setState(() => hold2 = v)),
                  _slider('Cycles', cycles, 1, 30, (v) => setState(() => cycles = v), suffix: ''),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go('/session/custom?i=$inhale&h1=$hold1&e=$exhale&h2=$hold2&c=$cycles'),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start session'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, int value, int min, int max, ValueChanged<int> onChange, {String suffix = 's'}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
              Text('$value$suffix', style: const TextStyle(fontFamily: 'Fraunces', fontSize: 20, fontWeight: FontWeight.w500)),
            ],
          ),
          Slider(
            value: value.toDouble(), min: min.toDouble(), max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) => onChange(v.round()),
          ),
        ],
      ),
    );
  }
}
