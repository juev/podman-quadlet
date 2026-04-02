# Standard Notes

End-to-end encrypted note-taking service with sync across all platforms.

## Architecture

Standard Notes requires **5 containers** — significantly heavier than most self-hosted services:

| Container | Image | Purpose |
|---|---|---|
| `standardnotes` | `standardnotes/server` | API server (sync, auth, files) |
| `standardnotes-web` | `standardnotes/web` | Web interface (nginx + SPA) |
| `standardnotes-db` | `mysql:8` | MySQL database |
| `standardnotes-cache` | `redis:6.0-alpine` | Redis cache |
| `standardnotes-localstack` | `localstack/localstack:3.0` | AWS SNS/SQS emulation for internal messaging |

**Minimum requirements:** 2 GB RAM, 2 CPU.

## Domain Setup

Three subdomains are required, all proxied through a reverse proxy (e.g. Caddy):

- `notes.example.org` — web interface
- `api.notes.example.org` — API/sync server
- `files.notes.example.org` — file server

API and files point to the same container (`standardnotes:3000`), but separate domains
are needed for CORS and cookie isolation.

Example Caddyfile:

```caddyfile
notes.example.org {
    reverse_proxy standardnotes-web:80
}

api.notes.example.org {
    reverse_proxy standardnotes:3000
}

files.notes.example.org {
    reverse_proxy standardnotes:3000
}
```

## Deployment

```bash
# 1. Copy quadlet files
cp -r notes/standardnotes ~/.config/containers/systemd/standardnotes/

# 2. Copy config files (nginx.conf, localstack_bootstrap.sh)
cp -r configs/standardnotes ~/.config/containers/systemd/configs/standardnotes/
chmod +x ~/.config/containers/systemd/configs/standardnotes/localstack_bootstrap.sh

# 3. Create data directories
mkdir -p ~/volumes/standardnotes/{mysql,redis,logs,uploads}

# 4. Create .env from template
cp notes/standardnotes/env.example ~/volumes/standardnotes/.env
# Edit .env: set passwords, generate keys (openssl rand -hex 32), replace example.org
nano ~/volumes/standardnotes/.env

# 5. Update nginx.conf with your domain
# Replace api.notes.example.org with your actual API domain
nano ~/.config/containers/systemd/configs/standardnotes/nginx.conf

# 6. Update MySQL passwords in standardnotes-db.container to match .env
nano ~/.config/containers/systemd/standardnotes/standardnotes-db.container

# 7. Start
export XDG_RUNTIME_DIR=/run/user/$(id -u)
systemctl --user daemon-reload
systemctl --user start standardnotes
systemctl --user start standardnotes-web
```

## Known Complexities

### LocalStack Bootstrap

Standard Notes uses AWS SNS/SQS for internal microservice communication.
LocalStack emulates these services locally. The official `docker-compose.yml` inlines
topic/queue creation commands in the entrypoint, but Podman Quadlet has no multi-line
entrypoint equivalent. The bootstrap script (`localstack_bootstrap.sh`) is mounted as
an init hook and runs automatically on container start.

### Hardcoded API URL in Web App

The `standardnotes/web` image has `api.standardnotes.com` hardcoded in compiled
JavaScript bundles. Without patching, the web app connects to the official server
instead of your self-hosted instance.

**Solution:** nginx `sub_filter` that replaces the URL on the fly. This is why
a custom `nginx.conf` is required — see `configs/standardnotes/nginx.conf`.

### CORS and Cookie Domain

With three separate subdomains, browsers block cross-origin requests and cookies by
default. The `.env` must configure:

- `CORS_ALLOWED_ORIGINS` — the web interface origin
- `COOKIE_DOMAIN` — with a leading dot (`.notes.example.org`) so cookies work across subdomains
- `COOKIE_SECURE=true` — required for HTTPS

Without these, authentication silently fails.

### PRO Subscription Activation

Standard Notes uses a freemium model. Self-hosted instances need PRO activation
through the database:

1. Set `DISABLE_USER_REGISTRATION=false` in `.env`
2. Register an account via the web interface
3. Activate PRO via SQL (see below)
4. Set `DISABLE_USER_REGISTRATION=true` and restart

```bash
podman exec -it standardnotes-db mysql -u std_notes_user -p standard_notes_db
```

```sql
-- Find user UUID
SELECT uuid, email FROM users;

-- Create 10-year subscription (replace <user-uuid>)
INSERT INTO user_subscriptions
  (uuid, plan_name, ends_at, created_at, updated_at,
   user_uuid, subscription_id, subscription_type)
VALUES
  (UUID(), 'PRO_PLAN',
   DATE_ADD(NOW(), INTERVAL 10 YEAR),
   NOW(), NOW(),
   '<user-uuid>', 1, 'regular');

-- Assign PRO role (replace <user-uuid>)
INSERT INTO user_roles (uuid, role_uuid, user_uuid)
VALUES (UUID(),
  (SELECT uuid FROM roles WHERE name = 'PRO_USER'),
  '<user-uuid>');
```

Restart the API server after activation: `systemctl --user restart standardnotes`

### Offline Activation Code

The PRO subscription on the server does not automatically activate desktop and mobile
apps. Obtain the **Offline Activation Code** from the web interface:
**Preferences > General > Offline Activation Code**. Enter this code in each app.

Mobile tip: activate on desktop first — mobile apps pick up the subscription via sync.

## Backups

- **MySQL:** `podman exec standardnotes-db mysqldump -u std_notes_user -p standard_notes_db > sn_backup.sql`
- **Uploads:** `~/volumes/standardnotes/uploads/`
- **Keys:** `~/volumes/standardnotes/.env` (without it the server cannot decrypt data)
- **Client export:** Preferences > Backups > Download Backup (decrypted, as a safety net)
