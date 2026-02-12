-- 92-sigco-openproject-int.sql
CREATE SCHEMA IF NOT EXISTS sigco_int;

-- Mapeo de proyecto SIGCO -> Proyecto OpenProject
CREATE TABLE IF NOT EXISTS sigco_int.op_project_map (
  sigco_project_id   varchar PRIMARY KEY,
  op_project_id      integer NOT NULL,
  op_base_url        text NOT NULL, -- ej: http://kaizen-debian.local:8082
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);

-- FK suave (si existe sigco.projects)
ALTER TABLE sigco_int.op_project_map
  DROP CONSTRAINT IF EXISTS fk_op_project_map_sigco_project;

ALTER TABLE sigco_int.op_project_map
  ADD CONSTRAINT fk_op_project_map_sigco_project
  FOREIGN KEY (sigco_project_id) REFERENCES sigco.projects(project_id)
  ON UPDATE CASCADE ON DELETE CASCADE
  NOT VALID;

-- Mapeo WBS -> Work Package (1 WP por WBS)
CREATE TABLE IF NOT EXISTS sigco_int.op_wp_map (
  sigco_project_id     varchar NOT NULL,
  wbs_id               varchar NOT NULL,
  op_work_package_id   integer NOT NULL,
  created_at           timestamptz NOT NULL DEFAULT now(),
  updated_at           timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sigco_project_id, wbs_id)
);

CREATE INDEX IF NOT EXISTS idx_op_wp_map_wp_id ON sigco_int.op_wp_map(op_work_package_id);

-- Dedupe/idempotencia para time entries (evita duplicar al sincronizar)
CREATE TABLE IF NOT EXISTS sigco_int.op_time_entry_dedupe (
  dedupe_key         text PRIMARY KEY,
  op_time_entry_id   integer,
  created_at         timestamptz NOT NULL DEFAULT now()
);

-- =========================================
-- VISTA 1: HH directas por WBS/día total
-- Fuente: pd_produccion.hh_tarea (directas) + pd_header.fecha_pd + boq_control.wbs_id
-- =========================================
CREATE OR REPLACE VIEW sigco_int.v_hh_directas_wbs_dia AS
SELECT
  h.project_id               AS sigco_project_id,
  h.fecha_pd                AS spent_on,
  b.wbs_id                   AS wbs_id,
  SUM(COALESCE(p.hh_tarea,0))::numeric(12,2) AS hh_directas
FROM sigco.pd_produccion p
JOIN sigco.pd_header h
  ON h.pd_id = p.pd_id
JOIN sigco.boq_control b
  ON b.control_item_id = p.control_item_id
GROUP BY
  h.project_id, h.fecha_pd, b.wbs_id;

-- =========================================
-- VISTA 2: Avance acumulado por WBS (%)
-- Regla: cuenta SOLO etapa final (max cat_etapas.orden)
-- =========================================
CREATE OR REPLACE VIEW sigco_int.v_avance_wbs AS
WITH etapa_final AS (
  SELECT e.etapa_id
  FROM sigco.cat_etapas e
  ORDER BY e.orden DESC
  LIMIT 1
),
item_final AS (
  SELECT
    b.project_id AS sigco_project_id,
    b.wbs_id,
    b.control_item_id,
    COALESCE(b.cantidad_base, 0)::numeric(14,4) AS cantidad_base,
    COALESCE(SUM(
      CASE WHEN p.etapa_id = (SELECT etapa_id FROM etapa_final)
           THEN COALESCE(p.cantidad_dia,0)
           ELSE 0
      END
    ),0)::numeric(14,4) AS cantidad_final_acum
  FROM sigco.boq_control b
  LEFT JOIN sigco.pd_produccion p
    ON p.control_item_id = b.control_item_id
  GROUP BY b.project_id, b.wbs_id, b.control_item_id, b.cantidad_base
),
wbs_tot AS (
  SELECT
    sigco_project_id,
    wbs_id,
    SUM(cantidad_base)::numeric(14,4) AS base_total,
    SUM(LEAST(cantidad_final_acum, cantidad_base))::numeric(14,4) AS final_total
  FROM item_final
  GROUP BY sigco_project_id, wbs_id
)
SELECT
  sigco_project_id,
  wbs_id,
  base_total,
  final_total,
  CASE
    WHEN base_total > 0 THEN ROUND((final_total / base_total) * 100.0, 2)
    ELSE NULL
  END AS avance_pct
FROM wbs_tot;

-- =========================================
-- VISTA 3: WBS que aún no están mapeadas a WP
-- =========================================
CREATE OR REPLACE VIEW sigco_int.v_wbs_sin_wp AS
SELECT
  w.project_id AS sigco_project_id,
  w.wbs_id,
  w.wbs_nombre,
  w.nivel,
  w.wbs_padre_id
FROM sigco.wbs w
LEFT JOIN sigco_int.op_wp_map m
  ON m.sigco_project_id = w.project_id
 AND m.wbs_id = w.wbs_id
WHERE m.wbs_id IS NULL;

