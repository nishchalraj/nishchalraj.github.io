export interface Article {
  slug: string;
  title: string;
  excerpt: string;
  readMin: number;
  body: string;
}

export const ARTICLES: Article[] = [
  {
    slug: 'how-to-breathe-478',
    title: 'How to breathe 4-7-8',
    excerpt: 'A simple sequence that signals the body to slow down.',
    readMin: 3,
    body: `
The 4-7-8 pattern was popularized by Dr. Andrew Weil but draws from pranayama traditions thousands of years old.

**The pattern**
1. Inhale through your nose for 4 seconds.
2. Hold for 7 seconds.
3. Exhale through your mouth for 8 seconds.

The long exhale is the active ingredient. A slow exhale stimulates the vagus nerve, which downshifts the autonomic nervous system from sympathetic ("alert") to parasympathetic ("rest"). After four cycles, most people notice a measurable drop in heart rate.

**When to use**
- Before sleep — the long exhale helps the transition.
- During acute anxiety — it interrupts the breath-rate feedback loop.
- After a difficult conversation — to reset.

**A note**
You do not need to hold for exactly 7. The ratio matters more than the number. Two-to-one exhale-to-inhale is the floor; 4-7-8 is a gentle reach.
    `.trim(),
  },
  {
    slug: 'why-the-exhale-matters',
    title: 'Why the exhale matters more than the inhale',
    excerpt: 'The often-overlooked half of every breath cycle.',
    readMin: 3,
    body: `
We are taught to "take a deep breath." But it is the *exhale* that does the calming work.

When you exhale, your heart rate naturally drops — a phenomenon called respiratory sinus arrhythmia. Lengthening the exhale relative to the inhale amplifies this. It is the easiest, cheapest, most-available calming intervention you own.

A useful target: exhales twice as long as inhales. Inhale 4, exhale 8. Inhale 3, exhale 6. The ratio matters more than the absolute count.
    `.trim(),
  },
  {
    slug: 'box-breathing-for-focus',
    title: 'Box breathing for focus',
    excerpt: 'Why Navy SEALs use this technique under pressure.',
    readMin: 2,
    body: `
Box breathing — 4 in, 4 hold, 4 out, 4 hold — is famously used by Navy SEALs to stay composed under pressure. The reason is simple: it gives the prefrontal cortex something to do.

By making the breath rhythm intentional and counted, you give the brain a tiny task. That task occupies the same cognitive resources that anxiety would otherwise commandeer. The body calms, the mind clears, and decision-making improves.

For focus before deep work: 8 cycles, 4-4-4-4. About 2 minutes. Begin.
    `.trim(),
  },
];

export const ARTICLE_BY_SLUG = Object.fromEntries(ARTICLES.map((a) => [a.slug, a]));
