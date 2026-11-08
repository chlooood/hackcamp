// POST /api/data  { op, ...args }  -> JSON
// Every op needs a valid Auth0 session cookie and only ever touches the logged-in user's rows.
// Buddies are read through buddy_activity(), which returns activity only (never entries).
const S = require('./_lib/session');
const { db } = require('./_lib/db');

const DAY = /^\d{4}-\d{2}-\d{2}$/;
const COLOURS = ['brown', 'light brown', 'dark brown', 'yellow', 'green', 'pale', 'reddish', 'black', 'unclear'];
const CHIPS = ['Stress', 'New food', 'Travel', 'Bad sleep', 'Meds', 'Bloated', 'Cramps', 'On my period'];
// Profile fields a user may change, with a check for each.
const PROFILE_FIELDS = {
  display_name: (v) => typeof v === 'string' && v.trim().length <= 40 ? v.trim() : undefined,
  mascot: (v) => /^#[0-9A-Fa-f]{6}$/.test(v) ? v : undefined,
  tier: (v) => Number.isInteger(v) && v >= 0 && v <= 6 ? v : undefined,
  div: (v) => Number.isInteger(v) && v >= 1 && v <= 3 ? v : undefined,
  gp: (v) => Number.isInteger(v) && v >= 0 && v <= 99 ? v : undefined,
  shields: (v) => Number.isInteger(v) && v >= 0 && v <= 2 ? v : undefined,
  mode: (v) => v === 'ranked' || v === 'casual' ? v : undefined,
  league_joined: (v) => typeof v === 'boolean' ? v : undefined,
  share_checkin: (v) => typeof v === 'boolean' ? v : undefined,
  share_streak: (v) => typeof v === 'boolean' ? v : undefined,
  share_rank: (v) => typeof v === 'boolean' ? v : undefined,
  discreet: (v) => typeof v === 'boolean' ? v : undefined,
  paused: (v) => typeof v === 'boolean' ? v : undefined,
  global_on: (v) => typeof v === 'boolean' ? v : undefined,
  plain_names: (v) => typeof v === 'boolean' ? v : undefined,
  notes: (v) => typeof v === 'string' && v.length <= 2000 ? v : undefined
};

class Bad extends Error {}
const need = (cond, msg) => { if (!cond) throw new Bad(msg); };
const day = (v) => { need(typeof v === 'string' && DAY.test(v), 'bad day'); return v; };

function entryRow(r) {
  need(r && typeof r === 'object', 'bad entry');
  need(r.kind === 'scan' || r.kind === 'pick', 'bad kind');
  const int = (v, lo, hi) => v == null ? null : (Number.isInteger(v) && v >= lo && v <= hi ? v : need(false, 'bad number'));
  return {
    day: day(r.day), kind: r.kind,
    score: int(r.score, 0, 100), bristol: int(r.bristol, 1, 7),
    colour: r.colour == null ? null : (COLOURS.includes(r.colour) ? r.colour : need(false, 'bad colour')),
    confidence: r.confidence == null ? null : Math.max(0, Math.min(1, Number(r.confidence) || 0)),
    comfort: int(r.comfort == null ? 0 : r.comfort, 0, 3),
    chips: Array.isArray(r.chips) ? r.chips.filter((c) => CHIPS.includes(c)).slice(0, 8) : [],
    blood: r.blood === true
  };
}

async function load(sql, me, user, today) {
  const [p] = await sql`select * from ensure_profile(${me}, ${user.name || ''})`;
  const since = new Date(Date.parse(today) - 60 * 864e5).toISOString().slice(0, 10);
  const gpSince = new Date(Date.parse(today) - 14 * 864e5).toISOString().slice(0, 10);
  const entries = await sql`select to_char(day, 'YYYY-MM-DD') as day, kind, score, bristol, colour, confidence, comfort, chips, blood
                            from entries where user_id = ${me} and day >= ${since} order by day`;
  const gp = await sql`select to_char(day, 'YYYY-MM-DD') as day, sum(delta)::int as delta from gp_events
                       where user_id = ${me} and day >= ${gpSince} group by day`;
  return { profile: p, entries, gp, buddies: await buddies(sql, me, today) };
}
async function buddies(sql, me, today) {
  return sql`select * from buddy_activity(${me}, ${today})`;
}

