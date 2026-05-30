import type { Metadata } from 'next';

export const metadata: Metadata = { title: 'About' };

export default function AboutPage() {
  return (
    <main className="mx-auto max-w-3xl px-5 py-20 prose-quiet">
      <h1 className="text-display text-5xl tracking-tight">About niyam</h1>
      <p className="mt-5 text-lg text-foreground-soft">
        <em>Niyam</em> is a Sanskrit word meaning <em>rule, routine, or discipline.</em> Not the punishing
        kind — the kind that makes a thing inevitable. The kind that turns breath into a place you come home to.
      </p>
      <p className="mt-4 text-foreground-soft">
        This app is a quiet space for that practice. It works offline. It doesn&apos;t ask for an account.
        It doesn&apos;t track you. The streak is private and gentle. The animations honor reduced-motion.
        The sound is optional. The point is the breath.
      </p>
      <p className="mt-4 text-foreground-soft">
        Built with care · open source on GitHub.
      </p>
    </main>
  );
}
