---
title: "Bases de Datos Distribuidas"
source_type: "Presentación académica (diapositivas)"
source_file: "Diapositiva TEMA 2 BDD.pdf"
author: "Ing. Jorge Ramirez"
subject: "Fundamentos, arquitectura, fragmentación, replicación y procesamiento distribuido de consultas"
language: "es"
processing_type: "knowledge_synthesis"
---

# Bases de Datos Distribuidas

## Descripción general

Este material académico introduce las bases de datos distribuidas (BDD), sus conceptos fundamentales y las estrategias para organizar datos en varios nodos conectados por una red. Explica la fragmentación y la replicación, sus variantes, las reglas que debe cumplir una fragmentación correcta y los compromisos que plantea la consistencia de las réplicas. Finalmente, presenta un ejemplo de optimización de consultas distribuidas mediante la ejecución local de selecciones y proyecciones para reducir el tráfico de red.

La presentación pertenece al material de la asignatura o unidad titulada **Bases de Datos Distribuidas**, elaborado por el Ing. Jorge Ramirez y marcado como **2 - 2026**. El objetivo general declarado es adquirir competencias para trabajar en un ambiente distribuido de bases de datos utilizando transacciones, disparadores y procedimientos almacenados.

El índice anuncia además arquitectura cliente-servidor, ventajas, consultas en SQL Server e implementación de operadores relacionales. Sin embargo, en las diapositivas disponibles esos asuntos no reciben todos un desarrollo específico: se conserva aquí lo que efectivamente aparece en la fuente y se señalan los temas anunciados cuyo desarrollo no está incluido.

## Desarrollo del conocimiento

## 1. Fundamentos de bases de datos y sistemas distribuidos

### 1.1. Base de datos

Una **base de datos** es un conjunto organizado de datos relacionados entre sí, almacenados de manera que puedan consultarse, modificarse y administrarse eficientemente.

**Ejemplo de la presentación:** una universidad almacena información de estudiantes, docentes, materias y calificaciones.

### 1.2. Sistema de Gestión de Bases de Datos (SGBD)

Un **Sistema de Gestión de Bases de Datos (SGBD)** es el software que permite crear, consultar, actualizar, proteger y administrar una base de datos.

La presentación menciona como ejemplos:

- PostgreSQL.
- MySQL.
- Oracle Database.
- Microsoft SQL Server.

### 1.3. Servidor de base de datos

Un **servidor de base de datos** es una computadora o sistema informático que ejecuta un SGBD y atiende solicitudes de usuarios o de otras aplicaciones.

**Ejemplo de la presentación:** el servidor de una empresa procesa las consultas del sistema de ventas.

### 1.4. Red de computadoras

Una **red de computadoras** es un conjunto de dispositivos interconectados que intercambian información mediante protocolos de comunicación.

**Ejemplo de la presentación:** las sucursales de una empresa se conectan mediante Internet, una VPN o enlaces privados.

### 1.5. Sistema distribuido de bases de datos

En un sistema distribuido de bases de datos, la información se almacena en varias computadoras. Estas computadoras se ponen en contacto mediante medios de comunicación como redes de alta velocidad o líneas telefónicas.

En el modelo distribuido convencional descrito por la presentación, los equipos **no comparten memoria RAM ni discos físicos**: cada uno utiliza sus propios recursos locales y se comunica con los demás mediante la red. La fuente aclara que existen arquitecturas especializadas diferentes y que esta descripción corresponde al modelo distribuido habitual.

Para comprender una BDD es necesario relacionar cuatro fundamentos:

1. Las bases de datos tradicionales y su organización.
2. Las redes de computadoras.
3. La distribución física de la información.
4. La comunicación entre sistemas.

La distribución no consiste simplemente en guardar una base de datos en una carpeta compartida. Supone nodos con recursos propios, intercambio de mensajes y coordinación de datos y operaciones entre sitios.

## 2. Definición y componentes de una base de datos distribuida

### 2.1. Definición de BDD

Una **Base de Datos Distribuida (BDD)** es una colección de múltiples bases de datos lógicamente interrelacionadas, pero distribuidas físicamente en diferentes nodos o servidores conectados mediante una red de comunicación.

