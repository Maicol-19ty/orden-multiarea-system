# Notas de Diseño - Base de Datos Sistema de Órdenes Multiárea

## 1. Selección de Tipos de Datos

### Tabla: AREAS

| Campo | Tipo | Justificación |
|-------|------|---------------|
| `id` | SERIAL | Auto-incrementable, eficiente para PKs pequeñas (4 bytes). Rango hasta 2 mil millones suficiente para áreas. |
| `nombre` | VARCHAR(100) | Longitud máxima razonable para nombres de departamentos. VARCHAR es más eficiente que TEXT para strings limitados. |
| `responsable` | VARCHAR(100) | Nombres de personas rara vez exceden 100 caracteres. Permite nombres compuestos y dobles apellidos. |

### Tabla: ORDENES

| Campo | Tipo | Justificación |
|-------|------|---------------|
| `id` | SERIAL | Auto-incrementable para identificación única de órdenes. |
| `titulo` | VARCHAR(200) | Títulos descriptivos pero concisos. 200 caracteres es suficiente para resúmenes. |
| `descripcion` | TEXT | Sin límite específico. Las descripciones detalladas pueden ser extensas y varían significativamente. |
| `creador` | VARCHAR(100) | Nombres de usuarios/personas. Consistente con `areas.responsable`. |
| `estado_global` | VARCHAR(50) | Permite estados descriptivos. Controlado por CHECK constraint. |
| `creada_en` | TIMESTAMP | Precisión de microsegundos. Sin zona horaria asumiendo UTC o configuración uniforme del servidor. |
| `actualizada_en` | TIMESTAMP | Mismo rationale que `creada_en`. Crucial para ordenamiento y filtrado temporal. |

### Tabla: ORDEN_AREA

| Campo | Tipo | Justificación |
|-------|------|---------------|
| `id` | SERIAL | PK auto-incrementable estándar. |
| `orden_id` | INTEGER | FK a `ordenes.id`. INTEGER (4 bytes) consistente con SERIAL. |
| `area_id` | INTEGER | FK a `areas.id`. INTEGER (4 bytes) consistente con SERIAL. |
| `asignada_a` | VARCHAR(100) | Nullable. Permite órdenes sin asignar. Mismo tipo que nombres de personas. |
| `estado_parcial` | VARCHAR(50) | Estados específicos por área. Controlado por CHECK constraint. |
| `seg_acumulados` | INTEGER | Segundos como entero (4 bytes). Rango: 0 a ~68 años. Suficiente para tracking de tiempo. Más eficiente que intervalos. |

### Tabla: HISTORIAL

| Campo | Tipo | Justificación |
|-------|------|---------------|
| `id` | SERIAL | PK auto-incrementable. Historial puede crecer mucho. |
| `orden_id` | INTEGER | FK a `ordenes.id`. |
| `evento` | VARCHAR(100) | Nombres de eventos breves pero descriptivos. |
| `detalle` | TEXT | Nullable. Detalles pueden ser extensos o ausentes. |
| `estado_global` | VARCHAR(50) | Captura el estado de la orden en el momento del evento. |
| `timestamp` | TIMESTAMP | Precisión temporal crucial para auditoría. |
| `actor` | VARCHAR(100) | Quién ejecutó la acción. Consistente con nombres de usuarios. |

## 2. Índices - Estrategia de Optimización

### Índices en AREAS
```sql
CREATE INDEX idx_areas_nombre ON areas(nombre);
```
- **Razón**: Búsquedas por nombre de área son comunes en filtros y joins.
- **Tipo**: B-tree (default).
- **Impacto**: Tabla pequeña (pocas áreas), pero índice ayuda en búsquedas exactas.

### Índices en ORDENES
```sql
CREATE INDEX idx_ordenes_estado_global ON ordenes(estado_global);
CREATE INDEX idx_ordenes_creador ON ordenes(creador);
CREATE INDEX idx_ordenes_creada_en ON ordenes(creada_en DESC);
CREATE INDEX idx_ordenes_actualizada_en ON ordenes(actualizada_en DESC);
```
- **idx_ordenes_estado_global**: Filtrado por estado es muy frecuente (ej: listar órdenes pendientes).
- **idx_ordenes_creador**: Consultas de "mis órdenes" o filtrado por usuario creador.
- **idx_ordenes_creada_en DESC**: Ordenamiento descendente (órdenes más recientes primero). DESC optimiza ORDER BY DESC.
- **idx_ordenes_actualizada_en DESC**: Listar órdenes actualizadas recientemente. Común en dashboards.

