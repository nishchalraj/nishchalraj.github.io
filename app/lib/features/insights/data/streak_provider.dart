import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../../core/utils/date_x.dart';
import 'streak_record.dart';

class StreakNotifier extends Notifier<StreakRecord> {
  static const _key = 'streak';

  @override
  StreakRecord build() {
    final stored = HiveBoxes.streak.get(_key);
    if (stored == null) {
      final empty = StreakRecord.empty();
      // ignore: discarded_futures
      HiveBoxes.streak.put(_key, empty);
      return empty;
    }
    return stored;
  }

  Future<void> _persist() async => HiveBoxes.streak.put(_key, state);

  Future<void> recordSessionToday() async {
    final d = todayKey();
    if (state.completedDays.contains(d)) return;
    int current;
    if (state.lastDay == null) {
      current = 1;
    } else if (state.lastDay == d) {
      current = state.current;
    } else if (addDays(state.lastDay!, 1) == d) {
      current = state.current + 1;
    } else {
      current = 1;
    }
    state.current = current;
    if (current > state.best) state.best = current;
    state.lastDay = d;
    final cd = List<String>.from(state.completedDays)..add(d);
    if (cd.length > 365) cd.removeRange(0, cd.length - 365);
    state.completedDays = cd;
    await _persist();
    ref.notifyListeners();
  }

  Future<void> clear() async {
    state.current = 0; state.best = 0; state.lastDay = null; state.completedDays = const [];
    await _persist();
    ref.notifyListeners();
  }
}

final streakProvider = NotifierProvider<StreakNotifier, StreakRecord>(StreakNotifier.new);
