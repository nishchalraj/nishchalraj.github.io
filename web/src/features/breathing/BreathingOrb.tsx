'use client';

import { motion, useReducedMotion } from 'framer-motion';
import { useBreathingEngine, type UseBreathingEngineArgs } from './useBreathingEngine';
import { ReducedMotionOrb } from './ReducedMotionOrb';
import type { Technique } from '@/lib/types';

interface BreathingOrbProps extends UseBreathingEngineArgs {
  size?: number | string;
  showCountdownRing?: boolean;
  showPhaseText?: boolean;
}

function phraseFor(kind: Technique['phases'][number]['kind']): string {
  switch (kind) {
    case 'inhale':   return 'Inhale';
    case 'exhale':   return 'Exhale';
    case 'hold-in':
    case 'hold-out': return 'Hold';
  }
}

export function BreathingOrb({
  technique,
  size = 'min(80vmin, 540px)',
  showCountdownRing = true,
  showPhaseText = true,
  ...rest
}: BreathingOrbProps) {
  const reduced = useReducedMotion();
  const { canvasRef, tick, running, controls } = useBreathingEngine({ technique, ...rest });

  if (reduced) return <ReducedMotionOrb technique={technique} {...rest} />;

  const phase = tick?.phase;
  const phaseProgress = tick?.phaseProgress ?? 0;
  const secondsLeft = phase
    ? Math.max(0, Math.ceil(phase.durationSec * (1 - phaseProgress)))
    : 0;

  const RING_RADIUS = 48;
  const RING_CIRC = 2 * Math.PI * RING_RADIUS;
  const dash = RING_CIRC * (1 - phaseProgress);

  return (
    <div
      className="relative grid place-items-center select-none"
      style={{ width: size, height: size }}
      onClick={() => (running ? controls.pause() : controls.resume())}
    >
      <canvas ref={canvasRef} className="absolute inset-0 h-full w-full" aria-hidden />

      {/* Countdown ring (DOM/SVG — crisp + accessible) */}
      {showCountdownRing && (
        <svg
          viewBox="0 0 100 100"
          className="absolute inset-0 h-full w-full pointer-events-none"
          aria-hidden
        >
          <circle
            cx="50" cy="50" r={RING_RADIUS}
            fill="none"
            stroke="rgb(var(--foreground) / 0.06)"
            strokeWidth="0.6"
          />
          <motion.circle
            cx="50" cy="50" r={RING_RADIUS}
            fill="none"
            stroke="rgb(var(--foreground) / 0.55)"
            strokeWidth="0.8"
            strokeLinecap="round"
            transform="rotate(-90 50 50)"
            strokeDasharray={RING_CIRC}
            strokeDashoffset={dash}
            transition={{ duration: 0 }}
          />
        </svg>
      )}

      {/* Phase text overlay */}
      {showPhaseText && phase && (
        <div className="relative flex flex-col items-center gap-2 text-foreground">
          <motion.div
            key={`${phase.kind}-${tick?.cycle}`}
            initial={{ opacity: 0, y: 6 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
            className="text-display text-3xl sm:text-4xl md:text-5xl tracking-tight"
            aria-live="polite"
          >
            {phraseFor(phase.kind)}
          </motion.div>
          <div className="tabular-nums text-sm text-foreground-soft">
            {secondsLeft}s
          </div>
        </div>
      )}
    </div>
  );
}

export { useBreathingEngine };
