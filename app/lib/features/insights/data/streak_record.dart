import 'package:hive_ce/hive.dart';

class StreakRecord extends HiveObject {
  StreakRecord({
    required this.current,
    required this.best,
    required this.lastDay,
    required this.completedDays,
  });

  int current;
  int best;
  String? lastDay;
  List<String> completedDays;

  static StreakRecord empty() =>
      StreakRecord(current: 0, best: 0, lastDay: null, completedDays: <String>[]);
}
