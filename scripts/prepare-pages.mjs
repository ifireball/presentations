import { cp, mkdir, rm } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { discoverPresentations, generateIndex } from './generate-index.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, '..');
const siteDir = join(root, '_site');

export async function preparePages() {
  await generateIndex();

  await rm(siteDir, { recursive: true, force: true });
  await mkdir(siteDir, { recursive: true });

  await cp(join(root, 'index.html'), join(siteDir, 'index.html'));
  await cp(join(root, '.nojekyll'), join(siteDir, '.nojekyll'));

  const presentations = await discoverPresentations();
  for (const presentation of presentations) {
    await cp(
      join(root, presentation.slug),
      join(siteDir, presentation.slug),
      { recursive: true },
    );
  }

  console.log(`Prepared _site/ (${presentations.length} presentation${presentations.length === 1 ? '' : 's'})`);
}

if (process.argv[1] && fileURLToPath(import.meta.url) === process.argv[1]) {
  preparePages().catch((err) => {
    console.error(err);
    process.exit(1);
  });
}
