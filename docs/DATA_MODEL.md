# InstaPET Data Model

## Database Strategy

| Environment | Client | Notes |
|---|---|---|
| Local | SQLite | File: `backend/.tmp/data.db` |
| Production | PostgreSQL | Via `DATABASE_CLIENT=postgres` |

No migration path between local SQLite and production PostgreSQL. Each environment uses its own seed.

## Entities

### User (extended `plugin::users-permissions.user`)

- username, email, displayName, bio, avatar
- isPrivate, status, postsCount, followersCount, followingCount
- profileCompleted

### Post (`api::post.post`)

- author, caption, mediaItems (repeatable component)
- visibility, status, likesCount, publishedAt, deletedAt

### Post Media Component (`post.media-item`)

- image, sortOrder, altText, width, height

### Post Like (`api::post-like.post-like`)

- user + post (unique pair)

### Follow (`api::follow.follow`)

- follower + following (unique pair, no self-follow in service layer)

### Activity (`api::activity.activity`)

- recipient, actor, type (post_like | follow), post, isRead

### App Media Owner (`api::app-media-owner.app-media-owner`)

- uploadFile, user, purpose, usageStatus

## Query Guidelines

- Use Strapi Document Service / `strapi.db.query()` — avoid raw SQL
- Use `containsi` for search (cross-DB)
- Avoid PostgreSQL-only syntax (`ILIKE`, `JSONB`, `RETURNING`)
