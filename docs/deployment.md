# SmartSpend — Deployment Guide

## Overview

SmartSpend consists of three deployable components:

| Component       | Technology       | Deployment Target                      |
| --------------- | ---------------- | -------------------------------------- |
| Flutter app     | Flutter / Dart   | Android, iOS, Web, Windows             |
| FastAPI backend | Python / Uvicorn | Docker container                       |
| Database        | PostgreSQL 16    | Docker container or managed DB service |

---

## Local Development (Docker Compose)

See the [Development Guide](development-guide.md) for the full local setup. The short version:

```bash
cp .env.example .env
# Edit .env — set POSTGRES_PASSWORD, JWT_SECRET, PGADMIN_PASSWORD
docker-compose up -d
flutter run
```

---

## Docker Compose Reference

### `docker-compose.yml` Services

| Service   | Container Name       | Image                  | Internal Port | Host Port                         |
| --------- | -------------------- | ---------------------- | ------------- | --------------------------------- |
| `db`      | `smartspend-db`      | `postgres:16-alpine`   | 5432          | `${POSTGRES_PORT}` (default 5432) |
| `backend` | `smartspend-api`     | `./backend/Dockerfile` | 8000          | 8000                              |
| `pgadmin` | `smartspend-pgadmin` | `dpage/pgadmin4`       | 80            | `${PGADMIN_PORT}` (default 5050)  |

### Starting / Stopping

```bash
# Start all services in background
docker-compose up -d

# Start specific service
docker-compose up -d backend

# Stop all services (preserves data)
docker-compose down

# Stop and delete all volumes (DESTROYS DATABASE DATA)
docker-compose down -v

# Rebuild images after code changes
docker-compose up -d --build backend
```

### Viewing Logs

```bash
docker-compose logs -f           # all services
docker-compose logs -f backend   # backend only
docker-compose logs -f db        # database only
```

---

## Backend — Production Deployment

### Environment Variables

The backend reads all configuration from environment variables. Set these on your production host or container orchestrator:

| Variable            | Required | Description                                                          |
| ------------------- | -------- | -------------------------------------------------------------------- |
| `POSTGRES_USER`     | Yes      | PostgreSQL username                                                  |
| `POSTGRES_PASSWORD` | Yes      | PostgreSQL password — use a strong random value                      |
| `POSTGRES_DB`       | Yes      | Database name                                                        |
| `POSTGRES_HOST`     | Yes      | Database host (e.g., `db` in Docker, or your managed DB hostname)    |
| `POSTGRES_PORT`     | No       | Database port (default: `5432`)                                      |
| `JWT_SECRET`        | Yes      | JWT signing secret — minimum 32 characters, cryptographically random |

### Dockerfile

`backend/Dockerfile` builds a production-ready image:

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app/ ./app/
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Building and pushing the backend image

```bash
docker build -t smartspend-api:latest ./backend
docker tag smartspend-api:latest your-registry/smartspend-api:latest
docker push your-registry/smartspend-api:latest
```

### Production considerations

- **CORS:** Update the allowed origins in `backend/app/main.py` to match your production frontend domain.
- **HTTPS:** Place the backend behind a reverse proxy (nginx, Caddy, or a cloud load balancer) with TLS termination.
- **Database:** Use a managed PostgreSQL service (e.g., AWS RDS, Supabase, Neon) instead of the Docker container for production persistence and backups.
- **JWT secret rotation:** Rotating the `JWT_SECRET` invalidates all existing tokens, forcing all users to re-login. Plan accordingly.
- **Connection pooling:** For high-traffic deployments, configure `pgbouncer` or use a connection pooler in front of PostgreSQL.

---

## Database — Initialization and Seeding

### First-time initialization

On first run, `docker/init.sql` is executed automatically by the PostgreSQL container (via the `/docker-entrypoint-initdb.d/` mount). This creates all tables.

`docker/seed.sql` is also mounted and populates a demo user account:

- Email: `demo@smartspend.dev`
- Password: `password123`
- 30 sample transactions, budgets, goals, and recommendations

To skip seeding in production, remove the `seed.sql` volume mount from `docker-compose.yml`.

### Applying schema changes

1. Modify `docker/init.sql` with new DDL statements
2. For development: `docker-compose down -v && docker-compose up -d`
3. For production: apply changes as incremental `ALTER TABLE` migrations directly against your production database

---

## Flutter App — Build & Release

### Web

```bash
flutter build web --dart-define=API_BASE_URL=https://api.yourapp.com/api/v1
```

Output in `build/web/`. Host the static files on any web server (nginx, Firebase Hosting, Netlify, S3 + CloudFront, etc.).

### Android

```bash
# Debug APK
flutter build apk --dart-define=API_BASE_URL=https://api.yourapp.com/api/v1

# Release APK (requires signing config)
flutter build apk --release --dart-define=API_BASE_URL=https://api.yourapp.com/api/v1

# App Bundle (recommended for Play Store)
flutter build appbundle --release --dart-define=API_BASE_URL=https://api.yourapp.com/api/v1
```

### iOS

Requires a macOS machine with Xcode installed.

```bash
flutter build ios --release --dart-define=API_BASE_URL=https://api.yourapp.com/api/v1
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and submit to the App Store.

### Windows

```bash
flutter build windows --dart-define=API_BASE_URL=https://api.yourapp.com/api/v1
```

Output in `build/windows/runner/Release/`.

---

## API URL Configuration

The Flutter app API base URL is configured at **build time** using `--dart-define`:

```bash
--dart-define=API_BASE_URL=https://api.yourapp.com/api/v1
```

If not specified, it defaults to `http://localhost:8000/api/v1`.

For CI/CD pipelines, pass this as a build argument:

```yaml
# Example: GitHub Actions
- name: Build Flutter web
  run: flutter build web --dart-define=API_BASE_URL=${{ secrets.API_BASE_URL }}
```

---

## CI/CD Checklist

Before deploying to production:

- [ ] `JWT_SECRET` is set to a cryptographically random string (≥ 32 chars)
- [ ] `POSTGRES_PASSWORD` is strong and not the default
- [ ] `.env` is not committed to version control
- [ ] CORS origins in `backend/app/main.py` include only your production domain
- [ ] Backend is behind HTTPS
- [ ] Database is not exposed on a public port
- [ ] Demo seed data (`seed.sql`) is not applied to production
- [ ] Flutter app built with `--release` flag and correct `API_BASE_URL`
- [ ] All Flutter tests pass: `flutter test`
- [ ] Backend health check passes: `GET /health`

---

## Health Monitoring

### Backend health endpoint

```
GET http://your-api-host/health
```

Returns `{ "status": "ok" }` when the backend is running. Use this as the liveness probe in your container orchestrator.

### Docker Compose health check

The `docker-compose.yml` includes a health check on the `db` service that the `backend` service depends on. The backend waits for PostgreSQL to be ready before starting.

---

## Rollback

### Backend rollback

```bash
# Re-deploy previous image tag
docker pull your-registry/smartspend-api:previous-tag
docker-compose stop backend
docker tag your-registry/smartspend-api:previous-tag smartspend-api:latest
docker-compose up -d backend
```

### Database rollback

Database schema changes should always be written as forward-compatible migrations. If a rollback is needed, apply the inverse DDL manually against the production database. Full database backups before any migration are strongly recommended.
