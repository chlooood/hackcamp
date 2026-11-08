// Encrypted cookies for the Auth0 login. AES-256-GCM with a key derived from AUTH0_SECRET,
// so the browser can carry the session but can't read or forge it.
const crypto = require('crypto');

const SESSION_COOKIE = 'plop_session';
const TX_COOKIE = 'plop_tx';
const SESSION_DAYS = 14;

function key() {
  const s = process.env.AUTH0_SECRET;
  if (!s || s.length < 32) throw new Error('AUTH0_SECRET missing or too short');
  return crypto.createHash('sha256').update(s).digest();
}
function b64url(buf) { return Buffer.from(buf).toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, ''); }
function fromB64url(s) { return Buffer.from(s.replace(/-/g, '+').replace(/_/g, '/'), 'base64'); }

function seal(obj) {
  const iv = crypto.randomBytes(12);
  const c = crypto.createCipheriv('aes-256-gcm', key(), iv);
  const body = Buffer.concat([c.update(JSON.stringify(obj), 'utf8'), c.final()]);
  return b64url(Buffer.concat([iv, c.getAuthTag(), body]));
}
function unseal(token) {
  try {
    const raw = fromB64url(token);
    const d = crypto.createDecipheriv('aes-256-gcm', key(), raw.subarray(0, 12));
    d.setAuthTag(raw.subarray(12, 28));
    const obj = JSON.parse(Buffer.concat([d.update(raw.subarray(28)), d.final()]).toString('utf8'));
    if (obj.exp && obj.exp < Date.now()) return null;
    return obj;
  } catch (e) { return null; }
}

function parseCookies(req) {
  const out = {};
  String(req.headers.cookie || '').split(';').forEach((p) => {
    const i = p.indexOf('=');
    if (i > 0) out[p.slice(0, i).trim()] = decodeURIComponent(p.slice(i + 1).trim());
  });
  return out;
}
function isLocal(req) { return /^(localhost|127\.0\.0\.1|\[::1\])(:\d+)?$/.test(String(req.headers.host || '')); }
function cookie(req, name, value, maxAgeSec) {
  return [
    name + '=' + encodeURIComponent(value),
    'Path=/', 'HttpOnly', 'SameSite=Lax',
    isLocal(req) ? '' : 'Secure',
    'Max-Age=' + maxAgeSec
  ].filter(Boolean).join('; ');
}

function getSession(req) {
  const c = parseCookies(req)[SESSION_COOKIE];
  const s = c ? unseal(c) : null;
  return s && s.sub ? s : null;
}
function sessionCookie(req, user) {
  const exp = Date.now() + SESSION_DAYS * 864e5;
  return cookie(req, SESSION_COOKIE, seal({ sub: user.sub, name: user.name || '', picture: user.picture || '', exp }), SESSION_DAYS * 86400);
}
function clearCookie(req, name) { return cookie(req, name, '', 0); }

function baseUrl(req) {
  if (process.env.APP_BASE_URL) return process.env.APP_BASE_URL.replace(/\/$/, '');
  const proto = String(req.headers['x-forwarded-proto'] || (isLocal(req) ? 'http' : 'https')).split(',')[0];
  return proto + '://' + req.headers.host;
}

module.exports = { seal, unseal, parseCookies, cookie, getSession, sessionCookie, clearCookie, baseUrl, b64url, SESSION_COOKIE, TX_COOKIE };
