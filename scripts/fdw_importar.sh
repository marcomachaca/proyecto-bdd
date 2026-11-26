#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
source .env

# Tablas a importar desde cada nodo remoto (ajustar cuando el Equipo 1 entregue el DDL)
TABLAS="ventas, detalle_venta, almacenes, inventario"

for i in 1 2 3 4 5 6; do
  echo ">>> Importando tablas remotas en nodo$i"
  {
    for j in 1 2 3 4 5 6; do
      [ "$i" = "$j" ] && continue
      echo "IMPORT FOREIGN SCHEMA public LIMIT TO ($TABLAS) FROM SERVER srv_nodo$j INTO remoto_n$j;"
    done
  } | docker compose exec -T "nodo$i" \
        psql -U "$PG_USER" -d "$PG_DB" -v ON_ERROR_STOP=1 -q
done
echo "Listo: tablas remotas importadas."
