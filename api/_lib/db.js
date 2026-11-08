// One Postgres connection pool per server instance. DATABASE_URL is the Supabase
// "Transaction pooler" connection string (port 6543), which needs prepare: false.
const postgres = require('postgres');

let sql = null;
function db() {
  if (sql) return sql;
  const url = process.env.DATABASE_URL;
  if (!url) throw new Error('DATABASE_URL missing');
  const local = /@(localhost|127\.0\.0\.1)[:/]/.test(url);
  sql = postgres(url, {
    prepare: false,
    ssl: local ? false : 'require',
    max: 3,
    idle_timeout: 20,
    connect_timeout: 10
  });
  return sql;
}
module.exports = { db };
