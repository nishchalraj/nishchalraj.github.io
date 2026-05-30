'use client';

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { storageKey } from './index';
import type { MoodLog, MoodKind } from '@/lib/types';
import { todayKey } from '@/lib/date';

interface MoodState {
  logs: MoodLog[];
  log: (mood: MoodKind, note?: string) => MoodLog;
  todayMood: () => MoodLog | null;
  clear: () => void;
}

export const useMoodStore = create<MoodState>()(
  persist(
    (set, get) => ({
      logs: [],
      log: (mood, note) => {
        const rec: MoodLog = {
          id: crypto.randomUUID(),
          day: todayKey(),
          mood, note, at: Date.now(),
        };
        const cutoff = Date.now() - 365 * 86_400_000;
        set({ logs: [...get().logs, rec].filter((l) => l.at >= cutoff) });
        return rec;
      },
      todayMood: () => {
        const k = todayKey();
        const day = get().logs.filter((l) => l.day === k);
        return day[day.length - 1] ?? null;
      },
      clear: () => set({ logs: [] }),
    }),
    {
      name: storageKey('mood'),
      version: 1,
      storage: createJSONStorage(() => localStorage),
    },
  ),
);
