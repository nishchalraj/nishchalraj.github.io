import type { Metadata, Viewport } from 'next';
import { Inter, Fraunces } from 'next/font/google';
import './globals.css';
import { Providers } from './providers';

const inter = Inter({ subsets: ['latin'], variable: '--font-inter', display: 'swap' });
const fraunces = Fraunces({
  subsets: ['latin'],
  variable: '--font-fraunces',
  display: 'swap',
  weight: ['300', '400', '500', '600', '700'],
});

export const metadata: Metadata = {
  metadataBase: new URL('https://niyam.yoga'),
  title: {
    default: 'niyam — breathe with discipline',
    template: '%s · niyam',
  },
  description:
    'niyam is a quiet, animated breathing companion. Build a daily breath routine with guided techniques, soundscapes, mood check-ins, and streaks.',
  keywords: ['breathing', 'meditation', 'box breathing', '4-7-8', 'pranayama', 'mindfulness', 'habit'],
  openGraph: {
    title: 'niyam — breathe with discipline',
    description: 'A modern, minimal breathing-habit app.',
    type: 'website',
    locale: 'en_US',
    url: 'https://niyam.yoga',
    siteName: 'niyam',
  },
  twitter: { card: 'summary_large_image' },
  manifest: '/manifest.webmanifest',
};

export const viewport: Viewport = {
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#FAF7F2' },
    { media: '(prefers-color-scheme: dark)', color: '#0F0E1F' },
  ],
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`${inter.variable} ${fraunces.variable}`} suppressHydrationWarning>
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
