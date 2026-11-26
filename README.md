# BoliviaDistribución — Sistema de Gestión Logística Nacional

Prototipo de **Sistema de Base de Datos Distribuida (SGBDD)** para la empresa ficticia
*BoliviaDistribución S.A.*, con **6 nodos PostgreSQL** distribuidos por departamento y
conectados mediante una red Docker común.

> **Estado actual (26/11/2026):** los 6 contenedores están saludables y la fragmentación
> horizontal está aplicada y verificada. Los scripts de FDW existen pero aún no se han
> ejecutado. Las tablas están vacías: la carga de datos corresponde al Equipo 5.

---

## Arquitectura

| Nodo | Contenedor | Departamento(s) | Puerto host | Rol |
| :--- | :--- | :--- | :--- | :--- |
| 1 | `nodo1_lapaz` | La Paz (`LP`) | 5441 | Central administrativa y consolidación |
| 2 | `nodo2_santacruz` | Santa Cruz (`SC`) | 5442 | Logística, agroindustria y retail |
| 3 | `nodo3_cochabamba` | Cochabamba (`CB`) | 5443 | Hub de distribución y ensamblaje |
| 4 | `nodo4_tarija` | Tarija y Chuquisaca (`TJ`, `CH`) | 5444 | Sub-nodo Sur |
| 5 | `nodo5_oruro` | Oruro y Potosí (`OR`, `PO`) | 5445 | Sub-nodo Occidente / minería |
| 6 | `nodo6_beni` | Beni y Pando (`BE`, `PA`) | 5446 | Sub-nodo Oriente / Amazonía |

- **Motor:** PostgreSQL 17.
- **Red interna:** `red_bdd`. Dentro de Docker los nodos se resuelven por nombre
  (`nodo1` … `nodo6`); desde el host se accede por `localhost` y los puertos de la tabla.
- **Persistencia:** un volumen por nodo (`nodo1_data` … `nodo6_data`).
- **Configuración común:** `wal_level=logical`, `max_prepared_transactions=20`,
  `max_connections=100` y healthcheck con `pg_isready`.

---

## Requisitos

- Docker Desktop o Docker Engine con **Compose v2** (`docker compose`, no `docker-compose`).
- **Bash** (Linux/macOS; en Windows usar WSL o Git Bash).
- Puertos **5441–5446** libres.
- Opcional: **DataGrip** para verificación visual.

---

## Puesta en marcha desde cero

1. Clonar el repositorio y entrar en la carpeta:

   ```bash
   git clone <URL-del-repositorio>
   cd proyecto-bdd
   ```

2. Crear el archivo de variables y ajustar la contraseña:

   ```bash
   cp .env.example .env
   # editar .env y cambiar PG_PASSWORD
   ```

   Las tres variables (`PG_USER`, `PG_PASSWORD`, `PG_DB`) se aplican a los 6 nodos.

3. Levantar los contenedores y esperar a que estén saludables:

   ```bash
   docker compose up -d --wait
   docker compose ps
   ```

4. Aplicar el esquema base y los fragmentos horizontales:

   ```bash
   bash scripts/aplicar_fragmentacion.sh
   ```

5. Configurar las conexiones entre nodos con `postgres_fdw`:

   ```bash
   bash scripts/fdw_servidores.sh
   bash scripts/fdw_importar.sh
   ```

6. Verificar el entorno:

   ```bash
   bash scripts/test_conectividad.sh
   bash scripts/verificar_fragmentacion.sh
   ```

> **Importante:** los scripts de `init/` solo se ejecutan al crear un volumen nuevo.
> Si el volumen ya existe, los pasos 4 y 5 son obligatorios para dejar el entorno
> utilizable.

---

## Verificación rápida

| Comando | Resultado esperado |
| :--- | :--- |
| `docker compose ps` | 6 contenedores en `Up (healthy)` |
| `bash scripts/test_conectividad.sh` | 30 líneas `OK` y `Conexiones fallidas: 0` |
| `bash scripts/verificar_fragmentacion.sh` | `RESULTADO: OK` |
| `docker compose exec -T nodo1 psql -U "$PG_USER" -d "$PG_DB" -c "SELECT count(*) FROM remoto_n2.ventas;"` | `0` (conexión FDW funcionando) |

