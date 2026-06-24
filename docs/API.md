# InstaPET API Reference

Base URL (local): `http://localhost:1337/api`

## Response Envelope

```json
{
  "data": {},
  "meta": {},
  "error": null
}
```

## Authentication

```http
POST /auth/local/register
POST /auth/local
Authorization: Bearer <jwt>   # protected routes
```

## Endpoints

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/health` | No | Health check |
| POST | `/auth/local/register` | No | Register |
| POST | `/auth/local` | No | Login |
| GET | `/profiles/me` | Yes | Current user |
| PATCH | `/profiles/me` | Yes | Update profile |
| GET | `/profiles/:username` | Yes | Public profile |
| GET | `/profiles/:username/posts` | Yes | User post grid |
| GET | `/profiles/:username/followers` | Yes | Followers list |
| GET | `/profiles/:username/following` | Yes | Following list |
| PUT | `/profiles/:username/follow` | Yes | Follow (idempotent) |
| DELETE | `/profiles/:username/follow` | Yes | Unfollow (idempotent) |
| POST | `/app-media/upload` | Yes | Upload images (multipart) |
| DELETE | `/app-media/:fileId` | Yes | Delete unused upload |
| POST | `/posts` | Yes | Create post |
| GET | `/posts/:documentId` | Yes | Post detail |
| DELETE | `/posts/:documentId` | Yes | Delete own post |
| PUT | `/posts/:documentId/like` | Yes | Like (idempotent) |
| DELETE | `/posts/:documentId/like` | Yes | Unlike (idempotent) |
| GET | `/feed?mode=home\|following\|discover` | Yes | Feed |
| GET | `/search/users?q=` | Yes | Search users |
| GET | `/activities` | Yes | Activity list |
| POST | `/activities/read` | Yes | Mark activities read |
| POST | `/account/change-password` | Yes | Change password |

## Upload

```http
POST /app-media/upload
Content-Type: multipart/form-data

files: <binary>
purpose: post | avatar
```