La presentación también la caracteriza como una base de datos virtual: sus partes componentes están almacenadas en varias bases de datos reales situadas en distintos lugares. La BDD constituye la unión lógica de esas bases de datos reales.

Por tanto, deben distinguirse dos dimensiones:

- **Dimensión lógica:** los datos forman un conjunto relacionado y pueden presentarse como una visión integrada.
- **Dimensión física:** los datos residen en diferentes bases de datos, computadoras o ubicaciones.

### 2.2. Sistema de Gestión de Bases de Datos Distribuidas (SGBDD / DDBMS)

El **Sistema de Gestión de Bases de Datos Distribuidas (SGBDD o DDBMS)** es el software que gestiona la BDD y procura que la distribución física sea transparente para los usuarios. Su propósito, según la presentación, es hacer que el conjunto parezca una única base de datos centralizada.

La transparencia de distribución significa que el usuario puede consultar la base integrada sin tener que conocer necesariamente la ubicación física de cada dato o réplica.

### 2.3. Nodo o sitio

Un **nodo** o **sitio** es cada equipo o servidor individual que forma parte de la red distribuida. Cada nodo dispone de capacidad propia de procesamiento y almacenamiento local.

### 2.4. Autonomía local

La **autonomía local** es la capacidad de cada nodo para gestionar sus propios datos y ejecutar transacciones locales de manera independiente, sin depender completamente de una entidad central.

La autonomía local no elimina la necesidad de coordinación cuando una operación involucra datos de varios nodos; describe la capacidad de administrar y operar los recursos propios del sitio.

## 3. Infraestructura y conceptos operativos de una BDD

Los siguientes conceptos permiten entender cómo se comunican y operan los nodos distribuidos.

### 3.1. Red de comunicación

Es el medio por el que los nodos intercambian solicitudes y datos. La presentación menciona Ethernet, fibra óptica e Internet como ejemplos.

### 3.2. Memoria local

Es la memoria RAM propia de cada computadora. Se utiliza para ejecutar procesos y almacenar datos temporalmente.

### 3.3. Almacenamiento local

Son los discos o unidades de almacenamiento administrados por cada computadora o servidor.

### 3.4. Paso de mensajes

Es el intercambio de información entre nodos mediante mensajes transmitidos por la red.

### 3.5. Latencia

Es el tiempo que tarda un mensaje o una solicitud en llegar a su destino y obtener una respuesta. La medición depende de cómo se defina el intervalo considerado.

### 3.6. Fallo de nodo o de red

Se produce cuando una computadora deja de funcionar o cuando los nodos pierden la comunicación entre sí.

### 3.7. Propiedades y características relevantes

La presentación identifica las siguientes propiedades:

- **Disponibilidad:** capacidad del sistema para atender solicitudes cuando se necesita acceder a los datos.
- **Consistencia:** propiedad que permite mantener los datos de acuerdo con las reglas e invariantes del sistema. En sistemas replicados también importa cuándo y cómo se reflejan las actualizaciones.
- **Rendimiento:** eficiencia con la que se procesan consultas y operaciones, considerando factores como el tiempo de respuesta y la cantidad de solicitudes atendidas.
- **Escalabilidad:** capacidad de ampliar recursos o incorporar nuevos nodos para responder al crecimiento de los datos y de la demanda.
- **Tolerancia a fallos:** capacidad de continuar ofreciendo determinados servicios o recuperarse cuando fallan componentes del sistema.

La presentación señala que las BDD pueden ofrecer alta disponibilidad, escalabilidad horizontal y transparencia de distribución, y que a menudo emplean redundancia de datos para favorecer la tolerancia a fallos y el rendimiento local. No obstante, **la distribución por sí sola no garantiza tolerancia a fallos**. Para ello hacen falta mecanismos de redundancia, recuperación y gestión de fallos.

## 4. Ejemplo integrador: empresa con sucursales

La presentación propone una empresa comercial con oficinas en Sucre, La Paz y Santa Cruz:

