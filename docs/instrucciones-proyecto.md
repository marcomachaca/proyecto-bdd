**Proyecto de Bases de Datos Distribuidas:**
**Sistema de Gestión Logística Nacional "BoliviaDistribución"**

**1. Enunciado y Contexto Empresarial**

La empresa nacional de logística y consumo masivo **"BoliviaDistribución S.A."** cuenta con centros operacionales en los 9 departamentos del país. La dirección de TI ha decidido migrar su arquitectura centralizada actual hacia un **Sistema de Base de Datos Distribuida (SGBDD)** para garantizar la autonomía operativa en cada departamento, reducir la latencia de red en operaciones locales y asegurar alta disponibilidad ante cortes de conectividad entre regiones.

El sistema debe gestionar las ventas, el inventario de almacenes y la facturación a nivel nacional, distribuyendo el almacenamiento y procesamiento entre los diferentes nodos regionales.

**2. Topología de Nodos y Distribución Geográfica**

La infraestructura de datos estará dividida en nodos interconectados con roles estratégicos según la región:

| Nodo | Departamento | Rol en el Sistema | Tipo de Operación Predominante |
| :--- | :--- | :--- | :--- |
| **Nodo 1** | **La Paz** | Nodo Central Administrativo y Consolidación | Consultas ejecutivas, auditoría y facturación central. |
| **Nodo 2** | **Santa Cruz** | Centro Logístico de Agroindustria y Retail | Alto volumen de inserciones de ventas e inventario masivo. |
| **Nodo 3** | **Cochabamba** | Hub de Distribución Central y Ensamblaje | Gestión de traspasos interdepartamentales de mercancía. |
| **Nodo 4** | **Tarija** | Sub-nodo Sur (Tarija y Chuquisaca) | Operaciones comerciales regionales y control de despacho. |
| **Nodo 5** | **Oruro** | Sub-nodo Occidente / Minería (Oruro y Potosí) | Registro de importaciones, aduana interior y stock pesado. |
| **Nodo 6** | **Beni** | Sub-nodo Oriente / Amazonía (Beni y Pando) | Operaciones de bajo ancho de banda y sincronización diferida. |

**3. Requerimientos del Proyecto**

Los estudiantes (en equipos de 3 a 4 personas) deberán diseñar, implementar y probar el prototipo del SGBDD siguiendo estos pilares técnicos:

**A. Diseño y Fragmentación de Datos**

1.  **Fragmentación Horizontal:**
    *   La tabla Ventas y DetalleVenta debe fragmentarse horizontalmente por el campo departamento_id. Las ventas realizadas en Santa Cruz residirán físicamente en el **Nodo 2**, las de Cochabamba en el **Nodo 3**, etc.

2.  **Fragmentación Vertical:**
    *   La tabla Clientes debe dividirse verticalmente: los datos de identificación y contacto público en nodos locales, mientras que la información de crédito, historial financiero y límites de pago deben almacenarse únicamente en el **Nodo 1 (La Paz)** por motivos de seguridad y auditoría.

**B. Replicación y Transparencia**

1.  **Replicación Parcial / Total:**
    *   La tabla Productos_Catálogo (precios, códigos de barra y descripciones) debe replicarse en **todos los nodos** para permitir búsquedas locales instantáneas sin sobrecargar la red interdepartamental.

2.  **Transparencia de Localización y Fragmentación:**
    *   Implementar vistas distribuidas (Distributed Views) o procedimientos almacenados que permitan a un analista en el **Nodo La Paz** ejecutar la consulta `SELECT * FROM Ventas_Nacionales` sin saber cómo están distribuidos los datos entre los departamentos.

**C. Transacciones Distribuidas y Concurrencia**

1.  **Proceso de Traspaso Interdepartamental (Ejemplo: Santa Cruz → Beni):**
    *   Diseñar una transacción distribuida para la transferencia de inventario entre almacenes de distintos departamentos.
    *   Garantizar la propiedad ACID utilizando el algoritmo de **Compromiso en Dos Fases (2PC - Two-Phase Commit)** o mecanismos nativos del motor seleccionado.
    *   Si el **Nodo Beni** pierde conexión a mitad del traspaso, el sistema debe realizar un *Rollback* automático en el **Nodo Santa Cruz**.

**4. Entregables por Fases (Hitos del Semestre)**

**Fase 1: Arquitectura y Modelado (Semanas 1)**

*   Documento de arquitectura de datos distribuidos (Diagramas Entidad-Relación globales y esquemas fragmentados).

```text
[PRODUCTOS_CATÁLOGO] 1 --- * [INVENTARIO] * --- 1 [ALMACENES]
         | 1                                         | 1
         |                                           |
         | *                                         | *
[DETALLE_VENTA] * --------------------------- 1 [VENTAS] * --- 1 [CLIENTES_DATOS_GENERALES]
                                                                          | 1
                                                                          |
                                                                          | 1
                                                              [CLIENTES_FINANCIERO]
```

**Definición de Entidades Principales:**

*   **PRODUCTOS_CATÁLOGO:** (id_producto, codigo_barras, nombre, descripcion, precio_unitario, categoria)
*   **CLIENTES_DATOS_GENERALES:** (id_cliente, nit_ci, razon_social, telefono, direccion, departamento_id)
*   **CLIENTES_FINANCIERO:** (id_cliente, limite_credito, saldo_pendiente, calificacion_riesgo, estado_credito)
*   **VENTAS:** (id_venta, fecha_hora, departamento_id, id_cliente, id_empleado, total_bs)
*   **DETALLE_VENTA:** (id_detalle, id_venta, id_producto, cantidad, precio_aplicado, subtotal)
*   **ALMACENES:** (id_almacen, nombre_almacen, departamento_id, direccion)
*   **INVENTARIO:** (id_almacen, id_producto, stock_actual, stock_minimo)

