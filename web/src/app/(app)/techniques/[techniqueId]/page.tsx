import { notFound } from 'next/navigation';
import { TECHNIQUES, techniqueById } from '@/features/breathing/techniques';
import { TechniqueDetailClient } from './client';

export function generateStaticParams() {
  return TECHNIQUES.map((t) => ({ techniqueId: t.id }));
}

export default async function TechniqueDetail({
  params,
}: {
  params: Promise<{ techniqueId: string }>;
}) {
  const { techniqueId } = await params;
  const technique = techniqueById(techniqueId);
  if (!technique) return notFound();
  return <TechniqueDetailClient technique={technique} />;
}
