-- Initial schema for Multi-Area Order System MVP
-- This migration creates the complete structure for the multi-area order routing system with timer tracking

-- ============================================================================
-- TABLA: areas
-- Descripción: Almacena las diferentes áreas o departamentos que procesan órdenes
-- ============================================================================
CREATE TABLE areas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    responsable VARCHAR(100) NOT NULL,
    CONSTRAINT chk_nombre_not_empty CHECK (LENGTH(TRIM(nombre)) > 0),
    CONSTRAINT chk_responsable_not_empty CHECK (LENGTH(TRIM(responsable)) > 0)
);

-- ============================================================================
-- TABLA: ordenes
-- Descripción: Órdenes de trabajo que pueden ser asignadas a múltiples áreas
-- ============================================================================
CREATE TABLE ordenes (
    id SERIAL PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT NOT NULL,
    creador VARCHAR(100) NOT NULL,
    estado_global VARCHAR(50) NOT NULL,
    creada_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizada_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_titulo_not_empty CHECK (LENGTH(TRIM(titulo)) > 0),
    CONSTRAINT chk_descripcion_not_empty CHECK (LENGTH(TRIM(descripcion)) > 0),
    CONSTRAINT chk_creador_not_empty CHECK (LENGTH(TRIM(creador)) > 0),
    CONSTRAINT chk_estado_global CHECK (estado_global IN ('pendiente', 'en_proceso', 'completada', 'cancelada'))
);

-- ============================================================================
-- TABLA: orden_area
-- Descripción: Relación muchos-a-muchos entre órdenes y áreas, con seguimiento de tiempo
-- ============================================================================
CREATE TABLE orden_area (
    id SERIAL PRIMARY KEY,
    orden_id INTEGER NOT NULL REFERENCES ordenes(id) ON DELETE CASCADE,
    area_id INTEGER NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    asignada_a VARCHAR(100),
    estado_parcial VARCHAR(50) NOT NULL,
    seg_acumulados INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT chk_estado_parcial CHECK (estado_parcial IN ('pendiente', 'en_proceso', 'completada', 'rechazada')),
    CONSTRAINT chk_seg_acumulados_positive CHECK (seg_acumulados >= 0),
    CONSTRAINT uq_orden_area UNIQUE (orden_id, area_id)
);

-- ============================================================================
-- TABLA: historial
-- Descripción: Registro de auditoría de todos los eventos importantes de las órdenes
-- ============================================================================
CREATE TABLE historial (
    id SERIAL PRIMARY KEY,
    orden_id INTEGER NOT NULL REFERENCES ordenes(id) ON DELETE CASCADE,
    evento VARCHAR(100) NOT NULL,
    detalle TEXT,
    estado_global VARCHAR(50) NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actor VARCHAR(100) NOT NULL,
    CONSTRAINT chk_evento_not_empty CHECK (LENGTH(TRIM(evento)) > 0),
    CONSTRAINT chk_actor_not_empty CHECK (LENGTH(TRIM(actor)) > 0),
    CONSTRAINT chk_historial_estado CHECK (estado_global IN ('pendiente', 'en_proceso', 'completada', 'cancelada'))
);

-- ============================================================================
-- ÍNDICES PARA OPTIMIZACIÓN DE CONSULTAS
-- ============================================================================

-- Índices para tabla areas
CREATE INDEX idx_areas_nombre ON areas(nombre);

-- Índices para tabla ordenes
CREATE INDEX idx_ordenes_estado_global ON ordenes(estado_global);
CREATE INDEX idx_ordenes_creador ON ordenes(creador);
CREATE INDEX idx_ordenes_creada_en ON ordenes(creada_en DESC);
CREATE INDEX idx_ordenes_actualizada_en ON ordenes(actualizada_en DESC);

-- Índices para tabla orden_area
CREATE INDEX idx_orden_area_orden_id ON orden_area(orden_id);
CREATE INDEX idx_orden_area_area_id ON orden_area(area_id);
CREATE INDEX idx_orden_area_estado_parcial ON orden_area(estado_parcial);
CREATE INDEX idx_orden_area_asignada_a ON orden_area(asignada_a);

-- Índices para tabla historial
CREATE INDEX idx_historial_orden_id ON historial(orden_id);
CREATE INDEX idx_historial_timestamp ON historial(timestamp DESC);
CREATE INDEX idx_historial_evento ON historial(evento);
CREATE INDEX idx_historial_actor ON historial(actor);
