import type { Metadata } from 'next';
export const metadata: Metadata = { title: 'Privacy' };

export default function PrivacyPage() {
  return (
    <main className="mx-auto max-w-3xl px-5 py-20">
      <h1 className="text-display text-5xl tracking-tight">Privacy</h1>
      <div className="mt-6 space-y-4 text-foreground-soft">
        <p>niyam does not collect, transmit, or store any of your personal data on a server.</p>
        <p>All sessions, streaks, mood logs, and preferences live in your browser&apos;s local storage and on your device only.</p>
        <p>There is no account. There is no analytics. There are no third-party trackers.</p>
        <p>If you clear your browser storage, your history is gone. You can also export and reset from the Profile screen.</p>
      </div>
    </main>
  );
}
