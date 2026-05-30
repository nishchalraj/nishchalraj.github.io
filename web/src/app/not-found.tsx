import Link from 'next/link';

export default function NotFound() {
  return (
    <main className="min-h-dvh grid place-items-center px-6">
      <div className="text-center">
        <p className="text-display text-7xl tracking-tight text-primary-strong">404</p>
        <p className="text-foreground-soft mt-3">This path is between breaths.</p>
        <Link
          href="/"
          className="mt-6 inline-block px-5 py-2.5 rounded-lg bg-primary text-white hover:bg-primary-strong transition-colors"
        >
          Return home
        </Link>
      </div>
    </main>
  );
}
