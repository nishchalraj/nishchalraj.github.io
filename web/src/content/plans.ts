import type { Plan } from '@/lib/types';

export const PLANS: Plan[] = [
  {
    id: 'morning-calm',
    title: 'Morning Calm',
    subtitle: '7 days · Start the day quiet',
    cover: 'from-primary/40 to-primary-soft/30',
    days: [
      { techniqueId: 'coherent-55', cycles: 8 },
      { techniqueId: 'box-4444',    cycles: 8 },
      { techniqueId: 'relax-478',   cycles: 5 },
      { techniqueId: 'coherent-55', cycles: 10 },
      { techniqueId: 'calm-extended', cycles: 8 },
      { techniqueId: 'box-4444',    cycles: 10 },
      { techniqueId: 'coherent-55', cycles: 12 },
    ],
  },
  {
    id: 'cloud-breath',
    title: 'Breathe with the Clouds',
    subtitle: '5 days · Soft afternoon reset',
    cover: 'from-primary-soft/40 to-primary/20',
    days: [
      { techniqueId: 'calm-extended', cycles: 6 },
      { techniqueId: 'box-4444',      cycles: 6 },
      { techniqueId: 'coherent-55',   cycles: 8 },
      { techniqueId: 'relax-478',     cycles: 4 },
      { techniqueId: 'calm-extended', cycles: 8 },
    ],
  },
  {
    id: 'deep-recovery',
    title: 'Deep Recovery',
    subtitle: '10 days · For the worn-out evenings',
    cover: 'from-primary/30 to-primary-strong/30',
    days: Array.from({ length: 10 }, (_, i) => ({
      techniqueId: i % 2 === 0 ? 'relax-478' : 'calm-extended',
      cycles: 5 + i,
    })),
  },
  {
    id: 'monthly-stress',
    title: 'Monthly Stress Reflection',
    subtitle: '28 days · A small daily practice',
    cover: 'from-primary-strong/30 to-primary-soft/40',
    days: Array.from({ length: 28 }, (_, i) => ({
      techniqueId: ['coherent-55', 'box-4444', 'calm-extended', 'relax-478'][i % 4],
      cycles: 6 + (i % 6),
    })),
  },
];

export const PLAN_BY_ID = Object.fromEntries(PLANS.map((p) => [p.id, p]));
