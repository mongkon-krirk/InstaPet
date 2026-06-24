# InstaPET Deployment Guide

## Production Architecture

```text
Flutter App → Strapi (DigitalOcean App Platform) → PostgreSQL (Managed)
                                              → Cloudflare R2 (uploads)
```

## Environment Variables (Production)

```env
NODE_ENV=production
DATABASE_CLIENT=postgres
DATABASE_URL=<managed-postgres-url>
DATABASE_SSL=true

UPLOAD_PROVIDER=cloudflare-r2
R2_ACCOUNT_ID=
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_BUCKET=instapet-production
R2_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
R2_PUBLIC_BASE_URL=https://media.instapet.example

PUBLIC_API_URL=https://api.instapet.example
CORS_ORIGINS=https://app.instapet.example
SEED_DATA=false
```

## Steps

1. Create DigitalOcean Managed PostgreSQL database
2. Create Cloudflare R2 bucket + API token
3. Deploy Strapi to App Platform with env vars above
4. Set health check path: `/api/health`
5. Build Flutter web with production API URL:

```bash
flutter build web --dart-define=API_BASE_URL=https://api.instapet.example/api
```

## Local vs Production

- **No data migration** from SQLite to PostgreSQL
- Run production seed or create users via app registration
- Use `scripts/reconcile-counters.ts` periodically to fix denormalized counters

## Counter Reconciliation

```bash
cd backend
npx ts-node ../scripts/reconcile-counters.ts
```
