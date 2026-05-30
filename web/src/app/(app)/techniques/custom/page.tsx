'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion } from 'framer-motion';
import { TopBar } from '@/components/nav/TopBar';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Play } from 'lucide-react';

function Slider({
  label, value, min, max, onChange, suffix = 's',
}: {
  label: string; value: number; min: number; max: number;
  onChange: (v: number) => void; suffix?: string;
}) {
  return (
    <div>
      <div className="flex justify-between items-baseline mb-2">
        <span className="text-sm text-foreground-soft">{label}</span>
        <span className="text-display text-xl tabular-nums">{value}{suffix}</span>
      </div>
      <input
        type="range"
        min={min} max={max} value={value}
        onChange={(e) => onChange(+e.target.value)}
        className="w-full accent-primary"
      />
    </div>
  );
}

export default function CustomBuilderPage() {
  const router = useRouter();
  const [inhale, setInhale]   = useState(4);
  const [hold1,  setHold1]    = useState(4);
  const [exhale, setExhale]   = useState(4);
  const [hold2,  setHold2]    = useState(4);
  const [cycles, setCycles]   = useState(8);

  const totalMin = Math.round(((inhale + hold1 + exhale + hold2) * cycles) / 60);

  const begin = () => {
    const qs = new URLSearchParams({
      i: String(inhale), h1: String(hold1), e: String(exhale), h2: String(hold2), c: String(cycles),
    });
    router.push(`/session/custom?${qs}`);
  };

  return (
    <>
      <TopBar title="Custom pattern" back="/techniques" />
      <main className="mx-auto max-w-md px-5 pt-4 pb-32">
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.4, ease: [0.16, 1, 0.3, 1] }}
        >
          <div className="mx-auto aspect-square w-full max-w-[200px] relative grid place-items-center">
            <motion.div
              className="absolute rounded-full bg-gradient-to-br from-primary/40 to-primary-soft/30"
              style={{ width: '85%', height: '85%' }}
              animate={{ scale: [0.7, 1, 0.7] }}
              transition={{ duration: inhale + hold1 + exhale + hold2, repeat: Infinity, ease: 'easeInOut' }}
            />
            <div className="relative h-16 w-16 rounded-full bg-primary text-white grid place-items-center text-xs font-mono">
              {inhale}-{hold1}-{exhale}-{hold2}
            </div>
          </div>
          <p className="text-center text-foreground-soft text-sm mt-3">
            ~{totalMin} min · {cycles} cycles
          </p>

          <Card className="p-6 mt-6 space-y-5">
            <Slider label="Inhale" value={inhale} min={1} max={12} onChange={setInhale} />
            <Slider label="Hold"   value={hold1}  min={0} max={12} onChange={setHold1} />
            <Slider label="Exhale" value={exhale} min={1} max={16} onChange={setExhale} />
            <Slider label="Hold"   value={hold2}  min={0} max={12} onChange={setHold2} />
            <Slider label="Cycles" value={cycles} min={1} max={30} onChange={setCycles} suffix="" />
          </Card>

          <Button size="lg" onClick={begin} className="mt-6 w-full">
            <Play size={18} /> Start session
          </Button>
        </motion.div>
      </main>
    </>
  );
}