> Los avisos `tabla vacía (pendiente la carga de datos del Equipo 5)` son normales
> mientras no existan datos. **No son fallos.**

---

## Conexión desde DataGrip o un cliente SQL

Usar `localhost` (no `nodo1`) y el puerto de cada nodo:

| Nodo | Host | Puerto | Base de datos | Usuario | Contraseña |
| :--- | :--- | :--- | :--- | :--- | :--- |
| 1 | `localhost` | `5441` | `PG_DB` | `PG_USER` | `PG_PASSWORD` |
| 2 | `localhost` | `5442` | `PG_DB` | `PG_USER` | `PG_PASSWORD` |
| 3 | `localhost` | `5443` | `PG_DB` | `PG_USER` | `PG_PASSWORD` |
| 4 | `localhost` | `5444` | `PG_DB` | `PG_USER` | `PG_PASSWORD` |
| 5 | `localhost` | `5445` | `PG_DB` | `PG_USER` | `PG_PASSWORD` |
| 6 | `localhost` | `5446` | `PG_DB` | `PG_USER` | `PG_PASSWORD` |

Los valores reales están en `.env` (que **no** se versiona).

También se puede entrar por consola:

```bash
docker compose exec -T nodo1 psql -U "$PG_USER" -d "$PG_DB"
```

---

## Estructura del repositorio

```text
.
├── docker-compose.yml          # 6 nodos PostgreSQL, red y volúmenes
├── .env.example                # plantilla de credenciales (copiar a .env)
├── init/
│   ├── 01_extensiones.sql      # postgres_fdw en los 6 nodos
│   └── 02_tablas_base.sql      # esquema base común
├── fragmentacion/
│   ├── nodo1.sql … nodo6.sql   # CHECK por departamento y secuencias
├── scripts/
│   ├── aplicar_fragmentacion.sh
│   ├── fdw_servidores.sh
│   ├── fdw_importar.sh
│   ├── test_conectividad.sh
│   └── verificar_fragmentacion.sh
├── docs/
│   ├── instrucciones-proyecto.md
│   ├── distribucion-trabajo-equipos.txt
│   └── bases_de_datos_distribuidas.md
└── tests/                      # pruebas automatizadas (pendiente)
```

---

## Scripts

| Script | Qué hace | Cuándo ejecutarlo |
| :--- | :--- | :--- |
| `scripts/aplicar_fragmentacion.sh` | Aplica el esquema base y el fragmento horizontal de cada nodo. | Después de levantar los contenedores o al recrear volúmenes. |
| `scripts/fdw_servidores.sh` | Crea 5 servidores FDW, credenciales y esquemas `remoto_nX` en cada nodo. | Después de aplicar la fragmentación. |
| `scripts/fdw_importar.sh` | Importa `ventas`, `detalle_venta`, `almacenes` e `inventario` de los otros nodos. | Después de `fdw_servidores.sh`. |
| `scripts/test_conectividad.sh` | Prueba las 30 conexiones dirigidas entre nodos. | Tras levantar el entorno. |
| `scripts/verificar_fragmentacion.sh` | Verifica restricciones, secuencias, filas fuera de fragmento y unicidad global. | Tras aplicar fragmentación y FDW. |

Todos los scripts son **idempotentes**: se pueden volver a ejecutar sin perder datos.

---

## Modelo de datos y fragmentación

El DDL base es una **propuesta del Equipo 2** hasta que el Equipo 1 entregue el modelo
definitivo. Si cambian nombres o tipos, hay que ajustar juntos
`init/02_tablas_base.sql` y `fragmentacion/nodoX.sql`.

### Fragmentación horizontal de ventas