- **Sucre:** registra las ventas de su sucursal.
- **La Paz:** administra los pedidos y las existencias locales.
- **Santa Cruz:** registra sus propias operaciones comerciales.
- **Red de comunicación:** permite intercambiar información entre las sucursales.
- **Replicación o fragmentación:** determina cómo se distribuyen los datos según las necesidades del negocio.
- **Consulta distribuida:** permite elaborar un informe consolidado de las ventas de las tres ciudades.

Aunque los datos se encuentren en computadoras físicamente separadas, el sistema puede ofrecer una visión integrada de la información. La forma concreta de conseguirlo depende del diseño, del SGBD y de los mecanismos de comunicación empleados.

Este ejemplo relaciona la distribución física de los datos con la integración lógica: cada sucursal puede operar con información local, mientras que una consulta distribuida reúne información de las distintas ubicaciones.

## 5. Estrategias de almacenamiento distribuido

La presentación distingue tres estrategias principales para almacenar datos en una arquitectura distribuida.

### 5.1. Sin replicación (disjunta)

Cada fragmento de datos existe en un único sitio específico de la red.

**Ventajas descritas:**

- Minimiza el espacio de almacenamiento.
- Elimina problemas de consistencia derivados de actualizar copias replicadas, puesto que no hay copias de esos fragmentos en otros sitios.

**Desventaja descrita:**

- Si falla un sitio, los datos que aloja quedan completamente inaccesibles.

### 5.2. Replicación total

Se guarda una copia completa de toda la base de datos en cada sitio de la red.

**Ventajas descritas:**

- Alta disponibilidad.
- Lecturas muy rápidas, porque pueden realizarse localmente en cada sitio.

**Desventajas descritas:**

- Costo de almacenamiento muy alto.
- Operaciones de escritura y actualización complejas y lentas debido a la sincronización de las copias.

### 5.3. Replicación parcial o híbrida

Los fragmentos de datos se replican únicamente en los sitios donde su frecuencia de acceso es alta.

**Ventajas descritas:**

- Equilibrio entre velocidad de lectura, disponibilidad y costos de almacenamiento y red.

**Desventaja descrita:**

- Requiere un diseño meticuloso del esquema de distribución.

### 5.4. Comparación de estrategias

| Estrategia | Organización de los datos | Ventajas indicadas | Desventajas indicadas |
|---|---|---|---|
| Sin replicación (disjunta) | Cada fragmento reside en un único sitio. | Menor almacenamiento; evita problemas de consistencia entre copias. | La caída del sitio puede dejar inaccesibles sus datos. |
| Replicación total | Cada sitio almacena una copia completa de la base global. | Alta disponibilidad y lecturas locales rápidas. | Alto almacenamiento y escrituras/actualizaciones costosas por sincronización. |
| Replicación parcial (híbrida) | Se copian determinados fragmentos en los sitios con alta frecuencia de acceso. | Equilibrio entre lecturas, disponibilidad y costos. | Diseño de distribución más cuidadoso. |

## 6. Fragmentación de datos

### 6.1. Definición

La **fragmentación** consiste en dividir una relación global \(R\) en partes más pequeñas denominadas fragmentos:

\[
R_1, R_2, \ldots, R_n
\]

La fragmentación determina cómo se separa una relación para distribuir sus partes entre distintos sitios. La relación global debe poder recuperarse a partir de sus fragmentos.

### 6.2. Reglas de una fragmentación correcta

Para que la división no altere la integridad de la base de datos, la presentación establece tres reglas fundamentales.

#### Completitud

Si un dato \(x\) pertenece a la relación \(R\), debe estar presente en al menos uno de los fragmentos \(R_i\). La fragmentación no debe perder datos de la relación global.

#### Reconstrucción

Debe existir un operador relacional que permita recuperar la relación original \(R\) combinando los fragmentos.

El operador concreto depende del tipo de fragmentación:

- En la fragmentación horizontal, la reconstrucción se realiza mediante unión (\(\cup\)).
- En la fragmentación vertical, la reconstrucción se realiza mediante reunión (*join*, \(\bowtie\)) utilizando la clave común.

#### Disyunción

Si la relación se divide horizontalmente, un registro no debe repetirse en más de un fragmento. La presentación exceptúa las claves primarias en la fragmentación vertical, donde se incluyen en los distintos fragmentos para permitir la reconstrucción.

