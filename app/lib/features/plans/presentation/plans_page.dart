import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/plan_progress_provider.dart';
import '../domain/plan_catalog.dart';

class PlansPage extends ConsumerWidget {
  const PlansPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(plansProvider);
    final cs = Theme.of(context).colorScheme;
    return CustomScrollView(
      slivers: [
        SliverAppBar(title: const Text('Plans'), floating: true, backgroundColor: Colors.transparent),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text('Multi-day programs to build the habit one breath at a time.',
                        style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
                  );
                }
                final p = PlanCatalog.all[i - 1];
                final pp = progress[p.id];
                final done = pp?.completedDays.length ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlanCard(plan: p, done: done, isActive: pp != null)
                    .animate(delay: (i * 70).ms).fadeIn(),
                );
              },
              childCount: PlanCatalog.all.length + 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.done, required this.isActive});
  final PlanDef plan;
  final int done;
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.go('/plans/${plan.id}'),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [cs.primary.withValues(alpha: 0.32), cs.primaryContainer.withValues(alpha: 0.2)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(plan.title,
                      style: const TextStyle(fontFamily: 'Fraunces', fontSize: 22, fontWeight: FontWeight.w500, letterSpacing: -0.4)),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: cs.onPrimary, borderRadius: BorderRadius.circular(99)),
                    child: Text('ACTIVE', style: TextStyle(fontSize: 9, letterSpacing: 1.4, color: cs.primary)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(plan.subtitle, style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7))),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: done / plan.days.length,
                minHeight: 5,
                backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
            ),
            const SizedBox(height: 6),
            Text('$done of ${plan.days.length} days',
                style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.6))),
          ],
        ),
      ),
    );
  }
}
