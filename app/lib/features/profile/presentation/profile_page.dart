import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/storage/hive_boxes.dart';
import '../../insights/data/mood_provider.dart';
import '../../insights/data/streak_provider.dart';
import '../../plans/data/plan_progress_provider.dart';
import '../data/prefs.dart';
import '../data/prefs_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    final p = ref.read(prefsProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(title: const Text('Profile'), floating: true, backgroundColor: Colors.transparent),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                          colors: [cs.primary, cs.primaryContainer]),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          (prefs.name.isEmpty ? '·' : prefs.name[0]).toUpperCase(),
                          style: TextStyle(fontFamily: 'Fraunces', fontSize: 36, fontWeight: FontWeight.w500, color: cs.onPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(prefs.name.isEmpty ? 'friend' : prefs.name,
                        style: const TextStyle(fontFamily: 'Fraunces', fontSize: 26, fontWeight: FontWeight.w500)),
                    Text('${prefs.goal.name} · niyam',
                        style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.6))),
                  ],
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _Row(
                        label: 'Name',
                        trailing: TextButton(
                          onPressed: () => _editName(context, prefs.name, p.setName),
                          child: Text(prefs.name.isEmpty ? 'set' : prefs.name),
                        ),
                      ),
                      _Row(
                        label: 'Reminder',
                        trailing: TextButton(
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(hour: prefs.reminderMinutes ~/ 60, minute: prefs.reminderMinutes % 60),
                            );
                            if (t != null) await p.setReminderMinutes(t.hour * 60 + t.minute);
                          },
                          child: Text(TimeOfDay(hour: prefs.reminderMinutes ~/ 60, minute: prefs.reminderMinutes % 60).format(context)),
                        ),
                      ),
                      _Row(
                        label: 'Theme',
                        trailing: DropdownButton<ThemeModePref>(
                          value: prefs.theme,
                          underline: const SizedBox.shrink(),
                          onChanged: (v) { if (v != null) p.setTheme(v); },
                          items: const [
                            DropdownMenuItem(value: ThemeModePref.system, child: Text('System')),
                            DropdownMenuItem(value: ThemeModePref.light, child: Text('Light')),
                            DropdownMenuItem(value: ThemeModePref.dark, child: Text('Dark')),
                          ],
                        ),
                      ),
                      _Row(
                        label: 'Voice cues',
                        trailing: Switch(value: prefs.voiceCues, onChanged: p.setVoiceCues),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _exportData(context),
                        child: const Text('Export data (.json)'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => _confirmReset(context, ref),
                        child: const Text('Reset everything', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text('niyam · v0.1.0 · everything stays on this device',
                    style: TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5))),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _editName(BuildContext context, String current, Future<void> Function(String) save) async {
    final c = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(c.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (result != null) await save(result);
  }

  Future<void> _exportData(BuildContext context) async {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'prefs': _prefsJson(HiveBoxes.prefs.get('prefs')),
      'sessions': HiveBoxes.sessions.values.map((s) => {
        'id': s.id, 'techniqueId': s.techniqueId, 'startedAtMs': s.startedAtMs,
        'durationSec': s.durationSec, 'cyclesCompleted': s.cyclesCompleted,
        'completed': s.completed, 'dayKey': s.dayKey,
      }).toList(),
      'moods': HiveBoxes.moods.values.map((m) => {
        'id': m.id, 'dayKey': m.dayKey, 'mood': m.mood.name, 'note': m.note, 'atMs': m.atMs,
      }).toList(),
      'streak': {
        'current': HiveBoxes.streak.get('streak')?.current ?? 0,
        'best':    HiveBoxes.streak.get('streak')?.best ?? 0,
      },
    };
    final json = const JsonEncoder.withIndent('  ').convert(data);
    await Share.share(json, subject: 'niyam-export.json');
  }

  Map<String, dynamic>? _prefsJson(Prefs? p) {
    if (p == null) return null;
    return {
      'name': p.name, 'goal': p.goal.name, 'reminderMinutes': p.reminderMinutes,
      'theme': p.theme.name, 'voiceCues': p.voiceCues, 'defaultSound': p.defaultSound,
      'volume': p.volume, 'onboarded': p.onboarded,
    };
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset everything?'),
        content: const Text('Clears sessions, streaks, moods, and preferences.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Reset')),
        ],
      ),
    );
    if (ok == true) {
      await HiveBoxes.sessions.clear();
      await ref.read(streakProvider.notifier).clear();
      await ref.read(moodProvider.notifier).clear();
      await ref.read(plansProvider.notifier).clear();
      await ref.read(prefsProvider.notifier).reset();
    }
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.trailing});
  final String label;
  final Widget trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(children: [
        Expanded(child: Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)))),
        trailing,
      ]),
    );
  }
}
