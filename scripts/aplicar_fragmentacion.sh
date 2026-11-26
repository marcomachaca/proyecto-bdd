#!/usr/bin/env bash
# Crea el esquema base en los 6 nodos y aplica el fragmento
# horizontal que corresponde a cada uno.
#
# Idempotente: se puede re-ejecutar sin perder datos.
set -euo pipefail
cd "$(dirname "$0")/.."
source .env

for i in 1 2 3 4 5 6; do
  if ! docker compose ps --services --status running | grep -qx "nodo$i"; then
    echo "FALLO nodo$i no está en ejecución."
    echo "      Levanta el entorno con: docker compose up -d"
    exit 1
  fi
done

echo ">>> Aplicando esquema base en los 6 nodos"
for i in 1 2 3 4 5 6; do
  docker compose exec -T "nodo$i" psql -U "$PG_USER" -d "$PG_DB" \
    -v ON_ERROR_STOP=1 -q < init/02_tablas_base.sql
  echo "    nodo$i OK"
done

echo ">>> Aplicando fragmento horizontal por nodo"
for i in 1 2 3 4 5 6; do
  archivo="fragmentacion/nodo$i.sql"
  if [ ! -f "$archivo" ]; then
    echo "FALLO no existe $archivo"
    exit 1
  fi
  docker compose exec -T "nodo$i" psql -U "$PG_USER" -d "$PG_DB" \
    -v ON_ERROR_STOP=1 -q < "$archivo"
  echo "    nodo$i <- $archivo"
done

echo "Listo: esquema base y fragmentos aplicados."
