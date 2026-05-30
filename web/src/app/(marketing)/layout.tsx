import Link from 'next/link';
import { MarketingNav } from '@/components/marketing/MarketingNav';

export default function MarketingLayout({ children }: { children: React.ReactNode }) {
  return (
    <>
      <MarketingNav />
      {children}
      <footer className="mx-auto max-w-6xl px-5 py-10 border-t border-foreground/5 text-sm text-foreground-soft flex flex-wrap items-center justify-between gap-4">
        <p>© niyam · breathe with discipline</p>
        <div className="flex gap-5">
          <Link href="/about" className="hover:text-foreground transition-colors">About</Link>
          <Link href="/privacy" className="hover:text-foreground transition-colors">Privacy</Link>
          <Link href="/learn" className="hover:text-foreground transition-colors">Learn</Link>
        </div>
      </footer>
    </>
  );
}
