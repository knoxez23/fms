# Farmly API Production Checklist

Use this before exposing the API to real users on the VPS.

## Secrets

- set a real `APP_KEY`
- use a strong database password
- use a strong Redis password if Redis is exposed outside Docker
- set `APP_ENV=production`
- set `APP_DEBUG=false`

## Domain and HTTPS

- point your API domain to the VPS
- put host Nginx, Caddy, or Traefik in front of the Docker `nginx` service
- terminate HTTPS at the proxy
- forward traffic to `127.0.0.1:8080`
- set `APP_URL=https://your-api-domain`
- set `SANCTUM_STATEFUL_DOMAINS` for the real frontend domain

## Backups

- create a host backup directory such as `/srv/farmly/backups`
- run `docker compose -f docker-compose.prod.yml exec app sh docker/backup-db.sh`
- automate that command with cron
- copy backups off-server or into object storage

## Health and Monitoring

- verify `docker compose -f docker-compose.prod.yml ps` shows healthy `app`, `nginx`, and `mysql`
- watch logs for `app`, `queue`, and `scheduler`
- add uptime monitoring against `/api/health`
- make sure Horizon is running if queues are enabled

## Laravel Ops

- run `php artisan migrate --force`
- run `php artisan storage:link` if your API serves public files
- confirm queue jobs and scheduler tasks are executing
- confirm CORS and Sanctum cookies work from the production frontend

## Recovery

- document how to restore the latest database backup
- keep a copy of the production `.env` outside the repo
- test a rebuild with `docker compose -f docker-compose.prod.yml up -d --build`
