import 'package:flutter_test/flutter_test.dart';

import 'package:niyam/features/session/domain/breathing_engine.dart';
import 'package:niyam/features/session/domain/phase.dart';
import 'package:niyam/features/session/domain/technique.dart';

/// Smoke test: the breathing engine emits ticks and completes after
/// the configured number of cycles.
void main() {
  test('BreathingEngine emits and completes', () async {
    final t = TechniqueRegistry.byId('coherent-55')!;
    // Override to a tiny 2-cycle, 1-second-per-phase engine for speed
    final tiny = Technique(
      id: 'tiny',
      name: 'tiny',
      tagline: '',
      description: '',
      phases: t.phases.map((p) => Phase(kind: p.kind, seconds: 1)).toList(),
      cycles: 1,
      category: TechniqueCategory.calm,
      pattern: 'tiny',
    );
    final engine = BreathingEngine(tiny);
    var ticks = 0;
    final sub = engine.ticks.listen((_) => ticks++);
    engine.start();
    await Future<void>.delayed(const Duration(seconds: 5));
    final summary = engine.finish();
    await sub.cancel();
    engine.dispose();
    expect(ticks, greaterThan(10), reason: 'engine should emit many ticks per second');
    expect(summary.cyclesCompleted, greaterThanOrEqualTo(1),
        reason: '4×1s phases × 1 cycle should complete within 5s');
  });
}
