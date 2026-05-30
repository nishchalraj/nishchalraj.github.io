'use client';

import { useEffect, useState } from 'react';
import type { Technique } from '@/lib/types';

interface Props {
  technique: Technique;
  onComplete?: (cycles: number, durationSec: number) => void;
  onCycle?: (cycle: number) => void;
}

const phraseFor = (k: Technique['phases'][number]['kind']) => {
  switch (k) {
    case 'inhale': return 'Inhale';
    case 'exhale': return 'Exhale';
    case 'hold-in':
    case 'hold-out': return 'Hold';
  }
};

/**
 * Accessibility-first fallback. No canvas, no continuous animation —
 * just live-region text + a simple CSS scale tween between phases.
 */
export function ReducedMotionOrb({ technique, onCycle, onComplete }: Props) {
  const phases = technique.phases.filter((p) => p.durationSec > 0);
  const [idx, setIdx] = useState(0);
  const [cycle, setCycle] = useState(0);
  const [secs, setSecs] = useState(phases[0]?.durationSec ?? 0);

  useEffect(() => {
    if (!phases.length) return;
    setSecs(phases[idx].durationSec);
    const tick = setInterval(() => setSecs((s) => Math.max(0, s - 1)), 1000);
    const next = setTimeout(() => {
      const nextIdx = (idx + 1) % phases.length;
      if (nextIdx === 0) {
        const c = cycle + 1;
        onCycle?.(c);
        if (c >= technique.cycles) {
          onComplete?.(c, technique.phases.reduce((s, p) => s + p.durationSec, 0) * c);
          clearInterval(tick);
          return;
        }
        setCycle(c);
      }
      setIdx(nextIdx);
    }, phases[idx].durationSec * 1000);
    return () => { clearInterval(tick); clearTimeout(next); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [idx, cycle]);

  if (!phases.length) return null;
  const phase = phases[idx];
  const expand = phase.kind === 'inhale' || phase.kind === 'hold-in';

  return (
    <div
      className="relative grid place-items-center"
      style={{ width: 'min(80vmin, 480px)', height: 'min(80vmin, 480px)' }}
      role="timer"
      aria-live="polite"
    >
      <div
        className="absolute rounded-full bg-primary/40 transition-transform"
        style={{
          width: '60%', height: '60%',
          transform: `scale(${expand ? 1 : 0.55})`,
          transitionDuration: `${phase.durationSec}s`,
          transitionTimingFunction: 'cubic-bezier(0.4,0,0.2,1)',
        }}
      />
      <div className="absolute rounded-full border border-foreground/10" style={{ width: '90%', height: '90%' }} />
      <div className="relative text-center">
        <div className="text-display text-4xl tracking-tight">{phraseFor(phase.kind)}</div>
        <div className="mt-2 tabular-nums text-foreground-soft">{secs}s</div>
        <div className="mt-1 text-xs text-foreground-soft/70">
          cycle {cycle + 1} / {technique.cycles}
        </div>
      </div>
    </div>
  );
}
