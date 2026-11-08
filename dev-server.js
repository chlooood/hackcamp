// Local dev server: serves public/ and runs the api/ functions the way Vercel does.
//   npm install
//   cp .env.example .env   (then fill in the values; .env is never committed)
//   npm run dev            -> http://localhost:3000
const http = require('http');
const fs = require('fs');
const path = require('path');

// Load .env without a dependency.
try {
  fs.readFileSync(path.join(__dirname, '.env'), 'utf8').split('\n').forEach((line) => {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*)\s*$/);
    if (m && process.env[m[1]] === undefined) process.env[m[1]] = m[2].replace(/^['"]|['"]$/g, '');
  });
} catch (e) { /* no .env: demo only */ }

const PORT = Number(process.env.PORT || 3000);
const ROOT = path.join(__dirname, 'public');
const TYPES = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.json': 'application/json', '.webmanifest': 'application/manifest+json', '.png': 'image/png', '.svg': 'image/svg+xml', '.css': 'text/css' };
const ROUTES = { '/api/scan': './api/scan', '/api/data': './api/data', '/api/auth': './api/auth' };

function vercelRes(res) {
  res.status = (c) => { res.statusCode = c; return res; };
  res.json = (obj) => { res.setHeader('Content-Type', 'application/json'); res.end(JSON.stringify(obj)); return res; };
  res.send = (b) => { res.end(b); return res; };
  return res;
}
function readBody(req) {
  return new Promise((resolve, reject) => {
    const chunks = []; let size = 0;
    req.on('data', (c) => { size += c.length; if (size > 5e6) { reject(new Error('too big')); req.destroy(); } else chunks.push(c); });
    req.on('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
  });
}

http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost');
  let route = url.pathname;
  const m = route.match(/^\/api\/auth\/([a-z]+)$/);       // same rewrite as vercel.json
  if (m) { route = '/api/auth'; url.searchParams.set('action', m[1]); }
  if (ROUTES[route]) {
    vercelRes(res);
    req.query = Object.fromEntries(url.searchParams);
    if (req.method === 'POST') {
      try { const raw = await readBody(req); req.body = raw ? JSON.parse(raw) : {}; }
      catch (e) { return res.status(400).json({ error: 'bad_json' }); }
    }
    try { await require(ROUTES[route])(req, res); }
    catch (e) { console.error(e); if (!res.headersSent) res.status(500).json({ error: 'server_error' }); }
    return;
  }
  // static files
  let file = path.normalize(path.join(ROOT, decodeURIComponent(url.pathname)));
  if (!file.startsWith(ROOT)) { res.statusCode = 403; return res.end(); }
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, 'index.html');
  fs.readFile(file, (err, data) => {
    if (err) { res.statusCode = 404; return res.end('Not found'); }
    res.setHeader('Content-Type', TYPES[path.extname(file)] || 'application/octet-stream');
    res.end(data);
  });
}).listen(PORT, () => {
  const has = (k) => (process.env[k] ? 'yes' : 'no');
  console.log('Plop dev server on http://localhost:' + PORT);
  console.log('  Gemini key: ' + has('GEMINI_API_KEY') + ' | Auth0: ' + has('AUTH0_CLIENT_SECRET') + ' | Database: ' + has('DATABASE_URL'));
});
