'use client';

import { motion } from 'framer-motion';
import Link from 'next/link';
import { Button } from '@/components/ui/Button';
import { ArrowRight } from 'lucide-react';

export function Hero() {
  return (
    <section className="relative overflow-hidden">
      {/* Animated background orbs */}
      <div className="pointer-events-none absolute inset-0 -z-10">
        <motion.div
          aria-hidden
          className="absolute -top-32 -right-24 h-[520px] w-[520px] rounded-full bg-gradient-to-tr from-primary/30 to-primary-soft/40 blur-3xl"
          animate={{ scale: [1, 1.08, 1], opacity: [0.7, 1, 0.7] }}
          transition={{ duration: 10, repeat: Infinity, ease: 'easeInOut' }}
        />
        <motion.div
          aria-hidden
          className="absolute -bottom-40 -left-24 h-[480px] w-[480px] rounded-full bg-gradient-to-tr from-primary-soft/30 to-primary/20 blur-3xl"
          animate={{ scale: [1, 1.06, 1], opacity: [0.6, 0.9, 0.6] }}
          transition={{ duration: 12, repeat: Infinity, ease: 'easeInOut', delay: 2 }}
        />
      </div>

      <div className="mx-auto max-w-6xl px-5 pt-20 pb-24 sm:pt-28 sm:pb-32 grid gap-12 lg:grid-cols-2 lg:items-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
        >
          <p className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-primary-soft/30 text-primary-strong dark:text-primary-soft text-xs tracking-wide uppercase font-medium">
            <span className="block h-1.5 w-1.5 rounded-full bg-primary animate-pulse" />
            niyam · breathe with discipline
          </p>
          <h1 className="mt-6 text-display text-5xl sm:text-6xl lg:text-7xl leading-[1.02] tracking-tight text-balance">
            Build a daily breath{' '}
            <span className="bg-gradient-to-r from-primary via-primary-strong to-primary bg-clip-text text-transparent">
              routine
            </span>{' '}
            that sticks.
          </h1>
          <p className="mt-6 text-lg text-foreground-soft max-w-xl text-balance">
            Seven calming techniques, mood check-ins, soundscapes, and gentle streaks —
            in a quiet app that feels nothing like a productivity tool.
          </p>
          <div className="mt-9 flex flex-wrap items-center gap-3">
            <Button asChild size="lg">
              <Link href="/home">Start breathing <ArrowRight size={18} /></Link>
            </Button>
            <Button asChild variant="ghost" size="lg">
              <Link href="/techniques">See techniques</Link>
            </Button>
          </div>
          <p className="mt-4 text-xs text-foreground-soft/70">
            Works offline · no account · honors reduced-motion
          </p>
        </motion.div>

        {/* Hero orb (presentation only — non-interactive CSS animation) */}
        <motion.div
          initial={{ opacity: 0, scale: 0.92 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.9, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
          className="relative mx-auto aspect-square w-full max-w-[480px]"
        >
          <div className="absolute inset-0 grid place-items-center">
            <motion.div
              className="h-[88%] w-[88%] rounded-full bg-gradient-to-br from-primary/45 via-primary-soft/30 to-primary/20 shadow-floating"
              animate={{ scale: [0.78, 1, 0.78] }}
              transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
            />
          </div>
          <div className="absolute inset-0 grid place-items-center">
            <motion.div
              className="h-[60%] w-[60%] rounded-full bg-gradient-to-br from-primary to-primary-strong shadow-raised"
              animate={{ scale: [0.92, 1.05, 0.92], opacity: [0.85, 1, 0.85] }}
              transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut', delay: 0.6 }}
            />
          </div>
          <div className="absolute inset-0 grid place-items-center text-white/95">
            <div className="text-center">
              <p className="text-display text-3xl tracking-tight">Inhale</p>
              <p className="text-xs uppercase tracking-[0.2em] mt-1 opacity-80">4 · 7 · 8</p>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
