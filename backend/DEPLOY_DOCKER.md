# Farmly API Docker Deploy

This stack is intended for production-like VPS testing of the Laravel API.

## Services

- `app`: PHP-FPM Laravel application
- `nginx`: public web entrypoint
- `queue`: Laravel Horizon worker
- `scheduler`: Laravel scheduler loop
- `mysql`: MySQL 8.4
- `redis`: Redis 7

## First-Time Setup

1. Copy the environment file:

```bash
cd backend
cp .env.docker.example .env
```

2. Edit `.env` and set at minimum:

- `APP_URL`
- `APP_KEY`
- `DB_DATABASE`
- `DB_USERNAME`
- `DB_PASSWORD`
- `MYSQL_ROOT_PASSWORD` in `docker-compose.prod.yml` if you keep the bundled MySQL
- `FRONTEND_URL`
- `SANCTUM_STATEFUL_DOMAINS`

3. Generate an application key if needed:

```bash
docker compose -f docker-compose.prod.yml run --rm app php artisan key:generate --show
```

Paste the generated key into `.env` as `APP_KEY=base64:...`.

## Start The Stack

```bash
docker compose -f docker-compose.prod.yml up -d --build
```

## Run Migrations

```bash
docker compose -f docker-compose.prod.yml run --rm -e RUN_MIGRATIONS=true app true
docker compose -f docker-compose.prod.yml exec app php artisan migrate --force
```

## Useful Commands

View logs:

```bash
docker compose -f docker-compose.prod.yml logs -f app nginx queue scheduler
```

Check API health:

```bash
curl http://YOUR_VPS_IP:8080/api/health
```

Run tests inside the container:

```bash
docker compose -f docker-compose.prod.yml exec app php artisan test
```

Restart after config changes:

```bash
docker compose -f docker-compose.prod.yml down
docker compose -f docker-compose.prod.yml up -d --build
```

## VPS Notes

- Put Nginx Proxy Manager, Traefik, or host Nginx in front if you want HTTPS and a real domain.
- Port `8080` is exposed by default for testing.
- Change the MySQL and Redis exposed ports if they conflict with existing VPS services.
- For a stricter production setup later, remove bind mounts and bake code into immutable images.