### 6.3. Fragmentación horizontal

La **fragmentación horizontal** divide una relación por filas o tuplas. Utiliza el operador de selección (\(\sigma\)) y asigna grupos de registros a distintos sitios según una condición lógica.

**Ejemplo de la presentación: relación global `Empleado`**

| ID | Nombre | Depto | Salario |
|---:|---|---|---:|
| 101 | Ana Ramos | Sistemas | 3500 |
| 102 | Bruno Díaz | Ventas | 2800 |
| 103 | Carlos Pérez | Sistemas | 4000 |
| 104 | Diana López | Ventas | 3100 |

Se crean dos fragmentos según el departamento:

\[
E_1 = \sigma_{Depto='Sistemas'}(Empleado)
\]

\[
E_2 = \sigma_{Depto='Ventas'}(Empleado)
\]

**Fragmento \(E_1\), departamento Sistemas:**

| ID | Nombre | Depto | Salario |
|---:|---|---|---:|
| 101 | Ana Ramos | Sistemas | 3500 |
| 103 | Carlos Pérez | Sistemas | 4000 |

**Fragmento \(E_2\), departamento Ventas:**

| ID | Nombre | Depto | Salario |
|---:|---|---|---:|
| 102 | Bruno Díaz | Ventas | 2800 |
| 104 | Diana López | Ventas | 3100 |

La relación original se reconstruye mediante:

\[
Empleado = E_1 \cup E_2
\]

En este ejemplo, cada fila se asigna a un fragmento de acuerdo con el valor del atributo `Depto`.

### 6.4. Fragmentación vertical

La **fragmentación vertical** divide una relación por columnas o atributos. Utiliza el operador de proyección (\(\pi\)).

La clave primaria debe incluirse en todos los fragmentos verticales para conservar el vínculo entre los atributos y permitir reconstruir las tuplas originales.

Para la relación `Empleado`, la presentación define:

\[
EV_1 = \pi_{ID, Nombre, Depto}(Empleado)
\]

\[
EV_2 = \pi_{ID, Salario}(Empleado)
\]

**Fragmento \(EV_1\):**

| ID | Nombre | Depto |
|---:|---|---|
| 101 | Ana Ramos | Sistemas |
| 102 | Bruno Díaz | Ventas |
| 103 | Carlos Pérez | Sistemas |
| 104 | Diana López | Ventas |

**Fragmento \(EV_2\):**

| ID | Salario |
|---:|---:|
| 101 | 3500 |
| 102 | 2800 |
| 103 | 4000 |
| 104 | 3100 |

La relación original se reconstruye mediante una reunión por la clave `ID`:

\[
Empleado = EV_1 \bowtie EV_2
\]

La repetición de `ID` en ambos fragmentos es intencional: permite relacionar los atributos que fueron separados.

### 6.5. Fragmentación mixta o híbrida

La **fragmentación mixta (híbrida)** combina fragmentación horizontal y vertical. Puede aplicar una selección horizontal sobre una proyección vertical, o realizar las operaciones en el orden inverso.

La presentación ejemplifica una expresión de selección sobre una proyección:

\[
EM_1 =
\sigma_{Salario>3000}
\left(
\pi_{ID, Nombre, Salario}(Empleado)
\right)
\]

Primero se proyectan los atributos `ID`, `Nombre` y `Salario`; sobre el resultado se seleccionan los registros cuyo salario es mayor que 3000.

## 7. Replicación en bases de datos distribuidas

### 7.1. Definición

La **replicación** es el proceso de almacenar y mantener copias idénticas de una base de datos completa o de fragmentos específicos en diferentes nodos o sitios físicos conectados mediante una red de computadoras.

A diferencia de la fragmentación, que divide los datos en partes, la replicación mantiene copias de los datos en más de un sitio.

### 7.2. Objetivos y ventajas principales

#### Alta disponibilidad y tolerancia a fallos

Si falla un nodo o un enlace de red, el sistema puede continuar respondiendo consultas utilizando las réplicas disponibles en otros nodos.

La continuidad efectiva depende de que existan réplicas utilizables y mecanismos adecuados para gestionar fallos.

