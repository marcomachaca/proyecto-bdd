#!/usr/bin/env bash
# Importa las tablas fragmentadas de los otros nodos como tablas
# foráneas en los esquemas remoto_nX.
#
# Idempotente: recrea los esquemas remoto_nX antes de importar,
# así que se puede re-ejecutar sin errores de "relation exists".
# Requiere: ./scripts/fdw_servidores.sh y ./scripts/aplicar_fragmentacion.sh
set -euo pipefail
cd "$(dirname "$0")/.."
source .env

TABLAS="ventas, detalle_venta, almacenes, inventario"
LISTA="ventas detalle_venta almacenes inventario"

echo ">>> Comprobando prerrequisitos"
for i in 1 2 3 4 5 6; do
  servidores=$(docker compose exec -T "nodo$i" psql -U "$PG_USER" -d "$PG_DB" \
    -tAc "SELECT count(*) FROM pg_foreign_server;" | tr -d '[:space:]')
  if [ "$servidores" != "5" ]; then
    echo "FALLO nodo$i tiene $servidores servidores FDW (se esperan 5)."
    echo "      Ejecuta antes: ./scripts/fdw_servidores.sh"
    exit 1
  fi
  for t in $LISTA; do
    existe=$(docker compose exec -T "nodo$i" psql -U "$PG_USER" -d "$PG_DB" \
      -tAc "SELECT to_regclass('public.$t') IS NOT NULL;" | tr -d '[:space:]')
    if [ "$existe" != "t" ]; then
      echo "FALLO falta la tabla $t en nodo$i."
      echo "      Ejecuta antes: ./scripts/aplicar_fragmentacion.sh"
      exit 1
    fi
  done
done

for i in 1 2 3 4 5 6; do
  echo ">>> Importando tablas remotas en nodo$i"
  {
    echo "SET client_min_messages = warning;"
    for j in 1 2 3 4 5 6; do
      [ "$i" = "$j" ] && continue
      cat <<SQL
DROP SCHEMA IF EXISTS remoto_n$j CASCADE;
CREATE SCHEMA remoto_n$j;
IMPORT FOREIGN SCHEMA public LIMIT TO ($TABLAS) FROM SERVER srv_nodo$j INTO remoto_n$j;
SQL
    done
  } | docker compose exec -T "nodo$i" \
        psql -U "$PG_USER" -d "$PG_DB" -v ON_ERROR_STOP=1 -q
done

echo "Listo: tablas remotas importadas (re-ejecutable)."
