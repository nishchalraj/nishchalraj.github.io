// niyam breathing engine — pure-TS RAF-driven port of /index.html TweenPulse.
// - setInterval → single requestAnimationFrame loop driven by performance.now()
// - Clean pause/resume (preserves phase progress)
// - DPR-aware sizing
// - Honors visibilitychange auto-pause
// - Emits state per tick for the canvas painter + DOM overlays

import type { Phase, Technique, PhaseKind } from '@/lib/types';
import { DEFAULT_ORB_COLOR, RGB, lerpColor, lighten, nextLavenderColor, toCss } from './color';
import { drawDonut, drawPie } from './drawPrimitives';

export interface EngineTick {
  phaseIndex: number;
  phase: Phase;
  phaseProgress: number; // 0..1
  cycle: number;
  cyclesTotal: number;
  elapsedSec: number;
  totalSec: number;
  color: RGB;
  running: boolean;
}

export interface EngineEvents {
  onTick?: (tick: EngineTick) => void;
  onPhaseChange?: (phase: Phase, index: number) => void;
  onCycle?: (cycleCompleted: number) => void;
  onComplete?: (cyclesCompleted: number, durationSec: number) => void;
}

export interface EngineHandle {
  start: () => void;
  pause: () => void;
  resume: () => void;
  stop: () => void;
  skipPhase: () => void;
  isRunning: () => boolean;
  /** Force a re-render at the current state (useful on theme change). */
  invalidate: () => void;
  dispose: () => void;
}

interface InternalState {
  phases: Phase[];      // non-zero phases only
  phaseIndex: number;
  phaseStartMs: number;
  phasePauseAcc: number; // accumulated paused ms in current phase
  pausedAt: number | null;
  cycle: number;
  cyclesTotal: number;
  startMs: number;
  totalPauseAcc: number;
  startColor: RGB;
  endColor: RGB;
  running: boolean;
  rafId: number | null;
  disposed: boolean;
}

const SMALL_TEXT_SCALE = 0.045;
const LARGE_TEXT_SCALE = 0.15;

const isExpansion = (k: PhaseKind) => k === 'inhale' || k === 'hold-in';   // larger orb
const isContraction = (k: PhaseKind) => k === 'exhale' || k === 'hold-out'; // smaller orb

export interface CreateEngineOpts {
  canvas: HTMLCanvasElement;
  technique: Technique;
  themeMode: 'light' | 'dark';
  reducedMotion: boolean;
  events?: EngineEvents;
}

