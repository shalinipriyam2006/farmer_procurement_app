const fs = require('fs');
const path = require('path');
const { pool, isPostgresConnected } = require('./pool');

async function runMigrations() {
  console.log('[DB Migration] Starting PostgreSQL schema migration...');
  const isConnected = await isPostgresConnected();
  
  if (!isConnected) {
    console.log('[DB Migration] PostgreSQL connection unavailable. Schema migration skipped (using in-memory fallback store for local dev).');
    return;
  }

  try {
    const sqlPath = path.join(__dirname, 'schema.sql');
    const sql = fs.readFileSync(sqlPath, 'utf-8');
    await pool.query(sql);
    console.log('[DB Migration] PostgreSQL database schema migration completed successfully!');
  } catch (err) {
    console.error('[DB Migration Error] Migration failed:', err.message);
  }
}

if (require.main === module) {
  runMigrations().then(() => process.exit(0));
}

module.exports = { runMigrations };
