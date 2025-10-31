-- Seed data for Multi-Area Order System MVP
-- This migration populates initial data for testing and development

-- ============================================================================
-- SEED DATA: areas
-- Descripción: 3 áreas de trabajo con sus responsables
-- ============================================================================
INSERT INTO areas (nombre, responsable) VALUES
('Desarrollo', 'María García'),
('Diseño', 'Carlos Rodríguez'),
('Operaciones', 'Ana Martínez');

-- ============================================================================
-- SEED DATA: ordenes
-- Descripción: 8 órdenes con diferentes estados y creadores
-- ============================================================================
INSERT INTO ordenes (titulo, descripcion, creador, estado_global) VALUES
('Implementar módulo de autenticación', 
 'Desarrollar sistema de login con JWT y refresh tokens para la aplicación web',
 'Juan Pérez', 
 'en_proceso'),

('Diseñar nueva interfaz de usuario',
 'Crear mockups y prototipos para el dashboard principal con los nuevos colores corporativos',
 'Laura Torres',
 'en_proceso'),

('Optimizar base de datos',
 'Revisar y optimizar queries lentas, añadir índices necesarios y limpiar datos obsoletos',
 'Roberto Sánchez',
 'pendiente'),

('Implementar API de reportes',
 'Desarrollar endpoints REST para generación de reportes en PDF y Excel',
 'Juan Pérez',
 'en_proceso'),

('Actualizar documentación técnica',
 'Revisar y actualizar toda la documentación del API y guías de deployment',
 'María López',
 'completada'),

('Migrar servidor de producción',
 'Planificar y ejecutar migración del servidor a nueva infraestructura cloud',
 'Roberto Sánchez',
 'pendiente'),

('Diseñar sistema de notificaciones',
 'Crear diseño visual para notificaciones push y emails transaccionales',
 'Laura Torres',
 'completada'),

('Implementar dashboard de métricas',
 'Desarrollar dashboard interactivo con gráficas en tiempo real de KPIs del sistema',
 'Juan Pérez',
 'en_proceso');

-- ============================================================================
-- SEED DATA: orden_area
-- Descripción: Asignaciones de órdenes a áreas
-- Nota: Las órdenes 1, 2, 4 y 8 son multiárea (asignadas a múltiples áreas)
-- ============================================================================

-- Orden 1: Implementar módulo de autenticación (MULTIÁREA: Desarrollo + Diseño)
INSERT INTO orden_area (orden_id, area_id, asignada_a, estado_parcial, seg_acumulados) VALUES
(1, 1, 'Pedro Ramírez', 'en_proceso', 7200),    -- Desarrollo: 2 horas
(1, 2, 'Sofia Delgado', 'completada', 3600);    -- Diseño: 1 hora

-- Orden 2: Diseñar nueva interfaz (MULTIÁREA: Diseño + Desarrollo)
INSERT INTO orden_area (orden_id, area_id, asignada_a, estado_parcial, seg_acumulados) VALUES
(2, 2, 'Sofia Delgado', 'en_proceso', 14400),   -- Diseño: 4 horas
(2, 1, 'Pedro Ramírez', 'pendiente', 0);        -- Desarrollo: por empezar

-- Orden 3: Optimizar base de datos (Una sola área)
INSERT INTO orden_area (orden_id, area_id, asignada_a, estado_parcial, seg_acumulados) VALUES
(3, 3, 'Miguel Vargas', 'pendiente', 0);        -- Operaciones

-- Orden 4: Implementar API de reportes (MULTIÁREA: Desarrollo + Operaciones)
INSERT INTO orden_area (orden_id, area_id, asignada_a, estado_parcial, seg_acumulados) VALUES
(4, 1, 'Andrea Morales', 'en_proceso', 10800),  -- Desarrollo: 3 horas
(4, 3, 'Miguel Vargas', 'pendiente', 0);        -- Operaciones: por empezar

-- Orden 5: Actualizar documentación (Una sola área)
INSERT INTO orden_area (orden_id, area_id, asignada_a, estado_parcial, seg_acumulados) VALUES
(5, 1, 'Pedro Ramírez', 'completada', 5400);    -- Desarrollo: 1.5 horas

-- Orden 6: Migrar servidor (Una sola área)
INSERT INTO orden_area (orden_id, area_id, asignada_a, estado_parcial, seg_acumulados) VALUES
(6, 3, NULL, 'pendiente', 0);                   -- Operaciones: sin asignar aún

-- Orden 7: Diseñar sistema de notificaciones (Una sola área)
INSERT INTO orden_area (orden_id, area_id, asignada_a, estado_parcial, seg_acumulados) VALUES
(7, 2, 'Sofia Delgado', 'completada', 9000);    -- Diseño: 2.5 horas

