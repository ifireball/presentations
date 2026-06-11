import { spawn } from 'node:child_process';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import chokidar from 'chokidar';
import { generateIndex } from './generate-index.mjs';

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, '..');
const port = process.env.PORT || 8080;

await generateIndex();

const watcher = chokidar.watch(root, {
  ignored: [
    /(^|[/\\])\../,
    /node_modules/,
    /index\.html$/,
  ],
  ignoreInitial: true,
});

let regenTimer;
function scheduleRegen() {
  clearTimeout(regenTimer);
  regenTimer = setTimeout(() => {
    generateIndex().catch((err) => console.error('index regen failed:', err));
  }, 200);
}

watcher.on('addDir', scheduleRegen);
watcher.on('unlinkDir', scheduleRegen);

const server = spawn(
  'npx',
  [
    'live-server',
    root,
    `--port=${port}`,
    '--no-browser',
    '--watch=.',
    '--ignore=node_modules,.git',
  ],
  { stdio: 'inherit', cwd: root },
);

console.log(`Dev server at http://127.0.0.1:${port}/ (live reload enabled)`);

function shutdown() {
  watcher.close();
  server.kill('SIGTERM');
  process.exit(0);
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);

server.on('exit', (code) => {
  watcher.close();
  process.exit(code ?? 0);
});
