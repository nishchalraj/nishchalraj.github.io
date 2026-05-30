import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../insights/data/mood_log.dart';
import '../../insights/data/mood_provider.dart';

class MoodPage extends ConsumerStatefulWidget {
  const MoodPage({super.key});
  @override
  ConsumerState<MoodPage> createState() => _MoodPageState();
}

class _MoodPageState extends ConsumerState<MoodPage> {
  MoodKind? _selected;
  final _note = TextEditingController();

  static const _moods = [
    (MoodKind.calm,      -math.pi / 2),
    (MoodKind.energetic, -math.pi / 10),
    (MoodKind.neutral,    math.pi / 3),
    (MoodKind.anxious,    math.pi * 0.7),
    (MoodKind.sad,        math.pi * 1.1),
  ];

  @override
  void dispose() { _note.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_selected == null) return;
    await ref.read(moodProvider.notifier).log(_selected!, note: _note.text.trim().isEmpty ? null : _note.text.trim());
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/home')),
        title: const Text('How do you feel?'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            Text('A quick check-in. Tap the feeling closest to right now.',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (_, c) {
                final size = math.min(360.0, c.maxWidth);
                return SizedBox(
                  width: size, height: size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Soft rotating halo
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 2 * math.pi),
                        duration: const Duration(seconds: 80),
                        builder: (_, v, __) => Transform.rotate(
                          angle: v,
                          child: DecoratedBox(decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(colors: [
                              cs.primary.withValues(alpha: 0.2), cs.primary.withValues(alpha: 0.0),
                              cs.primary.withValues(alpha: 0.2),
                            ]),
                          ), child: const SizedBox.expand()),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.onSurface.withValues(alpha: 0.1)),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(60),
                        decoration: BoxDecoration(
                          color: cs.surface.withValues(alpha: 0.85),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Column(
                              key: ValueKey(_selected),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selected?.label ?? 'Tap',
                                  style: const TextStyle(fontFamily: 'Fraunces', fontSize: 26, fontWeight: FontWeight.w500, letterSpacing: -0.4),
                                ),
                                Text('your mood', style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
                              ],
                            ),
                          ),
                        ),
                      ),
                      ..._moods.map((m) {
                        final r = size * 0.4;
                        final x = r * math.cos(m.$2);
                        final y = r * math.sin(m.$2);
                        final active = _selected == m.$1;
                        return Transform.translate(
                          offset: Offset(x, y),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 250),
                            scale: active ? 1.1 : 1.0,
                            child: Material(
                              color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.05),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => setState(() => _selected = m.$1),
                                child: SizedBox(
                                  width: 64, height: 64,
                                  child: Center(child: Text(m.$1.emoji, style: const TextStyle(fontSize: 26))),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'A short note? (optional)',
                filled: true,
                fillColor: cs.onSurface.withValues(alpha: 0.04),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selected == null ? null : _save,
                child: const Text('Save check-in'),
              ).animate().fadeIn(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
