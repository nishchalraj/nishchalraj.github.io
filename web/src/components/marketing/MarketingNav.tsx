'use client';

import Link from 'next/link';
import { motion } from 'framer-motion';
import { useTheme } from 'next-themes';
import { Sun, Moon } from 'lucide-react';
import { Button } from '@/components/ui/Button';

export function MarketingNav() {
  const { resolvedTheme, setTheme } = useTheme();
  const isDark = resolvedTheme === 'dark';
  return (
    <motion.nav
      initial={{ y: -16, opacity: 0 }}
      animate={{ y: 0, opacity: 1 }}
      transition={{ duration: 0.6, ease: [0.16, 1, 0.3, 1] }}
      className="sticky top-0 z-40 backdrop-blur-md bg-surface/70 border-b border-foreground/5"
    >
      <div className="mx-auto flex max-w-6xl items-center justify-between px-5 py-4">
        <Link href="/" className="flex items-center gap-2.5 group">
          <span
            aria-hidden
            className="block h-6 w-6 rounded-full bg-gradient-to-tr from-primary to-primary-soft transition-transform duration-base ease-soft-out group-hover:scale-110"
          />
          <span className="text-display text-xl tracking-tight">niyam</span>
        </Link>
        <div className="flex items-center gap-1.5">
          <Link
            href="/about"
            className="hidden sm:inline-block px-3 py-2 text-sm text-foreground-soft hover:text-foreground transition-colors"
          >
            About
          </Link>
          <Link
            href="/learn"
            className="hidden sm:inline-block px-3 py-2 text-sm text-foreground-soft hover:text-foreground transition-colors"
          >
            Learn
          </Link>
          <Button
            variant="ghost"
            size="icon"
            aria-label="Toggle theme"
            onClick={() => setTheme(isDark ? 'light' : 'dark')}
          >
            {isDark ? <Sun size={18} /> : <Moon size={18} />}
          </Button>
          <Button asChild size="sm" className="ml-1">
            <Link href="/home">Open app</Link>
          </Button>
        </div>
      </div>
    </motion.nav>
  );
}