### Índices en ORDEN_AREA
```sql
CREATE INDEX idx_orden_area_orden_id ON orden_area(orden_id);
CREATE INDEX idx_orden_area_area_id ON orden_area(area_id);
CREATE INDEX idx_orden_area_estado_parcial ON orden_area(estado_parcial);
CREATE INDEX idx_orden_area_asignada_a ON orden_area(asignada_a);
```
- **idx_orden_area_orden_id**: Lookup de todas las áreas de una orden (muy frecuente).
- **idx_orden_area_area_id**: Lookup de todas las órdenes de un área (dashboard por área).
- **idx_orden_area_estado_parcial**: Filtrar tareas por estado en un área específica.
- **idx_orden_area_asignada_a**: Consultas de "mis tareas asignadas" por usuario.
- **Nota**: El constraint UNIQUE(orden_id, area_id) crea implícitamente un índice compuesto útil para lookups de pares específicos.

### Índices en HISTORIAL
```sql
CREATE INDEX idx_historial_orden_id ON historial(orden_id);
CREATE INDEX idx_historial_timestamp ON historial(timestamp DESC);
CREATE INDEX idx_historial_evento ON historial(evento);
CREATE INDEX idx_historial_actor ON historial(actor);
```
- **idx_historial_orden_id**: Obtener todo el historial de una orden (muy frecuente, especialmente con ON DELETE CASCADE).
- **idx_historial_timestamp DESC**: Ordenar eventos cronológicamente (más recientes primero).
- **idx_historial_evento**: Filtrar por tipo de evento (ej: todas las asignaciones).
- **idx_historial_actor**: Auditoría: acciones de un usuario específico.

## 3. Constraints - Integridad de Datos

### Foreign Keys

#### ORDEN_AREA
- **orden_id → ordenes(id) ON DELETE CASCADE**
  - Si se elimina una orden, automáticamente se eliminan todas sus asignaciones a áreas.
  - Mantiene la integridad sin dejar registros huérfanos.

- **area_id → areas(id) ON DELETE RESTRICT**
  - No permite eliminar un área si tiene órdenes asignadas.
  - Protege contra pérdida accidental de datos críticos.
  - Requiere reasignación de órdenes antes de eliminar un área.

#### HISTORIAL
- **orden_id → ordenes(id) ON DELETE CASCADE**
  - Si se elimina una orden, se elimina todo su historial.
  - El historial sin orden no tiene sentido (huérfano).

### Check Constraints

#### Estados Controlados
```sql
CONSTRAINT chk_estado_global CHECK (estado_global IN ('pendiente', 'en_proceso', 'completada', 'cancelada'))
CONSTRAINT chk_estado_parcial CHECK (estado_parcial IN ('pendiente', 'en_proceso', 'completada', 'rechazada'))
```
- **Razón**: Previene valores inválidos. Garantiza consistencia en queries y lógica de negocio.
- **Estados globales vs parciales**: Estados parciales incluyen 'rechazada' (un área puede rechazar una tarea sin cancelar toda la orden).

#### Validación de Campos No Vacíos
```sql
CONSTRAINT chk_nombre_not_empty CHECK (LENGTH(TRIM(nombre)) > 0)
```
- **Razón**: NOT NULL permite strings vacíos. Este constraint asegura contenido real.
- **Aplicado a**: nombres, títulos, descripciones, creadores, actores, eventos.

#### Validación de Valores Numéricos
```sql
CONSTRAINT chk_seg_acumulados_positive CHECK (seg_acumulados >= 0)
```
- **Razón**: Los segundos no pueden ser negativos. Previene datos ilógicos.

### Unique Constraints

#### areas.nombre
```sql
nombre VARCHAR(100) NOT NULL UNIQUE
```
- **Razón**: No puede haber dos áreas con el mismo nombre. Previene confusión y duplicados.

#### (orden_id, area_id) en ORDEN_AREA
```sql
CONSTRAINT uq_orden_area UNIQUE (orden_id, area_id)
```
- **Razón**: Una orden no puede asignarse dos veces a la misma área.
- **Beneficio adicional**: Crea índice compuesto útil para queries de lookup específico.

## 4. Decisiones de Diseño Clave

### Tabla ORDEN_AREA como Relación Enriquecida
- **Decisión**: En lugar de una simple tabla de unión, ORDEN_AREA incluye atributos (`asignada_a`, `estado_parcial`, `seg_acumulados`).
- **Razón**: Cada área necesita su propio estado y tracking de tiempo independiente.
- **Beneficio**: Permite órdenes multiárea con progreso paralelo e independiente.

