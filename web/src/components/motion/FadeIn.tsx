'use client';

import { motion, type HTMLMotionProps } from 'framer-motion';

interface FadeInProps extends HTMLMotionProps<'div'> {
  delay?: number;
  y?: number;
}

export function FadeIn({ delay = 0, y = 12, children, ...rest }: FadeInProps) {
  return (
    <motion.div
      initial={{ opacity: 0, y }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay, ease: [0.16, 1, 0.3, 1] }}
      {...rest}
    >
      {children}
    </motion.div>
  );
}

export function Stagger({
  children,
  step = 0.06,
  className,
}: {
  children: React.ReactNode;
  step?: number;
  className?: string;
}) {
  const items = Array.isArray(children) ? children : [children];
  return (
    <div className={className}>
      {items.map((c, i) => (
        <FadeIn key={i} delay={i * step}>{c}</FadeIn>
      ))}
    </div>
  );
}
