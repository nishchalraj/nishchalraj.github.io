'use client';

import { motion } from 'framer-motion';
import { TopBar } from '@/components/nav/TopBar';
import { Card } from '@/components/ui/Card';
import { useSessionsStore } from '@/stores/sessions.store';
import { useStreakStore } from '@/stores/streak.store';
import { useMoodStore } from '@/stores/mood.store';
import { useHydrated } from '@/stores/StoreHydrator';
import { todayKey, addDays } from '@/lib/date';

const moodScore: Record<string, number> = {
  sad: 1, anxious: 2, neutral: 3, calm: 4, energetic: 5,
};

export default function InsightsPage() {
  const hydrated = useHydrated();
  const history = useSessionsStore((s) => s.history);
  const totalMinutes = useSessionsStore((s) => s.totalMinutes());
  const streak = useStreakStore((s) => s.current);
  const best = useStreakStore((s) => s.best);
  const completedDays = useStreakStore((s) => s.completedDays);
  const moods = useMoodStore((s) => s.logs);

  // Build a 7×8 heatmap (last 56 days), oldest top-left.
  const today = todayKey();
  const grid: { key: string; intensity: number }[] = [];
  for (let i = 55; i >= 0; i--) {
    const k = addDays(today, -i);
    const count = hydrated ? history.filter((r) => r.day === k).length : 0;
    const completed = hydrated ? completedDays.includes(k) : false;
    grid.push({ key: k, intensity: completed ? Math.min(4, 1 + count) : 0 });
  }

  // Last 30 days mood line
  const moodLine: { day: string; v: number }[] = [];
  for (let i = 29; i >= 0; i--) {
    const k = addDays(today, -i);
    const recs = moods.filter((m) => m.day === k);
    const v = recs.length ? recs.reduce((s, m) => s + moodScore[m.mood], 0) / recs.length : 0;
    moodLine.push({ day: k, v });
  }
  const W = 300, H = 64;
  const pts = moodLine.map((p, i) => {
    const x = (i / (moodLine.length - 1)) * W;
    const y = p.v ? H - ((p.v - 1) / 4) * (H - 8) - 4 : H / 2;
    return `${x.toFixed(1)},${y.toFixed(1)}`;
  }).join(' ');

  return (
    <>
      <TopBar title="Insights" />
      <main className="mx-auto max-w-3xl px-5 pt-2 pb-32 space-y-5">
        <motion.section
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
          className="grid grid-cols-3 gap-3"
        >
          {[
            { label: 'Streak',    value: hydrated ? streak : 0,        suffix: 'days' },
            { label: 'Best',      value: hydrated ? best : 0,           suffix: 'days' },
            { label: 'Minutes',   value: hydrated ? totalMinutes : 0,  suffix: 'total' },
          ].map((s, i) => (
            <Card key={i} className="p-4 text-center">
              <p className="text-display text-3xl tracking-tight">{s.value}</p>
              <p className="text-[10px] uppercase tracking-wider text-foreground-soft mt-1">
                {s.label} · {s.suffix}
              </p>
            </Card>
          ))}
        </motion.section>

        <Card className="p-6">
          <p className="text-xs uppercase tracking-wider text-foreground-soft mb-4">Last 8 weeks</p>
          <div className="grid grid-cols-8 gap-1.5">
            {grid.map((c, i) => (
              <div
                key={c.key}
                title={`${c.key}${c.intensity ? ` · ${c.intensity} session${c.intensity > 1 ? 's' : ''}` : ''}`}
                className="aspect-square rounded-sm transition-colors"
                style={{
                  background:
                    c.intensity === 0 ? 'rgb(var(--foreground) / 0.07)'
                    : c.intensity === 1 ? 'rgb(var(--primary) / 0.35)'
                    : c.intensity === 2 ? 'rgb(var(--primary) / 0.55)'
                    : c.intensity === 3 ? 'rgb(var(--primary) / 0.75)'
                    : 'rgb(var(--primary) / 0.95)',
                  opacity: hydrated ? 1 : 0.4,
                  transitionDelay: `${i * 6}ms`,
                }}
              />
            ))}
          </div>
        </Card>

        <Card className="p-6">
          <p className="text-xs uppercase tracking-wider text-foreground-soft mb-2">Mood · 30 days</p>
          <svg viewBox={`0 0 ${W} ${H}`} className="w-full h-16" aria-label="Mood line">
            <polyline
              fill="none"
              stroke="rgb(var(--primary))"
              strokeWidth="1.6"
              strokeLinecap="round"
              strokeLinejoin="round"
              points={pts}
            />
          </svg>
          <div className="flex justify-between text-[10px] text-foreground-soft mt-2 uppercase tracking-wider">
            <span>sad</span>
            <span>neutral</span>
            <span>energetic</span>
          </div>
        </Card>
      </main>
    </>
  );
}