### Segundos como INTEGER vs INTERVAL
- **Decisión**: Almacenar tiempo como segundos (INTEGER).
- **Razón**:
  - Más simple para cálculos y agregaciones (SUM, AVG).
  - Más eficiente en espacio (4 bytes vs 16 bytes para INTERVAL).
  - Conversión a formato legible fácil en capa de aplicación.
  - No necesitamos precisión de microsegundos para tiempo acumulado.

### TIMESTAMP sin Zona Horaria
- **Decisión**: TIMESTAMP en lugar de TIMESTAMPTZ.
- **Razón**: 
  - Asumiendo configuración uniforme del servidor (UTC).
  - Simplifica queries y comparaciones.
  - Si necesitamos zonas horarias en futuro, conversión es posible en capa de aplicación.
  - Para MVP, añadir complejidad de zonas horarias no es necesario.

### Estados como VARCHAR vs ENUM
- **Decisión**: VARCHAR con CHECK constraints en lugar de ENUM nativo de PostgreSQL.
- **Razón**:
  - ENUM de PostgreSQL requiere ALTER TYPE para añadir valores (complejidad en producción).
  - CHECK constraints son más flexibles y visibles en el DDL.
  - Cambiar valores permitidos es más simple (ALTER TABLE vs ALTER TYPE + CASCADE).
  - Mejor portabilidad a otros RDBMS si fuera necesario.

### Tabla HISTORIAL Completa
- **Decisión**: Incluir `estado_global` en historial además de en ordenes.
- **Razón**: 
  - Captura el estado en el momento del evento (histórico real).
  - Permite auditoría temporal precisa.
  - No depende de JOINs para saber el estado en momentos pasados.

## 5. Consideraciones de Performance

### Crecimiento de Tablas
- **areas**: Crecimiento muy lento (decenas de registros). Sin preocupaciones.
- **ordenes**: Crecimiento moderado (miles a decenas de miles). Índices apropiados.
- **orden_area**: Proporcional a ordenes × áreas promedio (ej: 3). Crecimiento moderado.
- **historial**: **Mayor crecimiento**. Múltiples eventos por orden. Necesita índices eficientes.

### Estrategia de Mantenimiento Futuro
- **Particionado de historial**: Considerar particionado por timestamp cuando tabla crezca significativamente (>1M registros).
- **Archivado**: Política de archivado de órdenes antiguas y su historial.
- **VACUUM**: PostgreSQL auto-vacuum debe estar habilitado (default).

### Query Patterns Optimizados
Los índices están diseñados para los siguientes patrones comunes:
1. Dashboard por área: índices en area_id
2. Mis tareas: índices en asignada_a
3. Órdenes recientes: índices DESC en timestamps
4. Filtrado por estado: índices en estados
5. Auditoría: índices en historial por orden, actor, evento

## 6. Seguridad e Integridad

### Prevención de Inyección SQL
- Aplicación debe usar prepared statements / parameterized queries.
- No se confía en input del usuario directamente en DDL.

### Auditoría
- Tabla `historial` proporciona trazabilidad completa.
- Todos los eventos críticos registran actor y timestamp.
- No hay DELETEs sin registro (constraints ON DELETE CASCADE solo donde lógico).

### Validación en Múltiples Capas
- **Base de datos**: Constraints (CHECK, FK, UNIQUE, NOT NULL)
- **Aplicación**: Validación adicional en capa de servicio
- **Estrategia**: Defense in depth - la BD es última línea de defensa

## 7. Migraciones y Versionado

### Flyway
- Migraciones numeradas: V1, V2, etc.
- V1: Schema DDL
- V2: Seed data
- Futuras migraciones: Cambios incrementales

### Rollback
- No se proporciona rollback automático.
- Estrategia: Backup antes de deployment + migraciones hacia adelante (migrations forward).
- Para cambios complejos: crear migraciones de reversión manualmente si necesario.

## Resumen de Métricas

| Tabla | PKs | FKs | Índices (adicionales) | Constraints |
|-------|-----|-----|------------------------|-------------|
| areas | 1 | 0 | 1 | 3 (UNIQUE, 2x CHECK) |
| ordenes | 1 | 0 | 4 | 4 (4x CHECK) |
| orden_area | 1 | 2 | 4 | 5 (2x FK, 2x CHECK, 1x UNIQUE) |
| historial | 1 | 1 | 4 | 4 (1x FK, 3x CHECK) |

**Total**: 4 tablas, 4 PKs, 3 FKs, 13 índices adicionales, 16 constraints
