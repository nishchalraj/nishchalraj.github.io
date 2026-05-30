'use client';

import { motion } from 'framer-motion';
import { todayKey, shortDay } from '@/lib/date';
import { cn } from '@/lib/cn';

interface CalendarStripProps {
  completedDays: string[];
  days?: number;
}

export function CalendarStrip({ completedDays, days = 7 }: CalendarStripProps) {
  const today = new Date();
  const cells = Array.from({ length: days }, (_, i) => {
    const d = new Date(today);
    d.setDate(today.getDate() - (days - 1 - i));
    const key = todayKey(d);
    return { d, key, completed: completedDays.includes(key), isToday: key === todayKey() };
  });
  return (
    <div className="flex justify-between gap-2">
      {cells.map((c, i) => (
        <motion.div
          key={c.key}
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: i * 0.04, duration: 0.4 }}
          className="flex-1"
        >
          <div className={cn(
            'rounded-md py-2.5 px-1 text-center transition-all',
            c.isToday
              ? 'bg-primary text-white shadow-card'
              : 'bg-surface-alt/60 border border-foreground/5',
          )}>
            <div className={cn(
              'text-[10px] uppercase tracking-wider',
              c.isToday ? 'opacity-85' : 'text-foreground-soft',
            )}>
              {shortDay(c.d).slice(0, 1)}
            </div>
            <div className="text-base tabular-nums font-medium mt-0.5">
              {c.d.getDate()}
            </div>
            <div className="h-1 mt-1.5 flex justify-center">
              {c.completed && (
                <motion.span
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.1, type: 'spring', stiffness: 400 }}
                  className={cn(
                    'block h-1 w-1 rounded-full',
                    c.isToday ? 'bg-white' : 'bg-primary',
                  )}
                  aria-label="Completed"
                />
              )}
            </div>
          </div>
        </motion.div>
      ))}
    </div>
  );
}
