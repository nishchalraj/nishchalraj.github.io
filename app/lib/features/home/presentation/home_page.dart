import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/date_x.dart';
import '../../insights/data/mood_log.dart';
import '../../insights/data/mood_provider.dart';
import '../../insights/data/streak_provider.dart';
import '../../profile/data/prefs_provider.dart';
import '../../session/data/session_repository.dart';
import '../../session/domain/technique.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    final streak = ref.watch(streakProvider);
    final mood = ref.watch(moodProvider.notifier).todayMood();
    final lastTechId = ref.read(sessionRepositoryProvider).lastTechniqueId();
    final featured = lastTechId != null
        ? (TechniqueRegistry.byId(lastTechId) ?? TechniqueRegistry.all.first)
        : TechniqueRegistry.all.first;
    final recommended = TechniqueRegistry.all.take(4).toList();
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Colors.transparent,
          floating: true,
          elevation: 0,
          title: const Text('niyam'),
          titleTextStyle: TextStyle(
            fontFamily: 'Fraunces', fontSize: 22, fontWeight: FontWeight.w500,
            color: cs.onSurface, letterSpacing: -0.4,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Text('${greetingFor()}${prefs.name.isNotEmpty ? ", ${prefs.name}" : ""} 🌿',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 6),
              const Text('Find your calm.',
                  style: TextStyle(fontFamily: 'Fraunces', fontSize: 36, fontWeight: FontWeight.w500, letterSpacing: -0.8)),
              const SizedBox(height: 20),

              _CalendarStrip(completedDays: streak.completedDays),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(child: _StreakCard(current: streak.current)),
                const SizedBox(width: 12),
                Expanded(
                  child: _TapCard(
                    onTap: () => context.go('/mood'),
                    title: mood == null ? 'How do you feel?' : "Today's mood",
                    value: mood?.mood.label ?? 'Check in →',
                  ),
                ),
              ]),
              const SizedBox(height: 16),

              _FeaturedCard(technique: featured),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Text('Recommended', style: TextStyle(fontFamily: 'Fraunces', fontSize: 20, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  TextButton(onPressed: () => context.go('/techniques'), child: const Text('All →')),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.15,
                ),
                itemCount: recommended.length,
                itemBuilder: (_, i) {
                  final t = recommended[i];
                  return _TechniqueMini(technique: t)
                    .animate(delay: (i * 80).ms).fadeIn(duration: 400.ms);
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _CalendarStrip extends StatelessWidget {
  const _CalendarStrip({required this.completedDays});
  final List<String> completedDays;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final cells = List<DateTime>.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    return Row(
      children: cells.map((d) {
        final key = dayKeyOf(d);
        final isToday = key == dayKeyOf(today);
        final completed = completedDays.contains(key);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isToday ? cs.primary : cs.onSurface.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: isToday ? null : Border.all(color: cs.onSurface.withValues(alpha: 0.06)),
              ),
              child: Column(
                children: [
                  Text(
                    ['M','T','W','T','F','S','S'][d.weekday - 1],
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: isToday ? cs.onPrimary.withValues(alpha: 0.85) : cs.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500,
                      color: isToday ? cs.onPrimary : cs.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4, width: completed ? 4 : 0,
                    decoration: BoxDecoration(
                      color: isToday ? cs.onPrimary : cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.current});
  final int current;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.local_fire_department, size: 14, color: cs.primary),
              const SizedBox(width: 6),
              Text('STREAK', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: cs.primary)),
            ]),
            const SizedBox(height: 6),
            Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Text('$current',
                  style: const TextStyle(fontFamily: 'Fraunces', fontSize: 36, fontWeight: FontWeight.w500)),
              const SizedBox(width: 4),
              Text('days', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _TapCard extends StatelessWidget {
  const _TapCard({required this.onTap, required this.title, required this.value});
  final VoidCallback onTap;
  final String title;
  final String value;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 11, letterSpacing: 1.2, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontFamily: 'Fraunces', fontSize: 22, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.technique});
  final Technique technique;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.go('/session/${technique.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [cs.primary, cs.primaryContainer],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FOR YOU TODAY', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: cs.onPrimary.withValues(alpha: 0.85))),
            const SizedBox(height: 8),
            Text(technique.name,
                style: TextStyle(fontFamily: 'Fraunces', fontSize: 28, fontWeight: FontWeight.w500, color: cs.onPrimary, letterSpacing: -0.6)),
            const SizedBox(height: 4),
            Text('${technique.tagline} · ${technique.cycles} cycles',
                style: TextStyle(color: cs.onPrimary.withValues(alpha: 0.9))),
            const SizedBox(height: 16),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.onPrimary, borderRadius: BorderRadius.circular(99),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Start', style: TextStyle(color: cs.primary, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16, color: cs.primary),
                ]),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _TechniqueMini extends StatelessWidget {
  const _TechniqueMini({required this.technique});
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
                Icon(Icons.auto_awesome, size: 14, color: cs.primary.withValues(alpha: 0.7)),
                const Spacer(),
                Text(technique.pattern, style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: cs.onSurface.withValues(alpha: 0.6))),
              ]),
              const Spacer(),
              Text(technique.name, style: const TextStyle(fontFamily: 'Fraunces', fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: -0.4)),
              const SizedBox(height: 2),
              Text(technique.tagline, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
            ],
          ),
        ),
      ),
    );
  }
}
