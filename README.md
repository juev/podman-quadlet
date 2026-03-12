# Podman Quadlet

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Services](https://img.shields.io/badge/services-35-green.svg)](#available-services)
[![Podman](https://img.shields.io/badge/Podman-4.4%2B-blueviolet.svg)](https://podman.io/)

Ready-to-use **Podman Quadlet** service definitions for systemd — a rootless, daemonless, compose-free
way to run self-hosted services.

Each service is a plain `.container` file that systemd picks up natively via the
[Quadlet generator](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html).
No `docker-compose`, no `podman-compose`, no YAML — just INI files and `systemctl`.

## Why Quadlet

- **Native systemd integration** — services start on boot, restart on failure, show up in `journalctl`
- **Rootless by default** — no daemon, no root, no attack surface
- **Declarative** — `.container` files describe the desired state, systemd handles the rest
- **Auto-updates** — `podman auto-update` pulls new images for containers with `AutoUpdate=registry`
- **No extra tools** — ships with Podman 4.4+, nothing else to install

## Quick Start

```bash
# 1. Copy service files
cp -r bookmarks/linkding ~/.config/containers/systemd/linkding/
cp networks/caddy.network ~/.config/containers/systemd/networks/

# 2. Create data directory (Podman won't create it automatically)
mkdir -p ~/volumes/linkding/data

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

## Deployment

### Prerequisites

- **Podman 4.4+** with Quadlet support
- **systemd** user session (enable lingering: `loginctl enable-linger $USER`)
- Directories created under `~/volumes/<service>/` for persistent data

### Step by Step

1. Copy the service directory to `~/.config/containers/systemd/<service>/`
2. Copy `networks/caddy.network` to `~/.config/containers/systemd/networks/` (if the service uses it)
3. Create data directories: `mkdir -p ~/volumes/<service>/data`
4. Edit environment variables or `EnvironmentFile=` paths as needed
5. Reload and start:

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
| `AutoUpdate=registry` | Enables automatic image updates via `podman auto-update` |
| `After=<dep>.service` | Ensures dependent containers start first |
| `WantedBy=default.target` | Starts the service on user login (with lingering) |

## Contributing

1. Fork the repository
2. Add a new service directory with `.container` file(s)
3. Follow existing conventions (bind mounts to `%h/volumes/`, `Network=caddy.network`, `AutoUpdate=registry`)
4. Open a pull request

## License

[MIT](LICENSE)
