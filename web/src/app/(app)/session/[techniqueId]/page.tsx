import { Suspense } from 'react';
import { notFound } from 'next/navigation';
import { TECHNIQUES, techniqueById } from '@/features/breathing/techniques';
import { SessionPlayerClient } from './client';

export function generateStaticParams() {
  return [...TECHNIQUES.map((t) => ({ techniqueId: t.id })), { techniqueId: 'custom' }];
}

export const dynamicParams = false;

export default async function SessionPage({
  params,
}: {
  params: Promise<{ techniqueId: string }>;
}) {
  const { techniqueId } = await params;
  if (techniqueId !== 'custom') {
    const t = techniqueById(techniqueId);
    if (!t) return notFound();
  }
  return (
    <Suspense fallback={<div className="min-h-dvh grid place-items-center text-foreground-soft">Preparing…</div>}>
      <SessionPlayerClient techniqueId={techniqueId} />
    </Suspense>
  );
}
