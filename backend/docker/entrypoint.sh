#!/usr/bin/env sh
set -eu

cd /var/www/html

if [ -f .env ] && [ -z "${APP_KEY:-}" ]; then
  current_key="$(grep '^APP_KEY=' .env | cut -d '=' -f2- || true)"
  if [ -n "${current_key}" ]; then
    export APP_KEY="$current_key"
  fi
fi

if [ ! -d vendor ]; then
  composer install \
    --no-dev \
    --prefer-dist \
    --no-interaction \
    --no-progress \
    --optimize-autoloader
fi

mkdir -p storage/logs storage/framework/cache storage/framework/sessions storage/framework/views bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache

if [ "${RUN_MIGRATIONS:-false}" = "true" ]; then
  php artisan migrate --force
fi

php artisan config:clear >/dev/null 2>&1 || true
php artisan route:clear >/dev/null 2>&1 || true
php artisan view:clear >/dev/null 2>&1 || true
php artisan config:cache >/dev/null 2>&1 || true
php artisan route:cache >/dev/null 2>&1 || true

exec "$@"
