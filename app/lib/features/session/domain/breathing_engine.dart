import 'dart:async';

import 'phase.dart';
import 'technique.dart';

/// Emitted on every engine tick (~60fps).
class BreathingTick {
  const BreathingTick({
    required this.phaseIndex,
    required this.phase,
    required this.phaseProgress,
    required this.cycle,
    required this.cyclesTotal,
    required this.elapsedSec,
    required this.running,
  });
  final int phaseIndex;
  final Phase phase;
  final double phaseProgress; // 0..1
  final int cycle;
  final int cyclesTotal;
  final double elapsedSec;
  final bool running;
}

class SessionSummary {
  const SessionSummary({
    required this.cyclesCompleted,
    required this.durationSec,
    required this.completed,
  });
  final int cyclesCompleted;
  final int durationSec;
  final bool completed;
}

/// Pure-Dart breathing engine. NO Flutter dependencies — fully unit-testable.
class BreathingEngine {
  BreathingEngine(this.technique)
      : _phases = technique.phases.where((p) => p.seconds > 0).toList(growable: false),
        _cyclesTotal = technique.cycles;

  final Technique technique;
  final List<Phase> _phases;
  final int _cyclesTotal;

  final _controller = StreamController<BreathingTick>.broadcast();
  Stream<BreathingTick> get ticks => _controller.stream;

  Timer? _timer;
  Stopwatch? _sw;
  int _phaseIndex = 0;
  int _cycle = 0;
  int _phaseElapsedMs = 0;
  int _phaseStartedAtMs = 0;
  bool _running = false;
  bool _disposed = false;
  int _completedAtSec = 0;

  bool get isRunning => _running;

  void start() {
    if (_disposed || _phases.isEmpty) return;
    _phaseIndex = 0;
    _cycle = 0;
    _phaseElapsedMs = 0;
    _completedAtSec = 0;
    _sw = Stopwatch()..start();
    _phaseStartedAtMs = 0;
    _running = true;
    _ensureTimer();
    _emit(0);
  }

  void pause() {
    if (!_running) return;
    _running = false;
    _phaseElapsedMs += (_sw?.elapsedMilliseconds ?? 0) - _phaseStartedAtMs;
    _sw?.stop();
    _timer?.cancel();
    _emitCurrent();
  }

  void resume() {
    if (_running || _disposed) return;
    _phaseStartedAtMs = _sw?.elapsedMilliseconds ?? 0;
    _sw?.start();
    _running = true;
    _ensureTimer();
  }

  void skipPhase() {
    if (_disposed) return;
    _advancePhase();
    if (_running) _emitCurrent();
  }

  SessionSummary finish() {
    _timer?.cancel();
    _running = false;
    _sw?.stop();
    final completed = _cycle >= _cyclesTotal;
    final dur = _completedAtSec > 0 ? _completedAtSec : (_sw?.elapsed.inSeconds ?? 0);
    return SessionSummary(
      cyclesCompleted: _cycle,
      durationSec: dur,
      completed: completed,
    );
  }

  void dispose() {
    _disposed = true;
    _running = false;
    _timer?.cancel();
    _controller.close();
  }

  void _ensureTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (_) => _onTick());
  }

  void _onTick() {
    if (!_running) return;
    final swMs = _sw?.elapsedMilliseconds ?? 0;
    final phaseMs = (_phases[_phaseIndex].seconds * 1000);
    final inPhaseMs = (swMs - _phaseStartedAtMs) + _phaseElapsedMs;
    if (inPhaseMs >= phaseMs) {
      _advancePhase();
      if (!_running) return;
    }
    _emitCurrent();
  }

  void _advancePhase() {
    _phaseIndex++;
    _phaseElapsedMs = 0;
    _phaseStartedAtMs = _sw?.elapsedMilliseconds ?? 0;
    if (_phaseIndex >= _phases.length) {
      _phaseIndex = 0;
      _cycle++;
      if (_cycle >= _cyclesTotal) {
        _completedAtSec = _sw?.elapsed.inSeconds ?? 0;
        _running = false;
        _timer?.cancel();
        _emit(1.0);
        return;
      }
    }
  }

  void _emitCurrent() {
    final phaseMs = (_phases[_phaseIndex].seconds * 1000);
    final swMs = _sw?.elapsedMilliseconds ?? 0;
    final inPhaseMs = (swMs - _phaseStartedAtMs) + _phaseElapsedMs;
    final p = phaseMs == 0 ? 0.0 : (inPhaseMs / phaseMs).clamp(0.0, 1.0).toDouble();
    _emit(p);
  }

  void _emit(double progress) {
    if (_controller.isClosed) return;
    _controller.add(BreathingTick(
      phaseIndex: _phaseIndex,
      phase: _phases[_phaseIndex],
      phaseProgress: progress,
      cycle: _cycle,
      cyclesTotal: _cyclesTotal,
      elapsedSec: (_sw?.elapsedMilliseconds ?? 0) / 1000,
      running: _running,
    ));
  }
}
