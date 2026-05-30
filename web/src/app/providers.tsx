'use client';

import { ThemeProvider } from 'next-themes';
import { MotionConfig } from 'framer-motion';
import { AudioProvider } from '@/features/audio/AudioProvider';
import { StoreHydrator } from '@/stores/StoreHydrator';

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
      <MotionConfig reducedMotion="user" transition={{ duration: 0.35, ease: [0.16, 1, 0.3, 1] }}>
        <AudioProvider>
          <StoreHydrator>{children}</StoreHydrator>
        </AudioProvider>
      </MotionConfig>
    </ThemeProvider>
  );
}
