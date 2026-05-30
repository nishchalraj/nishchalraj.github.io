import 'package:hive_ce/hive.dart';

class PlanProgress extends HiveObject {
  PlanProgress({
    required this.planId,
    required this.startedAtMs,
    required this.completedDays,
  });

  final String planId;
  final int startedAtMs;
  List<int> completedDays;
}
