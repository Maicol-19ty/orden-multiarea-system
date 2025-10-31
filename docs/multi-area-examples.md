# Ejemplos de Órdenes Multiárea

Este documento demuestra la funcionalidad multiárea del sistema con ejemplos concretos del seed data.

## Concepto de Órdenes Multiárea

Una **orden multiárea** es una orden de trabajo que requiere la colaboración de múltiples departamentos o áreas para completarse. Cada área tiene:
- Su propia asignación de persona
- Su propio estado parcial independiente
- Su propio tracking de tiempo acumulado

## Ejemplos en el Sistema

### Orden #1: Implementar módulo de autenticación
**Estado Global**: en_proceso

| Área | Asignada a | Estado Parcial | Tiempo Acumulado |
|------|-----------|----------------|------------------|
| Desarrollo | Pedro Ramírez | en_proceso | 2 horas |
| Diseño | Sofia Delgado | completada | 1 hora |

**Descripción**: Esta orden requiere desarrollo backend (Desarrollo) y diseño de UI/UX para las pantallas de login (Diseño). El área de Diseño ya completó su parte, mientras Desarrollo continúa trabajando.

**Eventos registrados**:
1. Orden creada (Juan Pérez)
2. Asignada a Desarrollo (María García)
3. Asignada a Diseño (Carlos Rodríguez)
4. Diseño completado (Sofia Delgado)

---

### Orden #2: Diseñar nueva interfaz de usuario
**Estado Global**: en_proceso

| Área | Asignada a | Estado Parcial | Tiempo Acumulado |
|------|-----------|----------------|------------------|
| Diseño | Sofia Delgado | en_proceso | 4 horas |
| Desarrollo | Pedro Ramírez | pendiente | 0 horas |

**Descripción**: El diseño de la nueva UI comienza en el área de Diseño (mockups y prototipos). Una vez completado, Desarrollo implementará los diseños. Actualmente Diseño está trabajando activamente mientras Desarrollo está en espera.

---

### Orden #4: Implementar API de reportes
**Estado Global**: en_proceso

| Área | Asignada a | Estado Parcial | Tiempo Acumulado |
|------|-----------|----------------|------------------|
| Desarrollo | Andrea Morales | en_proceso | 3 horas |
| Operaciones | Miguel Vargas | pendiente | 0 horas |

**Descripción**: Desarrollo está construyendo los endpoints de la API. Una vez completados, Operaciones configurará el deployment, escalabilidad y monitoreo en producción.

---

### Orden #8: Implementar dashboard de métricas ⭐
**Estado Global**: en_proceso

| Área | Asignada a | Estado Parcial | Tiempo Acumulado |
|------|-----------|----------------|------------------|
| Desarrollo | Andrea Morales | en_proceso | 5 horas |
| Diseño | Carlos Méndez | en_proceso | 2 horas |
| Operaciones | Miguel Vargas | pendiente | 0 horas |

**Descripción**: Esta es la orden más compleja, requiriendo **3 áreas diferentes**:
- **Desarrollo**: Implementa el backend, APIs de datos y lógica de métricas
- **Diseño**: Crea visualizaciones, gráficas y UI del dashboard
- **Operaciones**: Configurará recolección de métricas y optimización de performance

Actualmente Desarrollo y Diseño trabajan en paralelo, mientras Operaciones esperará a que tengan avances significativos.

**Eventos registrados**:
1. Orden creada (Juan Pérez)
2. Asignada a Diseño (Carlos Rodríguez)
3. Asignada a Desarrollo (María García)
4. Asignada a Operaciones (Ana Martínez)
5. Progreso actualizado (Andrea Morales)

---

## Comparación: Órdenes Simple vs Multiárea

### Orden Simple (Orden #5: Actualizar documentación)
```
Ordenes
   ↓
   ├─ Orden_Area (1 registro)
   │    └─ Área: Desarrollo
   │         └─ Asignada a: Pedro Ramírez
   └─ Historial (3 eventos)
```

### Orden Multiárea (Orden #8: Dashboard de métricas)
```
Ordenes
   ↓
   ├─ Orden_Area (3 registros)
   │    ├─ Área: Desarrollo
   │    │    └─ Asignada a: Andrea Morales (5h)
   │    ├─ Área: Diseño
   │    │    └─ Asignada a: Carlos Méndez (2h)
   │    └─ Área: Operaciones
   │         └─ Asignada a: Miguel Vargas (0h)
   └─ Historial (5 eventos)
```

## Consultas Útiles

