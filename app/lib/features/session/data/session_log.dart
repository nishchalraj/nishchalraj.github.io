import 'package:hive_ce/hive.dart';

class SessionLog extends HiveObject {
  SessionLog({
    required this.id,
    required this.techniqueId,
    required this.startedAtMs,
    required this.durationSec,
    required this.cyclesCompleted,
    required this.completed,
    required this.dayKey,
  });

  final String id;
  final String techniqueId;
  final int startedAtMs;
  final int durationSec;
  final int cyclesCompleted;
  final bool completed;
  final String dayKey;
}
