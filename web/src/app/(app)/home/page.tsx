'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import { Sparkles, Flame, ArrowRight } from 'lucide-react';
import { TopBar } from '@/components/nav/TopBar';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { CalendarStrip } from '@/components/calendar/CalendarStrip';
import { TECHNIQUES } from '@/features/breathing/techniques';
import { usePrefsStore } from '@/stores/prefs.store';
import { useSessionsStore } from '@/stores/sessions.store';
import { useStreakStore } from '@/stores/streak.store';
import { useMoodStore } from '@/stores/mood.store';
import { greetingFor } from '@/lib/date';
import { useHydrated } from '@/stores/StoreHydrator';

export default function HomePage() {
  const hydrated = useHydrated();
  const name = usePrefsStore((s) => s.name);
  const goal = usePrefsStore((s) => s.goal);
  const streak = useStreakStore((s) => s.current);
  const completedDays = useStreakStore((s) => s.completedDays);
  const lastTechniqueId = useSessionsStore((s) => s.lastTechniqueId);
  const todayMood = useMoodStore((s) => s.todayMood());

  // Recommended = first 4 in current goal category, falling back to all.
  const recommended = TECHNIQUES.filter((t) => t.category === goal || true).slice(0, 4);
  const featured = lastTechniqueId
    ? TECHNIQUES.find((t) => t.id === lastTechniqueId) ?? recommended[0]
    : recommended[0];

  return (
    <>
      <TopBar />
      <main className="mx-auto max-w-3xl px-5 pt-2 pb-32">
        {/* Greeting */}
        <motion.section
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
          className="pt-2"
        >
          <p className="text-sm text-foreground-soft">{greetingFor()}{hydrated && name ? `, ${name}` : ''} 🌿</p>
          <h2 className="text-display text-4xl tracking-tight mt-1">
            Find your <span className="text-primary-strong">calm</span>.
          </h2>
        </motion.section>

        {/* Calendar strip */}
        <section className="mt-6">
          <CalendarStrip completedDays={completedDays} />
        </section>

        {/* Streak + Mood quick row */}
        <section className="mt-5 grid grid-cols-2 gap-3">
          <Card className="p-5 relative overflow-hidden">
            <div className="absolute -right-6 -top-6 h-24 w-24 rounded-full bg-primary/15 blur-2xl" aria-hidden />
            <div className="flex items-center gap-2 text-primary-strong dark:text-primary-soft">
              <Flame size={16} />
              <span className="text-xs uppercase tracking-wider">Streak</span>
            </div>
            <p className="text-display text-4xl tracking-tight mt-1">
              {hydrated ? streak : 0}<span className="text-base text-foreground-soft ml-1">days</span>
            </p>
          </Card>
          <Link href="/mood" className="group">
            <Card className="p-5 h-full hover:bg-primary-soft/15 transition-colors">
              <div className="text-xs uppercase tracking-wider text-foreground-soft">
                {hydrated && todayMood ? "Today's mood" : 'How do you feel?'}
              </div>
              <p className="text-display text-2xl tracking-tight mt-1 capitalize">
                {hydrated && todayMood ? todayMood.mood : 'Check in →'}
              </p>
            </Card>
          </Link>
        </section>

        {/* Featured "today" session */}
        {featured && (
          <motion.section
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1, duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
            className="mt-5"
          >
            <Card className="p-6 relative overflow-hidden bg-gradient-to-br from-primary via-primary-strong to-primary-soft text-white border-0">
              <motion.div
                aria-hidden
                className="absolute -top-12 -right-12 h-48 w-48 rounded-full bg-white/15 blur-3xl"
                animate={{ scale: [1, 1.15, 1] }}
                transition={{ duration: 6, repeat: Infinity, ease: 'easeInOut' }}
              />
              <p className="text-xs uppercase tracking-[0.18em] opacity-80">For you today</p>
              <h3 className="text-display text-3xl tracking-tight mt-2">{featured.name}</h3>
              <p className="text-sm opacity-90 mt-1">{featured.tagline} · {featured.cycles} cycles</p>
              <Button asChild variant="secondary" size="md" className="mt-5 bg-white text-primary-strong hover:bg-white/90">
                <Link href={`/session/${featured.id}`}>
                  Start <ArrowRight size={16} />
                </Link>
              </Button>
            </Card>
          </motion.section>
        )}

        {/* Recommended grid */}
        <section className="mt-6">
          <div className="flex items-center justify-between mb-3">
            <h3 className="text-display text-xl tracking-tight">Recommended</h3>
            <Link href="/techniques" className="text-sm text-primary-strong dark:text-primary-soft hover:underline">
              All techniques →
            </Link>
          </div>
          <div className="grid grid-cols-2 gap-3">
            {recommended.map((t, i) => (
              <motion.div
                key={t.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.15 + i * 0.05, duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
              >
                <Link href={`/techniques/${t.id}`}>
                  <Card className="p-4 h-full hover:border-primary/30 hover:shadow-raised transition-all">
                    <div className="flex items-start justify-between">
                      <Sparkles size={16} className="text-primary-strong/70" />
                      <span className="text-[10px] font-mono text-foreground-soft">{t.pattern}</span>
                    </div>
                    <p className="text-display text-xl tracking-tight mt-3">{t.name}</p>
                    <p className="text-xs text-foreground-soft mt-1">{t.tagline}</p>
                  </Card>
                </Link>
              </motion.div>
            ))}
          </div>
        </section>
      </main>
    </>
  );
}
