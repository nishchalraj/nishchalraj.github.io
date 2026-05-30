'use client';

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { storageKey } from './index';

interface PlansState {
  active: { planId: string; dayIndex: number; startedAt: number } | null;
  completed: Record<string, number[]>; // planId → completed day indices
  startPlan: (planId: string) => void;
  completePlanDay: (planId: string, dayIndex: number) => void;
  abandonPlan: () => void;
  clear: () => void;
}

export const usePlansStore = create<PlansState>()(
  persist(
    (set, get) => ({
      active: null,
      completed: {},
      startPlan: (planId) => set({ active: { planId, dayIndex: 0, startedAt: Date.now() } }),
      completePlanDay: (planId, dayIndex) => {
        const c = get().completed;
        const days = c[planId] ?? [];
        if (days.includes(dayIndex)) return;
        const next = { ...c, [planId]: [...days, dayIndex].sort((a, b) => a - b) };
        set({ completed: next });
      },
      abandonPlan: () => set({ active: null }),
      clear: () => set({ active: null, completed: {} }),
    }),
    {
      name: storageKey('plans'),
      version: 1,
      storage: createJSONStorage(() => localStorage),
    },
  ),
);