#### Reducción de latencia y mejora del rendimiento de lectura

Las consultas de lectura pueden procesarse localmente en el nodo más cercano al usuario, evitando transferir los datos por la red distribuida para cada consulta.

#### Balanceo de carga

El tráfico de lectura puede distribuirse entre varios nodos, en lugar de concentrarse y saturar un único servidor central.

### 7.3. Clasificación según el alcance del almacenamiento

**Replicación total:** cada nodo almacena una copia completa de toda la base de datos global. Maximiza la disponibilidad de lectura, pero implica costos elevados de almacenamiento y actualización.

**Replicación parcial:** solo determinados fragmentos se duplican en los nodos donde la frecuencia de acceso a esa información es alta. Busca equilibrar el costo de almacenamiento y la velocidad de acceso.

Esta clasificación coincide con las estrategias de almacenamiento distribuido descritas anteriormente.

### 7.4. Clasificación según la sincronización de datos

#### Replicación síncrona

Una transacción de escritura o modificación solo se confirma como exitosa cuando los cambios se han grabado en todas las réplicas del sistema.

- **Ventaja:** proporciona consistencia fuerte según la descripción de la presentación; todos los nodos leen exactamente los mismos datos en todo momento.
- **Desventaja:** genera mayor latencia en las escrituras y más sensibilidad a fallos de red, porque la confirmación depende de la propagación a las réplicas.

#### Replicación asíncrona

La modificación se graba primero en el nodo de origen y se confirma al usuario inmediatamente. Después, las actualizaciones se propagan a las demás réplicas en segundo plano.

- **Ventaja:** las escrituras pueden confirmarse rápidamente y el mecanismo tolera mejor las latencias de red.
- **Desventaja:** existe riesgo de consistencia eventual; durante breves intervalos algunas réplicas pueden estar desactualizadas.

### 7.5. El costo de mantener la consistencia

El principal inconveniente de la replicación señalado por la presentación es el costo de actualización.

Cada operación de escritura sobre un dato replicado —`INSERT`, `UPDATE` o `DELETE`— exige propagar la modificación a todas sus copias para evitar inconsistencias.

La coordinación de este proceso puede utilizar protocolos de concurrencia distribuida, entre ellos:

- **Two-Phase Commit (2PC):** protocolo citado para coordinar operaciones entre participantes.
- **Copia Primaria (Primary-Copy):** esquema citado para organizar la coordinación de las actualizaciones a partir de una copia primaria.

La presentación menciona estos mecanismos como formas de coordinación, pero no desarrolla sus fases internas ni sus algoritmos.

### 7.6. Gestión conjunta de réplicas y fragmentos

La replicación puede combinarse con la fragmentación: se distribuyen fragmentos de la relación global y se mantienen copias de un mismo fragmento en diferentes nodos.

La presentación identifica dos aspectos de la estrategia de gestión de réplicas:

**Transparencia de replicación:** el usuario debe poder consultar la base de datos sin necesitar conocer en qué sitio físico se encuentra almacenada la réplica.

**Control de consistencia:** cuando se modifica una tupla de un fragmento replicado —por ejemplo, en el Sitio 1— el sistema debe aplicar un protocolo de actualización, como Two-Phase Commit o Primary-Copy, para reflejar el cambio en todas las copias del fragmento —por ejemplo, en el Sitio 2— sin introducir inconsistencias.

## 8. Procesamiento distribuido de consultas

### 8.1. Costo de una consulta distribuida

En un entorno distribuido, el rendimiento no depende únicamente del acceso al disco local (I/O). También es determinante el costo de transmitir datos por la red.

La presentación expresa el costo total de la siguiente manera:

\[
CostoTotal = Costo_{I/O} + Costo_{CPU} + Costo_{Red}
\]

El **costo de red** representa el peso de transferir información entre nodos y puede convertirse en un factor decisivo de la ejecución.

### 8.2. Objetivo del procesador distribuido de consultas

El objetivo del procesador distribuido de consultas es reescribir la consulta algebraica global para minimizar la cantidad de bytes transferidos entre los nodos de la red.

La estrategia mostrada consiste en evaluar las operaciones tan cerca de los datos como sea posible y enviar únicamente los resultados necesarios.

