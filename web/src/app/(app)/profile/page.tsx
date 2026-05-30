'use client';

import { useTheme } from 'next-themes';
import { motion } from 'framer-motion';
import { TopBar } from '@/components/nav/TopBar';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { usePrefsStore } from '@/stores/prefs.store';
import { useSessionsStore } from '@/stores/sessions.store';
import { useStreakStore } from '@/stores/streak.store';
import { useMoodStore } from '@/stores/mood.store';
import { usePlansStore } from '@/stores/plans.store';
import { useHydrated } from '@/stores/StoreHydrator';

export default function ProfilePage() {
  const hydrated = useHydrated();
  const prefs = usePrefsStore();
  const sessionsClear = useSessionsStore((s) => s.clear);
  const streakClear = useStreakStore((s) => s.clear);
  const moodClear = useMoodStore((s) => s.clear);
  const plansClear = usePlansStore((s) => s.clear);
  const { setTheme } = useTheme();

  const exportData = () => {
    const data = {
      prefs: prefs,
      sessions: useSessionsStore.getState().history,
      mood: useMoodStore.getState().logs,
      streak: { current: useStreakStore.getState().current, best: useStreakStore.getState().best },
      exportedAt: new Date().toISOString(),
    };
    const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url; a.download = 'niyam-export.json'; a.click();
    URL.revokeObjectURL(url);
  };

  const reset = () => {
    if (!confirm('Reset everything? This clears sessions, streaks, moods, and preferences.')) return;
    sessionsClear(); streakClear(); moodClear(); plansClear();
    prefs.reset();
    location.reload();
  };

  return (
    <>
      <TopBar title="Profile" />
      <main className="mx-auto max-w-2xl px-5 pt-2 pb-32 space-y-4">
        <motion.section
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center py-6"
        >
          <div className="mx-auto h-20 w-20 rounded-full bg-gradient-to-br from-primary to-primary-strong grid place-items-center text-white text-display text-3xl">
            {hydrated ? (prefs.name?.slice(0, 1).toUpperCase() || '·') : '·'}
          </div>
          <p className="text-display text-3xl tracking-tight mt-4">
            {hydrated ? (prefs.name || 'friend') : 'friend'}
          </p>
          <p className="text-foreground-soft text-sm mt-1 capitalize">{hydrated ? prefs.goal : ''} · niyam</p>
        </motion.section>

        <Card className="p-5">
          <p className="text-xs uppercase tracking-wider text-foreground-soft mb-3">Preferences</p>
          <Row label="Name">
            <input
              defaultValue={prefs.name}
              onBlur={(e) => prefs.setName(e.target.value)}
              className="bg-transparent text-right outline-none border-b border-transparent focus:border-foreground/20"
            />
          </Row>
          <Row label="Reminder time">
            <input
              type="time"
              defaultValue={prefs.reminderTime}
              onChange={(e) => prefs.setReminderTime(e.target.value)}
              className="bg-transparent text-right outline-none"
            />
          </Row>
          <Row label="Theme">
            <select
              value={prefs.theme}
              onChange={(e) => { prefs.setTheme(e.target.value as 'light' | 'dark' | 'system'); setTheme(e.target.value); }}
              className="bg-transparent text-right outline-none capitalize"
            >
              <option value="system">System</option>
              <option value="light">Light</option>
              <option value="dark">Dark</option>
            </select>
          </Row>
          <Row label="Voice cues">
            <input
              type="checkbox"
              checked={prefs.voiceCues}
              onChange={(e) => prefs.setVoiceCues(e.target.checked)}
              className="accent-primary scale-125"
            />
          </Row>
        </Card>

        <Card className="p-5 space-y-2">
          <p className="text-xs uppercase tracking-wider text-foreground-soft mb-1">Data</p>
          <Button variant="outline" className="w-full" onClick={exportData}>Export data (.json)</Button>
          <Button variant="ghost" className="w-full text-red-500" onClick={reset}>Reset everything</Button>
        </Card>

        <p className="text-center text-xs text-foreground-soft/70 py-4">
          niyam · v0.1.0 · everything stays on this device
        </p>
      </main>
    </>
  );
}

function Row({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between py-2.5 border-b border-foreground/5 last:border-0 text-sm">
      <span className="text-foreground-soft">{label}</span>
      <span>{children}</span>
    </div>
  );
}
