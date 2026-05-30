import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import 'plan_progress.dart';

class PlansNotifier extends Notifier<Map<String, PlanProgress>> {
  @override
  Map<String, PlanProgress> build() {
    return { for (final p in HiveBoxes.plans.values) p.planId: p };
  }

  Future<void> startPlan(String planId) async {
    if (state.containsKey(planId)) return;
    final p = PlanProgress(
      planId: planId,
      startedAtMs: DateTime.now().millisecondsSinceEpoch,
      completedDays: <int>[],
    );
    await HiveBoxes.plans.add(p);
    state = { for (final pp in HiveBoxes.plans.values) pp.planId: pp };
  }

  Future<void> completeDay(String planId, int dayIndex) async {
    final p = state[planId];
    if (p == null || p.completedDays.contains(dayIndex)) return;
    p.completedDays = List<int>.from(p.completedDays)..add(dayIndex)..sort();
    await p.save();
    state = { ...state, planId: p };
  }

  Future<void> clear() async {
    await HiveBoxes.plans.clear();
    state = const {};
  }
}

final plansProvider = NotifierProvider<PlansNotifier, Map<String, PlanProgress>>(PlansNotifier.new);