### 8.3. Escenario del ejemplo de optimización

La relación `Empleado` está fragmentada horizontalmente en dos sitios:

- **Sitio 1:** contiene \(E_1 = \sigma_{Depto='Sistemas'}(Empleado)\), con 10.000 registros.
- **Sitio 2:** contiene \(E_2 = \sigma_{Depto='Ventas'}(Empleado)\), con 10.000 registros.

Un usuario situado en el **Sitio 3** solicita:

> Obtener el nombre de los empleados de Sistemas con salario mayor a 3500.

La consulta en álgebra relacional global es:

\[
\pi_{Nombre}
\left(
\sigma_{Depto='Sistemas' \land Salario>3500}(Empleado)
\right)
\]

Como la relación global se reconstruye a partir de los dos fragmentos:

\[
Empleado = E_1 \cup E_2
\]

la expresión puede escribirse sustituyendo la relación por sus fragmentos:

\[
\pi_{Nombre}
\left(
\sigma_{Depto='Sistemas' \land Salario>3500}(E_1 \cup E_2)
\right)
\]

### 8.4. Estrategia 1: consulta ingenua sin optimización

La estrategia no optimizada ejecuta los pasos siguientes:

1. Transfiere el fragmento completo \(E_1\) desde el Sitio 1 al Sitio 3: 10.000 registros.
2. Transfiere el fragmento completo \(E_2\) desde el Sitio 2 al Sitio 3: 10.000 registros.
3. Realiza en el Sitio 3 la unión \(E_1 \cup E_2\).
4. Aplica en el Sitio 3 la selección y la proyección.

**Impacto en la red:** se transfieren 20.000 registros completos.

La ineficiencia se debe a que se envían todos los registros antes de comprobar qué parte satisface la consulta.

### 8.5. Estrategia 2: consulta optimizada mediante *push-down* de operadores

La optimización aplica los predicados y las proyecciones en los sitios donde residen los datos, antes de transmitir resultados.

**Paso 1. Eliminación de fragmentos irrelevantes**

El fragmento \(E_2\) contiene únicamente empleados del departamento Ventas. Por tanto, la condición:

\[
Depto='Sistemas'
\]

aplicada sobre \(E_2\) produce el conjunto vacío:

\[
\sigma_{Depto='Sistemas'}(E_2)=\varnothing
\]

No es necesario enviar datos desde el Sitio 2.

**Paso 2. *Push-down* de selección y proyección al Sitio 1**

En lugar de transferir todo \(E_1\), el Sitio 1 evalúa localmente la condición salarial y proyecta solo el nombre:

\[
Respuesta_{Sitio1} =
\pi_{Nombre}
\left(
\sigma_{Salario>3500}(E_1)
\right)
\]

La condición de departamento ya está implícita en la definición del fragmento \(E_1\), que contiene solo empleados de Sistemas.

**Paso 3. Transferencia del resultado filtrado**

El Sitio 1 envía al Sitio 3 únicamente el resultado de la selección y proyección. La presentación utiliza como ejemplo un resultado de 50 nombres.

La expresión algebraica final optimizada es:

\[
\pi_{Nombre}
\left(
\sigma_{Salario>3500}(E_1)
\right)
\]

**Impacto en la red:** la transferencia se reduce de 20.000 registros completos a 50 registros que contienen únicamente el campo `Nombre`, según las cantidades ilustrativas del ejemplo.

### 8.6. Principio de optimización demostrado

El ejemplo demuestra dos operaciones importantes:

- **Eliminación de fragmentos irrelevantes:** si la definición de un fragmento permite demostrar que no puede satisfacer el predicado, ese fragmento no necesita participar en la consulta.
- **Empuje hacia abajo (*push-down*) de operadores:** las selecciones y proyecciones se ejecutan localmente antes de transferir los resultados.

La optimización reduce la comunicación de red al evitar transferencias de registros y atributos que no contribuyen al resultado final.

## 9. Modelo de datos del proyecto mostrado

En la diapositiva titulada **Proyecto de BDD** aparece un esquema de entidades o tablas con las siguientes relaciones y cardinalidades representadas:

