import { notFound } from 'next/navigation';
import { ARTICLES, ARTICLE_BY_SLUG } from '@/content/articles';
import { ArticleClient } from './client';

export function generateStaticParams() {
  return ARTICLES.map((a) => ({ slug: a.slug }));
}

export default async function ArticlePage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const article = ARTICLE_BY_SLUG[slug];
  if (!article) return notFound();
  return <ArticleClient article={article} />;
}