export function createEngine({
  canvas, technique, themeMode, reducedMotion, events,
}: CreateEngineOpts): EngineHandle {
  const ctx = canvas.getContext('2d', { alpha: true })!;

  const phases = technique.phases.filter((p) => p.durationSec > 0);
  const state: InternalState = {
    phases,
    phaseIndex: 0,
    phaseStartMs: 0,
    phasePauseAcc: 0,
    pausedAt: null,
    cycle: 0,
    cyclesTotal: technique.cycles,
    startMs: 0,
    totalPauseAcc: 0,
    startColor: { ...DEFAULT_ORB_COLOR },
    endColor: nextLavenderColor(),
    running: false,
    rafId: null,
    disposed: false,
  };

  let cvsW = 0, cvsH = 0;

  const resize = () => {
    const rect = canvas.getBoundingClientRect();
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    cvsW = Math.max(1, Math.floor(rect.width * dpr));
    cvsH = Math.max(1, Math.floor(rect.height * dpr));
    canvas.width = cvsW;
    canvas.height = cvsH;
  };

  const ro = new ResizeObserver(resize);
  ro.observe(canvas);
  resize();

  const onVisibility = () => {
    if (document.hidden && state.running) handle.pause();
  };
  document.addEventListener('visibilitychange', onVisibility);

  const advancePhase = () => {
    state.phaseIndex = (state.phaseIndex + 1) % state.phases.length;
    state.phaseStartMs = performance.now();
    state.phasePauseAcc = 0;
    state.startColor = { ...state.endColor };
    state.endColor = nextLavenderColor();
    if (state.phaseIndex === 0) {
      state.cycle++;
      events?.onCycle?.(state.cycle);
      if (state.cycle >= state.cyclesTotal) {
        const total = (performance.now() - state.startMs - state.totalPauseAcc) / 1000;
        finish(total);
        return;
      }
    }
    events?.onPhaseChange?.(state.phases[state.phaseIndex], state.phaseIndex);
  };

  const finish = (durationSec: number) => {
    state.running = false;
    if (state.rafId) cancelAnimationFrame(state.rafId);
    state.rafId = null;
    events?.onComplete?.(state.cycle, durationSec);
  };

  const draw = (e: number, phase: Phase, color: RGB) => {
    if (cvsW === 0) return;
    ctx.clearRect(0, 0, cvsW, cvsH);

    const n = cvsW / 2;       // center x = orb outer radius
    const l = cvsH / 2;       // center y

    const expanding   = isExpansion(phase.kind);   // hold-in or inhale → big inner
    const contracting = isContraction(phase.kind); // hold-out or exhale → small inner

    // outer radius is constant (= n); inner radius lerps between 0.8n (collapsed) and 0.2n (open)
    const innerStart = expanding   ? 0.8 * n : 0.2 * n;
    const innerEnd   = contracting ? 0.8 * n : 0.2 * n;
    const innerR     = innerStart + (innerEnd - innerStart) * e;

    // Ring outline radius (the thin tracking ring during inhale/exhale)
    const ringR = contracting ? 0.2 * n : 0.8 * n;

    drawDonut(ctx, n, l, n, innerR, { fillStyle: toCss(color) });

    if (phase.kind === 'inhale' || phase.kind === 'exhale') {
      // thin animated outline ring
      const stroke =
        phase.kind === 'exhale'
          ? toCss(color, 0.25)
          : themeMode === 'dark'
            ? 'rgba(0,0,0,0.12)'
            : 'rgba(255,255,255,0.4)';
      ctx.beginPath();
      ctx.arc(n, l, ringR, 0, Math.PI * 2);
      ctx.strokeStyle = stroke;
      ctx.lineWidth = 0.01 * cvsW;
      ctx.stroke();
    } else {
      // HOLD: pie sweep "draining" via destination-out
      const sweep = e > 0 ? -360 * (1 - e) : 0;
      ctx.globalCompositeOperation = 'destination-out';
      drawPie(
        ctx, n, l,
        n * (0.8 + e * 0.2),
        2 + n,
        -90, sweep,
        { fillStyle: lighten(color, 0.85) },
      );
      ctx.globalCompositeOperation = 'source-over';
    }
  };

  const tick = () => {
    if (!state.running) return;
    const now = performance.now();
    const phase = state.phases[state.phaseIndex];
    const phaseMs = phase.durationSec * 1000;
    const elapsed = now - state.phaseStartMs - state.phasePauseAcc;
    const e = Math.max(0, Math.min(1, elapsed / phaseMs));

    const color = lerpColor(state.startColor, state.endColor, e);

    if (!reducedMotion) draw(e, phase, color);

    const totalSec = (now - state.startMs - state.totalPauseAcc) / 1000;
    events?.onTick?.({
      phaseIndex: state.phaseIndex,
      phase,
      phaseProgress: e,
      cycle: state.cycle,
      cyclesTotal: state.cyclesTotal,
      elapsedSec: elapsed / 1000,
      totalSec,
      color,
      running: state.running,
    });

    if (elapsed >= phaseMs) {
      advancePhase();
    }
    if (state.running) state.rafId = requestAnimationFrame(tick);
  };

  const handle: EngineHandle = {
    start: () => {
      if (state.disposed) return;
      state.running = true;
      const now = performance.now();
      state.startMs = now;
      state.phaseStartMs = now;
      state.phasePauseAcc = 0;
      state.totalPauseAcc = 0;
      state.cycle = 0;
      state.phaseIndex = 0;
      state.startColor = { ...DEFAULT_ORB_COLOR };
      state.endColor = nextLavenderColor();
      events?.onPhaseChange?.(state.phases[0], 0);
      state.rafId = requestAnimationFrame(tick);
    },
    pause: () => {
      if (!state.running) return;
      state.running = false;
      state.pausedAt = performance.now();
      if (state.rafId) cancelAnimationFrame(state.rafId);
      state.rafId = null;
    },
    resume: () => {
      if (state.running || state.disposed || state.pausedAt == null) return;
      const pausedFor = performance.now() - state.pausedAt;
      state.phasePauseAcc += pausedFor;
      state.totalPauseAcc += pausedFor;
      state.pausedAt = null;
      state.running = true;
      state.rafId = requestAnimationFrame(tick);
    },
    stop: () => {
      state.running = false;
      if (state.rafId) cancelAnimationFrame(state.rafId);
      state.rafId = null;
      ctx.clearRect(0, 0, cvsW, cvsH);
    },
    skipPhase: () => {
      if (state.disposed) return;
      advancePhase();
      if (state.running && state.rafId == null) state.rafId = requestAnimationFrame(tick);
    },
    isRunning: () => state.running,
    invalidate: () => {
      if (state.rafId == null && state.phases.length) {
        const phase = state.phases[state.phaseIndex];
        draw(0, phase, state.startColor);
      }
    },
    dispose: () => {
      state.disposed = true;
      state.running = false;
      if (state.rafId) cancelAnimationFrame(state.rafId);
      ro.disconnect();
      document.removeEventListener('visibilitychange', onVisibility);
    },
  };

  // expose for debugging
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  if (typeof window !== 'undefined') (window as any).__niyamEngine = handle;

  return handle;
}

export { SMALL_TEXT_SCALE, LARGE_TEXT_SCALE };
