'use client';

import { useEffect } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import { BottomTabs } from '@/components/nav/BottomTabs';
import { PageTransition } from '@/components/motion/PageTransition';
import { usePrefsStore } from '@/stores/prefs.store';
import { useHydrated } from '@/stores/StoreHydrator';

const PUBLIC_APP_ROUTES = new Set(['/onboarding']);

export default function AppLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname() ?? '';
  const onboarded = usePrefsStore((s) => s.onboarded);
  const hydrated = useHydrated();

  // Redirect to onboarding once on first visit (post-hydration only).
  useEffect(() => {
    if (!hydrated) return;
    if (!onboarded && !PUBLIC_APP_ROUTES.has(pathname)) {
      router.replace('/onboarding');
    }
  }, [hydrated, onboarded, pathname, router]);

  // Hide bottom tabs in onboarding & full-screen session player.
  const hideNav =
    pathname.startsWith('/onboarding') || pathname.startsWith('/session');

  return (
    <div className="min-h-dvh pb-24">
      <PageTransition>{children}</PageTransition>
      {!hideNav && <BottomTabs />}
    </div>
  );
}
