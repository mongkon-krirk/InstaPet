# InstaPET

Pet photo social app — Flutter (web-first) + Strapi v5 API.

## Stack

| Layer | Local | Production |
|---|---|---|
| Mobile | Flutter Web (Chrome) | Flutter Web / iOS / Android (later) |
| API | Strapi v5 TypeScript | Strapi on DigitalOcean |
| Database | SQLite (`.tmp/data.db`) | PostgreSQL (Managed) |
| Media | Local disk (`public/uploads`) | Cloudflare R2 |

**Note:** Local and production databases are independent. There is no data migration between environments — seed each separately.

## Quick Start

### 1. Backend

```bash
cd backend
cp ../.env.example .env   # edit secrets if needed
npm install
npm run develop
```

- API: http://localhost:1337/api
- Health: http://localhost:1337/api/health
- Admin: http://localhost:1337/admin

Demo seed (when `SEED_DATA=true` and no posts exist, or `SEED_FORCE=true`):

- **10 users** with avatars (pet photos from the internet)
- **10 posts per user** (1–5 images each, pet photos from the internet)
- Follow relationships between users
- All demo passwords: `demo12345`

| Username | Pet |
|---|---|
| milo_cat | Cat |
| buddy_dog | Dog |
| luna_bunny | Rabbit |
| pip_hamster | Hamster |
| kiwi_bird | Bird |
| shelly_turtle | Turtle |
| goldie_fish | Fish |
| pepper_parrot | Parrot |
| cozy_guinea | Guinea pig |
| shadow_ferret | Ferret |

Force reseed (downloads ~300+ images, takes several minutes):

```bash
cd backend && npm run seed:demo
```

### 2. Mobile (Chrome)

```bash
cd mobile
flutter pub get
flutter run -d chrome --web-port=8080
```

The app connects to `http://localhost:1337/api` by default.

Override API URL:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:1337/api
```

## Project Structure

```text
InstaPET/
├── backend/          # Strapi v5 API
├── mobile/           # Flutter app (web-first)
├── scripts/          # Seed helpers, counter reconciliation
├── docs/             # API, data model, deployment guides
└── Assets/Ref/       # UI reference screenshots
```

## API Highlights

- `GET /api/health` — health check
- `POST /api/auth/local/register` — register
- `POST /api/auth/local` — login
- `GET /api/profiles/me` — current user profile
- `POST /api/app-media/upload` — image upload (multipart)
- `POST /api/posts` — create post
- `GET /api/feed?mode=home` — home feed
- `PUT /api/posts/:id/like` — like post
- `PUT /api/profiles/:username/follow` — follow user
- `GET /api/activities` — activity feed

See [docs/API.md](docs/API.md) for details.

## Production

See [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) for PostgreSQL + R2 + DigitalOcean setup.

## Specification

Full MVP spec: [docs/InstaPET_MVP_Technical_Spec_for_Cursor_v1.1.md](docs/InstaPET_MVP_Technical_Spec_for_Cursor_v1.1.md)
