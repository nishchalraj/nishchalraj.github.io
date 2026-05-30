'use client';

import { createContext, useContext, useEffect, useRef, useState } from 'react';
import { SOUNDS_BY_ID } from './manifest';
import type { SoundId } from '@/lib/types';
import { usePrefsStore } from '@/stores/prefs.store';

interface AudioContextValue {
  current: SoundId | null;
  play: (id: SoundId) => void;
  stop: () => void;
  setVolume: (v: number) => void;
  volume: number;
  unlocked: boolean;
}

const Ctx = createContext<AudioContextValue | null>(null);

export function useAudio() {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error('useAudio must be used inside AudioProvider');
  return ctx;
}

/**
 * Lightweight audio provider. Lazy-loads Howler on first use to keep the
 * marketing route bundle small. Gesture-gated init for Safari/iOS autoplay.
 */
export function AudioProvider({ children }: { children: React.ReactNode }) {
  const [current, setCurrent] = useState<SoundId | null>(null);
  const [unlocked, setUnlocked] = useState(false);
  const volume = usePrefsStore((s) => s.volume);
  const setVol = usePrefsStore((s) => s.setVolume);

  // Map of id → Howl instance (typed loosely to avoid Howler in marketing bundle).
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const howls = useRef<Map<SoundId, any>>(new Map());
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const HowlerRef = useRef<any>(null);

  useEffect(() => {
    const unlock = () => {
      if (!unlocked) setUnlocked(true);
    };
    window.addEventListener('pointerdown', unlock, { once: true });
    window.addEventListener('keydown', unlock, { once: true });
    return () => {
      window.removeEventListener('pointerdown', unlock);
      window.removeEventListener('keydown', unlock);
    };
  }, [unlocked]);

  const ensure = async () => {
    if (!HowlerRef.current) {
      HowlerRef.current = await import('howler');
    }
    return HowlerRef.current;
  };

  const stop = () => {
    if (current && howls.current.has(current)) {
      const h = howls.current.get(current);
      h.fade(volume, 0, 600);
      setTimeout(() => h.stop(), 650);
    }
    setCurrent(null);
  };

  const play = async (id: SoundId) => {
    if (id === 'none') { stop(); return; }
    const HowlerMod = await ensure();
    const { Howl } = HowlerMod;
    const meta = SOUNDS_BY_ID[id];
    if (!meta) return;

    if (current && howls.current.has(current)) {
      const prev = howls.current.get(current);
      prev.fade(volume, 0, 600);
      setTimeout(() => prev.stop(), 650);
    }

    let h = howls.current.get(id);
    if (!h) {
      h = new Howl({ src: [meta.src], loop: true, html5: false, volume: 0 });
      howls.current.set(id, h);
    }
    h.volume(0);
    h.play();
    h.fade(0, volume, 800);
    setCurrent(id);
  };

  const setVolume = (v: number) => {
    setVol(v);
    howls.current.forEach((h) => h.volume(v));
  };

  return (
    <Ctx.Provider value={{ current, play, stop, setVolume, volume, unlocked }}>
      {children}
    </Ctx.Provider>
  );
}
