'use client';

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { storageKey } from './index';
import type { SessionRecord, DayKey } from '@/lib/types';
import { todayKey } from '@/lib/date';

interface SessionsState {
  history: SessionRecord[];
  lastTechniqueId: string | null;
  logSession: (r: Omit<SessionRecord, 'id' | 'day'>) => SessionRecord;
  totalMinutes: () => number;
  sessionsOnDay: (day: DayKey) => SessionRecord[];
  clear: () => void;
}

export const useSessionsStore = create<SessionsState>()(
  persist(
    (set, get) => ({
      history: [],
      lastTechniqueId: null,
      logSession: (r) => {
        const rec: SessionRecord = {
          ...r,
          id: crypto.randomUUID(),
          day: todayKey(),
        };
        // Cap to last 365 days for performance.
        const cutoff = Date.now() - 365 * 86_400_000;
        const next = [...get().history, rec].filter((s) => s.startedAt >= cutoff);
        set({ history: next, lastTechniqueId: rec.techniqueId });
        return rec;
      },
      totalMinutes: () =>
        Math.round(get().history.reduce((s, r) => s + r.durationSec, 0) / 60),
      sessionsOnDay: (day) => get().history.filter((r) => r.day === day),
      clear: () => set({ history: [], lastTechniqueId: null }),
    }),
    {
      name: storageKey('sessions'),
      version: 1,
      storage: createJSONStorage(() => localStorage),
    },
  ),
);
