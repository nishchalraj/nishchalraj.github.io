'use client';

import { useEffect, useRef, useState } from 'react';
import { useTheme } from 'next-themes';
import { createEngine, type EngineHandle, type EngineTick } from './engine';
import type { Technique } from '@/lib/types';

export interface UseBreathingEngineArgs {
  technique: Technique;
  autoStart?: boolean;
  onCycle?: (cycle: number) => void;
  onComplete?: (cycles: number, durationSec: number) => void;
}

export interface UseBreathingEngineReturn {
  canvasRef: React.RefObject<HTMLCanvasElement | null>;
  tick: EngineTick | null;
  controls: {
    start: () => void;
    pause: () => void;
    resume: () => void;
    stop: () => void;
    skip: () => void;
  };
  running: boolean;
}

export function useBreathingEngine(args: UseBreathingEngineArgs): UseBreathingEngineReturn {
  const { technique, autoStart = true, onCycle, onComplete } = args;
  const canvasRef = useRef<HTMLCanvasElement | null>(null);
  const engineRef = useRef<EngineHandle | null>(null);
  const [tick, setTick] = useState<EngineTick | null>(null);
  const [running, setRunning] = useState(false);
  const { resolvedTheme } = useTheme();

  useEffect(() => {
    if (!canvasRef.current) return;
    const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    const engine = createEngine({
      canvas: canvasRef.current,
      technique,
      themeMode: resolvedTheme === 'dark' ? 'dark' : 'light',
      reducedMotion: reduced,
      events: {
        onTick: (t) => {
          setTick(t);
          setRunning(t.running);
        },
        onCycle,
        onComplete: (cycles, durationSec) => {
          setRunning(false);
          onComplete?.(cycles, durationSec);
        },
      },
    });
    engineRef.current = engine;
    if (autoStart) {
      setRunning(true);
      engine.start();
    }
    return () => engine.dispose();
    // We intentionally recreate the engine if the technique id changes; theme changes only invalidate.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [technique.id]);

  // Invalidate on theme change (color of background ring depends on theme).
  useEffect(() => {
    engineRef.current?.invalidate();
  }, [resolvedTheme]);

  return {
    canvasRef,
    tick,
    running,
    controls: {
      start: () => { engineRef.current?.start(); setRunning(true); },
      pause: () => { engineRef.current?.pause(); setRunning(false); },
      resume: () => { engineRef.current?.resume(); setRunning(true); },
      stop:  () => { engineRef.current?.stop(); setRunning(false); },
      skip:  () => engineRef.current?.skipPhase(),
    },
  };
}
