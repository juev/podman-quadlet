# Podman Quadlet

Podman Quadlet service definitions for systemd -- a rootless, compose-free alternative to docker-compose.
Each service is defined as a set of `.container`, `.network`, and `.volume` files that systemd picks up
automatically via the Quadlet generator.

## What is Podman Quadlet

Quadlet is a systemd generator shipped with Podman 4.4+. It converts declarative `.container`, `.network`,
and `.volume` files into native systemd unit files. Place them in `~/.config/containers/systemd/` (rootless)
or `/etc/containers/systemd/` (rootful), run `systemctl daemon-reload`, and systemd manages the containers
as regular services -- no `podman-compose` or `docker-compose` required.

Key file types:

- `.container` -- describes a container (image, volumes, ports, environment, network)
- `.network` -- describes a Podman network
- `.volume` -- describes a named volume

Quadlet reference: [Podman documentation](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)

## Repository Structure

```text
.
├── accessories/     Assorted infrastructure and utility services
├── bookmarks/       Bookmark and read-later managers
├── git/             Git hosting
├── networks/        Shared network definitions
├── notes/           Note-taking and knowledge base services
├── rss/             RSS/Atom feed readers
├── vault/           Password managers
├── vpn/             VPN and proxy services
└── wiki/            Wiki engines
```

Each service directory contains one or more `.container` files (and `.volume`/`.network` if needed).
Multi-container services (e.g., app + database) keep all files in the same directory.

## Table of Contents

- [accessories](./accessories/) -- assorted infrastructure and utility services
  - [baikal](./accessories/baikal/) -- lightweight CalDAV+CardDAV server
  - [caddy](./accessories/caddy/) -- powerful HTTPS reverse proxy with automatic TLS
  - [cloudflared](./accessories/cloudflared/) -- Cloudflare Tunnel client
  - [firefly](./accessories/firefly/) -- personal finances manager (app + PostgreSQL)
  - [headscale](./accessories/headscale/) -- open-source Tailscale control server
  - [jellyfin](./accessories/jellyfin/) -- free software media system
  - [mtg](./accessories/mtg/) -- MTPROTO proxy for Telegram
  - [n8n](./accessories/n8n/) -- workflow automation tool
  - [searxng](./accessories/searxng/) -- privacy-respecting metasearch engine (app + Valkey)
  - [versitygw](./accessories/versitygw/) -- S3-compatible gateway
  - [webdav](./accessories/webdav/) -- basic WebDAV server
- [bookmarks](./bookmarks/) -- bookmark and read-later services
  - [betula](./bookmarks/betula/) -- federated personal link collection manager
  - [espial](./bookmarks/espial/) -- open-source web-based bookmarking server
  - [linkace](./bookmarks/linkace/) -- self-hosted link archive (app + MySQL + Redis)
  - [linkding](./bookmarks/linkding/) -- self-hosted bookmark manager
  - [linkwarden](./bookmarks/linkwarden/) -- collaborative bookmark manager (app + PostgreSQL)
  - [shiori](./bookmarks/shiori/) -- simple bookmarks manager written in Go
  - [wallabag](./bookmarks/wallabag/) -- read-later service (app + Redis)
- [git](./git/) -- git hosting services
  - [forgejo](./git/forgejo/) -- self-hosted lightweight software forge (Gitea fork)
- [networks](./networks/) -- shared Podman network definitions
  - [caddy.network](./networks/caddy.network) -- shared network for services behind Caddy
- [notes](./notes/) -- note-taking services
  - [getoutline](./notes/getoutline/) -- collaborative knowledge base (app + PostgreSQL + Redis)
  - [silverbullet](./notes/silverbullet/) -- note-taking app for the hacker mindset
  - [standardnotes](./notes/standardnotes/) -- encrypted notes (app + MySQL + Redis + LocalStack)
- [rss](./rss/) -- RSS reader services
  - [freshrss](./rss/freshrss/) -- self-hosted RSS feed aggregator
  - [fusion](./rss/fusion/) -- lightweight self-hosted RSS aggregator
  - [miniflux](./rss/miniflux/) -- minimalist feed reader (app + PostgreSQL)
  - [yarr](./rss/yarr/) -- yet another RSS reader, web-based feed aggregator
- [vault](./vault/) -- password storage services
  - [vaultwarden](./vault/vaultwarden/) -- Bitwarden-compatible server written in Rust
- [vpn](./vpn/) -- VPN and proxy services
  - [tor-socks-proxy](./vpn/tor-socks-proxy/) -- Tor SOCKS5 proxy
  - [v2ray](./vpn/v2ray/) -- platform for building proxies to bypass network restrictions
  - [wireguard](./vpn/wireguard/) -- fast, modern VPN with state-of-the-art cryptography
- [wiki](./wiki/) -- wiki services
  - [dokuwiki](./wiki/dokuwiki/) -- simple wiki that does not require a database
  - [mediawiki](./wiki/mediawiki/) -- the wiki engine behind Wikipedia
  - [mycorrhiza](./wiki/mycorrhiza/) -- filesystem and git-based wiki engine written in Go
  - [wiki-js](./wiki/wiki-js/) -- powerful and extensible open-source wiki

