'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import { Play } from 'lucide-react';
import { TopBar } from '@/components/nav/TopBar';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import type { Technique } from '@/lib/types';

export function TechniqueDetailClient({ technique }: { technique: Technique }) {
  return (
    <>
      <TopBar title={technique.name} back="/techniques" />
      <main className="mx-auto max-w-2xl px-5 pt-4 pb-32">
        <motion.section
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
        >
          <p className="text-xs uppercase tracking-[0.18em] text-primary-strong dark:text-primary-soft">
            {technique.category} · {technique.pattern}
          </p>
          <h1 className="text-display text-5xl tracking-tight mt-2">{technique.name}</h1>
          <p className="text-foreground-soft mt-2">{technique.tagline}</p>

          <div className="mt-8 mx-auto aspect-square w-full max-w-[260px] relative grid place-items-center">
            <motion.div
              className="absolute h-56 w-56 rounded-full bg-gradient-to-br from-primary/40 to-primary-soft/30"
              animate={{ scale: [0.7, 1, 0.7] }}
              transition={{ duration: 6, repeat: Infinity, ease: 'easeInOut' }}
            />
            <div className="relative h-28 w-28 rounded-full bg-gradient-to-br from-primary to-primary-strong shadow-floating" />
          </div>

          <Card className="mt-8 p-6">
            <p className="text-foreground/90 leading-relaxed">{technique.description}</p>
            <div className="mt-5 grid grid-cols-4 gap-2 text-center text-xs">
              {technique.phases.map((p, i) => (
                <div key={i} className="rounded-md bg-primary-soft/30 py-2">
                  <p className="text-foreground-soft uppercase tracking-wider text-[10px]">
                    {p.kind === 'hold-in' || p.kind === 'hold-out' ? 'hold' : p.kind}
                  </p>
                  <p className="text-lg font-medium mt-1 tabular-nums">{p.durationSec}s</p>
                </div>
              ))}
            </div>
            <p className="text-xs text-foreground-soft mt-4">
              {technique.cycles} cycles · ~{Math.round(technique.phases.reduce((s, p) => s + p.durationSec, 0) * technique.cycles / 60)} min
            </p>
          </Card>

          <Button asChild size="lg" className="mt-6 w-full">
            <Link href={`/session/${technique.id}`}>
              <Play size={18} /> Begin session
            </Link>
          </Button>
        </motion.section>
      </main>
    </>
  );
}
