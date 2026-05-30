'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import { Check } from 'lucide-react';
import { TopBar } from '@/components/nav/TopBar';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { techniqueById } from '@/features/breathing/techniques';
import { usePlansStore } from '@/stores/plans.store';
import type { Plan } from '@/lib/types';
import { useHydrated } from '@/stores/StoreHydrator';

export function PlanDetailClient({ plan }: { plan: Plan }) {
  const hydrated = useHydrated();
  const active = usePlansStore((s) => s.active);
  const completed = usePlansStore((s) => s.completed[plan.id] ?? []);
  const start = usePlansStore((s) => s.startPlan);

  const isActive = hydrated && active?.planId === plan.id;

  return (
    <>
      <TopBar title={plan.title} back="/plans" />
      <main className="mx-auto max-w-3xl px-5 pt-4 pb-32">
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
          className={`rounded-xl p-8 bg-gradient-to-br ${plan.cover} border border-white/20 mb-6`}
        >
          <h1 className="text-display text-4xl tracking-tight">{plan.title}</h1>
          <p className="text-foreground-soft mt-2">{plan.subtitle}</p>
          {!isActive && (
            <Button className="mt-6" onClick={() => start(plan.id)}>Start plan</Button>
          )}
        </motion.div>

        <ol className="space-y-2">
          {plan.days.map((d, i) => {
            const t = techniqueById(d.techniqueId);
            const done = completed.includes(i);
            return (
              <motion.li
                key={i}
                initial={{ opacity: 0, x: -8 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: i * 0.02, duration: 0.3 }}
              >
                <Card className="p-4 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div className={
                      'h-8 w-8 rounded-full grid place-items-center text-xs font-medium ' +
                      (done ? 'bg-primary text-white' : 'bg-foreground/5 text-foreground-soft')
                    }>
                      {done ? <Check size={14} /> : i + 1}
                    </div>
                    <div>
                      <p className="text-sm font-medium">Day {i + 1} · {t?.name}</p>
                      <p className="text-xs text-foreground-soft">{d.cycles} cycles · {t?.pattern}</p>
                    </div>
                  </div>
                  <Link
                    href={`/session/${d.techniqueId}`}
                    className="text-sm text-primary-strong dark:text-primary-soft hover:underline"
                  >
                    Begin →
                  </Link>
                </Card>
              </motion.li>
            );
          })}
        </ol>
      </main>
    </>
  );
}
