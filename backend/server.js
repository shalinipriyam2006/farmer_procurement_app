const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const env = require('./config/env');
const dbPool = require('./db/pool');
const db = require('./data/database');

const authRoutes = require('./routes/auth');
const procurementRoutes = require('./routes/procurement');
const farmerRoutes = require('./routes/farmer');
const officerRoutes = require('./routes/officer');
const grievanceRoutes = require('./routes/grievance');
const documentRoutes = require('./routes/document');
const eventRoutes = require('./routes/events');
const verifyRoutes = require('./routes/verify');

const app = express();

// Security: Configurable CORS
const corsOptions = {
  origin: env.corsOrigin === '*' ? '*' : env.corsOrigin.split(',').map(o => o.trim()),
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Device-Id', 'X-Device-Secret'],
};
app.use(cors(corsOptions));
app.use(express.json());

// Security: Rate limiter for authentication endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 30, // Limit each IP to 30 authentication requests per windowMs
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    message: 'Too many authentication attempts from this IP, please try again after 15 minutes.',
  },
});

// API Base Router
app.use('/api/v1/auth', authLimiter, authRoutes);
app.use('/api/v1/procurement', procurementRoutes);
app.use('/api/v1/farmers', farmerRoutes);
app.use('/api/v1/officer', officerRoutes);
app.use('/api/v1/grievances', grievanceRoutes);
app.use('/api/v1/documents', documentRoutes);
app.use('/api/v1/events', eventRoutes);
app.use('/api/v1/verify', verifyRoutes);

// Database-Aware Healthcheck Endpoint
app.get('/api/v1/health', async (req, res) => {
  const dbHealth = await dbPool.checkConnection();
  const status = dbHealth.healthy ? 'HEALTHY' : (dbHealth.mode === 'in-memory-fallback' ? 'DEGRADED_LOCAL_FALLBACK' : 'UNHEALTHY');
  
  res.status(dbHealth.healthy || dbHealth.mode === 'in-memory-fallback' ? 200 : 500).json({
    status,
    service: 'Farmer Procurement API Gateway',
    timestamp: new Date().toISOString(),
    database: {
      healthy: dbHealth.healthy,
      mode: dbHealth.mode,
      details: dbHealth.error || dbHealth.reason || 'PostgreSQL database connected and serving queries',
    },
  });
});

const server = app.listen(env.port, '0.0.0.0', async () => {
  console.log(`=======================================================`);
  console.log(` Farmer Procurement Backend API running on 0.0.0.0:${env.port}`);
  console.log(` Base Endpoint: http://0.0.0.0:${env.port}/api/v1`);
  console.log(` Environment:   ${env.nodeEnv}`);
  console.log(`=======================================================`);

  // Attempt database sync on startup
  await db.syncFromPostgres();
});

// Graceful Shutdown Handling
async function handleGracefulShutdown(signal) {
  console.log(`\nReceived ${signal}. Shutting down server gracefully...`);
  server.close(async () => {
    console.log('HTTP Server closed.');
    await dbPool.closePool();
    process.exit(0);
  });

  // Force exit if shutdown takes too long (10 seconds timeout)
  setTimeout(() => {
    console.error('Could not close connections in time, forcing shutdown.');
    process.exit(1);
  }, 10000);
}

process.on('SIGINT', () => handleGracefulShutdown('SIGINT'));
process.on('SIGTERM', () => handleGracefulShutdown('SIGTERM'));

module.exports = app;
