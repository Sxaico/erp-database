BEGIN;

-- 0) Schema de reporting (solo lectura)
CREATE SCHEMA IF NOT EXISTS sigco_rpt;

-- ------------------------------------------------------------
-- 1) VISTA: Header "human-readable" + totales básicos
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW sigco_rpt.v_pd_header AS
SELECT
  h.pd_id,
  h.fecha_pd,
  h.responsable,
  h.hora_entrada,
  h.hora_salida,
  h.clima,
  h.plan_manana,
  h.observaciones_generales,
  h.fecha_carga,

  COALESCE(hh.hh_total, 0)         AS hh_total,
  COALESCE(hm.hm_total, 0)         AS hm_total,
  COALESCE(pr.prod_lineas, 0)      AS prod_lineas,
  COALESCE(ft.fotos_total, 0)      AS fotos_total
FROM sigco.pd_header h
LEFT JOIN (
  SELECT pd_id, SUM(horas) AS hh_total
  FROM sigco.pd_personal_hh
  GROUP BY pd_id
) hh ON hh.pd_id = h.pd_id
LEFT JOIN (
  SELECT pd_id, SUM(horas_maquina) AS hm_total
  FROM sigco.pd_equipos_hm
  GROUP BY pd_id
) hm ON hm.pd_id = h.pd_id
LEFT JOIN (
  SELECT pd_id, COUNT(*) AS prod_lineas
  FROM sigco.pd_produccion
  GROUP BY pd_id
) pr ON pr.pd_id = h.pd_id
LEFT JOIN (
  SELECT p.pd_id, COUNT(*) AS fotos_total
  FROM sigco.pd_produccion_fotos pf
  JOIN sigco.pd_produccion p ON p.id_registro = pf.produccion_id
  GROUP BY p.pd_id
) ft ON ft.pd_id = h.pd_id;


-- ------------------------------------------------------------
-- 2) VISTA: Producción detalle (con BOQ + Etapas + catálogos)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW sigco_rpt.v_pd_produccion_det AS
SELECT
  p.id_registro           AS prod_id,
  p.pd_id,
  h.fecha_pd,

  p.control_item_id,
  b.item_descripcion,

  p.etapa_id,
  e.etapa_nombre,
  e.orden                 AS etapa_orden,

  p.cantidad_dia,
  b.cantidad_base,
  u.unidad_tipo,

  p.hh_tarea,
  p.personas_tarea,
  p.ubicacion_referencia,
  p.observacion_linea,

  b.area_codigo,
  a.area_nombre,

  b.familia_id,
  f.familia_nombre,

  b.wbs_id,
  w.wbs_nombre
FROM sigco.pd_produccion p
JOIN sigco.pd_header h           ON h.pd_id = p.pd_id
LEFT JOIN sigco.boq_control b    ON b.control_item_id = p.control_item_id
LEFT JOIN sigco.cat_etapas e     ON e.etapa_id = p.etapa_id
LEFT JOIN sigco.cat_unidades u   ON u.unidad_id = b.unidad_id
LEFT JOIN sigco.cat_familias f   ON f.familia_id = b.familia_id
LEFT JOIN sigco.cat_areas_frentes a ON a.area_codigo = b.area_codigo
LEFT JOIN sigco.wbs w            ON w.wbs_id = b.wbs_id;


-- ------------------------------------------------------------
-- 3) VISTA: HH detalle (human-readable)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW sigco_rpt.v_pd_hh_det AS
SELECT
  hh.id_registro       AS hh_id,
  hh.pd_id,
  h.fecha_pd,

  hh.persona_nombre,

  hh.categoria_id,
  c.categoria_nombre,
  c.tipo              AS categoria_tipo,

  hh.horas,

  hh.area_codigo,
  a.area_nombre,

  hh.observacion
FROM sigco.pd_personal_hh hh
JOIN sigco.pd_header h ON h.pd_id = hh.pd_id
LEFT JOIN sigco.cat_categorias_personal c ON c.categoria_id = hh.categoria_id
LEFT JOIN sigco.cat_areas_frentes a       ON a.area_codigo = hh.area_codigo;


-- ------------------------------------------------------------
-- 4) VISTA: HM detalle (human-readable)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW sigco_rpt.v_pd_hm_det AS
SELECT
  hm.id_registro     AS hm_id,
  hm.pd_id,
  h.fecha_pd,

  hm.equipo_id,
  e.equipo_nombre,
  e.equipo_tipo,

  hm.horas_maquina,

  hm.area_codigo,
  a.area_nombre,

  hm.observacion
FROM sigco.pd_equipos_hm hm
JOIN sigco.pd_header h ON h.pd_id = hm.pd_id
LEFT JOIN sigco.cat_equipos e      ON e.equipo_id = hm.equipo_id
LEFT JOIN sigco.cat_areas_frentes a ON a.area_codigo = hm.area_codigo;


