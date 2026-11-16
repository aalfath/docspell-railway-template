[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/docspell-1?utm_medium=integration&utm_source=button&utm_campaign=docspell)

# Docspell on Railway

This repo is the source of the **Docspell** template on Railway. It deploys [Docspell](https://docspell.org) 0.43.0, a self-hosted document organizer, with full-text search in PostgreSQL and invite-only sign-up.

## What it deploys

| Service | Source | Purpose |
|---|---|---|
| `restserver` | [`restserver/`](restserver/) (`ghcr.io/docspell/restserver:v0.43.0`, pinned by digest) | Web UI and REST API, public domain, health check `/api/info/version` |
| `joex` | [`joex/`](joex/) (`ghcr.io/docspell/joex:v0.43.0`, pinned by digest) | Job executor: OCR (tesseract/ocrmypdf), text extraction, PDF conversion, previews, full-text indexing. Private only, no health check (so old and new joex never run side by side during a redeploy) |
| `Postgres` | Railway PostgreSQL | Database. Docspell stores uploaded files, metadata and the full-text index here, so the Postgres volume is the only data to back up |

Each app folder holds a `Dockerfile` (the official image, pinned by version and digest) and a small `start.sh` that maps Railway's `PORT`, binds to IPv4 and IPv6 (Railway's private network is IPv6), and sets fixed defaults: full-text search in PostgreSQL (no Solr service), invite-only sign-up, addons off.

## Variables

| Service | Variable | Default | Notes |
|---|---|---|---|
| restserver | `PORT` | `7880` | Port the web UI listens on |
| restserver | `DOCSPELL_SERVER_BASE__URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL; change it when you add a custom domain |
| restserver | `DOCSPELL_SERVER_INTERNAL__URL` | `http://${{RAILWAY_PRIVATE_DOMAIN}}:7880` | How joex reaches the server |
| restserver | `DOCSPELL_SERVER_BACKEND_JDBC_URL`, `_USER`, `_PASSWORD` | references to `Postgres` | Database connection |
| restserver | `DOCSPELL_SERVER_AUTH_SERVER__SECRET` | generated | Signs login tokens |
| restserver | `DOCSPELL_SERVER_ADMIN__ENDPOINT_SECRET` | generated | Protects the admin endpoints |
| restserver | `DOCSPELL_SERVER_BACKEND_SIGNUP_NEW__INVITE__PASSWORD` | generated | Password to create invitation keys |
| joex | `PORT` | `7878` | Internal port |
| joex | `DOCSPELL_JOEX_BASE__URL` | `http://${{RAILWAY_PRIVATE_DOMAIN}}:7878` | How the server reaches joex |
| joex | `DOCSPELL_JOEX_JDBC_URL`, `_USER`, `_PASSWORD` | references to `Postgres` | Database connection |

Any other Docspell setting can be added as an environment variable, see [Docspell: configuration](https://docspell.org/docs/configure/) (`docspell.server.x-y.z` becomes `DOCSPELL_SERVER_X__Y_Z`). Examples: `DOCSPELL_SERVER_BACKEND_SIGNUP_MODE=closed` once your accounts exist, or `DOCSPELL_SERVER_INTEGRATION__ENDPOINT_ENABLED=true` for the upload integration endpoint.

## First setup

Sign-up is invite-only, so nobody else can register on your public URL.

1. In Railway, open the `restserver` service → Variables and copy `DOCSPELL_SERVER_BACKEND_SIGNUP_NEW__INVITE__PASSWORD`.
2. Open `https://YOUR-DOMAIN/app/newinvite`, paste that password and create an invitation key.
3. Open `https://YOUR-DOMAIN/app/register`, enter a collective name, a user name, a password and the invitation key. Use the same name for collective and user to log in with just that name.
4. Log in and upload documents. joex processes them in the background (OCR, text extraction, tagging suggestions).

## Updates

Railway notifies everyone who deployed this template when a change is merged to `main` of this repo, and each deployer chooses when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first. Docspell migrates its database on start and can't be downgraded, so back up the Postgres volume before you update.

## Local test

`docker compose up --build` runs the same images and settings locally (web UI on the published port of `restserver`, test-only passwords in `docker-compose.yml`).
