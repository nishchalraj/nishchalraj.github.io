'use client';

import { motion } from 'framer-motion';
import { TopBar } from '@/components/nav/TopBar';
import type { Article } from '@/content/articles';

export function ArticleClient({ article }: { article: Article }) {
  return (
    <>
      <TopBar title="Learn" back="/learn" />
      <main className="mx-auto max-w-2xl px-5 pt-4 pb-32">
        <motion.article
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5, ease: [0.16, 1, 0.3, 1] }}
        >
          <p className="text-xs uppercase tracking-wider text-primary-strong dark:text-primary-soft">
            {article.readMin} min read
          </p>
          <h1 className="text-display text-5xl tracking-tight mt-2 leading-[1.05]">{article.title}</h1>
          <p className="text-foreground-soft text-lg mt-3 leading-relaxed">{article.excerpt}</p>
          <div className="mt-8 space-y-4 text-foreground/90 leading-relaxed whitespace-pre-line">
            {article.body}
          </div>
        </motion.article>
      </main>
    </>
  );
}
