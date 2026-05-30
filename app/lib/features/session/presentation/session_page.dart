import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/audio_service.dart';
import '../../profile/data/prefs_provider.dart';
import '../domain/technique.dart';
import 'breathing_orb.dart';
import 'session_controller.dart';

class SessionPage extends ConsumerStatefulWidget {
  const SessionPage({super.key, required this.technique});
  final Technique technique;

  @override
  ConsumerState<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends ConsumerState<SessionPage> {
  static const _steps = ['Ready', '3', '2', '1', 'Breathe'];
  int _stepIdx = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runCountdown());
    // Start preferred soundscape
    final prefs = ref.read(prefsProvider);
    if (prefs.defaultSound.isNotEmpty && prefs.defaultSound != 'none') {
      // ignore: discarded_futures
      ref.read(audioServiceProvider).play(prefs.defaultSound, volume: prefs.volume);
    }
  }

  Future<void> _runCountdown() async {
    for (var i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      setState(() => _stepIdx = i);
      await Future<void>.delayed(const Duration(milliseconds: 900));
    }
    if (!mounted) return;
    ref.read(sessionControllerProvider(widget.technique).notifier).startAfterCountdown();
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    ref.read(audioServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sessionControllerProvider(widget.technique));
    final ctrl  = ref.read(sessionControllerProvider(widget.technique).notifier);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient halo background
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 8),
              builder: (_, v, __) => DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      cs.primary.withValues(alpha: 0.20 + 0.06 * v),
                      cs.surface,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      _RoundIcon(icon: Icons.close, onTap: () => context.go('/home')),
                      const Spacer(),
                      Column(
                        children: [
                          Text(widget.technique.category.name.toUpperCase(),
                              style: TextStyle(fontSize: 11, letterSpacing: 1.6,
                                  color: cs.onSurface.withValues(alpha: 0.6))),
                          const SizedBox(height: 2),
                          Text(widget.technique.name,
                              style: const TextStyle(
                                  fontFamily: 'Fraunces',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.4)),
                        ],
                      ),
                      const Spacer(),
                      _RoundIcon(icon: Icons.tune, onTap: () {}),
                    ],
                  ),
                ),
                Expanded(child: Center(child: _buildBody(state, ctrl))),
                if (state.phase == SessionPhase.running || state.phase == SessionPhase.paused)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32, top: 16),
                    child: _Controls(
                      paused: state.phase == SessionPhase.paused,
                      onToggle: ctrl.togglePause,
                      onEnd: ctrl.end,
                      onSkip: ctrl.skipPhase,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SessionState state, SessionController ctrl) {
    final cs = Theme.of(context).colorScheme;
    switch (state.phase) {
      case SessionPhase.countdown:
        final size = MediaQuery.of(context).size.shortestSide * 0.7;
        return Center(
          child: Text(
            _steps[_stepIdx],
            key: ValueKey(_stepIdx),
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: size * 0.28,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
              letterSpacing: -1.5,
            ),
          ).animate(key: ValueKey(_stepIdx)).fadeIn(duration: 250.ms).scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutCubic),
        );
      case SessionPhase.running:
      case SessionPhase.paused:
        return BreathingOrb(
          tick: state.tick,
          size: MediaQuery.of(context).size.shortestSide * 0.85,
        );
      case SessionPhase.done:
        return _DoneScreen(
          technique: state.technique,
          cyclesCompleted: state.tick?.cycle ?? 0,
        );
    }
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 44, height: 44, child: Icon(icon, size: 20)),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.paused,
    required this.onToggle,
    required this.onEnd,
    required this.onSkip,
  });

  final bool paused;
  final VoidCallback onToggle;
  final VoidCallback onEnd;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 56, height: 56,
          child: Material(
            color: cs.primary,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onToggle,
              child: Icon(paused ? Icons.play_arrow : Icons.pause, color: cs.onPrimary, size: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(onPressed: onEnd, child: const Text('End session')),
        const SizedBox(width: 12),
        SizedBox(
          width: 48, height: 48,
          child: Material(
            color: cs.onSurface.withValues(alpha: 0.05),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onSkip,
              child: const Icon(Icons.skip_next, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}

class _DoneScreen extends StatelessWidget {
  const _DoneScreen({required this.technique, required this.cyclesCompleted});
  final Technique technique;
  final int cyclesCompleted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Well done.',
              style: TextStyle(fontFamily: 'Fraunces', fontSize: 44, fontWeight: FontWeight.w500, letterSpacing: -1)),
          const SizedBox(height: 12),
          Text('$cyclesCompleted ${cyclesCompleted == 1 ? "cycle" : "cycles"} of ${technique.name}. Your streak grew.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
          const SizedBox(height: 32),
          Wrap(
            spacing: 12, runSpacing: 12, alignment: WrapAlignment.center,
            children: [
              FilledButton(
                onPressed: () => context.go('/mood'),
                child: const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('How do you feel?')),
              ),
              TextButton(onPressed: () => context.go('/home'), child: const Text('Home')),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
