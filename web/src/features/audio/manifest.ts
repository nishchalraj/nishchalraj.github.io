import type { SoundMeta } from '@/lib/types';

export const SOUNDS: SoundMeta[] = [
  { id: 'forest',  label: 'Forest',   src: '/sounds/forest.mp3',  description: 'Distant birds and rustling leaves.' },
  { id: 'ocean',   label: 'Ocean',    src: '/sounds/ocean.mp3',   description: 'Slow rolling surf.' },
  { id: 'rain',    label: 'Rain',     src: '/sounds/rain.mp3',    description: 'Steady soft rainfall.' },
  { id: 'fire',    label: 'Fire',     src: '/sounds/fire.mp3',    description: 'Crackling embers.' },
  { id: 'wind',    label: 'Wind',     src: '/sounds/wind.mp3',    description: 'High mountain wind.' },
  { id: 'waves',   label: 'Waves',    src: '/sounds/waves.mp3',   description: 'Gentle lapping water.' },
];

export const SOUNDS_BY_ID = Object.fromEntries(SOUNDS.map((s) => [s.id, s]));
