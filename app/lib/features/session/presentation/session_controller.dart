import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/session_repository.dart';
import '../domain/breathing_engine.dart';
import '../domain/technique.dart';
import '../../insights/data/streak_provider.dart';

enum SessionPhase { countdown, running, paused, done }

class SessionState {
  const SessionState({
    required this.technique,
    required this.phase,
    required this.tick,
    required this.completedAt,
  });

  final Technique technique;
  final SessionPhase phase;
  final BreathingTick? tick;
  final DateTime? completedAt;

  SessionState copyWith({
    SessionPhase? phase,
    BreathingTick? tick,
    DateTime? completedAt,
  }) =>
      SessionState(
        technique: technique,
        phase: phase ?? this.phase,
        tick: tick ?? this.tick,
        completedAt: completedAt ?? this.completedAt,
      );
}

class SessionController extends AutoDisposeFamilyNotifier<SessionState, Technique> {
  late BreathingEngine _engine;
  StreamSubscription<BreathingTick>? _sub;
  int _startedAtMs = 0;
  int _lastPhaseIndex = -1;
  int _lastCycle = -1;

  @override
  SessionState build(Technique arg) {
    _engine = BreathingEngine(arg);
    _sub = _engine.ticks.listen(_onTick);
    ref.onDispose(() {
      _sub?.cancel();
      _engine.dispose();
    });
    return SessionState(
      technique: arg,
      phase: SessionPhase.countdown,
      tick: null,
      completedAt: null,
    );
  }

  void startAfterCountdown() {
    _startedAtMs = DateTime.now().millisecondsSinceEpoch;
    _engine.start();
    state = state.copyWith(phase: SessionPhase.running);
  }

  void togglePause() {
    if (state.phase == SessionPhase.running) {
      _engine.pause();
      state = state.copyWith(phase: SessionPhase.paused);
    } else if (state.phase == SessionPhase.paused) {
      _engine.resume();
      state = state.copyWith(phase: SessionPhase.running);
    }
  }

  void skipPhase() => _engine.skipPhase();

  Future<void> end() async {
    final summary = _engine.finish();
    await _persist(summary);
    state = state.copyWith(phase: SessionPhase.done, completedAt: DateTime.now());
  }

  Future<void> _persist(SessionSummary summary) async {
    final repo = ref.read(sessionRepositoryProvider);
    await repo.log(
      techniqueId: state.technique.id,
      startedAtMs: _startedAtMs,
      durationSec: summary.durationSec,
      cyclesCompleted: summary.cyclesCompleted,
      completed: summary.completed,
    );
    await ref.read(streakProvider.notifier).recordSessionToday();
  }

  void _onTick(BreathingTick t) {
    // Haptic on phase transition (debounced via _lastPhaseIndex check)
    if (t.phaseIndex != _lastPhaseIndex || t.cycle != _lastCycle) {
      _lastPhaseIndex = t.phaseIndex;
      _lastCycle = t.cycle;
      // ignore: discarded_futures
      HapticFeedback.lightImpact();
    }
    if (!t.running && t.cycle >= t.cyclesTotal) {
      // engine completed naturally
      // ignore: discarded_futures
      end();
      return;
    }
    state = state.copyWith(tick: t);
  }
}

final sessionControllerProvider =
    NotifierProvider.autoDispose.family<SessionController, SessionState, Technique>(
  SessionController.new,
);