- `PRODUCTOS_CATÁLOGO` se relaciona con `INVENTARIO` con cardinalidades indicadas como `1` a `*`.
- `INVENTARIO` se relaciona con `ALMACENES` con cardinalidades indicadas como `*` a `1` en la disposición del diagrama.
- `DETALLE_VENTA` se relaciona con `PRODUCTOS_CATÁLOGO` con cardinalidades indicadas como `*` a `1`.
- `DETALLE_VENTA` se relaciona con `VENTAS` con cardinalidades indicadas como `*` a `1`.
- `VENTAS` se relaciona con `CLIENTES_DATOS_GENERALES` con cardinalidades indicadas como `*` a `1`.
- `CLIENTES_DATOS_GENERALES` se relaciona con `CLIENTES_FINANCIERO` con cardinalidad `1` a `1`.

La diapositiva no proporciona atributos, claves, reglas de negocio ni una explicación textual de este modelo. Por ello, las relaciones se registran como aparecen en el esquema, sin inferir campos o restricciones adicionales.

## 10. Comprobación de aprendizaje incluida en la presentación

La presentación incluye cuatro preguntas de selección múltiple para comprobar la comprensión de los fundamentos de BDD. Las respuestas conceptualmente respaldadas por el propio material son:

1. **¿Qué caracteriza principalmente a una base de datos distribuida?**  
   Los datos se almacenan en varios nodos conectados por una red.

2. **¿Cuál es la diferencia entre fragmentación y replicación?**  
   La fragmentación divide los datos; la replicación mantiene copias.

3. **¿Cómo intercambian información los nodos de una arquitectura distribuida convencional?**  
   Mediante mensajes y protocolos de comunicación por la red.

4. **¿La distribución garantiza por sí sola la tolerancia a fallos?**  
   No. Se necesitan mecanismos de redundancia, recuperación y gestión de fallos.

Estas respuestas se desprenden de las definiciones y explicaciones de las diapositivas; las preguntas originales aparecen en las páginas 14 y 15.

## Relaciones y conexiones fundamentales

### A. Distribución física y visión lógica integrada

Una BDD almacena datos en varios nodos físicos, pero los datos están lógicamente relacionados. El SGBDD administra esa distribución para que el sistema pueda presentarse como una base integrada. La separación física no implica que el usuario deba tratar cada sitio como una base independiente.

### B. Nodos, red y comunicación

Cada nodo dispone de procesamiento, memoria y almacenamiento locales. La red permite intercambiar solicitudes y datos mediante mensajes. La latencia y los fallos de nodo o de red afectan la comunicación y, por tanto, pueden influir en el rendimiento y la disponibilidad.

### C. Fragmentación frente a replicación

- **Fragmentar** significa dividir una relación en partes.
- **Replicar** significa mantener copias de una base completa o de fragmentos.

Ambas técnicas pueden utilizarse juntas: los fragmentos se distribuyen entre nodos y algunas de esas partes se copian en otros sitios.

### D. Fragmentación y reconstrucción de la relación global

La fragmentación debe preservar la posibilidad de reconstruir la relación original:

- La fragmentación horizontal separa tuplas y se reconstruye con unión (\(\cup\)).
- La fragmentación vertical separa atributos y se reconstruye con reunión (\(\bowtie\)) mediante la clave primaria.
- La fragmentación mixta combina ambos criterios.

La completitud evita pérdida de datos; la reconstrucción asegura que la relación original pueda recuperarse; la disyunción evita solapamientos no previstos, con la salvedad de las claves compartidas en fragmentación vertical.

### E. Replicación, disponibilidad y consistencia

Las réplicas pueden mejorar la disponibilidad, distribuir lecturas y reducir la latencia de acceso. Sin embargo, las escrituras deben propagarse a las copias para evitar divergencias. Así aparece un compromiso entre rapidez de confirmación y sincronización:

- La replicación síncrona espera la grabación en todas las réplicas antes de confirmar.
- La replicación asíncrona confirma en el origen y propaga después, aceptando posibles intervalos de desactualización.

### F. Diseño de almacenamiento y costos

