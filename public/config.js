// Supabase connection for Plop. Leave both empty to run on demo data only.
// From Supabase: Project Settings > API (Project URL and the publishable / "anon public" key).
// The publishable key is designed to be public: row level security in db/schema.sql protects the data.
// NEVER put the service role / secret key (sb_secret_...) here or anywhere in the repo.
window.PLOP_CONFIG = {
  supabaseUrl: 'https://dsqpjrydaqggddjneppq.supabase.co',
  supabaseAnonKey: 'sb_publishable_tRgBdFX_iDLZEOFrdpoKZw_Sbdlmpne'
};
