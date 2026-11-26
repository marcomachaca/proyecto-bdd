-- ============================================================
-- 02_tablas_base.sql
-- Esquema base común a los 6 nodos.
--
-- PROPUESTA DEL EQUIPO 2 hasta que el Equipo 1 entregue el DDL
-- definitivo. Si cambian nombres o tipos, este archivo y
-- fragmentacion/nodoX.sql deben ajustarse juntos.
--
-- Este script NO define qué filas van en cada nodo: eso está en
-- fragmentacion/nodoX.sql (CHECK por departamento + secuencias).
--
-- Es idempotente: se puede reaplicar sobre una base existente.
-- Se ejecuta automáticamente al crear un volumen nuevo (init/)
-- y también desde scripts/aplicar_fragmentacion.sh.
-- ============================================================

SET client_min_messages = warning;

-- ------------------------------------------------------------
-- PRODUCTOS_CATALOGO
-- Replicada en los 6 nodos (Equipo 3). Los ids se generan en el
-- Nodo 1 y se replican: no usar una secuencia local aquí.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS productos_catalogo (
  id_producto     BIGINT PRIMARY KEY,
  codigo_barras   VARCHAR(20)  NOT NULL UNIQUE,
  nombre          VARCHAR(120) NOT NULL,
  descripcion     TEXT,
  precio_unitario NUMERIC(12,2) NOT NULL CHECK (precio_unitario >= 0),
  categoria       VARCHAR(60)
);

-- ------------------------------------------------------------
-- CLIENTES_DATOS_GENERALES  (F_C1)
-- Fragmento vertical público, fragmentado horizontalmente por
-- departamento (Equipo 3).
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS clientes_datos_generales (
  id_cliente      BIGINT PRIMARY KEY,
  nit_ci          VARCHAR(20)  NOT NULL,
  razon_social    VARCHAR(150) NOT NULL,
  telefono        VARCHAR(30),
  direccion       VARCHAR(200),
  departamento_id VARCHAR(2)   NOT NULL
    CHECK (departamento_id IN ('LP','SC','CB','TJ','CH','OR','PO','BE','PA'))
);

-- ------------------------------------------------------------
-- CLIENTES_FINANCIERO  (F_C2)
-- Debe residir SOLO en el Nodo 1 (La Paz). Se crea en todos los
-- nodos para no bloquear el desarrollo; el Equipo 3 debe dejarla
-- vacía fuera del Nodo 1 (o eliminarla allí) al implementar la
-- fragmentación vertical.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS clientes_financiero (
  id_cliente          BIGINT PRIMARY KEY,
  limite_credito      NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (limite_credito >= 0),
  saldo_pendiente     NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (saldo_pendiente >= 0),
  calificacion_riesgo VARCHAR(10)   CHECK (calificacion_riesgo IN ('A','B','C','D')),
  estado_credito      VARCHAR(15)   NOT NULL DEFAULT 'ACTIVO'
    CHECK (estado_credito IN ('ACTIVO','SUSPENDIDO','BLOQUEADO'))
);

-- ------------------------------------------------------------
-- ALMACENES
-- Cada nodo conserva únicamente los almacenes de su fragmento.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS almacenes (
  id_almacen      BIGINT PRIMARY KEY,
  nombre_almacen  VARCHAR(120) NOT NULL,
  departamento_id VARCHAR(2)   NOT NULL
    CHECK (departamento_id IN ('LP','SC','CB','TJ','CH','OR','PO','BE','PA')),
  direccion       VARCHAR(200)
);

-- ------------------------------------------------------------
-- VENTAS  (fragmentada horizontalmente por departamento_id)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ventas (
  id_venta        BIGINT PRIMARY KEY,
  fecha_hora      TIMESTAMP    NOT NULL DEFAULT now(),
  departamento_id VARCHAR(2)   NOT NULL
    CHECK (departamento_id IN ('LP','SC','CB','TJ','CH','OR','PO','BE','PA')),
  id_cliente      BIGINT       NOT NULL REFERENCES clientes_datos_generales(id_cliente),
  id_empleado     BIGINT,
  total_bs        NUMERIC(12,2) NOT NULL DEFAULT 0 CHECK (total_bs >= 0)
);

-- ------------------------------------------------------------
-- DETALLE_VENTA
-- No lleva departamento_id: queda acotada a las ventas locales
-- por la clave foránea (y por tanto al fragmento del nodo).
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS detalle_venta (
  id_detalle      BIGINT PRIMARY KEY,
  id_venta        BIGINT        NOT NULL REFERENCES ventas(id_venta) ON DELETE CASCADE,
  id_producto     BIGINT        NOT NULL REFERENCES productos_catalogo(id_producto),
  cantidad        INTEGER       NOT NULL CHECK (cantidad > 0),
  precio_aplicado NUMERIC(12,2) NOT NULL CHECK (precio_aplicado >= 0),
  subtotal        NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0)
);

-- ------------------------------------------------------------
-- INVENTARIO
-- Acotado a los almacenes locales por la clave foránea.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS inventario (
  id_almacen   BIGINT  NOT NULL REFERENCES almacenes(id_almacen) ON DELETE CASCADE,
  id_producto  BIGINT  NOT NULL REFERENCES productos_catalogo(id_producto),
  stock_actual INTEGER NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
  stock_minimo INTEGER NOT NULL DEFAULT 0 CHECK (stock_minimo >= 0),
  PRIMARY KEY (id_almacen, id_producto)
);

-- ------------------------------------------------------------
-- Secuencias con ids globalmente únicos.
-- INCREMENT 6 = número de nodos; cada nodo arranca en su número
-- (ver fragmentacion/nodoX.sql). Así ningún id se repite entre
-- nodos y los JOIN por FDW son correctos.
-- ------------------------------------------------------------
CREATE SEQUENCE IF NOT EXISTS seq_clientes      INCREMENT BY 6 START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_almacenes     INCREMENT BY 6 START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_ventas        INCREMENT BY 6 START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_detalle_venta INCREMENT BY 6 START WITH 1;

ALTER TABLE clientes_datos_generales ALTER COLUMN id_cliente SET DEFAULT nextval('seq_clientes');
ALTER TABLE almacenes                ALTER COLUMN id_almacen  SET DEFAULT nextval('seq_almacenes');
ALTER TABLE ventas                   ALTER COLUMN id_venta    SET DEFAULT nextval('seq_ventas');
ALTER TABLE detalle_venta            ALTER COLUMN id_detalle  SET DEFAULT nextval('seq_detalle_venta');

-- ------------------------------------------------------------
-- Índices de apoyo
-- ------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_clientes_departamento    ON clientes_datos_generales (departamento_id);
CREATE INDEX IF NOT EXISTS idx_almacenes_departamento   ON almacenes (departamento_id);
CREATE INDEX IF NOT EXISTS idx_ventas_departamento      ON ventas (departamento_id);
CREATE INDEX IF NOT EXISTS idx_ventas_fecha             ON ventas (fecha_hora);
CREATE INDEX IF NOT EXISTS idx_ventas_cliente           ON ventas (id_cliente);
CREATE INDEX IF NOT EXISTS idx_detalle_venta_venta      ON detalle_venta (id_venta);
CREATE INDEX IF NOT EXISTS idx_detalle_venta_producto   ON detalle_venta (id_producto);
CREATE INDEX IF NOT EXISTS idx_inventario_producto      ON inventario (id_producto);
