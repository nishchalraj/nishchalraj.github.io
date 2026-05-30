'use client';

import Link from 'next/link';
import { useState } from 'react';
import { motion } from 'framer-motion';
import { TopBar } from '@/components/nav/TopBar';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { TECHNIQUES } from '@/features/breathing/techniques';
import { cn } from '@/lib/cn';
import { Sliders } from 'lucide-react';

export default function TechniquesPage() {
  const [tab, setTab] = useState<'guided' | 'custom'>('guided');
  return (
    <>
      <TopBar title="Techniques" />
      <main className="mx-auto max-w-3xl px-5 pt-2 pb-32">
        <div className="flex gap-1 p-1 bg-surface-alt/60 rounded-lg w-fit">
          {(['guided', 'custom'] as const).map((t) => (
            <button
              key={t}
              onClick={() => setTab(t)}
              className={cn(
                'relative px-4 py-2 text-sm rounded-md transition-colors',
                tab === t ? 'text-foreground' : 'text-foreground-soft hover:text-foreground',
              )}
            >
              {tab === t && (
                <motion.span
                  layoutId="tab-tech"
                  className="absolute inset-0 bg-surface shadow-card rounded-md -z-10"
                  transition={{ type: 'spring', stiffness: 360, damping: 32 }}
                />
              )}
              {t === 'guided' ? 'Guided' : 'Custom'}
            </button>
          ))}
        </div>

        {tab === 'guided' && (
          <section className="mt-6 grid gap-3 sm:grid-cols-2">
            {TECHNIQUES.map((t, i) => (
              <motion.div
                key={t.id}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.04, duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
              >
                <Link href={`/techniques/${t.id}`}>
                  <Card className="p-5 h-full hover:border-primary/30 hover:shadow-raised transition-all group">
                    <div className="flex items-start justify-between mb-3">
                      <span className="text-xs uppercase tracking-wider text-primary-strong dark:text-primary-soft">
                        {t.category}
                      </span>
                      <span className="font-mono text-xs text-foreground-soft">{t.pattern}</span>
                    </div>
                    <div className="aspect-square w-full max-w-[112px] mx-auto relative grid place-items-center mb-3">
                      <motion.div
                        className="absolute h-20 w-20 rounded-full bg-gradient-to-br from-primary/40 to-primary-soft/30"
                        animate={{ scale: [0.75, 1, 0.75] }}
                        transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}
                      />
                      <div className="relative h-12 w-12 rounded-full bg-primary group-hover:scale-110 transition-transform duration-base" />
                    </div>
                    <p className="text-display text-xl tracking-tight">{t.name}</p>
                    <p className="text-xs text-foreground-soft mt-1">{t.tagline}</p>
                  </Card>
                </Link>
              </motion.div>
            ))}
          </section>
        )}

        {tab === 'custom' && (
          <section className="mt-6">
            <Card className="p-8 text-center">
              <Sliders className="mx-auto text-primary mb-4" size={32} />
              <h3 className="text-display text-2xl tracking-tight">Build your own</h3>
              <p className="text-sm text-foreground-soft mt-2">
                Slide your own inhale, hold, exhale, and second hold. Pick cycles. Run it.
              </p>
              <Button asChild className="mt-6">
                <Link href="/techniques/custom">Open builder</Link>
              </Button>
            </Card>
          </section>
        )}
      </main>
    </>
  );
}