### Listar todas las órdenes multiárea
```sql
SELECT 
  o.id,
  o.titulo,
  o.estado_global,
  COUNT(DISTINCT oa.area_id) as num_areas,
  string_agg(DISTINCT a.nombre, ', ' ORDER BY a.nombre) as areas
FROM ordenes o
JOIN orden_area oa ON o.id = oa.orden_id
JOIN areas a ON oa.area_id = a.id
GROUP BY o.id, o.titulo, o.estado_global
HAVING COUNT(DISTINCT oa.area_id) > 1
ORDER BY COUNT(DISTINCT oa.area_id) DESC, o.id;
```

### Ver progreso detallado de una orden multiárea
```sql
SELECT 
  o.titulo,
  o.estado_global,
  a.nombre as area,
  oa.asignada_a,
  oa.estado_parcial,
  ROUND(oa.seg_acumulados / 3600.0, 2) as horas_trabajadas
FROM ordenes o
JOIN orden_area oa ON o.id = oa.orden_id
JOIN areas a ON oa.area_id = a.id
WHERE o.id = 8
ORDER BY a.nombre;
```

### Timeline completo de una orden multiárea
```sql
SELECT 
  h.timestamp,
  h.evento,
  h.detalle,
  h.estado_global,
  h.actor
FROM historial h
WHERE h.orden_id = 8
ORDER BY h.timestamp;
```

## Ventajas del Modelo Multiárea

1. **Independencia**: Cada área trabaja a su ritmo con su propio estado
2. **Paralelismo**: Múltiples áreas pueden trabajar simultáneamente
3. **Tracking Preciso**: Tiempo acumulado por área para métricas y reportes
4. **Auditoría Completa**: Historial detallado de cada acción en cada área
5. **Flexibilidad**: Fácil añadir o remover áreas de una orden
6. **Escalabilidad**: El modelo soporta N áreas por orden

## Flujo de Trabajo Típico

### Orden Simple (1 área)
```
1. Creación → 2. Asignación → 3. Trabajo → 4. Completación
```

### Orden Multiárea (N áreas)
```
1. Creación
   ↓
2. Asignaciones Paralelas
   ├─ Área A → Trabajo → Completación A
   ├─ Área B → Trabajo → Completación B
   └─ Área C → Trabajo → Completación C
   ↓
3. Todas las áreas completas
   ↓
4. Orden Completada Globalmente
```

## Estados y Transiciones

### Estado Global de la Orden
- **pendiente**: Orden creada, áreas no asignadas o sin empezar
- **en_proceso**: Al menos un área trabajando activamente
- **completada**: Todas las áreas completaron su trabajo
- **cancelada**: Orden cancelada (se cancelan todas las áreas)

### Estado Parcial por Área
- **pendiente**: Área asignada pero no comenzó
- **en_proceso**: Área trabajando activamente
- **completada**: Área finalizó su parte
- **rechazada**: Área rechazó la tarea (no afecta orden global automáticamente)

## Métricas y Reportes Posibles

Con este modelo, se pueden generar:

1. **Por Orden**: Total de horas invertidas, áreas involucradas, progreso
2. **Por Área**: Carga de trabajo, órdenes activas, tiempo promedio
3. **Por Persona**: Asignaciones, horas trabajadas, órdenes completadas
4. **Tendencias**: Órdenes más complejas (más áreas), cuellos de botella
5. **Eficiencia**: Comparación de tiempo entre áreas, identificar retrasos

## Ejemplo de Métrica: Distribución de Trabajo

```sql
SELECT 
  a.nombre as area,
  a.responsable,
  COUNT(DISTINCT oa.orden_id) as ordenes_totales,
  COUNT(DISTINCT CASE WHEN oa.estado_parcial = 'en_proceso' THEN oa.orden_id END) as ordenes_activas,
  COUNT(DISTINCT CASE WHEN oa.estado_parcial = 'completada' THEN oa.orden_id END) as ordenes_completadas,
  ROUND(SUM(oa.seg_acumulados) / 3600.0, 2) as total_horas_invertidas
FROM areas a
LEFT JOIN orden_area oa ON a.id = oa.area_id
GROUP BY a.id, a.nombre, a.responsable
ORDER BY total_horas_invertidas DESC;
```

Resultado con los datos seed:
```
    area     |   responsable    | ordenes_totales | ordenes_activas | ordenes_completadas | total_horas_invertidas
-------------+------------------+-----------------+-----------------+---------------------+-----------------------
 Desarrollo  | María García     |               5 |               3 |                   1 |                  11.50
 Diseño      | Carlos Rodríguez |               4 |               2 |                   2 |                   9.50
 Operaciones | Ana Martínez     |               4 |               0 |                   0 |                   0.00
```

Esta vista muestra que Operaciones tiene órdenes asignadas pero aún no ha comenzado a trabajar (típico de un área de deployment que espera a que desarrollo termine).
