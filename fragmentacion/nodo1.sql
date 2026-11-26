-- ============================================================
-- Fragmento horizontal — Nodo 1 (La Paz)
-- Predicado: sigma_{departamento_id = 'LP'} sobre
--            VENTAS, ALMACENES y CLIENTES_DATOS_GENERALES.
-- DETALLE_VENTA e INVENTARIO quedan acotados por sus claves
-- foráneas a las ventas y almacenes locales.
--
-- Se aplica SOLO en nodo1. Es idempotente.
-- ============================================================

SET client_min_messages = warning;

-- 1. Secuencias: ids únicos a nivel nacional (6 nodos).
ALTER SEQUENCE seq_clientes      INCREMENT BY 6;
ALTER SEQUENCE seq_almacenes     INCREMENT BY 6;
ALTER SEQUENCE seq_ventas        INCREMENT BY 6;
ALTER SEQUENCE seq_detalle_venta INCREMENT BY 6;

-- Arranque en 1 solo si la secuencia nunca se usó (no pisa datos).
DO $$
BEGIN
  IF NOT (SELECT is_called FROM seq_clientes) THEN
    PERFORM setval('seq_clientes', 1, false);
  END IF;
  IF NOT (SELECT is_called FROM seq_almacenes) THEN
    PERFORM setval('seq_almacenes', 1, false);
  END IF;
  IF NOT (SELECT is_called FROM seq_ventas) THEN
    PERFORM setval('seq_ventas', 1, false);
  END IF;
  IF NOT (SELECT is_called FROM seq_detalle_venta) THEN
    PERFORM setval('seq_detalle_venta', 1, false);
  END IF;
END $$;

-- 2. Restricciones de fragmento.
ALTER TABLE ventas DROP CONSTRAINT IF EXISTS chk_ventas_fragmento;
ALTER TABLE ventas ADD CONSTRAINT chk_ventas_fragmento
  CHECK (departamento_id IN ('LP'));

ALTER TABLE almacenes DROP CONSTRAINT IF EXISTS chk_almacenes_fragmento;
ALTER TABLE almacenes ADD CONSTRAINT chk_almacenes_fragmento
  CHECK (departamento_id IN ('LP'));

ALTER TABLE clientes_datos_generales DROP CONSTRAINT IF EXISTS chk_clientes_fragmento;
ALTER TABLE clientes_datos_generales ADD CONSTRAINT chk_clientes_fragmento
  CHECK (departamento_id IN ('LP'));
