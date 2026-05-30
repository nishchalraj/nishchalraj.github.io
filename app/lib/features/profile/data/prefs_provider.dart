import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/hive_boxes.dart';
import 'prefs.dart';

class PrefsNotifier extends Notifier<Prefs> {
  static const _key = 'prefs';

  @override
  Prefs build() {
    final stored = HiveBoxes.prefs.get(_key);
    if (stored == null) {
      final fresh = Prefs.defaults();
      // Fire-and-forget — Hive writes are durable but async-safe.
      // ignore: discarded_futures
      HiveBoxes.prefs.put(_key, fresh);
      return fresh;
    }
    return stored;
  }

  Future<void> _persist() async {
    await HiveBoxes.prefs.put(_key, state);
  }

  Future<void> setName(String name) async        { state.name = name; await _persist(); ref.notifyListeners(); }
  Future<void> setGoal(Goal g) async              { state.goal = g; await _persist(); ref.notifyListeners(); }
  Future<void> setReminderMinutes(int m) async    { state.reminderMinutes = m; await _persist(); ref.notifyListeners(); }
  Future<void> setTheme(ThemeModePref t) async    { state.theme = t; await _persist(); ref.notifyListeners(); }
  Future<void> setVoiceCues(bool v) async         { state.voiceCues = v; await _persist(); ref.notifyListeners(); }
  Future<void> setDefaultSound(String s) async    { state.defaultSound = s; await _persist(); ref.notifyListeners(); }
  Future<void> setVolume(double v) async          { state.volume = v.clamp(0, 1); await _persist(); ref.notifyListeners(); }
  Future<void> completeOnboarding() async         { state.onboarded = true; await _persist(); ref.notifyListeners(); }
  Future<void> reset() async {
    state = Prefs.defaults();
    await _persist();
    ref.notifyListeners();
  }
}

final prefsProvider = NotifierProvider<PrefsNotifier, Prefs>(PrefsNotifier.new);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final t = ref.watch(prefsProvider).theme;
  switch (t) {
    case ThemeModePref.light:  return ThemeMode.light;
    case ThemeModePref.dark:   return ThemeMode.dark;
    case ThemeModePref.system: return ThemeMode.system;
  }
});
