'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import { Button } from '@/components/ui/Button';

export function CTA() {
  return (
    <section className="mx-auto max-w-6xl px-5 py-24">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
        transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
        className="rounded-xl p-10 sm:p-16 bg-gradient-to-br from-primary via-primary-strong to-primary-soft text-white text-center relative overflow-hidden"
      >
        <motion.div
          aria-hidden
          className="absolute -top-20 -left-20 h-80 w-80 rounded-full bg-white/15 blur-3xl"
          animate={{ scale: [1, 1.2, 1] }}
          transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
        />
        <motion.div
          aria-hidden
          className="absolute -bottom-20 -right-20 h-80 w-80 rounded-full bg-white/10 blur-3xl"
          animate={{ scale: [1.1, 1, 1.1] }}
          transition={{ duration: 9, repeat: Infinity, ease: 'easeInOut' }}
        />
        <div className="relative">
          <h2 className="text-display text-4xl sm:text-5xl tracking-tight">
            Begin your <em className="italic">niyam</em>.
          </h2>
          <p className="mt-3 text-white/85 max-w-xl mx-auto">
            One minute, one breath, today. The streak starts itself.
          </p>
          <Button asChild size="lg" variant="secondary" className="mt-8 bg-white text-primary-strong hover:bg-white/90">
            <Link href="/home">Open the app</Link>
          </Button>
        </div>
      </motion.div>
    </section>
  );
}
