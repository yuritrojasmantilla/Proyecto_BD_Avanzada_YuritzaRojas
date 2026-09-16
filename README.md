# Proyecto de Base de Datos para un E-commerce

## Curso

**MySQL II**

## Descripción

Este proyecto consiste en el diseño e implementación de una base de datos relacional para un sistema de comercio electrónico (E-commerce). El proyecto integra la creación y poblamiento de la base de datos, consultas avanzadas para análisis de información, funciones, procedimientos almacenados, triggers, eventos programados y mecanismos de seguridad mediante roles y usuarios. El objetivo es aplicar los conocimientos de MySQL II para construir una solución organizada, automatizada y segura que permita gestionar productos, categorías, proveedores, clientes, ventas, devoluciones y demás procesos asociados a una plataforma de comercio electrónico.

## Integrante

* **Yuritza Juliana Rojas Mantilla**

## Estructura del Proyecto

El proyecto se encuentra dividido en siete archivos SQL, organizados de acuerdo con la funcionalidad que implementa cada uno:

| Archivo                             | Descripción                                                                               |
| ----------------------------------- | ----------------------------------------------------------------------------------------- |
| `01_Esquema_y_Datos.sql`            | Creación de la estructura de la base de datos y carga de datos iniciales.                 |
| `02_Consultas_Avanzadas.sql`        | Consultas de análisis y reportes para responder diferentes preguntas de negocio.          |
| `03_Funciones.sql`                  | Funciones almacenadas para realizar cálculos y validaciones dentro de la base de datos.   |
| `04_Seguridad.sql`                  | Creación de roles, usuarios y asignación de permisos.                                     |
| `05_Triggers.sql`                   | Triggers para automatización, validación y auditoría de operaciones.                      |
| `06_Eventos.sql`                    | Eventos programados para automatizar tareas de mantenimiento y generación de información. |
| `07_Procedimientos_Almacenados.sql` | Procedimientos almacenados para ejecutar operaciones complejas y transaccionales.         |

## Instrucciones de Ejecución

Para ejecutar correctamente el proyecto, se recomienda seguir el siguiente orden:

### 1. Crear la base de datos y cargar los datos

Ejecutar primero:

```sql
01_Esquema_y_Datos.sql
```

Este archivo crea la base de datos `ecommerce`, sus tablas, relaciones y datos iniciales.

### 2. Ejecutar las consultas avanzadas

Ejecutar:

```sql
02_Consultas_Avanzadas.sql
```

Este archivo contiene las consultas utilizadas para realizar análisis sobre los datos del E-commerce.

### 3. Crear las funciones

Ejecutar:

```sql
03_Funciones.sql
```

Este archivo crea las funciones almacenadas utilizadas para cálculos y validaciones.

### 4. Configurar la seguridad

Ejecutar:

```sql
04_Seguridad.sql
```

Este archivo crea los roles y usuarios y establece los permisos correspondientes para cada perfil.

> **Nota:** Para ejecutar correctamente este archivo pueden ser necesarios privilegios administrativos de MySQL.

### 5. Crear los triggers

Ejecutar:

```sql
05_Triggers.sql
```

Este archivo implementa los triggers encargados de automatizar validaciones, actualización de información y procesos de auditoría.

### 6. Crear los eventos programados

Ejecutar:

```sql
06_Eventos.sql
```

Este archivo crea los eventos programados y configura el `event_scheduler` de MySQL para permitir su ejecución automática.

### 7. Crear los procedimientos almacenados

Finalmente, ejecutar:

```sql
07_Procedimientos_Almacenados.sql
```

Este archivo crea los procedimientos almacenados utilizados para realizar operaciones complejas y transaccionales sobre la base de datos.

## Orden de Ejecución

En resumen, los archivos deben ejecutarse en el siguiente orden:

```text
01_Esquema_y_Datos.sql
        ↓
02_Consultas_Avanzadas.sql
        ↓
03_Funciones.sql
        ↓
04_Seguridad.sql
        ↓
05_Triggers.sql
        ↓
06_Eventos.sql
        ↓
07_Procedimientos_Almacenados.sql
```

## Tecnologías

* **MySQL**
* **SQL**
* **MySQL Workbench**
* **GitHub**

## Objetivo Académico

El proyecto tiene como finalidad integrar los conocimientos adquiridos en el curso **MySQL II**, aplicando conceptos de modelado y gestión de bases de datos, consultas avanzadas, programación almacenada, automatización mediante triggers y eventos, y control de acceso mediante roles y permisos.

---

**Proyecto académico — MySQL II**
**Yuritza Juliana Rojas Mantilla**
