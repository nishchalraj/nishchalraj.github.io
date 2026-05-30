export type PhaseKind = 'inhale' | 'hold-in' | 'exhale' | 'hold-out';

export interface Phase {
  kind: PhaseKind;
  durationSec: number;
}

export interface Technique {
  id: string;
  name: string;
  tagline: string;
  description: string;
  phases: Phase[];
  cycles: number;
  category: 'calm' | 'focus' | 'sleep' | 'energy';
  pattern: string; // human-readable like "4-7-8" or "4-4-4-4"
  tags: string[];
  recommendedSound?: SoundId;
}

export type SoundId = 'forest' | 'ocean' | 'rain' | 'fire' | 'wind' | 'waves' | 'none';

export interface SoundMeta {
  id: SoundId;
  label: string;
  src: string;
  description: string;
}

export type DayKey = string; // YYYY-MM-DD in local TZ
export type Goal = 'calm' | 'sleep' | 'focus' | 'energy';
export type MoodKind = 'calm' | 'neutral' | 'anxious' | 'sad' | 'energetic';
export type ThemeMode = 'light' | 'dark' | 'system';
export type ReducedMotion = 'system' | 'on' | 'off';

export interface SessionRecord {
  id: string;
  techniqueId: string;
  planId?: string;
  startedAt: number;
  durationSec: number;
  cyclesCompleted: number;
  completed: boolean;
  day: DayKey;
}

export interface MoodLog {
  id: string;
  day: DayKey;
  mood: MoodKind;
  note?: string;
  at: number;
}

export interface StreakRecord {
  current: number;
  best: number;
  lastDay: DayKey | null;
  completedDays: DayKey[];
}

export interface UserPrefs {
  name: string;
  goal: Goal;
  reminderTime: string; // HH:mm
  theme: ThemeMode;
  voiceCues: boolean;
  defaultSound: SoundId;
  volume: number;
  reducedMotion: ReducedMotion;
  onboarded: boolean;
}

export interface Plan {
  id: string;
  title: string;
  subtitle: string;
  cover: string; // gradient class or image url
  days: Array<{ techniqueId: string; cycles: number }>;
}
