import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../core/utils/date_x.dart';
import 'session_log.dart';

class SessionRepository {
  Future<SessionLog> log({
    required String techniqueId,
    required int startedAtMs,
    required int durationSec,
    required int cyclesCompleted,
    required bool completed,
  }) async {
    final rec = SessionLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      techniqueId: techniqueId,
      startedAtMs: startedAtMs,
      durationSec: durationSec,
      cyclesCompleted: cyclesCompleted,
      completed: completed,
      dayKey: todayKey(),
    );
    await HiveBoxes.sessions.add(rec);
    return rec;
  }

  Iterable<SessionLog> all() => HiveBoxes.sessions.values;
  String? lastTechniqueId() {
    final v = HiveBoxes.sessions.values;
    if (v.isEmpty) return null;
    return v.last.techniqueId;
  }
  int totalMinutes() => (HiveBoxes.sessions.values.fold<int>(0, (s, r) => s + r.durationSec) / 60).round();
}

final sessionRepositoryProvider = Provider<SessionRepository>((_) => SessionRepository());

final sessionsListProvider = StreamProvider<List<SessionLog>>((ref) async* {
  yield HiveBoxes.sessions.values.toList();
  await for (final _ in HiveBoxes.sessions.watch()) {
    yield HiveBoxes.sessions.values.toList();
  }
});
