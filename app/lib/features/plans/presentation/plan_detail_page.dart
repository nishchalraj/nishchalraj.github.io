import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../session/domain/technique.dart';
import '../data/plan_progress_provider.dart';
import '../domain/plan_catalog.dart';

class PlanDetailPage extends ConsumerWidget {
  const PlanDetailPage({super.key, required this.planId});
  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = PlanCatalog.byId(planId);
    if (plan == null) return const Scaffold(body: Center(child: Text('Unknown plan')));
    final progress = ref.watch(plansProvider)[planId];
    final completed = progress?.completedDays ?? const <int>[];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/plans')),
        title: Text(plan.title),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        itemCount: plan.days.length + 1,
        itemBuilder: (_, i) {
          if (i == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [cs.primary.withValues(alpha: 0.32), cs.primaryContainer.withValues(alpha: 0.2)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(plan.title,
                      style: const TextStyle(fontFamily: 'Fraunces', fontSize: 28, fontWeight: FontWeight.w500, letterSpacing: -0.6)),
                  const SizedBox(height: 4),
                  Text(plan.subtitle, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
                  const SizedBox(height: 16),
                  if (progress == null)
                    FilledButton(
                      onPressed: () => ref.read(plansProvider.notifier).startPlan(plan.id),
                      child: const Text('Start plan'),
                    ),
                ],
              ),
            );
          }
          final dayIdx = i - 1;
          final day = plan.days[dayIdx];
          final t = TechniqueRegistry.byId(day.techniqueId);
          final done = completed.contains(dayIdx);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: done ? cs.primary : cs.onSurface.withValues(alpha: 0.05),
                child: done
                    ? Icon(Icons.check, size: 14, color: cs.onPrimary)
                    : Text('${dayIdx + 1}', style: TextStyle(fontSize: 12, color: cs.onSurface)),
              ),
              title: Text('Day ${dayIdx + 1} · ${t?.name ?? day.techniqueId}',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text('${day.cycles} cycles · ${t?.pattern ?? ""}'),
              trailing: TextButton(
                onPressed: () => context.go('/session/${day.techniqueId}'),
                child: const Text('Begin →'),
              ),
            ),
          );
        },
      ),
    );
  }
}
