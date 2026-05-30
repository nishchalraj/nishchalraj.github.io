'use client';

import { motion } from 'framer-motion';
import Link from 'next/link';
import { TECHNIQUES } from '@/features/breathing/techniques';

export function TechniqueStrip() {
  return (
    <section className="mx-auto max-w-6xl px-5 py-20">
      <div className="flex items-end justify-between mb-8 gap-4">
        <h2 className="text-display text-4xl tracking-tight">A breath for every moment.</h2>
        <Link
          href="/techniques"
          className="hidden sm:inline-block text-sm text-primary-strong dark:text-primary-soft hover:underline whitespace-nowrap"
        >
          All techniques →
        </Link>
      </div>
      <div className="flex gap-3 overflow-x-auto scrollbar-none -mx-5 px-5 pb-2">
        {TECHNIQUES.map((t, i) => (
          <motion.div
            key={t.id}
            initial={{ opacity: 0, x: 30 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5, delay: i * 0.04, ease: [0.16, 1, 0.3, 1] }}
            className="shrink-0 w-[240px] rounded-xl p-5 bg-gradient-to-br from-primary-soft/30 to-primary/10 border border-primary/15"
          >
            <p className="text-xs tracking-[0.18em] uppercase text-primary-strong dark:text-primary-soft mb-2">
              {t.category}
            </p>
            <p className="text-display text-2xl tracking-tight">{t.name}</p>
            <p className="text-xs text-foreground-soft mt-1">{t.tagline}</p>
            <div className="mt-6 flex items-center justify-between">
              <span className="font-mono text-xs text-foreground-soft">{t.pattern}</span>
              <Link
                href={`/session/${t.id}`}
                className="text-xs px-3 py-1.5 rounded-full bg-primary text-white hover:bg-primary-strong transition-colors"
              >
                Try it
              </Link>
            </div>
          </motion.div>
        ))}
      </div>
    </section>
  );
}