const OPS = {
  async load(sql, me, b, user) { return load(sql, me, user, day(b.today)); },
  async buddies(sql, me, b) { return { buddies: await buddies(sql, me, day(b.today)) }; },
  async entry(sql, me, b) {
    const r = entryRow(b.row);
    await sql`insert into entries ${sql({ user_id: me, ...r })}
              on conflict (user_id, day) do update set
                kind = excluded.kind, score = excluded.score, bristol = excluded.bristol, colour = excluded.colour,
                confidence = excluded.confidence, comfort = excluded.comfort, chips = excluded.chips, blood = excluded.blood`;
    return { ok: true };
  },
  async delEntry(sql, me, b) { await sql`delete from entries where user_id = ${me} and day = ${day(b.day)}`; return { ok: true }; },
  async gp(sql, me, b) {
    const r = b.row || {};
    need(Number.isInteger(r.delta) && Math.abs(r.delta) <= 200, 'bad delta');
    need(typeof r.reason === 'string' && r.reason.length <= 60, 'bad reason');
    await sql`insert into gp_events (user_id, day, delta, reason) values (${me}, ${day(r.day)}, ${r.delta}, ${r.reason})`;
    return { ok: true };
  },
  async profile(sql, me, b) {
    const patch = {};
    Object.keys(b.patch || {}).forEach((k) => {
      if (!PROFILE_FIELDS[k]) return;
      const v = PROFILE_FIELDS[k](b.patch[k]);
      if (v !== undefined) patch[k] = v;
    });
    need(Object.keys(patch).length, 'nothing to update');
    await sql`update profiles set ${sql(patch)} where id = ${me}`;
    return { ok: true };
  },
  async cheer(sql, me, b) {
    need(typeof b.to === 'string', 'bad buddy');
    const d = day(b.day);
    if (b.on) {
      // only to an accepted buddy
      const n = await sql`insert into cheers (from_id, to_id, day)
                          select ${me}, ${b.to}, ${d} where exists (select 1 from buddies where user_id = ${me} and buddy_id = ${b.to})
                          on conflict do nothing returning 1`;
      return { ok: true, sent: n.length > 0 };
    }
    await sql`delete from cheers where from_id = ${me} and to_id = ${b.to} and day = ${d}`;
    return { ok: true };
  },
  async invite(sql, me, b, user) {
    need(typeof b.code === 'string' && b.code.length <= 16, 'bad code');
    await sql`select ensure_profile(${me}, ${user.name || ''})`;
    try {
      const [r] = await sql`select accept_invite(${me}, ${b.code}) as name`;
      return { ok: true, name: r.name, buddies: await buddies(sql, me, day(b.today)) };
    } catch (e) {
      throw new Bad(/own invite/.test(e.message) ? 'own_invite' : 'invite_not_found');
    }
  },
  async remove(sql, me, b) {
    need(typeof b.buddy === 'string', 'bad buddy');
    await sql`select remove_buddy(${me}, ${b.buddy})`;
    return { ok: true, buddies: await buddies(sql, me, day(b.today)) };
  },
  async demoJoin(sql, me, b) {
    try {
      const [r] = await sql`select demo_join(${me}) as n`;
      return { ok: true, added: r.n, buddies: await buddies(sql, me, day(b.today)) };
    } catch (e) { throw new Bad('seed_missing'); }
  },
  async deleteMe(sql, me) {
    // Cascades to entries, GP, buddies and cheers. The Auth0 login itself is removed by
    // logging out; deleting the Auth0 account needs the Management API (see DEPLOY.md).
    await sql`delete from profiles where id = ${me}`;
    return { ok: true };
  }
};

async function handler(req, res) {
  res.setHeader('Cache-Control', 'no-store');
  if (req.method !== 'POST') return res.status(405).json({ error: 'post_only' });
  let session;
  try { session = S.getSession(req); } catch (e) { return res.status(503).json({ error: 'login_not_configured' }); }
  if (!session) return res.status(401).json({ error: 'not_logged_in' });
  const b = req.body || {};
  const op = OPS[b.op];
  if (!op) return res.status(400).json({ error: 'unknown_op' });
  try {
    const sql = db();
    return res.status(200).json(await op(sql, session.sub, b, session));
  } catch (e) {
    if (e instanceof Bad) return res.status(400).json({ error: e.message });
    // Don't leak SQL details. The op name is enough to debug.
    console.error('data op failed', b.op, e && e.code);
    return res.status(500).json({ error: 'server_error' });
  }
}

module.exports = handler;
