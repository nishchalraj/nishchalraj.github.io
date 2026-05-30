import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_service.dart';
import '../../profile/data/prefs_provider.dart';

class SoundscapesPage extends ConsumerStatefulWidget {
  const SoundscapesPage({super.key});
  @override
  ConsumerState<SoundscapesPage> createState() => _SoundscapesPageState();
}

class _SoundscapesPageState extends ConsumerState<SoundscapesPage> {
  int _timerSec = 0;
  int _remaining = 0;
  Timer? _ticker;

  @override
  void dispose() { _ticker?.cancel(); super.dispose(); }

  void _setTimer(int s) {
    _ticker?.cancel();
    setState(() { _timerSec = s; _remaining = s; });
    if (s > 0) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) { t.cancel(); return; }
        setState(() {
          if (_remaining <= 1) {
            _remaining = 0; t.cancel();
            // ignore: discarded_futures
            ref.read(audioServiceProvider).stop();
          } else {
            _remaining--;
          }
        });
      });
    }
  }

  String _fmt(int s) => '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final audio = ref.watch(audioServiceProvider);
    final prefs = ref.watch(prefsProvider);
    final current = audio.currentId;

    return CustomScrollView(
      slivers: [
        SliverAppBar(title: const Text('Soundscapes'), floating: true, backgroundColor: Colors.transparent),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text('Layer one under your breath, or just sit and listen.',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4,
                ),
                itemCount: kSoundscapes.length,
                itemBuilder: (_, i) {
                  final s = kSoundscapes[i];
                  final active = current == s.id;
                  return InkWell(
                    onTap: () async {
                      if (active) {
                        await audio.stop();
                      } else {
                        await audio.play(s.id, volume: prefs.volume);
                      }
                      if (mounted) setState(() {});
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: active ? [BoxShadow(color: cs.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))] : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(s.label, style: TextStyle(
                                fontFamily: 'Fraunces', fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: -0.4,
                                color: active ? cs.onPrimary : cs.onSurface,
                              )),
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: active
                                    ? cs.onPrimary.withValues(alpha: 0.2)
                                    : cs.primary.withValues(alpha: 0.15),
                                child: Icon(active ? Icons.pause : Icons.play_arrow,
                                    size: 14, color: active ? cs.onPrimary : cs.primary),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(s.description,
                              style: TextStyle(fontSize: 11,
                                  color: (active ? cs.onPrimary : cs.onSurface).withValues(alpha: 0.7))),
                        ],
                      ),
                    ),
                  ).animate(delay: (i * 50).ms).fadeIn();
                },
              ),
              if (current != null) ...[
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TIMER', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: cs.onSurface.withValues(alpha: 0.6))),
                        const SizedBox(height: 8),
                        Wrap(spacing: 8, children: [
                          for (final t in [5*60, 10*60, 20*60, 0])
                            ChoiceChip(
                              label: Text(t == 0 ? '∞' : '${t ~/ 60} min'),
                              selected: _timerSec == t,
                              onSelected: (_) => _setTimer(t),
                            ),
                        ]),
                        if (_timerSec > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(_fmt(_remaining),
                                style: const TextStyle(fontFamily: 'Fraunces', fontSize: 32, fontWeight: FontWeight.w500, fontFeatures: [FontFeature.tabularFigures()])),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VOLUME', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: cs.onSurface.withValues(alpha: 0.6))),
                      Slider(
                        value: prefs.volume,
                        onChanged: (v) {
                          // ignore: discarded_futures
                          ref.read(prefsProvider.notifier).setVolume(v);
                          // ignore: discarded_futures
                          audio.setVolume(v);
                        },
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
