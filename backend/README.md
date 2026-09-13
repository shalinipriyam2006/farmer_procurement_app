# Farmer Procurement Management System - Backend API

Production-ready backend API service built with Node.js, Express, and PostgreSQL database persistence for the Farmer Procurement Management Platform.

---

## 1. System Requirements

- **Node.js**: v18.x or v20.x LTS
- **npm**: v9.x or higher
- **PostgreSQL**: v14.x or higher (or AWS RDS / Cloud SQL PostgreSQL)
- **OS**: Linux / macOS / Windows Server

---

## 2. Environment Configuration

Create a `.env` file inside the `backend/` directory or export environment variables:

```env
# Application Port & Node Environment
PORT=3000
NODE_ENV=production

# API Gateway URL
API_BASE_URL=https://your-domain.com/api/v1

# Security & CORS
JWT_SECRET=prod_super_secret_jwt_key_9847192837
CORS_ORIGIN=https://your-app-domain.com,http://localhost:3000

# PostgreSQL Database Connection String
DATABASE_URL=postgresql://procurement_user:secure_password@localhost:5432/farmer_procurement

# Optional Third-Party Government Service Adapters
GOVERNMENT_API_BASE_URL=
GOVERNMENT_API_KEY=
MAPS_API_KEY=
```

> **IMPORTANT**: In production (`NODE_ENV=production`), the application will refuse to start if `JWT_SECRET` is unset or left as the default placeholder.

---

## 3. Database Setup & Migrations

### A. Run Database Migration (Schema Setup)
Executes DDL to create all 12 relational entity tables (`users`, `farmers`, `officers`, `procurement_centres`, `tokens`, `queue_entries`, `procurement_records`, `payments`, `notifications`, `grievances`, `documents`, `audit_logs`) along with indexes and constraints:

```bash
npm run db:migrate
```

### B. Seed Development Data (Development ONLY)
Populates realistic sample data for local testing.

```bash
npm run db:seed
```

> **NOTE ON DATA SEEDING**:
> Development seed data is completely isolated in `db/seed.js` and is **NEVER** automatically executed in production mode. It provides realistic Tamil Nadu procurement scenario testing without impersonating or scraping government systems.

---

## 4. Running the Backend

### Development Mode
Runs local node server with fallback in-memory database support if PostgreSQL is offline:

```bash
npm run dev
# or
node server.js
```

### Production Mode
```bash
NODE_ENV=production JWT_SECRET=your_production_secret DATABASE_URL=postgresql://user:pass@host:5432/dbname npm start
```

---

## 5. Health Check & Monitoring Endpoint

- **Endpoint**: `GET /api/v1/health`
- **Response**:
```json
{
  "status": "HEALTHY",
  "service": "Farmer Procurement API Gateway",
  "timestamp": "2026-09-13T15:20:00.000Z",
  "database": {
    "healthy": true,
    "mode": "postgresql",
    "details": "PostgreSQL database connected and serving queries"
  }
}
```

---

## 6. Architecture & Security Features

1. **Entity Models**: Supports all 12 core system entities (`User`, `Farmer`, `Officer`, `ProcurementCentre`, `Token`, `QueueEntry`, `ProcurementRecord`, `Payment`, `Notification`, `Grievance`, `Document`, `AuditLog`).
2. **Rate Limiting**: Protects authentication endpoints (`/api/v1/auth/*`) against brute-force attacks using `express-rate-limit` (30 requests / 15 mins).
3. **CORS Control**: Strict origin validation configurable via `CORS_ORIGIN`.
4. **Graceful Shutdown**: Intercepts `SIGINT` / `SIGTERM` signals to drain connection pools cleanly before exiting.
5. **Government Adapter Compatibility**: Preserves `GovernmentProcurementService` adapter structure for future official API integrations.
