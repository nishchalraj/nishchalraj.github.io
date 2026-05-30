import 'package:hive_ce/hive.dart';

import '../../features/insights/data/mood_log.dart';
import '../../features/insights/data/streak_record.dart';
import '../../features/plans/data/plan_progress.dart';
import '../../features/profile/data/prefs.dart';
import '../../features/session/data/session_log.dart';
import '../../features/session/domain/phase.dart';
import 'type_ids.dart';

void registerAdapters() {
  // Hand-rolled adapters keep us free of build_runner for v1.
  Hive
    ..registerAdapter(PhaseKindAdapter())
    ..registerAdapter(GoalAdapter())
    ..registerAdapter(ThemeModePrefAdapter())
    ..registerAdapter(MoodKindAdapter())
    ..registerAdapter(SessionLogAdapter())
    ..registerAdapter(MoodLogAdapter())
    ..registerAdapter(StreakRecordAdapter())
    ..registerAdapter(PrefsAdapter())
    ..registerAdapter(PlanProgressAdapter());
}

// Re-exported for adapter implementations.
class _TypeIds {
  static int get phaseKind   => TypeIds.phaseKind;
  static int get goal        => TypeIds.goal;
  static int get themeMode   => TypeIds.themeMode;
  static int get moodKind    => TypeIds.moodKind;
  static int get sessionLog  => TypeIds.sessionLog;
  static int get moodLog     => TypeIds.moodLog;
  static int get streak      => TypeIds.streakRecord;
  static int get prefs       => TypeIds.prefs;
  static int get planProg    => TypeIds.planProgress;
}

class PhaseKindAdapter extends TypeAdapter<PhaseKind> {
  @override final int typeId = _TypeIds.phaseKind;
  @override PhaseKind read(BinaryReader r) => PhaseKind.values[r.readByte()];
  @override void write(BinaryWriter w, PhaseKind o) => w.writeByte(o.index);
}

class GoalAdapter extends TypeAdapter<Goal> {
  @override final int typeId = _TypeIds.goal;
  @override Goal read(BinaryReader r) => Goal.values[r.readByte()];
  @override void write(BinaryWriter w, Goal o) => w.writeByte(o.index);
}

class ThemeModePrefAdapter extends TypeAdapter<ThemeModePref> {
  @override final int typeId = _TypeIds.themeMode;
  @override ThemeModePref read(BinaryReader r) => ThemeModePref.values[r.readByte()];
  @override void write(BinaryWriter w, ThemeModePref o) => w.writeByte(o.index);
}

class MoodKindAdapter extends TypeAdapter<MoodKind> {
  @override final int typeId = _TypeIds.moodKind;
  @override MoodKind read(BinaryReader r) => MoodKind.values[r.readByte()];
  @override void write(BinaryWriter w, MoodKind o) => w.writeByte(o.index);
}

class SessionLogAdapter extends TypeAdapter<SessionLog> {
  @override final int typeId = _TypeIds.sessionLog;
  @override
  SessionLog read(BinaryReader r) => SessionLog(
    id:               r.readString(),
    techniqueId:      r.readString(),
    startedAtMs:      r.readInt(),
    durationSec:      r.readInt(),
    cyclesCompleted:  r.readInt(),
    completed:        r.readBool(),
    dayKey:           r.readString(),
  );
  @override
  void write(BinaryWriter w, SessionLog o) {
    w.writeString(o.id);
    w.writeString(o.techniqueId);
    w.writeInt(o.startedAtMs);
    w.writeInt(o.durationSec);
    w.writeInt(o.cyclesCompleted);
    w.writeBool(o.completed);
    w.writeString(o.dayKey);
  }
}

class MoodLogAdapter extends TypeAdapter<MoodLog> {
  @override final int typeId = _TypeIds.moodLog;
  @override
  MoodLog read(BinaryReader r) {
    final id     = r.readString();
    final dayKey = r.readString();
    final mood   = MoodKind.values[r.readByte()];
    final note   = r.readString();
    final atMs   = r.readInt();
    return MoodLog(
      id: id,
      dayKey: dayKey,
      mood: mood,
      note: note.isEmpty ? null : note,
      atMs: atMs,
    );
  }
  @override
  void write(BinaryWriter w, MoodLog o) {
    w.writeString(o.id);
    w.writeString(o.dayKey);
    w.writeByte(o.mood.index);
    w.writeString(o.note ?? '');
    w.writeInt(o.atMs);
  }
}

class StreakRecordAdapter extends TypeAdapter<StreakRecord> {
  @override final int typeId = _TypeIds.streak;
  @override
  StreakRecord read(BinaryReader r) {
    final current = r.readInt();
    final best    = r.readInt();
    final last    = r.readString();
    final days    = List<String>.from(r.readStringList());
    return StreakRecord(
      current: current,
      best: best,
      lastDay: last.isEmpty ? null : last,
      completedDays: days,
    );
  }
  @override
  void write(BinaryWriter w, StreakRecord o) {
    w.writeInt(o.current);
    w.writeInt(o.best);
    w.writeString(o.lastDay ?? '');
    w.writeStringList(o.completedDays);
  }
}

class PrefsAdapter extends TypeAdapter<Prefs> {
  @override final int typeId = _TypeIds.prefs;
  @override
  Prefs read(BinaryReader r) => Prefs(
    name: r.readString(),
    goal: Goal.values[r.readByte()],
    reminderMinutes: r.readInt(),
    theme: ThemeModePref.values[r.readByte()],
    voiceCues: r.readBool(),
    defaultSound: r.readString(),
    volume: r.readDouble(),
    onboarded: r.readBool(),
    schemaVersion: r.readInt(),
  );
  @override
  void write(BinaryWriter w, Prefs o) {
    w.writeString(o.name);
    w.writeByte(o.goal.index);
    w.writeInt(o.reminderMinutes);
    w.writeByte(o.theme.index);
    w.writeBool(o.voiceCues);
    w.writeString(o.defaultSound);
    w.writeDouble(o.volume);
    w.writeBool(o.onboarded);
    w.writeInt(o.schemaVersion);
  }
}

class PlanProgressAdapter extends TypeAdapter<PlanProgress> {
  @override final int typeId = _TypeIds.planProg;
  @override
  PlanProgress read(BinaryReader r) => PlanProgress(
    planId: r.readString(),
    startedAtMs: r.readInt(),
    completedDays: r.readIntList(),
  );
  @override
  void write(BinaryWriter w, PlanProgress o) {
    w.writeString(o.planId);
    w.writeInt(o.startedAtMs);
    w.writeIntList(o.completedDays);
  }
}
