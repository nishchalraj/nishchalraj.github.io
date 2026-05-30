'use client';

import { motion } from 'framer-motion';
import { useState, useEffect } from 'react';
import { TopBar } from '@/components/nav/TopBar';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { useAudio } from '@/features/audio/AudioProvider';
import { SOUNDS } from '@/features/audio/manifest';
import type { SoundId } from '@/lib/types';
import { Pause, Play } from 'lucide-react';

const TIMERS = [
  { label: '5 min',  sec: 5 * 60 },
  { label: '10 min', sec: 10 * 60 },
  { label: '20 min', sec: 20 * 60 },
  { label: '∞',      sec: 0 },
];

export default function SoundsPage() {
  const audio = useAudio();
  const [duration, setDuration] = useState(0);
  const [remaining, setRemaining] = useState(0);

  useEffect(() => {
    if (!duration || !audio.current) return;
    setRemaining(duration);
    const t = setInterval(() => {
      setRemaining((s) => {
        if (s <= 1) {
          clearInterval(t);
          audio.stop();
          return 0;
        }
        return s - 1;
      });
    }, 1000);
    return () => clearInterval(t);
  }, [duration, audio]);

  const fmt = (s: number) => `${Math.floor(s / 60)}:${String(s % 60).padStart(2, '0')}`;

  return (
    <>
      <TopBar title="Soundscapes" />
      <main className="mx-auto max-w-3xl px-5 pt-2 pb-32">
        <p className="text-foreground-soft text-sm">
          Layer one under your breath, or just sit and listen.
        </p>

        <div className="mt-6 grid gap-3 grid-cols-2 sm:grid-cols-3">
          {SOUNDS.map((s, i) => {
            const active = audio.current === s.id;
            return (
              <motion.div
                key={s.id}
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: i * 0.04, duration: 0.4 }}
              >
                <button
                  onClick={() => (active ? audio.stop() : audio.play(s.id as SoundId))}
                  className={
                    'w-full text-left rounded-xl p-5 transition-all duration-base border ' +
                    (active
                      ? 'bg-primary text-white border-primary shadow-raised'
                      : 'bg-surface-alt/60 border-foreground/5 hover:border-primary/40')
                  }
                >
                  <div className="flex items-start justify-between">
                    <span className="text-display text-xl tracking-tight">{s.label}</span>
                    <span className={
                      'h-9 w-9 rounded-full grid place-items-center ' +
                      (active ? 'bg-white/20' : 'bg-primary-soft/30')
                    }>
                      {active ? <Pause size={14} /> : <Play size={14} />}
                    </span>
                  </div>
                  <p className={'text-xs mt-3 ' + (active ? 'text-white/85' : 'text-foreground-soft')}>
                    {s.description}
                  </p>
                </button>
              </motion.div>
            );
          })}
        </div>

        {audio.current && (
          <Card className="mt-8 p-5">
            <p className="text-xs uppercase tracking-wider text-foreground-soft">Timer</p>
            <div className="mt-3 flex flex-wrap gap-2">
              {TIMERS.map((t) => (
                <Button
                  key={t.label}
                  variant={duration === t.sec ? 'primary' : 'outline'}
                  size="sm"
                  onClick={() => setDuration(t.sec)}
                >
                  {t.label}
                </Button>
              ))}
            </div>
            {duration > 0 && (
              <p className="text-display text-4xl tabular-nums tracking-tight mt-4">
                {fmt(remaining)}
              </p>
            )}
          </Card>
        )}

        <Card className="mt-6 p-5">
          <p className="text-xs uppercase tracking-wider text-foreground-soft">Volume</p>
          <input
            type="range" min={0} max={1} step={0.01}
            value={audio.volume}
            onChange={(e) => audio.setVolume(+e.target.value)}
            className="w-full mt-3 accent-primary"
          />
        </Card>
      </main>
    </>
  );
}
