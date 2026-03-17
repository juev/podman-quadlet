# Podman Quadlet

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Services](https://img.shields.io/badge/services-37-green.svg)](#available-services)
[![Podman](https://img.shields.io/badge/Podman-4.4%2B-blueviolet.svg)](https://podman.io/)

Ready-to-use **Podman Quadlet** service definitions for systemd — a rootless, daemonless, compose-free
way to run self-hosted services.

Each service is a plain `.container` file that systemd picks up natively via the
[Quadlet generator](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html).
No `docker-compose`, no `podman-compose`, no YAML — just INI files and `systemctl`.

```text
.
├── configs/          Service configuration files (Caddyfile, YAML, TOML, JSON)
├── accessories/      Infrastructure and utility services
├── bookmarks/        Bookmark and read-later managers
├── git/              Git hosting
├── monitoring/       Monitoring, alerting, and observability stack
├── networks/         Shared Podman network definitions
├── notes/            Note-taking and knowledge base services
├── rss/              RSS/Atom feed readers
├── vault/            Password managers
├── vpn/              VPN and proxy services
└── wiki/             Wiki engines
```

## Why Quadlet

- **Native systemd integration** — services start on boot, restart on failure, show up in `journalctl`
- **Rootless by default** — no daemon, no root, no attack surface
- **Declarative** — `.container` files describe the desired state, systemd handles the rest
- **Auto-updates** — `podman auto-update` pulls new images for containers with `AutoUpdate=registry`
- **No extra tools** — ships with Podman 4.4+, nothing else to install

## Quick Start

```bash
# 1. Copy Quadlet files and shared network
cp -r bookmarks/linkding ~/.config/containers/systemd/linkding/
cp networks/caddy.network ~/.config/containers/systemd/networks/

# 2. Create data directory and environment file
mkdir -p ~/volumes/linkding/data
cp bookmarks/linkding/env.example ~/volumes/linkding/.env
nano ~/volumes/linkding/.env

# 3. Reload and start
export XDG_RUNTIME_DIR=/run/user/$(id -u)
systemctl --user daemon-reload
systemctl --user start linkding
```

## Available Services

<details>
<summary><b>Accessories</b> — infrastructure and utility services (11)</summary>

| Service | Description |
| --- | --- |
| [baikal](./accessories/baikal/) | Lightweight CalDAV+CardDAV server |
| [caddy](./accessories/caddy/) | HTTPS reverse proxy with automatic TLS |
| [cloudflared](./accessories/cloudflared/) | Cloudflare Tunnel client |
| [firefly](./accessories/firefly/) | Personal finances manager (+ PostgreSQL) |
| [headscale](./accessories/headscale/) | Self-hosted Tailscale control server |
| [jellyfin](./accessories/jellyfin/) | Free software media system |
| [mtg](./accessories/mtg/) | MTPROTO proxy for Telegram |
| [n8n](./accessories/n8n/) | Workflow automation tool |
| [searxng](./accessories/searxng/) | Privacy-respecting metasearch engine (+ Valkey) |
| [versitygw](./accessories/versitygw/) | S3-compatible gateway |
| [webdav](./accessories/webdav/) | Basic WebDAV server |

</details>

<details>
<summary><b>Bookmarks</b> — bookmark and read-later services (7)</summary>

| Service | Description |
| --- | --- |
| [betula](./bookmarks/betula/) | Federated personal link collection manager |
| [espial](./bookmarks/espial/) | Open-source web-based bookmarking server |
| [linkace](./bookmarks/linkace/) | Self-hosted link archive (+ MariaDB + Redis) |
| [linkding](./bookmarks/linkding/) | Self-hosted bookmark manager |
| [linkwarden](./bookmarks/linkwarden/) | Collaborative bookmark manager (+ PostgreSQL) |
| [shiori](./bookmarks/shiori/) | Simple bookmarks manager written in Go |
| [wallabag](./bookmarks/wallabag/) | Read-later service (+ Redis) |

</details>

<details>
<summary><b>Git</b> — git hosting (1)</summary>

| Service | Description |
| --- | --- |
| [forgejo](./git/forgejo/) | Self-hosted lightweight software forge (Gitea fork) |

</details>

<details>
<summary><b>Monitoring</b> — monitoring and alerting (8)</summary>

| Service | Description |
| --- | --- |
| [alertmanager](./monitoring/alertmanager/) | Alert routing and notification manager for Prometheus |
| [alloy](./monitoring/alloy/) | OpenTelemetry Collector distribution by Grafana |
| [grafana](./monitoring/grafana/) | Observability dashboards and visualization |
| [loki](./monitoring/loki/) | Log aggregation system by Grafana |
| [ntfy](./monitoring/ntfy/) | Self-hosted push notification server |
| [prometheus](./monitoring/prometheus/) | Metrics collection and alerting toolkit |
| [prometheus-podman-exporter](./monitoring/prometheus-podman-exporter/) | Prometheus exporter for Podman container metrics |
| [snmp-exporter](./monitoring/snmp-exporter/) | SNMP metrics exporter for Prometheus |

</details>

<details>
<summary><b>Notes</b> — note-taking services (3)</summary>

| Service | Description |
| --- | --- |
| [getoutline](./notes/getoutline/) | Collaborative knowledge base (+ PostgreSQL + Redis) |
| [silverbullet](./notes/silverbullet/) | Note-taking app for the hacker mindset |
| [standardnotes](./notes/standardnotes/) | Encrypted notes (+ MySQL + Redis + LocalStack) |

</details>

<details>
<summary><b>RSS</b> — feed readers (4)</summary>

| Service | Description |
| --- | --- |
| [freshrss](./rss/freshrss/) | Self-hosted RSS feed aggregator |
| [fusion](./rss/fusion/) | Lightweight self-hosted RSS aggregator |
| [miniflux](./rss/miniflux/) | Minimalist feed reader (+ PostgreSQL) |
| [yarr](./rss/yarr/) | Yet another RSS reader |

</details>

<details>
<summary><b>Vault</b> — password storage (1)</summary>

| Service | Description |
| --- | --- |
| [vaultwarden](./vault/vaultwarden/) | Bitwarden-compatible server written in Rust |

</details>

<details>
<summary><b>VPN</b> — VPN and proxy services (3)</summary>

| Service | Description |
| --- | --- |
| [tor-socks-proxy](./vpn/tor-socks-proxy/) | Tor SOCKS5 proxy |
| [v2ray](./vpn/v2ray/) | Platform for building proxies to bypass network restrictions |
| [wireguard](./vpn/wireguard/) | Fast, modern VPN with state-of-the-art cryptography |

</details>

<details>
<summary><b>Wiki</b> — wiki engines (4)</summary>

| Service | Description |
| --- | --- |
| [dokuwiki](./wiki/dokuwiki/) | Simple wiki that does not require a database |
| [mediawiki](./wiki/mediawiki/) | The wiki engine behind Wikipedia |
| [mycorrhiza](./wiki/mycorrhiza/) | Filesystem and git-based wiki engine written in Go |
| [wiki-js](./wiki/wiki-js/) | Powerful and extensible open-source wiki |

</details>

## File Layout

The repository mirrors the target server structure. Three types of files go to three different locations:

| What | Repo path | Server path | Tracked in git? |
| --- | --- | --- | --- |
| Quadlet units | `<category>/<service>/*.container` | `~/.config/containers/systemd/<service>/` | yes |
| Shared networks | `networks/*.network` | `~/.config/containers/systemd/networks/` | yes |
| Config files | `configs/<service>/` | `~/.config/containers/systemd/configs/<service>/` | yes |
| Environment | `<category>/<service>/env.example` | `~/volumes/<service>/.env` | **no** (secrets) |
| Data volumes | — | `~/volumes/<service>/` | no |

- **configs/** — service configuration files (Caddyfile, config.yaml, settings.yml, etc.). Edit `example.org` placeholders and copy to the server. These are safe to track in git.
- **env.example** — template for `.env` files containing secrets (passwords, tokens, API keys). Copy to `~/volumes/<service>/.env` and fill in real values. **Never commit `.env` files.**
- **volumes/** — persistent data directories on the server (databases, uploads, caches). Not part of this repo.

## Deployment

### Prerequisites

- **Podman 4.4+** with Quadlet support
- **systemd** user session with lingering enabled (see [User lingering](#user-lingering) below)
- Privileged ports allowed for rootless users (see [Privileged ports](#privileged-ports) below)

### Step by Step

1. Copy `.container` and `.network` files to `~/.config/containers/systemd/<service>/`
2. Copy shared networks: `cp networks/caddy.network ~/.config/containers/systemd/networks/`
3. Copy config files (if the service has them): `cp -r configs/<service> ~/.config/containers/systemd/configs/`
4. Create data directories: `mkdir -p ~/volumes/<service>/data`
5. Create `.env` from template and fill in real values:

```bash
cp <category>/<service>/env.example ~/volumes/<service>/.env
nano ~/volumes/<service>/.env
```

6. Reload and start:

```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
systemctl --user daemon-reload
systemctl --user start <service>
```

### Docker Compose vs Quadlet

| Docker Compose | Podman Quadlet |
| --- | --- |
| `docker-compose up -d` | `systemctl --user start <service>` |
| `docker-compose down` | `systemctl --user stop <service>` |
| `restart: always` | `[Service] Restart=always` |
| `volumes:` mapping | `Volume=` directive |
| `networks:` section | `Network=<name>.network` referencing a `.network` file |
| `environment:` | `Environment=` or `EnvironmentFile=` |
| `ports: "127.0.0.1:8080:80"` | `PublishPort=127.0.0.1:8080:80` |

### Common Commands

```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)

systemctl --user daemon-reload              # reload unit files
systemctl --user start <service>            # start
systemctl --user stop <service>             # stop
systemctl --user restart <service>          # restart
systemctl --user status <service> --no-pager  # status
journalctl --user -u <service> -f           # follow logs
```

## Rootless Podman Gotchas

> **Important.** These are real-world issues encountered in production.
> Read this section before deploying.

<details>
<summary><b>User lingering</b></summary>

By default, systemd kills all user processes on logout. To keep services running after
you disconnect from SSH, enable lingering:

```bash
sudo loginctl enable-linger $USER
```

Without this, all your containers will stop as soon as you log out.

</details>

<details>
<summary><b>Privileged ports</b></summary>

Rootless Podman cannot bind to ports below 1024 by default. Services like Caddy (ports 80, 443)
will fail to start. To allow unprivileged users to bind low ports:

```bash
sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80
```

To make it permanent:

```bash
echo "net.ipv4.ip_unprivileged_port_start=80" | sudo tee /etc/sysctl.d/podman-privileged-ports.conf
sudo sysctl --system
```

</details>

<details>
<summary><b>XDG_RUNTIME_DIR via SSH</b></summary>

SSH does not forward `XDG_RUNTIME_DIR`. Without it, `systemctl --user` commands fail.
Always set it explicitly:

```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
```

</details>

<details>
<summary><b>Bind mount inode trap</b></summary>

Rootless Podman mounts files by inode. Replacing a config file (new inode) means the container
still sees the old content.

**Creates a new inode** (container does NOT see the change):

- `sed -i`, `cat > file`, `python open('w')`

**Writes to existing inode** (container sees the change):

- `tee`, `dd`, writing to an already-open fd

After replacing a file with a new inode — restart the container:

```bash
systemctl --user restart <service>
```

</details>

<details>
<summary><b>File ownership and user namespaces</b></summary>

Rootless Podman remaps UIDs. For services that write to bind-mounted volumes, add to `[Container]`:

```ini
UserNS=keep-id
```

This maps the host user to UID 0 inside the container. If the process runs as UID 1000:

```ini
UserNS=keep-id:uid=1000,gid=1000
```

</details>

<details>
<summary><b>Directory creation</b></summary>

Podman does **not** auto-create directories for bind mounts (unlike Docker Compose).
Create them before starting:

```bash
mkdir -p ~/volumes/<service>/data
```

</details>

<details>
<summary><b>Network (pasta) and IP changes</b></summary>

The pasta network session initializes at container start and does not update when the host IP
changes. Fix: full stop and start of **all** containers through systemd (not `podman stop` —
systemd will restart them immediately):

```bash
systemctl --user stop <service1> <service2> ...
systemctl --user start <service1> <service2> ...
```

</details>

<details>
<summary><b>Shared networks</b></summary>

Quadlet has no external networks. Define a shared `.network` file and reference it:

```ini
# caddy.network
[Network]
NetworkName=caddy
```

```ini
# any .container file
[Container]
Network=caddy.network
```

</details>

<details>
<summary><b>Caddy config reload</b></summary>

Graceful reload without dropping connections:

```bash
podman exec caddy caddy reload --config /etc/caddy/Caddyfile
```

Only works if the Caddyfile was updated in-place (same inode). Otherwise restart the container.

</details>

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
EnvironmentFile=%h/volumes/myservice/.env
Network=caddy.network
AutoUpdate=registry

[Service]
Restart=always

[Install]
WantedBy=default.target
```

| Directive | Meaning |
| --- | --- |
| `%h` | Expands to the user's home directory |
| `EnvironmentFile=` | Reads environment variables from a file (use for secrets) |
| `AutoUpdate=registry` | Enables automatic image updates via `podman auto-update` |
| `After=<dep>.service` | Ensures dependent containers start first |
| `WantedBy=default.target` | Starts the service on user login (with lingering) |

## Contributing

1. Fork the repository
2. Add a new service directory with `.container` file(s) and `env.example`
3. Follow existing conventions:
   - Config files in `configs/<service>/`, data volumes in `%h/volumes/<service>/`
   - Secrets in `EnvironmentFile=` (pointing to `%h/volumes/<service>/.env`), not inline
   - App containers on `caddy.network`, DB/Redis on internal `<service>.network` only
   - `AutoUpdate=registry` for public images
4. Open a pull request

## License

[MIT](LICENSE)
