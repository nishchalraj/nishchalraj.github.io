// Copies CNAME and .nojekyll into the static export so GitHub Pages keeps serving
// niyam.yoga and doesn't process the output as Jekyll.
import { copyFile, writeFile, mkdir } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const webRoot = resolve(__dirname, '..');
const repoRoot = resolve(webRoot, '..');
const docs = resolve(repoRoot, 'docs');

await mkdir(docs, { recursive: true });

const cnameSrc = resolve(webRoot, 'CNAME');
if (existsSync(cnameSrc)) {
  await copyFile(cnameSrc, resolve(docs, 'CNAME'));
  console.log('[postbuild] CNAME copied');
}

await writeFile(resolve(docs, '.nojekyll'), '');
console.log('[postbuild] .nojekyll written');

console.log('[postbuild] done. niyam.yoga will serve from /docs');
