'use client';

import { useEffect, useMemo, useState } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { Pause, Play, SkipForward, X, Volume2 } from 'lucide-react';
import { BreathingOrb } from '@/features/breathing/BreathingOrb';
import { techniqueById, makeCustomTechnique } from '@/features/breathing/techniques';
import { Button } from '@/components/ui/Button';
import { useSessionsStore } from '@/stores/sessions.store';
import { useStreakStore } from '@/stores/streak.store';
import { usePrefsStore } from '@/stores/prefs.store';
import { useAudio } from '@/features/audio/AudioProvider';
import type { Technique, SoundId } from '@/lib/types';
import { SOUNDS } from '@/features/audio/manifest';

const COUNTDOWN_STEPS = ['Ready', '3', '2', '1', 'Breathe'];

export function SessionPlayerClient({ techniqueId }: { techniqueId: string }) {
  const router = useRouter();
  const search = useSearchParams();
  const logSession = useSessionsStore((s) => s.logSession);
  const recordStreak = useStreakStore((s) => s.recordSession);
  const defaultSound = usePrefsStore((s) => s.defaultSound);
  const audio = useAudio();

  const [phase, setPhase] = useState<'countdown' | 'running' | 'done'>('countdown');
  const [countdownIdx, setCountdownIdx] = useState(0);
  const [running, setRunning] = useState(true);
  const [completed, setCompleted] = useState(0);
  const [sound, setSound] = useState<SoundId>(defaultSound);
  const [soundOpen, setSoundOpen] = useState(false);
  const startedAtRef = useState(Date.now())[0];

  const technique: Technique | null = useMemo(() => {
    if (techniqueId === 'custom') {
      const i  = Number(search.get('i')  ?? 4);
      const h1 = Number(search.get('h1') ?? 4);
      const e  = Number(search.get('e')  ?? 4);
      const h2 = Number(search.get('h2') ?? 4);
      const c  = Number(search.get('c')  ?? 8);
      return makeCustomTechnique(i, h1, e, h2, c);
    }
    return techniqueById(techniqueId) ?? null;
  }, [techniqueId, search]);

  // 4-step countdown
  useEffect(() => {
    if (phase !== 'countdown') return;
    const t = setInterval(() => {
      setCountdownIdx((i) => {
        const next = i + 1;
        if (next >= COUNTDOWN_STEPS.length) {
          setPhase('running');
          return i;
        }
        return next;
      });
    }, 900);
    return () => clearInterval(t);
  }, [phase]);

  // Auto-start chosen soundscape (gesture-gated by AudioProvider)
  useEffect(() => {
    if (sound !== 'none') void audio.play(sound);
    return () => { audio.stop(); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sound]);

  if (!technique) return null;

  const finish = (cycles: number) => {
    const durationSec = Math.round((Date.now() - startedAtRef) / 1000);
    logSession({
      techniqueId: technique.id,
      startedAt: startedAtRef,
      durationSec,
      cyclesCompleted: cycles,
      completed: cycles >= technique.cycles,
    });
    recordStreak();
    setPhase('done');
    audio.stop();
  };

  const exit = () => {
    audio.stop();
    router.replace('/home');
  };

  return (
    <main className="fixed inset-0 z-50 bg-surface text-foreground overflow-hidden">
      {/* Ambient halo */}
      <motion.div
        aria-hidden
        className="absolute inset-0 -z-10"
        animate={{ background: [
          'radial-gradient(ellipse at center, rgba(167,139,250,0.20), transparent 60%)',
          'radial-gradient(ellipse at center, rgba(196,181,253,0.28), transparent 60%)',
          'radial-gradient(ellipse at center, rgba(167,139,250,0.20), transparent 60%)',
        ] }}
        transition={{ duration: 12, repeat: Infinity, ease: 'easeInOut' }}
      />

      {/* Header */}
      <header className="absolute top-0 inset-x-0 flex items-center justify-between px-5 py-4 z-10">
        <button
          onClick={exit}
          className="h-10 w-10 grid place-items-center rounded-full bg-foreground/5 hover:bg-foreground/10"
          aria-label="Exit session"
        >
          <X size={18} />
        </button>
        <div className="text-center">
          <p className="text-xs uppercase tracking-[0.18em] text-foreground-soft">{technique.category}</p>
          <p className="text-display text-lg tracking-tight">{technique.name}</p>
        </div>
        <button
          onClick={() => setSoundOpen((v) => !v)}
          className={'h-10 w-10 grid place-items-center rounded-full transition-colors ' +
            (sound !== 'none' ? 'bg-primary text-white' : 'bg-foreground/5 hover:bg-foreground/10')}
          aria-label="Choose soundscape"
        >
          <Volume2 size={18} />
        </button>
      </header>

      {/* Soundscape sheet */}
      <AnimatePresence>
        {soundOpen && (
          <motion.div
            initial={{ y: -8, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: -8, opacity: 0 }}
            className="absolute top-[68px] right-4 z-30 w-56 rounded-xl bg-surface-alt shadow-floating border border-foreground/10 p-3"
          >
            <p className="text-xs text-foreground-soft mb-2 px-1">Soundscape</p>
            <div className="space-y-1">
              <button
                onClick={() => { setSound('none'); setSoundOpen(false); }}
                className={'w-full text-left px-3 py-2 text-sm rounded-md ' +
                  (sound === 'none' ? 'bg-primary-soft/40' : 'hover:bg-foreground/5')}
              >
                None
              </button>
              {SOUNDS.map((s) => (
                <button
                  key={s.id}
                  onClick={() => { setSound(s.id); setSoundOpen(false); }}
                  className={'w-full text-left px-3 py-2 text-sm rounded-md ' +
                    (sound === s.id ? 'bg-primary-soft/40' : 'hover:bg-foreground/5')}
                >
                  {s.label}
                </button>
              ))}
            </div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Content */}
      <div className="h-full grid place-items-center">
        {phase === 'countdown' && (
          <AnimatePresence mode="wait">
            <motion.div
              key={countdownIdx}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 1.1 }}
              transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
              className="text-display text-7xl sm:text-8xl tracking-tight"
            >
              {COUNTDOWN_STEPS[countdownIdx]}
            </motion.div>
          </AnimatePresence>
        )}

        {phase === 'running' && (
          <BreathingOrb
            technique={technique}
            autoStart={running}
            onCycle={(c) => setCompleted(c)}
            onComplete={(c) => finish(c)}
          />
        )}

        {phase === 'done' && (
          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
            className="text-center px-6"
          >
            <p className="text-display text-5xl tracking-tight">Well done.</p>
            <p className="text-foreground-soft mt-3">
              {completed} {completed === 1 ? 'cycle' : 'cycles'} of {technique.name}. Your streak grew.
            </p>
            <div className="mt-8 flex flex-wrap gap-3 justify-center">
              <Button onClick={() => router.replace('/mood')}>How do you feel?</Button>
              <Button variant="ghost" onClick={() => router.replace('/home')}>Home</Button>
            </div>
          </motion.div>
        )}
      </div>

      {/* Controls */}
      {phase === 'running' && (
        <div className="absolute bottom-8 inset-x-0 flex items-center justify-center gap-3 px-6">
          <button
            onClick={() => setRunning((r) => !r)}
            className="h-14 w-14 rounded-full bg-primary text-white grid place-items-center shadow-raised hover:bg-primary-strong transition-colors active:scale-95"
            aria-label={running ? 'Pause' : 'Resume'}
          >
            {running ? <Pause size={20} /> : <Play size={20} />}
          </button>
          <button
            onClick={() => finish(completed)}
            className="h-12 px-5 rounded-full bg-foreground/5 hover:bg-foreground/10 text-sm transition-colors"
          >
            End session
          </button>
          <button
            onClick={() => {
              // skip via a custom event the engine could listen to — but the simplest UX is to advance completed count
              // For now we just trigger early finish if at last cycle
            }}
            className="h-14 w-14 rounded-full bg-foreground/5 hover:bg-foreground/10 grid place-items-center transition-colors"
            aria-label="Skip phase"
            title="Skip phase"
          >
            <SkipForward size={18} />
          </button>
        </div>
      )}
    </main>
  );
}
