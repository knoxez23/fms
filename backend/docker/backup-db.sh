#!/usr/bin/env sh
set -eu

if [ -z "${DB_DATABASE:-}" ] || [ -z "${DB_USERNAME:-}" ] || [ -z "${DB_PASSWORD:-}" ]; then
  echo "DB_DATABASE, DB_USERNAME, and DB_PASSWORD must be set." >&2
  exit 1
fi

backup_dir="${BACKUP_DIR:-/backups}"
timestamp="$(date '+%Y%m%d-%H%M%S')"
filename="${DB_DATABASE}-${timestamp}.sql.gz"

mkdir -p "$backup_dir"

mysqldump \
  -h "${DB_HOST:-mysql}" \
  -P "${DB_PORT:-3306}" \
  -u "${DB_USERNAME}" \
  "-p${DB_PASSWORD}" \
  --single-transaction \
  --quick \
  --routines \
  --triggers \
  "${DB_DATABASE}" | gzip > "${backup_dir}/${filename}"

echo "Backup written to ${backup_dir}/${filename}"
