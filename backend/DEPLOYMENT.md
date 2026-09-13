# Render Cloud Deployment Guide - Farmer Procurement Backend

Beginner-friendly step-by-step guide for deploying the Node.js Express Backend and PostgreSQL database on **Render** (https://render.com).

---

## 1. Required Cloud Architecture on Render

- **Render PostgreSQL**: Managed relational database storing all 12 core system entities.
- **Render Web Service**: Node.js v18/v20 Express server serving public HTTPS REST API endpoints.

---

## 2. Step-by-Step Deployment Instructions

### Step A: Push Code to GitHub
1. Create a repository on GitHub (e.g. `farmer_procurement_app`).
2. Commit and push your codebase:
   ```bash
   git add .
   git commit -m "Prepare production backend & PostgreSQL persistence"
   git push origin main
   ```
   > **Note**: Verify that `.env` files are ignored by git and not uploaded to GitHub.

---

### Step B: Create PostgreSQL Database on Render
1. Log in to [Render Dashboard](https://dashboard.render.com).
2. Click **New +** -> **PostgreSQL**.
3. Fill in details:
   - **Name**: `farmer-procurement-db`
   - **Database**: `farmer_procurement`
   - **User**: `procurement_user`
   - **Region**: Choose closest to target users (e.g. Singapore / Frankfurt / Oregon)
   - **Plan**: Free / Basic
4. Click **Create Database**.
5. Once created, copy the **Internal Database URL** (e.g. `postgresql://procurement_user:password@dpg-xxxxxx-a.render.com/farmer_procurement`).

---

### Step C: Create Web Service on Render
1. Click **New +** -> **Web Service**.
2. Select **Build and deploy from a Git repository** and select your repository.
3. Fill in configuration settings:
   - **Name**: `farmer-procurement-api`
   - **Root Directory**: `backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install && npm run db:migrate`
   - **Start Command**: `npm start`
4. Expand **Advanced** -> **Health Check Path**: `/api/v1/health`

---

### Step D: Configure Environment Variables
Under the **Environment Variables** section on Render, add:

| Key | Example / Description |
|---|---|
| `NODE_ENV` | `production` |
| `DATABASE_URL` | *(Paste Internal Database URL from Step B)* |
| `JWT_SECRET` | *(Generate strong random string, e.g. `prod_jwt_secret_8492049281`)* |
| `CORS_ORIGIN` | `*` |
| `API_BASE_URL` | `https://farmer-procurement-api.onrender.com/api/v1` |

Click **Save Changes** and click **Deploy Web Service**.

---

## 3. Verification & HTTPS Endpoint

1. Once deployment succeeds, Render assigns a public HTTPS URL:
   `https://farmer-procurement-api.onrender.com`
2. Test the healthcheck endpoint in your browser or curl:
   `GET https://farmer-procurement-api.onrender.com/api/v1/health`
3. Response should return HTTP status `200`:
   ```json
   {
     "status": "HEALTHY",
     "service": "Farmer Procurement API Gateway",
     "timestamp": "2026-09-13T16:00:00.000Z",
     "database": {
       "healthy": true,
       "mode": "postgresql",
       "details": "PostgreSQL database connected and serving queries"
     }
   }
   ```

---

## 4. Connecting Flutter Application to Cloud Backend

In `lib/config/app_config.dart`, update `apiBaseUrl` with your Render HTTPS endpoint:

```dart
static const String apiBaseUrl = 'https://farmer-procurement-api.onrender.com/api/v1';
```

Then compile the release APK:
```bash
flutter build apk --release
```
