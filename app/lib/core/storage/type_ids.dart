/// Hive type-ids. Never reuse a number. Add new types at the next free slot.
abstract final class TypeIds {
  static const int sessionLog   = 1;
  static const int moodLog      = 2;
  static const int streakRecord = 3;
  static const int prefs        = 4;
  static const int planProgress = 5;
  static const int phaseKind    = 10;
  static const int goal         = 11;
  static const int themeMode    = 12;
  static const int moodKind     = 13;
}
