// Использует вход установленного Firebase CLI без сервисного ключа в репозитории.
// Временные ADC доступны только владельцу и удаляются после выполнения seed.
import { access, mkdtemp, realpath, rm, writeFile } from 'node:fs/promises';
import { constants } from 'node:fs';
import { createRequire } from 'node:module';
import { delimiter, join } from 'node:path';
import { tmpdir } from 'node:os';
import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';

let cliRequire;
for (const directory of (process.env.PATH ?? '').split(delimiter)) {
  const executable = join(directory, 'firebase');
  try {
    await access(executable, constants.X_OK);
    const candidate = createRequire(await realpath(executable));
    candidate.resolve('firebase-tools/lib/auth.js');
    cliRequire = candidate;
    break;
  } catch { /* Проверяем следующий каталог PATH. */ }
}
if (!cliRequire) throw new Error('Установите Firebase CLI (npm install -g firebase-tools) и выполните firebase login.');
const auth = cliRequire('firebase-tools/lib/auth.js');
const api = cliRequire('firebase-tools/lib/api.js');
const projectRoot = fileURLToPath(new URL('../../', import.meta.url));
const account = auth.getProjectDefaultAccount(projectRoot);
if (!account?.tokens?.refresh_token) throw new Error('Нет сессии Firebase CLI. Выполните firebase login.');

const directory = await mkdtemp(join(tmpdir(), 'clothesshop-seed-'));
try {
  const credentials = join(directory, 'credentials.json');
  await writeFile(credentials, JSON.stringify({
    type: 'authorized_user',
    client_id: api.clientId(),
    client_secret: api.clientSecret(),
    refresh_token: account.tokens.refresh_token,
  }), { mode: 0o600 });
  const code = await new Promise((resolve, reject) => {
    const child = spawn('npm', ['run', 'seed', '--', ...process.argv.slice(2)], {
      cwd: fileURLToPath(new URL('./', import.meta.url)),
      env: { ...process.env, GOOGLE_APPLICATION_CREDENTIALS: credentials },
      stdio: 'inherit',
    });
    child.on('error', reject);
    child.on('exit', (code) => resolve(code ?? 1));
  });
  process.exitCode = code;
} finally {
  await rm(directory, { recursive: true, force: true });
}
