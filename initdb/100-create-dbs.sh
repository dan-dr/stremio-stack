#!/usr/bin/env bash
set -euo pipefail

# Runs once on first init of the Postgres volume.

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" <<'EOSQL'
-- Create DBs only if they don't exist (idempotent)
SELECT 'CREATE DATABASE comet'              WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'comet')\gexec
SELECT 'CREATE DATABASE zilean'             WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'zilean')\gexec
SELECT 'CREATE DATABASE trakt'   WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'trakt')\gexec
EOSQL
