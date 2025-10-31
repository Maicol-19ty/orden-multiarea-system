# Diagrama Entidad-Relación (ER) - Sistema de Órdenes Multiárea

## Descripción del Modelo

El sistema de órdenes multiárea está diseñado para gestionar órdenes de trabajo que pueden ser asignadas y procesadas por múltiples áreas o departamentos, con seguimiento de tiempo y auditoría completa de eventos.

## Entidades

### 1. AREAS
Representa los diferentes departamentos o áreas que procesan órdenes.

**Atributos:**
- `id` (PK): Identificador único autoincrementable
- `nombre`: Nombre del área (único, no nulo)
- `responsable`: Nombre del responsable del área (no nulo)

**Constraints:**
- PRIMARY KEY en `id`
- UNIQUE en `nombre`
- CHECK para validar que nombre y responsable no estén vacíos

### 2. ORDENES
Representa las órdenes de trabajo del sistema.

**Atributos:**
- `id` (PK): Identificador único autoincrementable
- `titulo`: Título descriptivo de la orden (no nulo)
- `descripcion`: Descripción detallada de la orden (no nulo)
- `creador`: Nombre de quien creó la orden (no nulo)
- `estado_global`: Estado actual de la orden (no nulo)
- `creada_en`: Timestamp de creación (default: CURRENT_TIMESTAMP)
- `actualizada_en`: Timestamp de última actualización (default: CURRENT_TIMESTAMP)

**Constraints:**
- PRIMARY KEY en `id`
- CHECK en `estado_global`: valores permitidos ('pendiente', 'en_proceso', 'completada', 'cancelada')
- CHECK para validar que titulo, descripcion y creador no estén vacíos

### 3. ORDEN_AREA
Tabla de relación muchos-a-muchos entre órdenes y áreas, con atributos adicionales de seguimiento.

**Atributos:**
- `id` (PK): Identificador único autoincrementable
- `orden_id` (FK): Referencia a ordenes.id (no nulo)
- `area_id` (FK): Referencia a areas.id (no nulo)
- `asignada_a`: Nombre de la persona asignada (puede ser null)
- `estado_parcial`: Estado de la orden en esta área específica (no nulo)
- `seg_acumulados`: Segundos de trabajo acumulados en esta área (default: 0)

**Constraints:**
- PRIMARY KEY en `id`
- FOREIGN KEY `orden_id` REFERENCES ordenes(id) ON DELETE CASCADE
- FOREIGN KEY `area_id` REFERENCES areas(id) ON DELETE RESTRICT
- CHECK en `estado_parcial`: valores permitidos ('pendiente', 'en_proceso', 'completada', 'rechazada')
- CHECK en `seg_acumulados`: debe ser >= 0
- UNIQUE en combinación (orden_id, area_id) - una orden no puede asignarse dos veces a la misma área

### 4. HISTORIAL
Registro de auditoría para todos los eventos importantes de las órdenes.

**Atributos:**
- `id` (PK): Identificador único autoincrementable
- `orden_id` (FK): Referencia a ordenes.id (no nulo)
- `evento`: Nombre descriptivo del evento (no nulo)
- `detalle`: Descripción detallada del evento (puede ser null)
- `estado_global`: Estado de la orden al momento del evento (no nulo)
- `timestamp`: Momento del evento (default: CURRENT_TIMESTAMP)
- `actor`: Persona que generó el evento (no nulo)

**Constraints:**
- PRIMARY KEY en `id`
- FOREIGN KEY `orden_id` REFERENCES ordenes(id) ON DELETE CASCADE
- CHECK en `estado_global`: valores permitidos ('pendiente', 'en_proceso', 'completada', 'cancelada')
- CHECK para validar que evento y actor no estén vacíos

## Relaciones

### ORDENES ←→ AREAS (Relación muchos-a-muchos a través de ORDEN_AREA)
- **Cardinalidad**: Una orden puede ser asignada a múltiples áreas, y un área puede procesar múltiples órdenes
- **Tabla intermedia**: orden_area
- **Atributos de la relación**: asignada_a, estado_parcial, seg_acumulados
- **Integridad referencial**: 
  - ON DELETE CASCADE en orden_id (si se elimina una orden, se eliminan sus asignaciones)
  - ON DELETE RESTRICT en area_id (no se puede eliminar un área con órdenes asignadas)

### ORDENES ←→ HISTORIAL (Relación uno-a-muchos)
- **Cardinalidad**: Una orden puede tener múltiples entradas en el historial
- **Integridad referencial**: ON DELETE CASCADE (si se elimina una orden, se elimina su historial)

## Diagrama Textual

```
┌──────────────────┐
│     AREAS        │
├──────────────────┤
│ PK id            │
│    nombre (UQ)   │
│    responsable   │
└────────┬─────────┘
         │
         │ 1
         │
         │ N
         │
┌────────┴──────────────────────┐
│      ORDEN_AREA               │
├───────────────────────────────┤
│ PK id                         │
│ FK orden_id                   │
│ FK area_id                    │
│    asignada_a                 │
│    estado_parcial             │
│    seg_acumulados             │
└───────────┬───────────────────┘
            │
            │ N
            │
            │ 1
            │
┌───────────┴───────────┐              ┌──────────────────┐
│      ORDENES          │              │    HISTORIAL     │
├───────────────────────┤              ├──────────────────┤
│ PK id                 │ 1         N  │ PK id            │
│    titulo             │──────────────│ FK orden_id      │
│    descripcion        │              │    evento        │
│    creador            │              │    detalle       │
│    estado_global      │              │    estado_global │
│    creada_en          │              │    timestamp     │
│    actualizada_en     │              │    actor         │
└───────────────────────┘              └──────────────────┘
```

## Flujo de Datos Típico

1. **Creación de Orden**: Se crea un registro en `ordenes` con estado_global='pendiente'
2. **Registro de Creación**: Se añade entrada en `historial` documentando la creación
3. **Asignación a Áreas**: Se crean registros en `orden_area` para cada área asignada
4. **Registro de Asignaciones**: Se añaden entradas en `historial` por cada asignación
5. **Trabajo en Áreas**: Cada área actualiza su `estado_parcial` y `seg_acumulados` en `orden_area`
6. **Actualizaciones**: Cada cambio importante genera una entrada en `historial`
7. **Completación**: Cuando todas las áreas completan su trabajo, `estado_global` en `ordenes` cambia a 'completada'
8. **Registro Final**: Se registra la completación en `historial`

## Notas de Diseño

- Las órdenes multiárea se identifican por tener múltiples registros en `orden_area` con el mismo `orden_id`
- El campo `seg_acumulados` permite tracking preciso del tiempo invertido por área
- La tabla `historial` proporciona trazabilidad completa y auditoría
- Los constraints CHECK garantizan la integridad de los estados en todo el sistema
- El uso de ON DELETE CASCADE vs RESTRICT protege la integridad referencial apropiadamente
