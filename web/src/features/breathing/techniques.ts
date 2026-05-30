import type { Technique } from '@/lib/types';

const t = (s: number, kind: Technique['phases'][number]['kind']) => ({ durationSec: s, kind });

export const TECHNIQUES: Technique[] = [
  {
    id: 'relax-478',
    name: 'Relax',
    tagline: '4-7-8 breathing',
    description:
      'A calming pattern: inhale for 4, hold for 7, exhale for 8. Activates the parasympathetic system and slows the heart.',
    phases: [t(4, 'inhale'), t(7, 'hold-in'), t(8, 'exhale'), t(0, 'hold-out')],
    cycles: 6,
    category: 'calm',
    pattern: '4-7-8',
    tags: ['sleep', 'anxiety', 'beginner-friendly'],
    recommendedSound: 'rain',
  },
  {
    id: 'box-4444',
    name: 'Box',
    tagline: 'Equal four-part',
    description:
      'Four equal parts: inhale, hold, exhale, hold. Used by Navy SEALs to stay calm under pressure. Excellent for focus.',
    phases: [t(4, 'inhale'), t(4, 'hold-in'), t(4, 'exhale'), t(4, 'hold-out')],
    cycles: 8,
    category: 'focus',
    pattern: '4-4-4-4',
    tags: ['focus', 'discipline', 'classic'],
    recommendedSound: 'wind',
  },
  {
    id: 'calm-extended',
    name: 'Calm',
    tagline: 'Extended exhale',
    description:
      'A long, slow exhale that gently downshifts the nervous system. Inhale 4, exhale 8.',
    phases: [t(4, 'inhale'), t(0, 'hold-in'), t(8, 'exhale'), t(0, 'hold-out')],
    cycles: 10,
    category: 'calm',
    pattern: '4-0-8',
    tags: ['stress', 'evening'],
    recommendedSound: 'ocean',
  },
  {
    id: 'coherent-55',
    name: 'Coherent',
    tagline: '5-5 heart rhythm',
    description:
      'Resonant breathing at 5 in / 5 out maximizes heart-rate variability — a marker of recovery and calm.',
    phases: [t(5, 'inhale'), t(0, 'hold-in'), t(5, 'exhale'), t(0, 'hold-out')],
    cycles: 12,
    category: 'calm',
    pattern: '5-5',
    tags: ['HRV', 'daily'],
    recommendedSound: 'forest',
  },
  {
    id: 'energize',
    name: 'Energize',
    tagline: 'Stimulating breath',
    description:
      'A short, brisk inhale and slightly longer exhale to wake the body up without overdoing it.',
    phases: [t(2, 'inhale'), t(0, 'hold-in'), t(3, 'exhale'), t(0, 'hold-out')],
    cycles: 20,
    category: 'energy',
    pattern: '2-3',
    tags: ['morning', 'wake-up'],
    recommendedSound: 'forest',
  },
  {
    id: 'strengthen',
    name: 'Strengthen',
    tagline: 'Belly breath',
    description:
      'Slow diaphragmatic breathing. Place a hand on your belly and let it rise. Builds breath capacity.',
    phases: [t(6, 'inhale'), t(2, 'hold-in'), t(6, 'exhale'), t(2, 'hold-out')],
    cycles: 8,
    category: 'focus',
    pattern: '6-2-6-2',
    tags: ['diaphragm', 'capacity'],
    recommendedSound: 'waves',
  },
  {
    id: 'wim-hof-light',
    name: 'Wim Hof (light)',
    tagline: 'Power breath',
    description:
      'A gentle take on the Wim Hof method — 30 deep breaths followed by a relaxed hold. Beginner-safe version.',
    phases: [t(2, 'inhale'), t(0, 'hold-in'), t(2, 'exhale'), t(0, 'hold-out')],
    cycles: 30,
    category: 'energy',
    pattern: '2-2',
    tags: ['advanced', 'energy'],
    recommendedSound: 'wind',
  },
];

export const TECHNIQUES_BY_ID: Record<string, Technique> = Object.fromEntries(
  TECHNIQUES.map((t) => [t.id, t]),
);

export function techniqueById(id: string): Technique | undefined {
  return TECHNIQUES_BY_ID[id];
}

/** Custom-built technique from sliders. */
export function makeCustomTechnique(
  inhale: number, holdIn: number, exhale: number, holdOut: number, cycles: number,
): Technique {
  return {
    id: 'custom',
    name: 'Custom',
    tagline: `${inhale}-${holdIn}-${exhale}-${holdOut}`,
    description: 'Your custom pattern.',
    phases: [
      { kind: 'inhale',   durationSec: inhale },
      { kind: 'hold-in',  durationSec: holdIn },
      { kind: 'exhale',   durationSec: exhale },
      { kind: 'hold-out', durationSec: holdOut },
    ],
    cycles,
    category: 'focus',
    pattern: `${inhale}-${holdIn}-${exhale}-${holdOut}`,
    tags: ['custom'],
  };
}