La elección entre no replicar, replicar totalmente o replicar parcialmente implica equilibrar almacenamiento, disponibilidad, velocidad de lectura y costo de actualización. La replicación total maximiza las copias disponibles, pero eleva el costo de almacenamiento y sincronización. La replicación parcial busca distribuir copias donde el acceso es frecuente, a costa de un diseño más cuidadoso.

### G. Optimización de consultas y costo de red

El costo total de una consulta distribuida incorpora I/O, CPU y red. Cuando la transmisión es costosa, resulta conveniente reducir los datos transferidos. La eliminación de fragmentos irrelevantes y el *push-down* de selecciones y proyecciones permiten procesar datos en el sitio de origen y enviar solo el resultado requerido.

### H. Transparencia y autonomía local

La transparencia de distribución y replicación busca ocultar al usuario la ubicación física de los datos. La autonomía local, en cambio, reconoce que cada nodo puede administrar sus propios datos y ejecutar operaciones locales. Son propiedades complementarias: el usuario puede disponer de una visión integrada aunque los nodos mantengan capacidad de gestión local.

## Limitaciones y ambigüedades

- **Arquitectura cliente-servidor:** aparece en el índice de contenidos, pero las diapositivas disponibles no desarrollan una explicación, un diagrama específico ni una comparación de arquitecturas cliente-servidor.
- **Ventajas de las BDD:** el índice anuncia este tema. Se describen propiedades y beneficios concretos —disponibilidad, escalabilidad, rendimiento, tolerancia a fallos, lecturas locales y balanceo de carga—, pero no existe una sección sistemática que enumere todas las ventajas y desventajas de las BDD en general.
- **Consultas en SQL Server e implementación de operadores relacionales:** se anuncian en el índice, pero no se incluyen sentencias SQL ni ejemplos de implementación en SQL Server en las diapositivas procesadas.
- **Transacciones, disparadores y procedimientos almacenados:** forman parte del objetivo general de la unidad, pero no se desarrollan procedimientos, sintaxis ni ejemplos en este material.
- **Proyecto de BDD:** la diapositiva presenta un esquema de tablas y cardinalidades, pero no especifica atributos, claves, reglas de integridad, distribución de fragmentos ni asignación de réplicas.
- **Protocolos 2PC y Primary-Copy:** se mencionan como mecanismos de coordinación de actualizaciones, pero no se describen sus pasos, condiciones de fallo ni variantes.
- **Ejemplo de consulta optimizada:** las cifras de 10.000 registros por fragmento y 50 nombres transferidos son datos del ejemplo didáctico. No se presentan mediciones de tiempo, tamaño en bytes ni resultados experimentales.
- **Terminología de fragmentación:** la diapositiva escribe “Compleitud”; se normaliza en este documento como “Completitud” por el sentido de la definición, sin cambiar el concepto expuesto.
- **Alcance de la consistencia fuerte:** la presentación caracteriza la replicación síncrona como consistente fuerte y afirma que todos los nodos leen los mismos datos en todo momento. No detalla condiciones de confirmación, aislamiento ni el modelo formal de consistencia utilizado.
- **Arquitecturas distribuidas:** la afirmación de que los nodos no comparten RAM ni discos se refiere expresamente al modelo distribuido convencional descrito; la fuente reconoce la existencia de arquitecturas especializadas diferentes.

## Referencias internas de la fuente

Las referencias corresponden a las páginas del PDF original:

| Páginas | Contenido |
|---|---|
| 1–3 | Título, objetivo general e índice de la unidad. |
| 4–8 | Introducción y conceptos fundamentales: base de datos, SGBD, servidor y red. |
| 9–13 | Definición de BDD, SGBDD, nodo, autonomía local, conceptos operativos, propiedades y ejemplo de sucursales. |
| 14–15 | Comprobación de aprendizaje. |
| 16 | Esquema del proyecto de BDD. |
| 17 | Estrategias de almacenamiento distribuido. |
| 18–22 | Definición, reglas y tipos de fragmentación con ejemplos de la relación `Empleado`. |
| 23–28 | Replicación, objetivos, clasificaciones, consistencia y gestión conjunta con fragmentación. |
| 29–32 | Costo y procesamiento distribuido de consultas; ejemplo de consulta ingenua y optimizada. |
