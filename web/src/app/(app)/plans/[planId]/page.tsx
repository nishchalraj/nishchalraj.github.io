import { notFound } from 'next/navigation';
import { PLANS, PLAN_BY_ID } from '@/content/plans';
import { PlanDetailClient } from './client';

export function generateStaticParams() {
  return PLANS.map((p) => ({ planId: p.id }));
}

export default async function PlanDetail({ params }: { params: Promise<{ planId: string }> }) {
  const { planId } = await params;
  const plan = PLAN_BY_ID[planId];
  if (!plan) return notFound();
  return <PlanDetailClient plan={plan} />;
}
