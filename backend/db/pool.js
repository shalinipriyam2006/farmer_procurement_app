const { Pool } = require('pg');
const env = require('../config/env');

let pool = null;
let isConnected = false;

if (env.databaseUrl && env.databaseUrl.startsWith('postgres')) {
  pool = new Pool({
    connectionString: env.databaseUrl,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 5000,
  });

  pool.on('error', (err) => {
    console.error('Unexpected error on idle PostgreSQL client:', err);
    isConnected = false;
  });
}

/**
 * Check if database is connected and healthy
 */
async function checkConnection() {
  if (!pool) return { healthy: false, mode: 'in-memory-fallback', reason: 'No DATABASE_URL postgres connection string configured' };
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW()');
    client.release();
    isConnected = true;
    return { healthy: true, mode: 'postgresql', serverTime: result.rows[0].now };
  } catch (err) {
    isConnected = false;
    return { healthy: false, mode: 'in-memory-fallback', error: err.message };
  }
}

/**
 * Execute SQL Query
 */
async function query(text, params) {
  if (!pool) {
    throw new Error('PostgreSQL pool not initialized');
  }
  return pool.query(text, params);
}

/**
 * Graceful pool shutdown
 */
async function closePool() {
  if (pool) {
    console.log('Closing PostgreSQL connection pool...');
    await pool.end();
    console.log('PostgreSQL pool closed successfully.');
  }
}

function setIsConnected(val) {
  isConnected = val;
}

module.exports = {
  pool,
  checkConnection,
  query,
  closePool,
  setIsConnected,
  get isDbConnected() {
    return isConnected;
  }
};
