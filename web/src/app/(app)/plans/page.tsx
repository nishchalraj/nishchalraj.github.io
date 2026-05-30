'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import { TopBar } from '@/components/nav/TopBar';
import { Card } from '@/components/ui/Card';
import { PLANS } from '@/content/plans';
import { usePlansStore } from '@/stores/plans.store';
import { useHydrated } from '@/stores/StoreHydrator';

export default function PlansPage() {
  const hydrated = useHydrated();
  const active = usePlansStore((s) => s.active);
  const completed = usePlansStore((s) => s.completed);

  return (
    <>
      <TopBar title="Plans" />
      <main className="mx-auto max-w-3xl px-5 pt-2 pb-32">
        <p className="text-foreground-soft text-sm">
          Multi-day programs to build the habit one breath at a time.
        </p>
        <div className="mt-6 grid gap-4">
          {PLANS.map((p, i) => {
            const isActive = hydrated && active?.planId === p.id;
            const done = hydrated ? (completed[p.id] ?? []).length : 0;
            return (
              <motion.div
                key={p.id}
                initial={{ opacity: 0, y: 12 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.05, duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
              >
                <Link href={`/plans/${p.id}`}>
                  <Card className={`p-6 relative overflow-hidden bg-gradient-to-br ${p.cover} border border-white/20`}>
                    {isActive && (
                      <span className="absolute top-4 right-4 text-[10px] uppercase tracking-wider bg-white/85 text-primary-strong px-2 py-1 rounded-full">
                        Active
                      </span>
                    )}
                    <h3 className="text-display text-2xl tracking-tight text-foreground">{p.title}</h3>
                    <p className="text-sm text-foreground-soft mt-1">{p.subtitle}</p>
                    <div className="mt-5 h-1.5 rounded-full bg-foreground/10 overflow-hidden">
                      <div
                        className="h-full bg-primary transition-all duration-slow ease-soft-out"
                        style={{ width: `${(done / p.days.length) * 100}%` }}
                      />
                    </div>
                    <p className="text-xs text-foreground-soft mt-2">
                      {done} of {p.days.length} days
                    </p>
                  </Card>
                </Link>
              </motion.div>
            );
          })}
        </div>
      </main>
    </>
  );
}
