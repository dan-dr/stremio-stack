# AGENTS.md — Stremio Stack

## ⚠️ CRITICAL: Do NOT use `docker compose up/down/restart`

This stack is managed by **Arcane** (running at `http://localhost:3552`).
Never run `docker compose up`, `docker compose down`, or `docker compose restart` directly.
Doing so can orphan containers, break networks, and conflict with Arcane's state.

## How to manage containers

## ⚠️ CRITICAL: Do NOT run Tailscale commands without explicit permission

Do not run `tailscale` commands, including `tailscale serve`, `tailscale funnel`,
`tailscale up`, `tailscale down`, or `tailscale set`, unless the user explicitly
asks for that specific Tailscale action in the current conversation.

### To restart a single container
```bash
sudo docker restart <container_name>
```
This is safe — it restarts in-place without recreating.

### To apply compose.yaml changes (env vars, image version, etc.)
Use the **Arcane UI** at `http://localhost:3552` or its REST API:

1. The compose project lives at `/home/arcane/projects/Stremio/`
2. Edit `compose.yaml` or `.env` as needed
3. Redeploy via Arcane UI or API (see below)

### Arcane API (auth required)
- `POST /api/environments/{envId}/containers/{containerId}/restart` — restart
- `POST /api/environments/{envId}/containers/{containerId}/stop` — stop  
- `POST /api/environments/{envId}/containers/{containerId}/start` — start
- `POST /api/environments/{envId}/projects/{projectId}/redeploy` — redeploy (recreates with new config)
- `POST /api/environments/{envId}/gitops-syncs/{syncId}/sync` — sync from git

Auth: Login via `POST /api/auth/login` with username/password to get a token.

### If you only changed env vars and need to recreate ONE container
Safest manual approach (if Arcane API isn't set up):
```bash
sudo docker stop <name> && sudo docker rm <name>
# Then trigger redeploy from Arcane UI
```

## Network
- All containers are on the `stremio_default` Docker network
- Compose project name is `stremio` (not `stremio-stack`)
- Containers reference each other by service name (e.g., `mediafusion`, `stremthru`, `redis`)

## Key files
- `compose.yaml` — main stack definition
- `.env` — all secrets and config variables
- `initdb/` — Postgres init scripts
- `data/` — persistent volumes (created at runtime)

## File ownership
- Arcane reads and writes this project as the `arcane` user. After editing files Arcane uses
  (`compose.yaml`, `.env`, `.env.example`, `.github/dependabot.yml`, and related config),
  make sure they remain owned by `arcane:arcane`.

## Container quick reference
| Container | Port (internal) | Purpose |
|---|---|---|
| aiostreams | 3000 | Main Stremio addon aggregator |
| mediafusion | 8000 | Stream source (torrent scraping) |
| comet | 8000 | Stream source (Zilean-backed) |
| stremthru | 8080 | Debrid proxy + Store/Torz/Wrap |
| zilean | 8181 | DMM torrent indexer |
| aiometadata | 3232 | Metadata enrichment |
| stremio-postgres | 5432 | Shared PostgreSQL |
| stremio-redis | 6379 | Shared Redis |
| mediafusion-worker | - | MediaFusion background jobs |
| trawl | 8191 | Cloudflare/JavaScript challenge solver for MediaFusion |
