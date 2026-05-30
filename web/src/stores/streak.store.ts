'use client';

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { storageKey } from './index';
import type { StreakRecord, DayKey } from '@/lib/types';
import { addDays, todayKey } from '@/lib/date';

interface StreakState extends StreakRecord {
  recordSession: (day?: DayKey) => void;
  clear: () => void;
}

const empty: StreakRecord = { current: 0, best: 0, lastDay: null, completedDays: [] };

export const useStreakStore = create<StreakState>()(
  persist(
    (set, get) => ({
      ...empty,
      recordSession: (day) => {
        const d = day ?? todayKey();
        const s = get();
        if (s.completedDays.includes(d)) return; // already logged today
        let current = s.current;
        if (!s.lastDay) {
          current = 1;
        } else if (s.lastDay === d) {
          current = s.current; // shouldn't happen due to guard above
        } else if (addDays(s.lastDay, 1) === d) {
          current = s.current + 1;
        } else {
          current = 1; // streak broken
        }
        const best = Math.max(s.best, current);
        const completedDays = [...s.completedDays, d].slice(-365);
        set({ current, best, lastDay: d, completedDays });
      },
      clear: () => set(empty),
    }),
    {
      name: storageKey('streak'),
      version: 1,
      storage: createJSONStorage(() => localStorage),
    },
  ),
);
