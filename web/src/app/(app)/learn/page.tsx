'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import { TopBar } from '@/components/nav/TopBar';
import { Card } from '@/components/ui/Card';
import { ARTICLES } from '@/content/articles';

export default function LearnPage() {
  return (
    <>
      <TopBar title="Learn" />
      <main className="mx-auto max-w-3xl px-5 pt-2 pb-32">
        <p className="text-foreground-soft text-sm">
          Short notes on why these patterns work.
        </p>
        <div className="mt-6 grid gap-3">
          {ARTICLES.map((a, i) => (
            <motion.div
              key={a.slug}
              initial={{ opacity: 0, y: 8 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.05, duration: 0.4 }}
            >
              <Link href={`/learn/${a.slug}`}>
                <Card className="p-5 hover:border-primary/30 hover:shadow-raised transition-all">
                  <p className="text-xs uppercase tracking-wider text-primary-strong dark:text-primary-soft">
                    {a.readMin} min read
                  </p>
                  <h3 className="text-display text-xl tracking-tight mt-1">{a.title}</h3>
                  <p className="text-sm text-foreground-soft mt-1">{a.excerpt}</p>
                </Card>
              </Link>
            </motion.div>
          ))}
        </div>
      </main>
    </>
  );
}
