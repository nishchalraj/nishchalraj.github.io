'use client';

import Link from 'next/link';
import { useTheme } from 'next-themes';
import { Sun, Moon } from 'lucide-react';
import { Button } from '@/components/ui/Button';

export function TopBar({ title, back }: { title?: string; back?: string }) {
  const { resolvedTheme, setTheme } = useTheme();
  const isDark = resolvedTheme === 'dark';
  return (
    <header className="sticky top-0 z-30 flex items-center justify-between px-5 py-4 backdrop-blur-md bg-surface/70 border-b border-foreground/5">
      <div className="flex items-center gap-3">
        {back && (
          <Link
            href={back}
            className="h-9 w-9 grid place-items-center rounded-full bg-foreground/5 hover:bg-foreground/10 transition-colors"
            aria-label="Back"
          >
            <span aria-hidden>←</span>
          </Link>
        )}
        <div className="flex flex-col">
          {title ? (
            <h1 className="text-lg font-medium tracking-tight">{title}</h1>
          ) : (
            <Link href="/home" className="text-display text-2xl tracking-tight">
              niyam
            </Link>
          )}
        </div>
      </div>
      <Button
        variant="ghost"
        size="icon"
        aria-label="Toggle theme"
        onClick={() => setTheme(isDark ? 'light' : 'dark')}
      >
        {isDark ? <Sun size={18} /> : <Moon size={18} />}
      </Button>
    </header>
  );
}
