import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../features/insights/data/mood_log.dart';
import '../../features/insights/data/streak_record.dart';
import '../../features/plans/data/plan_progress.dart';
import '../../features/profile/data/prefs.dart';
import '../../features/session/data/session_log.dart';

abstract final class HiveBoxes {
  static const _sessions = 'sessions';
  static const _moods    = 'moods';
  static const _streak   = 'streak';
  static const _prefs    = 'prefs';
  static const _plans    = 'plans';

  static Box<SessionLog>   get sessions => Hive.box<SessionLog>(_sessions);
  static Box<MoodLog>      get moods    => Hive.box<MoodLog>(_moods);
  static Box<StreakRecord> get streak   => Hive.box<StreakRecord>(_streak);
  static Box<Prefs>        get prefs    => Hive.box<Prefs>(_prefs);
  static Box<PlanProgress> get plans    => Hive.box<PlanProgress>(_plans);

  static Future<void> openAll() async {
    await Future.wait([
      Hive.openBox<SessionLog>(_sessions),
      Hive.openBox<MoodLog>(_moods),
      Hive.openBox<StreakRecord>(_streak),
      Hive.openBox<Prefs>(_prefs),
      Hive.openBox<PlanProgress>(_plans),
    ]);
  }
}
