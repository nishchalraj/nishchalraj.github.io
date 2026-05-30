import { Hero } from '@/components/marketing/Hero';
import { Features } from '@/components/marketing/Features';
import { TechniqueStrip } from '@/components/marketing/TechniqueStrip';
import { CTA } from '@/components/marketing/CTA';

export default function LandingPage() {
  return (
    <main>
      <Hero />
      <Features />
      <TechniqueStrip />
      <CTA />
    </main>
  );
}
