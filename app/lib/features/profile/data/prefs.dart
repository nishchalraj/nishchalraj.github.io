import 'package:hive_ce/hive.dart';

enum Goal { calm, sleep, focus, energy }
enum ThemeModePref { system, light, dark }

class Prefs extends HiveObject {
  Prefs({
    required this.name,
    required this.goal,
    required this.reminderMinutes,
    required this.theme,
    required this.voiceCues,
    required this.defaultSound,
    required this.volume,
    required this.onboarded,
    required this.schemaVersion,
  });

  String name;
  Goal goal;
  int reminderMinutes; // since midnight
  ThemeModePref theme;
  bool voiceCues;
  String defaultSound;
  double volume;
  bool onboarded;
  int schemaVersion;

  static Prefs defaults() => Prefs(
        name: '',
        goal: Goal.calm,
        reminderMinutes: 8 * 60,
        theme: ThemeModePref.system,
        voiceCues: false,
        defaultSound: 'forest',
        volume: 0.55,
        onboarded: false,
        schemaVersion: 1,
      );
}