| Nodo | Predicado |
| :--- | :--- |
| 1 | `departamento_id = 'LP'` |
| 2 | `departamento_id = 'SC'` |
| 3 | `departamento_id = 'CB'` |
| 4 | `departamento_id IN ('TJ','CH')` |
| 5 | `departamento_id IN ('OR','PO')` |
| 6 | `departamento_id IN ('BE','PA')` |

- `detalle_venta` e `inventario` **heredan** el fragmento por clave foránea.
- Las secuencias usan `INCREMENT 6` y cada nodo arranca en su número, de modo que los
  `id` son únicos a nivel nacional.
- Cada nodo tiene restricciones `CHECK` que impiden guardar registros de otra región.

### Otros elementos del modelo

- `clientes_datos_generales`: fragmentación horizontal por departamento.
- `clientes_financiero`: debe residir solo en el Nodo 1 (Equipo 3).
- `productos_catalogo`: replicada en los 6 nodos (Equipo 3).

---

## Equipos y responsabilidades

| Equipo | Tareas principales |
| :--- | :--- |
| **1** | Modelo entidad-relación, DDL definitivo y verificación SQL. |
| **2** | Docker/Compose, fragmentación horizontal de ventas, FDW y verificación en DataGrip. |
| **3** | Fragmentación vertical de clientes y replicación lógica de productos. |
| **4** | Vistas distribuidas, consultas entre nodos y coordinador 2PC. |
| **5** | Generación y carga de 50.000 ventas, pruebas con pytest, integración y documentación final. |

El detalle está en [`docs/distribucion-trabajo-equipos.txt`](docs/distribucion-trabajo-equipos.txt)
y los requisitos completos en [`docs/instrucciones-proyecto.md`](docs/instrucciones-proyecto.md).

---

## Flujo de trabajo

- Mantener `main` estable; trabajar en ramas por equipo y abrir *pull request*.
- **Nunca** subir `.env` (contiene contraseñas). Solo se versiona `.env.example`.
- Antes de cerrar un cambio, ejecutar `test_conectividad.sh` y
  `verificar_fragmentacion.sh`.
- Actualizar este README si cambian puertos, scripts o pasos de despliegue.

---

## Problemas comunes

| Síntoma | Causa probable / solución |
| :--- | :--- |
| Un contenedor no está `healthy` | Ver logs: `docker compose logs nodoX` |
| `permission denied` al ejecutar un script | Ejecutarlo con `bash scripts/...` |
| `port is already allocated` | Otro proceso usa 5441–5446; cambiar el puerto en `docker-compose.yml` |
| `FALLO restricciones de fragmento` | Ejecutar `bash scripts/aplicar_fragmentacion.sh` |
| `relation "remoto_nX.ventas" does not exist` | Ejecutar `fdw_servidores.sh` y luego `fdw_importar.sh` |
| Error de autenticación tras cambiar `.env` | La contraseña se fija al crear el volumen; recrear con `down -v` o usar `ALTER USER` |
| Las tablas están vacías | Pendiente la carga de datos del Equipo 5 |

### Reinicio total (borra los datos)

```bash
docker compose down -v
docker compose up -d --wait
bash scripts/aplicar_fragmentacion.sh
bash scripts/fdw_servidores.sh
bash scripts/fdw_importar.sh
```

---

## Estado del proyecto

- [x] 6 contenedores PostgreSQL, red y volúmenes.
- [x] Esquema base y extensiones.
- [x] Fragmentación horizontal definida, aplicada y verificable.
- [x] Scripts de FDW listos.
- [ ] FDW ejecutado en el entorno.
- [ ] Conexiones de DataGrip configuradas por cada integrante.
- [ ] Carga de 50.000 ventas (Equipo 5).
- [ ] Fragmentación vertical y replicación (Equipo 3).
- [ ] Vistas distribuidas y 2PC (Equipo 4).
- [ ] Pruebas automatizadas con pytest (Equipo 5).

---

## Contexto académico

Proyecto de la asignatura **Bases de Datos Distribuidas (2/2026)**.

- **Integrantes:** _(completar)_
- **Docente:** _(completar)_
- **Universidad:** _(completar)_