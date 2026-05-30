'use client';

import { motion } from 'framer-motion';
import { Wind, HeartPulse, Calendar, Sparkles, Volume2, Moon } from 'lucide-react';

const FEATURES = [
  { icon: Wind,        title: 'Seven guided techniques',  copy: '4-7-8, Box, Coherent 5-5, Energize, Strengthen, Wim Hof — each with on-brand phase animations.' },
  { icon: Sparkles,    title: 'Custom builder',            copy: 'Slide your own inhale-hold-exhale-hold pattern. Save it. Run it tomorrow.' },
  { icon: HeartPulse,  title: 'Mood-aware',                copy: 'A circular check-in before and after — see how your breath changed how you feel.' },
  { icon: Calendar,    title: 'Quiet streaks',             copy: 'A gentle dot on your calendar. No fire emojis, no guilt — just a record of you showing up.' },
  { icon: Volume2,     title: 'Soundscapes',               copy: 'Forest, ocean, rain, wind, fire, waves. Standalone timer mode or layer under any session.' },
  { icon: Moon,        title: 'Calm by default',           copy: 'Honors reduced-motion. Honors dark mode. Honors your evening.' },
];

export function Features() {
  return (
    <section className="mx-auto max-w-6xl px-5 py-24">
      <div className="max-w-2xl mb-12">
        <h2 className="text-display text-4xl sm:text-5xl tracking-tight">
          Everything you need to <em className="italic text-primary-strong">show up</em>.
        </h2>
        <p className="mt-4 text-foreground-soft text-lg">
          Designed around the daily ritual, not the marketing funnel.
        </p>
      </div>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {FEATURES.map((f, i) => {
          const Icon = f.icon;
          return (
            <motion.article
              key={f.title}
              initial={{ opacity: 0, y: 18 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: '-80px' }}
              transition={{ duration: 0.6, delay: i * 0.05, ease: [0.16, 1, 0.3, 1] }}
              className="group rounded-xl p-6 bg-surface-alt/50 border border-foreground/5 hover:border-primary/40 hover:shadow-raised transition-all duration-base"
            >
              <div className="h-11 w-11 rounded-lg bg-primary-soft/40 text-primary-strong grid place-items-center mb-4 group-hover:scale-110 transition-transform duration-base ease-soft-out">
                <Icon size={20} strokeWidth={1.8} />
              </div>
              <h3 className="text-lg font-semibold tracking-tight">{f.title}</h3>
              <p className="mt-2 text-sm text-foreground-soft leading-relaxed">{f.copy}</p>
            </motion.article>
          );
        })}
      </div>
    </section>
  );
}