## Deployment

### Quick Start

1. Copy the service directory to `~/.config/containers/systemd/<service>/`
2. Copy shared network files to `~/.config/containers/systemd/networks/`
3. Create data directories under `~/volumes/<service>/`
4. Reload systemd units and start the service:

```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
systemctl --user daemon-reload
systemctl --user start <service>
```

### Example: Deploying Linkding

```bash
# Copy Quadlet files
cp -r bookmarks/linkding ~/.config/containers/systemd/linkding/
cp networks/caddy.network ~/.config/containers/systemd/networks/

# Create data directory
mkdir -p ~/volumes/linkding/data

# Reload and start
export XDG_RUNTIME_DIR=/run/user/$(id -u)
systemctl --user daemon-reload
systemctl --user start linkding
```

## Key Differences from Docker Compose

| Docker Compose | Podman Quadlet |
| --- | --- |
| `docker-compose up -d` | `systemctl --user start <service>` |
| `docker-compose down` | `systemctl --user stop <service>` |
| `restart: always` | `[Service] Restart=always` |
| `volumes:` mapping | `Volume=` directive |
| `networks:` section | `Network=<name>.network` referencing a `.network` file |
| `environment:` | `Environment=` or `EnvironmentFile=` |
| `ports: "127.0.0.1:8080:80"` | `PublishPort=127.0.0.1:8080:80` |
| External networks | Not supported; use shared `.network` files instead |

## Common Commands

```bash
# Set XDG_RUNTIME_DIR (required when connecting via SSH)
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# Reload unit files after adding or changing Quadlet files
systemctl --user daemon-reload

# Start / stop / restart a service
systemctl --user start <service>
systemctl --user stop <service>
systemctl --user restart <service>

# Check service status
systemctl --user status <service> --no-pager

# Follow logs
journalctl --user -u <service> -f

# List all Podman container units
systemctl --user list-units --type=service 'podman-*'
```

## Rootless Podman Specifics

### XDG_RUNTIME_DIR via SSH

SSH does not forward `XDG_RUNTIME_DIR`. Without it, `systemctl --user` commands fail.
Always set it explicitly before running any user-level systemd command:

```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
systemctl --user daemon-reload
systemctl --user start <service>
```

### Bind Mount and File Replacement (inode issue)

Rootless Podman mounts files by inode. If a config file is replaced with a new file (new inode),
the container still sees the old content.

Operations that **create a new inode** (container does NOT see the change):

- `sed -i`
- `python open('w')`
- `cat > file`

Operations that **write to the existing inode** (container sees the change):

- `tee`
- `dd`
- Writing to an already-open file descriptor

After replacing a file with a new inode, a container restart is required:

```bash
systemctl --user restart <service>
```

### File Ownership and User Namespaces

Rootless Podman uses user namespaces. The UID inside the container is not the same as the UID on
the host. For services that need to write to bind-mounted volumes, add `UserNS=keep-id` to the
`[Container]` section:

```ini
[Container]
UserNS=keep-id
```

This maps the current host user to UID 0 inside the container. Some services run as a non-root user
internally (e.g., UID 1000). In that case, specify the mapping explicitly:

```ini
[Container]
UserNS=keep-id:uid=1000,gid=1000
```

### Directory Creation

Podman does **not** auto-create directories for bind mounts (unlike Docker Compose). You must
create them manually before starting the service:

```bash
mkdir -p ~/volumes/<service>/data
```

### Network (pasta) and IP Changes

The pasta network session initializes when containers start and does not update when the host IP
changes. `host.containers.internal` (`169.254.1.2`) stops working after an IP change.

To fix this, perform a full stop and start of **all** containers through systemd (not `podman stop`,
because systemd will immediately restart them due to `Restart=always`):

```bash
systemctl --user stop <service1> <service2> ...
systemctl --user start <service1> <service2> ...
```

### External / Shared Networks

Quadlet does not support external networks in the Docker Compose sense. Instead, define shared
networks as `.network` files and reference them from multiple `.container` files:

```ini
# In any .container file
[Container]
Network=caddy.network
```

The corresponding `caddy.network` file:

```ini
[Network]
NetworkName=caddy
```

### Caddy Config Reload

To reload Caddy configuration without dropping active connections:

```bash
podman exec caddy caddy reload --config /etc/caddy/Caddyfile
```

This only works if the Caddyfile was updated in-place (same inode). If the file was replaced
(new inode), restart the container instead:

```bash
systemctl --user restart caddy
```

## Quadlet File Reference

A minimal `.container` file:

```ini
[Unit]
Description=My Service
After=network-online.target

[Container]
Image=docker.io/library/myimage:latest
PublishPort=127.0.0.1:8080:80
Volume=%h/volumes/myservice/data:/data
Network=caddy.network
AutoUpdate=registry

[Service]
Restart=always

[Install]
WantedBy=default.target
```

Notable directives:

- `%h` -- expands to the user's home directory (useful for rootless bind mounts)
- `AutoUpdate=registry` -- enables automatic image updates via `podman auto-update`
- `After=<dependency>.service` -- ensures dependent containers start first
- `WantedBy=default.target` -- starts the service on user login (with lingering enabled)
