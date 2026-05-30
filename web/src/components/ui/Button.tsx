'use client';

import { Slot } from '@radix-ui/react-slot';
import { forwardRef } from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/cn';

const button = cva(
  'inline-flex items-center justify-center gap-2 whitespace-nowrap font-medium select-none ' +
  'transition-[transform,background-color,box-shadow,opacity] duration-fast ease-soft-out ' +
  'disabled:opacity-50 disabled:pointer-events-none ' +
  'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-2 focus-visible:ring-offset-surface ' +
  'active:scale-[0.97]',
  {
    variants: {
      variant: {
        primary:
          'bg-primary text-white shadow-card hover:bg-primary-strong hover:shadow-raised',
        secondary:
          'bg-surface-alt text-foreground border border-border hover:bg-primary-soft/30',
        ghost:
          'bg-transparent text-foreground hover:bg-primary-soft/20',
        outline:
          'bg-transparent text-foreground border border-foreground/15 hover:border-foreground/30',
        soft:
          'bg-primary-soft/40 text-primary-strong dark:text-primary-soft hover:bg-primary-soft/60',
      },
      size: {
        sm: 'h-9 px-3 text-sm rounded-md',
        md: 'h-11 px-5 text-sm rounded-lg',
        lg: 'h-14 px-7 text-base rounded-xl',
        icon: 'h-10 w-10 rounded-full',
      },
    },
    defaultVariants: { variant: 'primary', size: 'md' },
  },
);

export interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof button> {
  asChild?: boolean;
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant, size, asChild, ...props }, ref) => {
    const Comp = asChild ? Slot : 'button';
    return <Comp ref={ref} className={cn(button({ variant, size }), className)} {...props} />;
  },
);
Button.displayName = 'Button';
