'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { Button } from '@/components/ui/Button';
import { usePrefsStore } from '@/stores/prefs.store';
import type { Goal } from '@/lib/types';
import { cn } from '@/lib/cn';

const GOALS: { id: Goal; title: string; emoji: string; description: string }[] = [
  { id: 'calm',   title: 'Find calm',         emoji: '🌿', description: 'Lower anxiety and slow the day down.' },
  { id: 'sleep',  title: 'Sleep better',      emoji: '🌙', description: 'A wind-down before bed.' },
  { id: 'focus',  title: 'Sharpen focus',     emoji: '🎯', description: 'Steady the mind before deep work.' },
  { id: 'energy', title: 'Energize',          emoji: '⚡',  description: 'Wake up the body without overdoing it.' },
];

export default function OnboardingPage() {
  const router = useRouter();
  const setName = usePrefsStore((s) => s.setName);
  const setGoal = usePrefsStore((s) => s.setGoal);
  const setReminderTime = usePrefsStore((s) => s.setReminderTime);
  const complete = usePrefsStore((s) => s.completeOnboarding);

  const [step, setStep] = useState(0);
  const [name, setNameLocal] = useState('');
  const [goal, setGoalLocal] = useState<Goal>('calm');
  const [reminder, setReminder] = useState('08:00');

  const next = () => setStep((s) => Math.min(s + 1, 3));
  const back = () => setStep((s) => Math.max(s - 1, 0));

  const finish = () => {
    setName(name.trim() || 'friend');
    setGoal(goal);
    setReminderTime(reminder);
    complete();
    router.replace('/home');
  };

  return (
    <main className="min-h-dvh flex flex-col">
      {/* Ambient orb */}
      <div className="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
        <motion.div
          className="absolute -top-32 left-1/2 -translate-x-1/2 h-[680px] w-[680px] rounded-full bg-gradient-to-br from-primary/25 to-primary-soft/30 blur-3xl"
          animate={{ scale: [1, 1.1, 1] }}
          transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
        />
      </div>

      {/* Progress dots */}
      <div className="px-6 pt-6 flex items-center justify-between">
        <span className="text-display text-2xl tracking-tight">niyam</span>
        <div className="flex gap-1.5">
          {[0, 1, 2, 3].map((i) => (
            <span
              key={i}
              className={cn(
                'h-1.5 w-6 rounded-full transition-all duration-base',
                i <= step ? 'bg-primary' : 'bg-foreground/15',
              )}
            />
          ))}
        </div>
      </div>

      <div className="flex-1 flex items-center justify-center px-6">
        <div className="w-full max-w-md">
          <AnimatePresence mode="wait">
            <motion.section
              key={step}
              initial={{ opacity: 0, y: 14 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -14 }}
              transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
            >
              {step === 0 && (
                <>
                  <h1 className="text-display text-4xl tracking-tight">Welcome.</h1>
                  <p className="text-foreground-soft mt-3 leading-relaxed">
                    A quiet place to build a breathing routine. Three quick questions and we&apos;re in.
                  </p>
                  <div className="mt-8">
                    <Button onClick={next} size="lg">Begin</Button>
                  </div>
                </>
              )}
              {step === 1 && (
                <>
                  <h2 className="text-display text-3xl tracking-tight">What should we call you?</h2>
                  <input
                    autoFocus
                    value={name}
                    onChange={(e) => setNameLocal(e.target.value)}
                    placeholder="Your name"
                    className="mt-6 w-full bg-transparent border-b-2 border-foreground/15 focus:border-primary outline-none py-3 text-2xl text-display tracking-tight transition-colors"
                    onKeyDown={(e) => e.key === 'Enter' && next()}
                  />
                  <div className="mt-8 flex gap-3">
                    <Button variant="ghost" onClick={back}>Back</Button>
                    <Button onClick={next}>Continue</Button>
                  </div>
                </>
              )}
              {step === 2 && (
                <>
                  <h2 className="text-display text-3xl tracking-tight">What brings you here?</h2>
                  <p className="text-sm text-foreground-soft mt-2">You can change this anytime.</p>
                  <div className="mt-6 grid grid-cols-2 gap-3">
                    {GOALS.map((g) => (
                      <button
                        key={g.id}
                        onClick={() => setGoalLocal(g.id)}
                        className={cn(
                          'rounded-xl p-4 text-left border transition-all',
                          goal === g.id
                            ? 'border-primary bg-primary-soft/30 shadow-card'
                            : 'border-foreground/10 hover:border-primary/40',
                        )}
                      >
                        <span className="text-2xl">{g.emoji}</span>
                        <p className="mt-2 font-medium">{g.title}</p>
                        <p className="text-xs text-foreground-soft mt-1">{g.description}</p>
                      </button>
                    ))}
                  </div>
                  <div className="mt-8 flex gap-3">
                    <Button variant="ghost" onClick={back}>Back</Button>
                    <Button onClick={next}>Continue</Button>
                  </div>
                </>
              )}
              {step === 3 && (
                <>
                  <h2 className="text-display text-3xl tracking-tight">When should we whisper?</h2>
                  <p className="text-sm text-foreground-soft mt-2">
                    A gentle daily reminder. Pick a quiet moment.
                  </p>
                  <input
                    type="time"
                    value={reminder}
                    onChange={(e) => setReminder(e.target.value)}
                    className="mt-6 bg-transparent border border-foreground/15 rounded-lg px-4 py-3 text-2xl text-display tracking-tight focus:border-primary outline-none"
                  />
                  <div className="mt-8 flex gap-3">
                    <Button variant="ghost" onClick={back}>Back</Button>
                    <Button onClick={finish} size="lg">Open niyam</Button>
                  </div>
                </>
              )}
            </motion.section>
          </AnimatePresence>
        </div>
      </div>
    </main>
  );
}