-- Orden 8: Dashboard de métricas (MULTIÁREA: Desarrollo + Diseño + Operaciones)
INSERT INTO orden_area (orden_id, area_id, asignada_a, estado_parcial, seg_acumulados) VALUES
(8, 1, 'Andrea Morales', 'en_proceso', 18000),  -- Desarrollo: 5 horas
(8, 2, 'Carlos Méndez', 'en_proceso', 7200),    -- Diseño: 2 horas
(8, 3, 'Miguel Vargas', 'pendiente', 0);        -- Operaciones: por empezar

-- ============================================================================
-- SEED DATA: historial
-- Descripción: Eventos importantes del ciclo de vida de las órdenes
-- ============================================================================

-- Historial para Orden 1
INSERT INTO historial (orden_id, evento, detalle, estado_global, actor) VALUES
(1, 'Orden creada', 'Nueva orden de trabajo creada en el sistema', 'pendiente', 'Juan Pérez'),
(1, 'Asignada a Desarrollo', 'Orden asignada al área de Desarrollo - Pedro Ramírez', 'en_proceso', 'María García'),
(1, 'Asignada a Diseño', 'Orden asignada al área de Diseño - Sofia Delgado', 'en_proceso', 'Carlos Rodríguez'),
(1, 'Diseño completado', 'El área de Diseño finalizó su parte de la orden', 'en_proceso', 'Sofia Delgado');

-- Historial para Orden 2
INSERT INTO historial (orden_id, evento, detalle, estado_global, actor) VALUES
(2, 'Orden creada', 'Nueva orden de trabajo creada en el sistema', 'pendiente', 'Laura Torres'),
(2, 'Asignada a Diseño', 'Orden asignada al área de Diseño - Sofia Delgado', 'en_proceso', 'Carlos Rodríguez'),
(2, 'Progreso actualizado', 'Mockups iniciales completados, falta revisión', 'en_proceso', 'Sofia Delgado');

-- Historial para Orden 3
INSERT INTO historial (orden_id, evento, detalle, estado_global, actor) VALUES
(3, 'Orden creada', 'Nueva orden de trabajo creada en el sistema', 'pendiente', 'Roberto Sánchez');

-- Historial para Orden 4
INSERT INTO historial (orden_id, evento, detalle, estado_global, actor) VALUES
(4, 'Orden creada', 'Nueva orden de trabajo creada en el sistema', 'pendiente', 'Juan Pérez'),
(4, 'Asignada a Desarrollo', 'Orden asignada al área de Desarrollo - Andrea Morales', 'en_proceso', 'María García'),
(4, 'Asignada a Operaciones', 'Orden asignada al área de Operaciones - Miguel Vargas', 'en_proceso', 'Ana Martínez');

-- Historial para Orden 5
INSERT INTO historial (orden_id, evento, detalle, estado_global, actor) VALUES
(5, 'Orden creada', 'Nueva orden de trabajo creada en el sistema', 'pendiente', 'María López'),
(5, 'Asignada a Desarrollo', 'Orden asignada al área de Desarrollo - Pedro Ramírez', 'en_proceso', 'María García'),
(5, 'Orden completada', 'Documentación actualizada y revisada', 'completada', 'Pedro Ramírez');

-- Historial para Orden 6
INSERT INTO historial (orden_id, evento, detalle, estado_global, actor) VALUES
(6, 'Orden creada', 'Nueva orden de trabajo creada en el sistema', 'pendiente', 'Roberto Sánchez'),
(6, 'Asignada a Operaciones', 'Orden asignada al área de Operaciones', 'pendiente', 'Ana Martínez');

-- Historial para Orden 7
INSERT INTO historial (orden_id, evento, detalle, estado_global, actor) VALUES
(7, 'Orden creada', 'Nueva orden de trabajo creada en el sistema', 'pendiente', 'Laura Torres'),
(7, 'Asignada a Diseño', 'Orden asignada al área de Diseño - Sofia Delgado', 'en_proceso', 'Carlos Rodríguez'),
(7, 'Diseño completado', 'Mockups y especificaciones de notificaciones finalizados', 'completada', 'Sofia Delgado');

-- Historial para Orden 8
INSERT INTO historial (orden_id, evento, detalle, estado_global, actor) VALUES
(8, 'Orden creada', 'Nueva orden de trabajo creada en el sistema', 'pendiente', 'Juan Pérez'),
(8, 'Asignada a Diseño', 'Orden asignada al área de Diseño - Carlos Méndez', 'en_proceso', 'Carlos Rodríguez'),
(8, 'Asignada a Desarrollo', 'Orden asignada al área de Desarrollo - Andrea Morales', 'en_proceso', 'María García'),
(8, 'Asignada a Operaciones', 'Orden asignada al área de Operaciones - Miguel Vargas', 'en_proceso', 'Ana Martínez'),
(8, 'Progreso actualizado', 'Backend del dashboard en desarrollo, diseño 70% completo', 'en_proceso', 'Andrea Morales');
