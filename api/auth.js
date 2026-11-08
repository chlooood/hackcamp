// Auth0 login, server side. One function, four routes (vercel.json rewrites /api/auth/:action):
//   GET /api/auth/login     -> sends you to Auth0's login page (authorization code + PKCE)
//   GET /api/auth/callback  -> Auth0 sends you back here; we swap the code for your identity
//   GET /api/auth/me        -> who is logged in (and whether login is set up at all)
//   GET /api/auth/logout    -> clears the session and logs you out of Auth0
// Env: AUTH0_DOMAIN, AUTH0_CLIENT_ID, AUTH0_CLIENT_SECRET, AUTH0_SECRET (and DATABASE_URL for "configured").
const crypto = require('crypto');
const S = require('./_lib/session');
const { db } = require('./_lib/db');

function cfg() {
  return {
    domain: (process.env.AUTH0_DOMAIN || '').replace(/^https?:\/\//, '').replace(/\/$/, ''),
    clientId: process.env.AUTH0_CLIENT_ID || '',
    clientSecret: process.env.AUTH0_CLIENT_SECRET || ''
  };
}
function configured() {
  const c = cfg();
  return !!(c.domain && c.clientId && c.clientSecret && process.env.AUTH0_SECRET && process.env.DATABASE_URL);
}
function redirect(res, url, cookies) {
  if (cookies && cookies.length) res.setHeader('Set-Cookie', cookies);
  res.statusCode = 302;
  res.setHeader('Location', url);
  res.end();
}
function decodeJwt(token) {
  const part = String(token || '').split('.')[1];
  return JSON.parse(Buffer.from(part.replace(/-/g, '+').replace(/_/g, '/'), 'base64').toString('utf8'));
}
// Ask Auth0 whether it will accept a login from this address, so the app never sends people to
// Auth0's "Callback URL mismatch" error page. Cached for a few minutes per address.
const loginChecks = {};
async function loginCheck(base, fetchImpl) {
  const hit = loginChecks[base];
  if (hit && hit.until > Date.now()) return hit.result;
  const c = cfg();
  const u = new URL('https://' + c.domain + '/authorize');
  u.search = new URLSearchParams({ response_type: 'code', client_id: c.clientId, redirect_uri: base + '/api/auth/callback', scope: 'openid', state: 'check' }).toString();
  let result = { ready: true, problem: null };
  try {
    const r = await fetchImpl(u.toString(), { redirect: 'manual' });
    if (r.status >= 400) {
      const t = (await r.text()).toLowerCase();
      if (t.includes('callback url mismatch')) result = { ready: false, problem: 'callback_url' };
      else if (t.includes('unauthorized_client') || t.includes('unknown client')) result = { ready: false, problem: 'client' };
      else result = { ready: false, problem: 'auth0_' + r.status };
    }
  } catch (e) {
    result = { ready: true, problem: null }; // can't reach Auth0 from here: don't block, let the user try
  }
  loginChecks[base] = { result, until: Date.now() + (result.ready ? 10 : 2) * 60e3 };
  return result;
}

async function recordLogin(sub, name) {
  try {
    const provider = String(sub).split('|')[0];
    const sql = db();
    try { await sql`select record_login(${sub}, ${name}, ${provider})`; }
    catch (e) { await sql`select ensure_profile(${sub}, ${name})`; } // database without db/tiger.sql
  } catch (e) { console.error('record login failed', e && e.code); }
}

function action(req) {
  const q = req.query && req.query.action;
  if (q) return String(q);
  const m = String(req.url || '').match(/\/api\/auth\/([a-z]+)/);
  return m ? m[1] : (new URL(req.url, 'http://x').searchParams.get('action') || '');
}

async function handler(req, res, fetchImpl = fetch) {
  res.setHeader('Cache-Control', 'no-store');
  const a = action(req);
  const c = cfg();
  const base = S.baseUrl(req);

  if (a === 'me') {
    const s = configured() ? S.getSession(req) : null;
    const check = configured() && !s ? await loginCheck(base, fetchImpl) : { ready: configured(), problem: null };
    return res.status(200).json({
      configured: configured(), loginReady: check.ready, loginProblem: check.problem,
      callbackUrl: base + '/api/auth/callback',
      user: s ? { sub: s.sub, name: s.name, picture: s.picture } : null
    });
  }
  if (!configured()) return res.status(503).json({ error: 'login_not_configured' });

  if (a === 'login') {
    const verifier = S.b64url(crypto.randomBytes(32));
    const tx = { state: S.b64url(crypto.randomBytes(16)), nonce: S.b64url(crypto.randomBytes(16)), verifier, exp: Date.now() + 10 * 60e3 };
    const challenge = S.b64url(crypto.createHash('sha256').update(verifier).digest());
    const u = new URL('https://' + c.domain + '/authorize');
    u.search = new URLSearchParams({
      response_type: 'code', client_id: c.clientId, redirect_uri: base + '/api/auth/callback',
      scope: 'openid profile email', state: tx.state, nonce: tx.nonce,
      code_challenge: challenge, code_challenge_method: 'S256',
      ...(new URL(req.url, 'http://x').searchParams.get('signup') ? { screen_hint: 'signup' } : {})
    }).toString();
    return redirect(res, u.toString(), [S.cookie(req, S.TX_COOKIE, S.seal(tx), 600)]);
  }

  if (a === 'callback') {
    const q = new URL(req.url, 'http://x').searchParams;
    const tx = S.unseal(S.parseCookies(req)[S.TX_COOKIE] || '');
    const fail = (why) => redirect(res, base + '/?login=' + encodeURIComponent(why) + '#login', [S.clearCookie(req, S.TX_COOKIE)]);
    if (q.get('error')) return fail(q.get('error'));
    if (!tx || !q.get('code') || q.get('state') !== tx.state) return fail('expired');
    let tokens;
    try {
      const r = await fetchImpl('https://' + c.domain + '/oauth/token', {
        method: 'POST', headers: { 'content-type': 'application/json' },
        body: JSON.stringify({
          grant_type: 'authorization_code', client_id: c.clientId, client_secret: c.clientSecret,
          code: q.get('code'), redirect_uri: base + '/api/auth/callback', code_verifier: tx.verifier
        })
      });
      if (!r.ok) return fail('token_' + r.status);
      tokens = await r.json();
    } catch (e) { return fail('network'); }
    // The ID token came straight from Auth0 over TLS in exchange for our client secret, so we
    // check its claims (issuer, audience, nonce, expiry) rather than re-verify the signature.
    let id;
    try { id = decodeJwt(tokens.id_token); } catch (e) { return fail('bad_token'); }
    const okClaims = id.iss === 'https://' + c.domain + '/' &&
      (id.aud === c.clientId || (Array.isArray(id.aud) && id.aud.includes(c.clientId))) &&
      id.nonce === tx.nonce && id.exp * 1000 > Date.now() && id.sub;
    if (!okClaims) return fail('bad_token');
    const raw = id.given_name || id.nickname || id.name || '';
    const name = raw.includes('@') ? raw.split('@')[0] : raw;
    // Create the account in the database (Tiger) and record this login. A database hiccup
    // must not block logging in: the app creates the profile again on its first load.
    await recordLogin(id.sub, name);
    return redirect(res, base + '/#home', [
      S.sessionCookie(req, { sub: id.sub, name, picture: id.picture }),
      S.clearCookie(req, S.TX_COOKIE)
    ]);
  }

  if (a === 'logout') {
    const u = new URL('https://' + c.domain + '/v2/logout');
    u.search = new URLSearchParams({ client_id: c.clientId, returnTo: base + '/' }).toString();
    return redirect(res, u.toString(), [S.clearCookie(req, S.SESSION_COOKIE)]);
  }

  return res.status(404).json({ error: 'unknown_action' });
}

module.exports = handler;
module.exports.configured = configured;
