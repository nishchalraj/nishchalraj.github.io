'use client';

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { storageKey } from './index';
import type { UserPrefs } from '@/lib/types';

interface PrefsState extends UserPrefs {
  setName: (name: string) => void;
  setGoal: (goal: UserPrefs['goal']) => void;
  setReminderTime: (t: string) => void;
  setTheme: (theme: UserPrefs['theme']) => void;
  setVolume: (v: number) => void;
  setDefaultSound: (s: UserPrefs['defaultSound']) => void;
  setVoiceCues: (v: boolean) => void;
  setReducedMotion: (m: UserPrefs['reducedMotion']) => void;
  completeOnboarding: () => void;
  reset: () => void;
}

const DEFAULTS: UserPrefs = {
  name: '',
  goal: 'calm',
  reminderTime: '08:00',
  theme: 'system',
  voiceCues: false,
  defaultSound: 'forest',
  volume: 0.55,
  reducedMotion: 'system',
  onboarded: false,
};

export const usePrefsStore = create<PrefsState>()(
  persist(
    (set) => ({
      ...DEFAULTS,
      setName: (name) => set({ name }),
      setGoal: (goal) => set({ goal }),
      setReminderTime: (reminderTime) => set({ reminderTime }),
      setTheme: (theme) => set({ theme }),
      setVolume: (volume) => set({ volume: Math.max(0, Math.min(1, volume)) }),
      setDefaultSound: (defaultSound) => set({ defaultSound }),
      setVoiceCues: (voiceCues) => set({ voiceCues }),
      setReducedMotion: (reducedMotion) => set({ reducedMotion }),
      completeOnboarding: () => set({ onboarded: true }),
      reset: () => set(DEFAULTS),
    }),
    {
      name: storageKey('prefs'),
      version: 1,
      storage: createJSONStorage(() => localStorage),
    },
  ),
);