-- ------------------------------------------------------------
-- 5) VISTA: Fotos detalle (por producción + metadatos Directus)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW sigco_rpt.v_pd_fotos_det AS
SELECT
  pf.id_registro        AS foto_registro_id,
  p.id_registro         AS prod_id,
  p.pd_id,
  h.fecha_pd,

  p.control_item_id,
  b.item_descripcion,

  p.etapa_id,
  et.etapa_nombre,

  pf.file_id,
  df.title              AS file_title,
  df.filename_download,
  df.type               AS file_type,
  df.filesize           AS file_size,
  df.uploaded_on,

  pf.descripcion        AS foto_descripcion,
  pf.orden              AS foto_orden
FROM sigco.pd_produccion_fotos pf
JOIN sigco.pd_produccion p      ON p.id_registro = pf.produccion_id
JOIN sigco.pd_header h          ON h.pd_id = p.pd_id
LEFT JOIN sigco.boq_control b   ON b.control_item_id = p.control_item_id
LEFT JOIN sigco.cat_etapas et   ON et.etapa_id = p.etapa_id
LEFT JOIN public.directus_files df ON df.id = pf.file_id;


-- ------------------------------------------------------------
-- 6) KPI: Resumen diario por Parte (pd_id) (útil para tablero operativo)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW sigco_rpt.v_kpi_pd_resumen AS
SELECT
  vh.pd_id,
  vh.fecha_pd,
  vh.responsable,
  vh.hora_entrada,
  vh.hora_salida,
  vh.hh_total,
  vh.hm_total,
  vh.prod_lineas,
  vh.fotos_total
FROM sigco_rpt.v_pd_header vh;


-- ------------------------------------------------------------
-- 7) KPI: Avance BOQ vs Real (usando SOLO etapa final = mayor orden)
--     Regla MVP: el avance contra BOQ lo medimos por la etapa "final".
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW sigco_rpt.v_kpi_boq_avance AS
WITH etapa_final AS (
  SELECT etapa_id, etapa_nombre, orden
  FROM sigco.cat_etapas
  WHERE COALESCE(activo, true) = true
  ORDER BY orden DESC NULLS LAST
  LIMIT 1
),
avance_final AS (
  SELECT
    p.control_item_id,
    SUM(p.cantidad_dia) AS avance_final_acum
  FROM sigco.pd_produccion p
  JOIN etapa_final ef ON ef.etapa_id = p.etapa_id
  GROUP BY p.control_item_id
)
SELECT
  b.control_item_id,
  b.item_descripcion,

  b.cantidad_base,
  COALESCE(af.avance_final_acum, 0) AS avance_final_acum,

  CASE
    WHEN b.cantidad_base IS NULL OR b.cantidad_base = 0 THEN NULL
    ELSE ROUND((COALESCE(af.avance_final_acum, 0) / b.cantidad_base) * 100, 2)
  END AS pct_avance,

  CASE
    WHEN b.cantidad_base IS NULL THEN NULL
    ELSE (b.cantidad_base - COALESCE(af.avance_final_acum, 0))
  END AS saldo,

  b.unidad_id,
  u.unidad_tipo,

  b.familia_id,
  f.familia_nombre,

  b.area_codigo,
  ar.area_nombre,

  b.wbs_id,
  w.wbs_nombre,

  ef.etapa_id        AS etapa_final_id,
  ef.etapa_nombre    AS etapa_final_nombre,
  ef.orden           AS etapa_final_orden
FROM sigco.boq_control b
CROSS JOIN etapa_final ef
LEFT JOIN avance_final af ON af.control_item_id = b.control_item_id
LEFT JOIN sigco.cat_unidades u      ON u.unidad_id = b.unidad_id
LEFT JOIN sigco.cat_familias f      ON f.familia_id = b.familia_id
LEFT JOIN sigco.cat_areas_frentes ar ON ar.area_codigo = b.area_codigo
LEFT JOIN sigco.wbs w               ON w.wbs_id = b.wbs_id
WHERE COALESCE(b.activo, true) = true;


-- ------------------------------------------------------------
-- 8) KPI: Resumen diario por FECHA (para gráficos rápidos)
--     (ojo: vos permitís fechas duplicadas, por eso contamos partes)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW sigco_rpt.v_kpi_diario AS
SELECT
  fecha_pd,
  COUNT(*)                AS partes,
  SUM(hh_total)           AS hh_total,
  SUM(hm_total)           AS hm_total,
  SUM(prod_lineas)        AS prod_lineas,
  SUM(fotos_total)        AS fotos_total
FROM sigco_rpt.v_pd_header
GROUP BY fecha_pd
ORDER BY fecha_pd DESC;


-- 9) Permisos (para que Directus / Metabase / API lo lean)
GRANT USAGE ON SCHEMA sigco_rpt TO erp_user;
GRANT SELECT ON ALL TABLES IN SCHEMA sigco_rpt TO erp_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA sigco_rpt GRANT SELECT ON TABLES TO erp_user;

COMMIT;

