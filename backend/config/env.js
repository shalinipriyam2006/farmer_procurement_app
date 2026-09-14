const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const nodeEnv = process.env.NODE_ENV || 'development';
const jwtSecret = process.env.JWT_SECRET || 'default_jwt_secret';
const otpDevMode = process.env.OTP_DEV_MODE === 'true' || nodeEnv !== 'production';

if (nodeEnv === 'production') {
  if (!process.env.JWT_SECRET || process.env.JWT_SECRET === 'default_jwt_secret') {
    console.error('FATAL ERROR: JWT_SECRET environment variable must be set to a secure string in production!');
    process.exit(1);
  }
}

module.exports = {
  nodeEnv,
  otpDevMode,
  port: process.env.PORT || 3000,
  apiBaseUrl: process.env.API_BASE_URL || 'http://localhost:3000/api/v1',
  govtApiBaseUrl: process.env.GOVERNMENT_API_BASE_URL || '',
  govtApiKey: process.env.GOVERNMENT_API_KEY || '',
  databaseUrl: process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5432/farmer_procurement',
  jwtSecret,
  corsOrigin: process.env.CORS_ORIGIN || '*',
  mapsApiKey: process.env.MAPS_API_KEY || '',
};