**A. Fragmentación Horizontal (Partitioning/Sharding)**

Aplica a tablas con alto volumen de transacciones operativas locales para mantener los datos cerca de donde se generan.

*   **Tabla VENTAS y DETALLE_VENTA:**
    *   **Criterio de Fragmentación:** Predicado por campo departamento_id.
    *   **Reglas de Fragmentación:**
        *   Fragmento \(F_{V1} = \sigma_{departamento\_id='LP'}(VENTAS) \rightarrow\) Almacenado en **Nodo 1 (La Paz)**.
        *   Fragmento \(F_{V2} = \sigma_{departamento\_id='SC'}(VENTAS) \rightarrow\) Almacenado en **Nodo 2 (Santa Cruz)**.
        *   Fragmento \(F_{V3} = \sigma_{departamento\_id='CB'}(VENTAS) \rightarrow\) Almacenado en **Nodo 3 (Cochabamba)**.
        *   Fragmento \(F_{V4} = \sigma_{departamento\_id \in \{'TJ','CH'\}}(VENTAS) \rightarrow\) Almacenado en **Nodo 4 (Tarija)**.
        *   Fragmento \(F_{V5} = \sigma_{departamento\_id \in \{'OR','PO'\}}(VENTAS) \rightarrow\) Almacenado en **Nodo 5 (Oruro)**.
        *   Fragmento \(F_{V6} = \sigma_{departamento\_id \in \{'BE','PA'\}}(VENTAS) \rightarrow\) Almacenado en **Nodo 6 (Beni)**.

*   **Tabla INVENTARIO:**
    *   **Criterio de Fragmentación:** Derivada del id_almacen asociado al departamento.
    *   **Distribución:** Cada nodo gestiona exclusivamente el stock físico de sus almacenes locales.

**B. Fragmentación Vertical**

Aplica para separar información de uso cotidiano de datos sensibles o de alto impacto crediticio.

*   **Tabla CLIENTES:**
    *   **Fragmento \(F_{C1}\) (Datos Públicos/Operativos):** PROJECTION(id_cliente, nit_ci, razon_social, telefono, direccion, departamento_id).
        *   *Ubicación:* Fragmentado horizontalmente por departamento_id en los **Nodos 1 al 6** para permitir facturación rápida.
    *   **Fragmento \(F_{C2}\) (Datos Financieros y Riesgo):** PROJECTION(id_cliente, limite_credito, saldo_pendiente, calificacion_riesgo, estado_credito).
        *   *Ubicación:* Almacenado de forma **exclusiva y centralizada en el Nodo 1 (La Paz)** por requerimientos de auditoría y regulación de banca/crédito corporativo.

**C. Replicación de Datos**

*   **Tabla PRODUCTOS_CATÁLOGO:**
    *   **Estrategia:** Replicación Total (Full Replication) en los 6 nodos.
    *   **Justificación:** Tabla de lectura masiva y baja frecuencia de actualización. Permite validar precios y productos en cada venta de forma 100% local sin llamadas remotas por red.
    *   **Mecanismo de Actualización:** Replicación asíncrona mediante publicación/suscripción desde el Nodo 1 (La Paz).

*   Matriz de distribución de datos (CRUD por nodo).
*   Justificación de las decisiones de fragmentación y estrategia de replicación.

**Fase 2: Despliegue de Infraestructura y Datos (Semanas 1-2)**

*   Despliegue de nodos utilizando entornos virtualizados o contenedores (ej. Docker, PostgreSQL con postgres_fdw, Citus, MariaDB Galera o CockroachDB).
*   Scripts de creación de bases de datos locales, tablas globales, fragmentos y réplicas.
*   Carga de datos de prueba (mínimo 50,000 registros de ventas distribuidos entre los departamentos).

**Fase 3: Lógica Distribuida y Pruebas de Estrés (Semanas 2-3)**

*   Implementación de vistas globales y consultas distribuidas con *JOINs* entre nodos (ej. unir datos de cliente en La Paz con ventas en Tarija).
*   Pruebas de simulación de fallo de red: Desconectar artificialmente el nodo de **Beni** o **Oruro** y demostrar que los demás nodos siguen operando con **Autonomía Local**.
*   Pruebas de consistencia eventual o fuerte al actualizar el catálogo de productos desde el nodo **La Paz**.

**5. Rúbrica de Evaluación**

| Criterio | Descripción | Puntuación |
| :--- | :--- | :--- |
| **Diseño y Fragmentación** | Correcta aplicación de fragmentación horizontal y vertical ajustada al escenario boliviano. | 25% |
| **Autonomía Local y Transparencia** | Los nodos operan localmente ante caídas de red; las consultas globales ocultan la complejidad. | 25% |
| **Transacciones y Concurrencia** | Manejo adecuado de 2PC/ACID en transacciones entre dos o más departamentos sin inconsistencias. | 25% |
| **Demostración Práctica** | Sustentación en vivo simulando caídas de nodos y ejecución de transacciones distribuidas. | 20% |
| **Documentación Técnica** | Manual de arquitectura, scripts DDL/DML y guía de despliegue. | 5% |
