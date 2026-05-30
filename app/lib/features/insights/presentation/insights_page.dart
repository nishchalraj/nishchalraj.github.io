import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_x.dart';
import '../data/mood_log.dart';
import '../data/mood_provider.dart';
import '../data/streak_provider.dart';
import '../../session/data/session_repository.dart';

const _moodScore = <MoodKind, double>{
  MoodKind.sad: 1, MoodKind.anxious: 2, MoodKind.neutral: 3, MoodKind.calm: 4, MoodKind.energetic: 5,
};

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);
    final moods = ref.watch(moodProvider);
    final sessions = ref.read(sessionRepositoryProvider).all().toList();
    final totalMin = ref.read(sessionRepositoryProvider).totalMinutes();
    final cs = Theme.of(context).colorScheme;

    // 56-day heatmap
    final today = todayKey();
    final cells = List<({String key, int intensity})>.generate(56, (i) {
      final k = addDays(today, -(55 - i));
      final completed = streak.completedDays.contains(k);
      final count = sessions.where((s) => s.dayKey == k).length;
      return (key: k, intensity: completed ? (1 + count).clamp(1, 4) : 0);
    });

    // 30-day mood line
    final spots = List<FlSpot>.generate(30, (i) {
      final k = addDays(today, -(29 - i));
      final logs = moods.where((m) => m.dayKey == k).toList();
      if (logs.isEmpty) return FlSpot(i.toDouble(), 0);
      final avg = logs.fold<double>(0, (s, m) => s + (_moodScore[m.mood] ?? 0)) / logs.length;
      return FlSpot(i.toDouble(), avg);
    }).where((s) => s.y > 0).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar(title: const Text('Insights'), floating: true, backgroundColor: Colors.transparent),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(children: [
                Expanded(child: _StatCard(value: '${streak.current}', label: 'streak · days')),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(value: '${streak.best}', label: 'best · days')),
                const SizedBox(width: 8),
                Expanded(child: _StatCard(value: '$totalMin', label: 'minutes · total')),
              ]),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('LAST 8 WEEKS', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: cs.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 8, mainAxisSpacing: 4, crossAxisSpacing: 4,
                        ),
                        itemCount: cells.length,
                        itemBuilder: (_, i) {
                          final c = cells[i];
                          final color = c.intensity == 0
                              ? cs.onSurface.withValues(alpha: 0.07)
                              : cs.primary.withValues(alpha: 0.25 + c.intensity * 0.18);
                          return Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('MOOD · 30 DAYS', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: cs.onSurface.withValues(alpha: 0.6))),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 80,
                        child: spots.length < 2
                            ? Center(child: Text('Log a few moods to see trends.',
                                style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5))))
                            : LineChart(LineChartData(
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                titlesData: const FlTitlesData(show: false),
                                minY: 1, maxY: 5,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: spots,
                                    isCurved: true, barWidth: 2,
                                    color: cs.primary,
                                    dotData: const FlDotData(show: false),
                                  ),
                                ],
                              )),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('sad', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: cs.onSurface.withValues(alpha: 0.5))),
                          Text('neutral', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: cs.onSurface.withValues(alpha: 0.5))),
                          Text('energetic', style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: cs.onSurface.withValues(alpha: 0.5))),
                        ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontFamily: 'Fraunces', fontSize: 26, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, letterSpacing: 1.2, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    ),
  );
}
