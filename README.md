<img width="533" height="800" alt="image" src="https://github.com/user-attachments/assets/abc87d5c-e0b1-4c04-97bc-2c7c11904595" />

# Stremio Stack (Arcane Edition)

Designed to live behind Tailscale. Treat it as private and internal.

A compact, well-behaved stack of services that powers a Stremio addon setup, managed by Arcane.

## Quick Start

- Rename `.env.example` to `.env` and fill in values.
- This stack is managed by Arcane at `http://localhost:3552`.
- Do not run `docker compose up/down/restart` here.

## Addons (Install Separately)

These are installed in Stremio itself, not by this stack:

- AIOStreams
- AIOMetadata
- Watchly

## Cinemeta (aka "Cinemata")

Recommended: disable Cinemeta catalogs/search via Cinebye so metadata and catalogs come from your preferred addons instead.

Cinebye is a community web tool used to hide/disable Cinemeta features (often after updates re-enable them).

```text
https://cinebye.elfhosted.com/
```

## Services

- `aiostreams` — addon aggregator
- `mediafusion` — torrent scraping source
- `comet` — Zilean-backed stream source
- `stremthru` — debrid proxy + store/wrap
- `zilean` — DMM torrent indexer
- `aiometadata` — metadata enrichment
- `stremio-postgres` — shared PostgreSQL
- `stremio-redis` — shared Redis
- `mediafusion-worker` — MediaFusion background jobs
- `trawl` — Cloudflare/JavaScript challenge solver for MediaFusion

## Key Files

- `compose.yaml` — stack definition
- `.env.example` — configuration template
- `initdb/` — Postgres initialization scripts
- `data/` — persistent volumes created at runtime
- `ddyo-aiostreams-template.json` — aiostreams helper template
- `aio_ddyo.jpg` — local artwork

## Operations

- Restart a single container safely:

```bash
sudo docker restart <container_name>
```

- If you change `compose.yaml` or configuration values, redeploy from the Arcane UI or API.

## Clear stream cache addon

`cache-reset` builds the public [stremio-cache-reset addon](https://github.com/dan-dr/stremio-cache-reset)
from a pinned commit. Set `CACHE_RESET_TOKEN`, `CACHE_RESET_BASE_URL` and
`CACHE_RESET_BIND_IP` in the private `.env`; never publish the token. Preserve an
existing token and base URL when migrating so installed links keep working.
The default bind address is loopback; remote players need a reachable host address.

Build the image before deploying, through Arcane's Build action or this build-only command:

```nu
docker compose build cache-reset
```

Sync the GitOps project, then apply the configuration through Arcane. Do not run
Compose up/down/restart directly. Open `CACHE_RESET_BASE_URL/TOKEN` to install in
Stremio. The addon uses the existing `redis` service, database 2, and plays a status
video after removing matching episode/movie stream caches. See the addon README
for exact cache scope, AIOStreams passthrough settings and testing instructions.

When migrating from a standalone process, stop it only after the new image passes
a temporary-port smoke test. Free port 3141 immediately before the Arcane deployment,
verify the container is healthy and test a reset, then disable the old service.
Keep the old configuration for rollback.
