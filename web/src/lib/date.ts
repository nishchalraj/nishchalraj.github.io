import type { DayKey } from './types';

export function todayKey(d = new Date()): DayKey {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

export function dayKey(d: Date): DayKey {
  return todayKey(d);
}

export function addDays(key: DayKey, n: number): DayKey {
  const [y, m, d] = key.split('-').map(Number);
  const date = new Date(y, m - 1, d);
  date.setDate(date.getDate() + n);
  return todayKey(date);
}

export function daysBetween(a: DayKey, b: DayKey): number {
  const da = new Date(a + 'T00:00:00').getTime();
  const db = new Date(b + 'T00:00:00').getTime();
  return Math.round((db - da) / 86_400_000);
}

export function greetingFor(d = new Date()): string {
  const h = d.getHours();
  if (h < 5) return 'Late night';
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  if (h < 21) return 'Good evening';
  return 'Good night';
}

export function monthName(d = new Date()): string {
  return d.toLocaleDateString(undefined, { month: 'long' });
}

export function shortDay(d: Date): string {
  return d.toLocaleDateString(undefined, { weekday: 'short' });
}
