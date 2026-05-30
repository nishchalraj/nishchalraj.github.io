import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/breathing_tokens.dart';
import '../domain/breathing_engine.dart';
import '../domain/phase.dart';

/// CustomPainter-driven breathing orb. Mirrors the web canvas math
/// (port of /index.html TweenPulse) but rendered with Skia.
class BreathingOrb extends StatelessWidget {
  const BreathingOrb({
    super.key,
    required this.tick,
    this.size = 320,
  });

  final BreathingTick? tick;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = context.bt;
    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(size),
              painter: _OrbPainter(tick: tick, tokens: tokens),
            ),
            if (tick != null) _CountdownRing(tick: tick!, size: size),
            if (tick != null) _PhaseText(tick: tick!),
          ],
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({required this.tick, required this.tokens});
  final BreathingTick? tick;
  final BreathingTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    final n = size.width / 2;
    final l = size.height / 2;
    final t = tick;
    if (t == null) {
      // idle state: collapsed orb
      final p = Paint()..color = tokens.inhale.withValues(alpha: 0.85);
      canvas.drawCircle(Offset(n, l), n * 0.4, p);
      return;
    }

    final phase = t.phase;
    final e = t.phaseProgress;
    final expanding = phase.kind.isExpanding;
    final contracting = phase.kind.isContracting;

    final innerStart = expanding ? 0.8 * n : 0.2 * n;
    final innerEnd   = contracting ? 0.8 * n : 0.2 * n;
    final innerR = innerStart + (innerEnd - innerStart) * e;
    final ringR = contracting ? 0.2 * n : 0.8 * n;

    final color = _colorFor(phase.kind, e);

    // Outer halo
    final haloPaint = Paint()
      ..color = tokens.orbGlow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(Offset(n, l), n * 0.95, haloPaint);

    // Donut: outer filled circle minus inner via dstOut
    final outer = Paint()..color = color;
    canvas.drawCircle(Offset(n, l), n, outer);

    if (innerR > 0) {
      final inner = Paint()..blendMode = BlendMode.dstOut..color = Colors.black;
      canvas.drawCircle(Offset(n, l), innerR, inner);
    }

    if (phase.kind == PhaseKind.inhale || phase.kind == PhaseKind.exhale) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..color = color.withValues(alpha: phase.kind == PhaseKind.exhale ? 0.25 : 0.4)
        ..strokeWidth = 0.01 * size.width;
      canvas.drawCircle(Offset(n, l), ringR, ring);
    } else {
      // Hold: pie sweep that drains as progress increases
      final sweep = e > 0 ? -2 * math.pi * (1 - e) : 0.0;
      final pieR = n * (0.8 + e * 0.2);
      final path = Path()
        ..moveTo(n, l)
        ..arcTo(
          Rect.fromCircle(center: Offset(n, l), radius: pieR),
          -math.pi / 2, sweep, false,
        )
        ..close();
      final hole = Paint()..blendMode = BlendMode.dstOut..color = Colors.black;
      canvas.drawPath(path, hole);
    }
  }

  Color _colorFor(PhaseKind k, double t) {
    final from = _phaseColor(k);
    final to = _nextPhaseColor(k);
    return Color.lerp(from, to, t)!;
  }

  Color _phaseColor(PhaseKind k) {
    switch (k) {
      case PhaseKind.inhale:  return tokens.inhale;
      case PhaseKind.holdIn:  return tokens.holdIn;
      case PhaseKind.exhale:  return tokens.exhale;
      case PhaseKind.holdOut: return tokens.holdOut;
    }
  }

  Color _nextPhaseColor(PhaseKind k) {
    // Soft lerp into the next phase's color for continuity.
    switch (k) {
      case PhaseKind.inhale:  return tokens.holdIn;
      case PhaseKind.holdIn:  return tokens.exhale;
      case PhaseKind.exhale:  return tokens.holdOut;
      case PhaseKind.holdOut: return tokens.inhale;
    }
  }

  @override
  bool shouldRepaint(covariant _OrbPainter old) =>
      old.tick?.phaseProgress != tick?.phaseProgress ||
      old.tick?.phaseIndex != tick?.phaseIndex;
}

class _CountdownRing extends StatelessWidget {
  const _CountdownRing({required this.tick, required this.size});
  final BreathingTick tick;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _RingPainter(progress: tick.phaseProgress, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55)),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width * 0.46;
    final c = Offset(size.width / 2, size.height / 2);
    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withValues(alpha: 0.1);
    canvas.drawCircle(c, r, bg);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = color;
    final sweep = 2 * math.pi * (1 - progress);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.progress != progress;
}

class _PhaseText extends StatelessWidget {
  const _PhaseText({required this.tick});
  final BreathingTick tick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final secondsLeft =
        (tick.phase.seconds * (1 - tick.phaseProgress)).ceil().clamp(0, 999);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey('${tick.phaseIndex}-${tick.cycle}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tick.phase.kind.label,
            style: TextStyle(
              fontSize: 36,
              fontFamily: 'Fraunces',
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${secondsLeft}s',
            style: TextStyle(
              fontFeatures: const [FontFeature.tabularFigures()],
              color: cs.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
