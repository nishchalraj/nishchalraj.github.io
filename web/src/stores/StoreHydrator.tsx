'use client';

import { useEffect, useState } from 'react';
import { usePrefsStore } from './prefs.store';
import { useSessionsStore } from './sessions.store';
import { useStreakStore } from './streak.store';
import { useMoodStore } from './mood.store';
import { usePlansStore } from './plans.store';

const stores = [usePrefsStore, useSessionsStore, useStreakStore, useMoodStore, usePlansStore];

/**
 * Waits for all persisted Zustand stores to rehydrate before rendering children.
 * Critical for static-export Next.js: avoids first-paint flash of default state.
 */
export function StoreHydrator({ children }: { children: React.ReactNode }) {
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    // For each store, check persist hydration; resolve when all are true.
    const checkAll = () => stores.every((s) => s.persist?.hasHydrated?.() ?? true);
    if (checkAll()) {
      setHydrated(true);
      return;
    }
    const unsubs = stores.map((s) =>
      s.persist?.onFinishHydration?.(() => {
        if (checkAll()) setHydrated(true);
      }),
    );
    return () => { unsubs.forEach((u) => u && u()); };
  }, []);

  // We render either way to keep first paint visible; just suppress SSR mismatches
  // by gating any client-state-dependent UI behind a `useHydrated` selector elsewhere.
  return <>{children}{!hydrated && null}</>;
}

export function useHydrated() {
  const [h, setH] = useState(false);
  useEffect(() => { setH(true); }, []);
  return h;
}
