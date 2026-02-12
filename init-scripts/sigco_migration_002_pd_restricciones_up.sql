-- SIGCO Migration 002 (v3) - Restricciones del Parte (alineado a esquema real)
-- Objetivo: No recrea la tabla (ya existe). Solo asegura constraints/índices y crea vistas de reporte.
-- Reversible: ver DOWN v3.

BEGIN;

-- 1) Constraint: horas_impacto >= 0 (si existe la columna)
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema='sigco' AND table_name='pd_restricciones' AND column_name='horas_impacto'
  ) THEN
    -- crear constraint solo si no existe
    IF NOT EXISTS (
      SELECT 1
      FROM pg_constraint c
      JOIN pg_class t ON t.oid = c.conrelid
      JOIN pg_namespace n ON n.oid = t.relnamespace
      WHERE n.nspname='sigco'
        AND t.relname='pd_restricciones'
        AND c.conname='ck_pd_restricciones_horas_nonneg'
    ) THEN
      EXECUTE $sql$
        ALTER TABLE sigco.pd_restricciones
        ADD CONSTRAINT ck_pd_restricciones_horas_nonneg
        CHECK (horas_impacto IS NULL OR horas_impacto >= 0)
      $sql$;
    END IF;
  END IF;
END $$;

-- 2) Índices útiles (idempotentes)
CREATE INDEX IF NOT EXISTS idx_pd_res_pd      ON sigco.pd_restricciones (pd_id);
CREATE INDEX IF NOT EXISTS idx_pd_res_restr   ON sigco.pd_restricciones (restriccion_id);
CREATE INDEX IF NOT EXISTS idx_pd_res_area    ON sigco.pd_restricciones (area_codigo);

-- 3) Schema de reportes
CREATE SCHEMA IF NOT EXISTS sigco_rpt;

-- 4) Vistas de detalle y resumen (OJO: en tu esquema el catálogo de áreas se llama cat_areas_frentes)
CREATE OR REPLACE VIEW sigco_rpt.v_pd_restricciones_det AS
SELECT
  r.id_registro                AS restriccion_registro_id,
  r.pd_id,
  h.fecha_pd,
  r.restriccion_id,
  cr.categoria                 AS restriccion_categoria,
  cr.restriccion_nombre,
  cr.restriccion_definicion,
  r.horas_impacto,
  r.area_codigo,
  a.area_nombre,
  r.descripcion_evento,
  r.accion_tomada
FROM sigco.pd_restricciones r
JOIN sigco.pd_header h
  ON (h.pd_id::text = r.pd_id::text)
LEFT JOIN sigco.cat_restricciones cr
  ON (cr.restriccion_id::text = r.restriccion_id::text)
LEFT JOIN sigco.cat_areas_frentes a
  ON (a.area_codigo::text = r.area_codigo::text);

CREATE OR REPLACE VIEW sigco_rpt.v_pd_restricciones_resumen AS
SELECT
  r.pd_id,
  h.fecha_pd,
  COALESCE(r.area_codigo, 'N/A')           AS area_codigo,
  a.area_nombre,
  COALESCE(cr.categoria, 'Sin categoría')  AS restriccion_categoria,
  r.restriccion_id,
  cr.restriccion_nombre,
  SUM(COALESCE(r.horas_impacto,0))::numeric(12,2) AS horas_impacto_total,
  COUNT(*)::bigint                          AS eventos
FROM sigco.pd_restricciones r
JOIN sigco.pd_header h
  ON (h.pd_id::text = r.pd_id::text)
LEFT JOIN sigco.cat_restricciones cr
  ON (cr.restriccion_id::text = r.restriccion_id::text)
LEFT JOIN sigco.cat_areas_frentes a
  ON (a.area_codigo::text = r.area_codigo::text)
GROUP BY
  r.pd_id, h.fecha_pd, r.area_codigo, a.area_nombre, cr.categoria, r.restriccion_id, cr.restriccion_nombre
ORDER BY
  h.fecha_pd DESC, r.pd_id;

-- KPI simple por Parte (total horas impacto)
CREATE OR REPLACE VIEW sigco_rpt.v_pd_restricciones_kpi AS
SELECT
  h.pd_id,
  h.fecha_pd,
  SUM(COALESCE(r.horas_impacto,0))::numeric(12,2) AS horas_improductivas
FROM sigco.pd_header h
LEFT JOIN sigco.pd_restricciones r
  ON (r.pd_id::text = h.pd_id::text)
GROUP BY h.pd_id, h.fecha_pd
ORDER BY h.fecha_pd DESC;

COMMIT;

