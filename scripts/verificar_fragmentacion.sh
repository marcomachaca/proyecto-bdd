#!/usr/bin/env bash
# Verifica que cada nodo contenga SOLO su fragmento horizontal y
# que las restricciones/secuencias estén bien configuradas.
#
# Uso: ./scripts/verificar_fragmentacion.sh
# Salida: 0 si todo está correcto, 1 si hay algún fallo.
set -uo pipefail
cd "$(dirname "$0")/.."
source .env

declare -A ESPERADO=(
  [1]="LP"
  [2]="SC"
  [3]="CB"
  [4]="CH,TJ"
  [5]="OR,PO"
  [6]="BE,PA"
)
declare -A NOMBRE=(
  [1]="La Paz"
  [2]="Santa Cruz"
  [3]="Cochabamba"
  [4]="Tarija / Chuquisaca"
  [5]="Oruro / Potosí"
  [6]="Beni / Pando"
)

fallos=0
avisos=0

psql_nodo() { # $1 = nodo, $2 = SQL
  docker compose exec -T "nodo$1" psql -U "$PG_USER" -d "$PG_DB" \
    -tAc "$2" 2>/dev/null | tr -d '[:space:]'
}

ok()    { echo "  OK    $*"; }
fallo() { echo "  FALLO $*"; fallos=$((fallos + 1)); }
aviso() { echo "  AVISO $*"; avisos=$((avisos + 1)); }

echo ">>> Verificando fragmentación horizontal"
for i in 1 2 3 4 5 6; do
  echo "== nodo$i (${NOMBRE[$i]}) =="

  if ! docker compose ps --services --status running | grep -qx "nodo$i"; then
    fallo "el contenedor nodo$i no está en ejecución"
    continue
  fi

  # 1. Restricciones CHECK del fragmento.
  n=$(psql_nodo "$i" "
    SELECT count(*) FROM pg_constraint
    WHERE contype = 'c'
      AND conname IN ('chk_ventas_fragmento',
                      'chk_almacenes_fragmento',
                      'chk_clientes_fragmento');")
  if [ "$n" = "3" ]; then
    ok "restricciones de fragmento (3/3)"
  else
    fallo "restricciones de fragmento: $n/3 (ejecuta ./scripts/aplicar_fragmentacion.sh)"
  fi

  # 2. Secuencias con incremento 6 (ids únicos entre nodos).
  inc=$(psql_nodo "$i" "
    SELECT coalesce(min(increment_by), 0) FROM pg_sequences
    WHERE schemaname = 'public'
      AND sequencename IN ('seq_clientes','seq_almacenes',
                           'seq_ventas','seq_detalle_venta');")
  if [ "$inc" = "6" ]; then
    ok "secuencias con INCREMENT 6"
  else
    fallo "secuencias con incremento '$inc' (se espera 6)"
  fi

  # 3. Cada tabla contiene solo los departamentos de su fragmento.
  for tabla in ventas almacenes clientes_datos_generales; do
    obtenido=$(psql_nodo "$i" "
      SELECT coalesce(string_agg(DISTINCT departamento_id, ',' ORDER BY departamento_id), '')
      FROM $tabla;")
    esperado="${ESPERADO[$i]}"
    lista=$(echo "$esperado" | sed "s/,/','/g")
    malas=$(psql_nodo "$i" "
      SELECT count(*) FROM $tabla
      WHERE departamento_id NOT IN ('$lista');")

    if [ "${malas:-0}" -gt 0 ]; then
      fallo "$tabla tiene $malas fila(s) fuera del fragmento (encontrado: ${obtenido:-vacío})"
    elif [ -z "$obtenido" ]; then
      aviso "$tabla vacía (pendiente la carga de datos del Equipo 5)"
    else
      ok "$tabla -> $obtenido (permitidos: $esperado)"
    fi
  done

  # 4. Integridad de los fragmentos derivados.
  huerf_det=$(psql_nodo "$i" "
    SELECT count(*) FROM detalle_venta d
    WHERE NOT EXISTS (SELECT 1 FROM ventas v WHERE v.id_venta = d.id_venta);")
  if [ "${huerf_det:-0}" -gt 0 ]; then
    fallo "detalle_venta con $huerf_det fila(s) sin venta local"
  else
    ok "detalle_venta acotado a ventas locales"
  fi

  huerf_inv=$(psql_nodo "$i" "
    SELECT count(*) FROM inventario i
    WHERE NOT EXISTS (SELECT 1 FROM almacenes a WHERE a.id_almacen = i.id_almacen);")
  if [ "${huerf_inv:-0}" -gt 0 ]; then
    fallo "inventario con $huerf_inv fila(s) sin almacén local"
  else
    ok "inventario acotado a almacenes locales"
  fi
done

# 5. Unicidad global de ids (solo si el FDW ya está importado).
echo "== Verificación global vía FDW (desde nodo1) =="
todos="t"
for j in 2 3 4 5 6; do
  existe=$(psql_nodo 1 "SELECT to_regclass('remoto_n$j.ventas') IS NOT NULL;")
  [ "$existe" = "t" ] || todos="f"
done

if [ "$todos" != "t" ]; then
  aviso "FDW sin importar: omite unicidad global (ejecuta ./scripts/fdw_importar.sh)"
else
  res=$(psql_nodo 1 "
    SELECT count(*) || '|' || (count(*) - count(DISTINCT id_venta))
    FROM (
      SELECT id_venta FROM ventas
      UNION ALL SELECT id_venta FROM remoto_n2.ventas
      UNION ALL SELECT id_venta FROM remoto_n3.ventas
      UNION ALL SELECT id_venta FROM remoto_n4.ventas
      UNION ALL SELECT id_venta FROM remoto_n5.ventas
      UNION ALL SELECT id_venta FROM remoto_n6.ventas
    ) t;")
  total="${res%%|*}"
  dups="${res##*|}"
  if [ -z "$res" ]; then
    aviso "no se pudo consultar las tablas remotas (¿nodos caídos?)"
  elif [ "${total:-0}" -eq 0 ]; then
    aviso "0 ventas nacionales (pendiente la carga de datos)"
  elif [ "${dups:-1}" -eq 0 ]; then
    ok "$total ventas nacionales, ids únicos"
  else
    fallo "$dups id_venta duplicados entre nodos"
  fi
fi

echo
if [ "$fallos" -eq 0 ]; then
  echo "RESULTADO: OK ($avisos aviso(s))"
  exit 0
else
  echo "RESULTADO: $fallos FALLO(S), $avisos aviso(s)"
  exit 1
fi
