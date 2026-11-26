#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source .env

for i in 1 2 3 4 5 6; do
  echo ">>> Configurando FDW en nodo$i"
  {
    echo "SET client_min_messages = warning;"
    echo "CREATE EXTENSION IF NOT EXISTS postgres_fdw;"
    for j in 1 2 3 4 5 6; do
      [ "$i" = "$j" ] && continue
      cat <<SQL
DROP SERVER IF EXISTS srv_nodo$j CASCADE;
CREATE SERVER srv_nodo$j FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'nodo$j', port '5432', dbname '$PG_DB');
CREATE USER MAPPING FOR $PG_USER SERVER srv_nodo$j
  OPTIONS (user '$PG_USER', password '$PG_PASSWORD');
CREATE SCHEMA IF NOT EXISTS remoto_n$j;
SQL
    done
  } | docker compose exec -T "nodo$i" \
        psql -U "$PG_USER" -d "$PG_DB" -v ON_ERROR_STOP=1 -q
done
echo "Listo: servidores FDW creados."
