import type { Config } from 'tailwindcss';
import tokens from '../design-tokens/tokens.json';

const config: Config = {
  darkMode: 'class',
  content: ['./src/**/*.{ts,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        lavender: tokens.color.lavender,
        cream: tokens.color.cream,
        'cream-soft': tokens.color.creamSoft,
        ink: tokens.color.ink,
        'ink-soft': tokens.color.inkSoft,
        muted: tokens.color.muted,
        surface: 'rgb(var(--surface) / <alpha-value>)',
        'surface-alt': 'rgb(var(--surface-alt) / <alpha-value>)',
        foreground: 'rgb(var(--foreground) / <alpha-value>)',
        'foreground-soft': 'rgb(var(--foreground-soft) / <alpha-value>)',
        primary: {
          DEFAULT: 'rgb(var(--primary) / <alpha-value>)',
          soft: 'rgb(var(--primary-soft) / <alpha-value>)',
          strong: 'rgb(var(--primary-strong) / <alpha-value>)',
        },
        border: 'rgb(var(--border) / <alpha-value>)',
        phase: {
          inhale: tokens.color.phase.inhale,
          holdIn: tokens.color.phase.holdIn,
          exhale: tokens.color.phase.exhale,
          holdOut: tokens.color.phase.holdOut,
        },
      },
      fontFamily: {
        display: ['var(--font-fraunces)', 'Georgia', 'serif'],
        sans: ['var(--font-inter)', '-apple-system', 'BlinkMacSystemFont', 'sans-serif'],
      },
      borderRadius: {
        xs: `${tokens.radius.xs}px`,
        sm: `${tokens.radius.sm}px`,
        md: `${tokens.radius.md}px`,
        lg: `${tokens.radius.lg}px`,
        xl: `${tokens.radius.xl}px`,
      },
      boxShadow: {
        card: tokens.elevation.card,
        raised: tokens.elevation.raised,
        floating: tokens.elevation.floating,
      },
      transitionDuration: {
        fast: `${tokens.motion.duration.fast}ms`,
        base: `${tokens.motion.duration.base}ms`,
        slow: `${tokens.motion.duration.slow}ms`,
      },
      transitionTimingFunction: {
        'soft-out': 'cubic-bezier(0.16,1.0,0.3,1.0)',
      },
      keyframes: {
        breathe: {
          '0%, 100%': { transform: 'scale(0.7)', opacity: '0.8' },
          '50%':      { transform: 'scale(1)',   opacity: '1' },
        },
        'fade-up': {
          from: { opacity: '0', transform: 'translateY(8px)' },
          to:   { opacity: '1', transform: 'translateY(0)' },
        },
        shimmer: {
          '0%':   { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(100%)' },
        },
      },
      animation: {
        breathe: 'breathe 8s cubic-bezier(0.4,0,0.2,1) infinite',
        'fade-up': 'fade-up 400ms cubic-bezier(0.16,1.0,0.3,1.0) both',
        shimmer: 'shimmer 2.4s linear infinite',
      },
    },
  },
  plugins: [],
};

export default config;
