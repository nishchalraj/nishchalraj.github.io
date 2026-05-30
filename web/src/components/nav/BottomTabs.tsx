'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { motion } from 'framer-motion';
import { Home, Activity, BookOpenText, User, Sparkles } from 'lucide-react';
import { cn } from '@/lib/cn';

const TABS = [
  { href: '/home',       label: 'Home',       icon: Home },
  { href: '/techniques', label: 'Techniques', icon: Sparkles },
  { href: '/sounds',     label: 'Sounds',     icon: Activity },
  { href: '/insights',   label: 'Insights',   icon: BookOpenText },
  { href: '/profile',    label: 'Profile',    icon: User },
];

export function BottomTabs() {
  const pathname = usePathname();
  return (
    <nav
      aria-label="Primary"
      className="fixed bottom-3 left-1/2 -translate-x-1/2 z-40 w-[min(560px,calc(100%-1.5rem))]"
    >
      <div className="glass rounded-xl px-2 py-1.5 flex items-center justify-between shadow-floating">
        {TABS.map((tab) => {
          const Icon = tab.icon;
          const active = pathname?.startsWith(tab.href);
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={cn(
                'relative flex-1 flex flex-col items-center gap-0.5 py-2 rounded-lg text-xs transition-colors',
                active ? 'text-primary-strong dark:text-primary-soft' : 'text-foreground-soft hover:text-foreground',
              )}
              aria-current={active ? 'page' : undefined}
            >
              {active && (
                <motion.span
                  layoutId="tab-pill"
                  className="absolute inset-0 bg-primary-soft/35 dark:bg-primary/15 rounded-lg -z-10"
                  transition={{ type: 'spring', stiffness: 360, damping: 30 }}
                />
              )}
              <Icon size={20} strokeWidth={1.8} />
              <span className="text-[11px] font-medium tracking-tight">{tab.label}</span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
