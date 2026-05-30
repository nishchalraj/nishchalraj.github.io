'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { TopBar } from '@/components/nav/TopBar';
import { Button } from '@/components/ui/Button';
import { useMoodStore } from '@/stores/mood.store';
import type { MoodKind } from '@/lib/types';
import { cn } from '@/lib/cn';

const MOODS: { id: MoodKind; label: string; emoji: string; angle: number }[] = [
  { id: 'calm',      label: 'Calm',      emoji: '🌿', angle: -90 },
  { id: 'energetic', label: 'Energetic', emoji: '⚡', angle: -18 },
  { id: 'neutral',   label: 'Neutral',   emoji: '🌤', angle: 54 },
  { id: 'anxious',   label: 'Anxious',   emoji: '🌊', angle: 126 },
  { id: 'sad',       label: 'Sad',       emoji: '🌧', angle: 198 },
];

export default function MoodPage() {
  const [selected, setSelected] = useState<MoodKind | null>(null);
  const [note, setNote] = useState('');
  const log = useMoodStore((s) => s.log);
  const router = useRouter();

  const save = () => {
    if (!selected) return;
    log(selected, note.trim() || undefined);
    router.push('/home');
  };

  return (
    <>
      <TopBar title="How do you feel?" back="/home" />
      <main className="mx-auto max-w-md px-5 pt-4 pb-32">
        <p className="text-foreground-soft text-sm">
          A quick check-in. Tap the feeling closest to right now.
        </p>

        <div className="relative mx-auto mt-10 aspect-square w-full max-w-[360px]">
          {/* Soft outer ring */}
          <motion.div
            className="absolute inset-0 rounded-full bg-gradient-to-br from-primary-soft/20 to-primary/15"
            animate={{ rotate: 360 }}
            transition={{ duration: 80, repeat: Infinity, ease: 'linear' }}
          />
          <div className="absolute inset-6 rounded-full border border-foreground/10" />
          <div className="absolute inset-16 rounded-full bg-surface/80 backdrop-blur-md shadow-card grid place-items-center">
            <div className="text-center">
              <motion.div
                key={selected ?? 'idle'}
                initial={{ opacity: 0, scale: 0.85 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ duration: 0.35, ease: [0.16, 1, 0.3, 1] }}
                className="text-display text-3xl tracking-tight capitalize"
              >
                {selected ?? 'Tap'}
              </motion.div>
              <p className="text-xs text-foreground-soft mt-1">your mood</p>
            </div>
          </div>

          {/* Mood pips around the dial */}
          {MOODS.map((m) => {
            const rad = (m.angle * Math.PI) / 180;
            const r = 44;
            const x = 50 + r * Math.cos(rad);
            const y = 50 + r * Math.sin(rad);
            const active = selected === m.id;
            return (
              <button
                key={m.id}
                onClick={() => setSelected(m.id)}
                style={{ left: `${x}%`, top: `${y}%` }}
                className={cn(
                  'absolute -translate-x-1/2 -translate-y-1/2 h-16 w-16 rounded-full grid place-items-center transition-all duration-base ease-soft-out',
                  active
                    ? 'bg-primary text-white scale-110 shadow-raised'
                    : 'bg-surface-alt/80 hover:bg-primary-soft/40 hover:scale-105',
                )}
                aria-pressed={active}
                aria-label={m.label}
              >
                <span className="text-2xl">{m.emoji}</span>
              </button>
            );
          })}
        </div>

        <textarea
          value={note}
          onChange={(e) => setNote(e.target.value)}
          placeholder="A short note? (optional)"
          rows={3}
          className="mt-6 w-full bg-surface-alt/60 border border-foreground/10 rounded-xl px-4 py-3 text-sm focus:border-primary outline-none resize-none transition-colors"
        />

        <Button disabled={!selected} size="lg" className="mt-5 w-full" onClick={save}>
          Save check-in
        </Button>
      </main>
    </>
  );
}
