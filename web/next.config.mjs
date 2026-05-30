import { PHASE_DEVELOPMENT_SERVER } from 'next/constants.js';

/**
 * Dev mode uses the default `.next` dir (sibling to package.json) so
 * Node can resolve `node_modules` via normal lookup. Production export
 * redirects to `../docs` so GitHub Pages can serve niyam.yoga.
 */
export default function config(phase) {
  const isDev = phase === PHASE_DEVELOPMENT_SERVER;
  /** @type {import('next').NextConfig} */
  return {
    output: isDev ? undefined : 'export',
    distDir: isDev ? '.next' : '../docs',
    trailingSlash: true,
    images: { unoptimized: true },
    reactStrictMode: true,
    cleanDistDir: !isDev,
    experimental: {
      optimizePackageImports: ['framer-motion', 'lucide-react'],
    },
  };
}
