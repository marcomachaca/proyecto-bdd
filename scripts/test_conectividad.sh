#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source .env

fallos=0
for i in 1 2 3 4 5 6; do
  for j in 1 2 3 4 5 6; do
    [ "$i" = "$j" ] && continue
    if docker compose exec -T -e PGPASSWORD="$PG_PASSWORD" "nodo$i" \
        psql -h "nodo$j" -U "$PG_USER" -d "$PG_DB" -tAc "select 1" >/dev/null 2>&1; then
      echo "OK    nodo$i -> nodo$j"
    else
      echo "FALLO nodo$i -> nodo$j"; fallos=$((fallos+1))
    fi
  done
done
echo "Conexiones fallidas: $fallos"
