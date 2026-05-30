import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../core/utils/date_x.dart';
import 'mood_log.dart';

class MoodNotifier extends Notifier<List<MoodLog>> {
  @override
  List<MoodLog> build() {
    return HiveBoxes.moods.values.toList();
  }

  Future<MoodLog> log(MoodKind mood, {String? note}) async {
    final rec = MoodLog(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      dayKey: todayKey(),
      mood: mood, note: note,
      atMs: DateTime.now().millisecondsSinceEpoch,
    );
    await HiveBoxes.moods.add(rec);
    state = HiveBoxes.moods.values.toList();
    return rec;
  }

  MoodLog? todayMood() {
    final d = todayKey();
    final today = state.where((m) => m.dayKey == d).toList();
    return today.isEmpty ? null : today.last;
  }

  Future<void> clear() async {
    await HiveBoxes.moods.clear();
    state = const [];
  }
}

final moodProvider = NotifierProvider<MoodNotifier, List<MoodLog>>(MoodNotifier.new);
