-- SIGCO MVP v1 - Esquema base (PostgreSQL 16)
-- Recomendado: ejecutar como usuario con permisos (erp_user).

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS sigco;

-- =========================
-- Catálogos
-- =========================

CREATE TABLE IF NOT EXISTS sigco.cat_areas_frentes (
  area_codigo        varchar PRIMARY KEY,
  area_nombre        varchar NOT NULL,
  descripcion        text,
  activo             boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS sigco.cat_etapas (
  etapa_id           varchar PRIMARY KEY,
  etapa_nombre       varchar NOT NULL,
  etapa_definicion   text,
  orden              integer,
  activo             boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS sigco.cat_familias (
  familia_id         varchar PRIMARY KEY,
  familia_nombre     varchar NOT NULL,
  alcance_tecnico    text
);

CREATE TABLE IF NOT EXISTS sigco.cat_unidades (
  unidad_id          varchar PRIMARY KEY,
  unidad_tipo        varchar,
  uso_tipico         text,
  activo             boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS sigco.cat_restricciones (
  restriccion_id         varchar PRIMARY KEY,
  categoria              varchar,
  restriccion_nombre     varchar NOT NULL,
  restriccion_definicion text,
  activo                 boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS sigco.cat_categorias_personal (
  categoria_id       varchar PRIMARY KEY,
  categoria_nombre   varchar NOT NULL,
  tipo               varchar NOT NULL, -- Directo / Indirecto
  descripcion        text,
  activo             boolean NOT NULL DEFAULT true,
  CONSTRAINT ck_cat_personal_tipo CHECK (tipo IN ('Directo','Indirecto'))
);

CREATE TABLE IF NOT EXISTS sigco.cat_equipos (
  equipo_id          varchar PRIMARY KEY,
  equipo_nombre      varchar NOT NULL,
  equipo_tipo        varchar,
  activo             boolean NOT NULL DEFAULT true
);

-- =========================
-- WBS & BOQ
-- =========================

CREATE TABLE IF NOT EXISTS sigco.wbs (
  wbs_id             varchar PRIMARY KEY,
  wbs_nombre         varchar NOT NULL,
  wbs_descripcion    text,
  wbs_padre_id       varchar,
  nivel              integer,
  activo             boolean NOT NULL DEFAULT true
);

DO $$
BEGIN
  ALTER TABLE sigco.wbs
    ADD CONSTRAINT fk_wbs_padre
    FOREIGN KEY (wbs_padre_id) REFERENCES sigco.wbs(wbs_id)
    ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN
  NULL;
END $$;

CREATE TABLE IF NOT EXISTS sigco.boq_control (
  control_item_id    varchar PRIMARY KEY,
  wbs_id             varchar NOT NULL,
  item_descripcion   text NOT NULL,
  familia_id         varchar,
  unidad_id          varchar,
  cantidad_base      numeric(14,3),
  area_codigo        varchar,
  activo             boolean NOT NULL DEFAULT true
);

DO $$
BEGIN
  ALTER TABLE sigco.boq_control
    ADD CONSTRAINT fk_boq_wbs
    FOREIGN KEY (wbs_id) REFERENCES sigco.wbs(wbs_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.boq_control
    ADD CONSTRAINT fk_boq_familia
    FOREIGN KEY (familia_id) REFERENCES sigco.cat_familias(familia_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.boq_control
    ADD CONSTRAINT fk_boq_unidad
    FOREIGN KEY (unidad_id) REFERENCES sigco.cat_unidades(unidad_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.boq_control
    ADD CONSTRAINT fk_boq_area
    FOREIGN KEY (area_codigo) REFERENCES sigco.cat_areas_frentes(area_codigo);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_boq_area ON sigco.boq_control(area_codigo);
CREATE INDEX IF NOT EXISTS idx_boq_wbs  ON sigco.boq_control(wbs_id);

-- =========================
-- Parte Diario (Header + líneas)
-- =========================

CREATE TABLE IF NOT EXISTS sigco.pd_header (
  pd_id                  varchar PRIMARY KEY DEFAULT gen_random_uuid()::text,
  fecha_pd               date NOT NULL,
  responsable            varchar,
  hora_entrada           time,
  hora_salida            time,
  clima                  varchar,
  plan_manana            text,
  observaciones_generales text,
  fecha_carga            timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_pd_header_fecha ON sigco.pd_header(fecha_pd);

-- Producción: PK simple + UNIQUE lógica (MVP-friendly para Directus/Appsmith)
CREATE TABLE IF NOT EXISTS sigco.pd_produccion (
  id_registro         bigserial PRIMARY KEY,
  pd_id               varchar NOT NULL,
  control_item_id     varchar NOT NULL,
  etapa_id            varchar NOT NULL,
  cantidad_dia        numeric(14,3),
  hh_tarea            numeric(12,2),
  personas_tarea      integer,
  ubicacion_referencia text,
  observacion_linea   text
);

DO $$
BEGIN
  ALTER TABLE sigco.pd_produccion
    ADD CONSTRAINT uq_pd_prod UNIQUE (pd_id, control_item_id, etapa_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.pd_produccion
    ADD CONSTRAINT fk_pd_prod_header
    FOREIGN KEY (pd_id) REFERENCES sigco.pd_header(pd_id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.pd_produccion
    ADD CONSTRAINT fk_pd_prod_item
    FOREIGN KEY (control_item_id) REFERENCES sigco.boq_control(control_item_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.pd_produccion
    ADD CONSTRAINT fk_pd_prod_etapa
    FOREIGN KEY (etapa_id) REFERENCES sigco.cat_etapas(etapa_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_pd_prod_pd ON sigco.pd_produccion(pd_id);

-- Personal HH
CREATE TABLE IF NOT EXISTS sigco.pd_personal_hh (
  id_registro       bigserial PRIMARY KEY,
  pd_id             varchar NOT NULL,
  persona_nombre    varchar NOT NULL,
  categoria_id      varchar NOT NULL,
  horas             numeric(12,2) NOT NULL,
  area_codigo       varchar,
  observacion       text
);

DO $$
BEGIN
  ALTER TABLE sigco.pd_personal_hh
    ADD CONSTRAINT fk_pd_hh_header
    FOREIGN KEY (pd_id) REFERENCES sigco.pd_header(pd_id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.pd_personal_hh
    ADD CONSTRAINT fk_pd_hh_categoria
    FOREIGN KEY (categoria_id) REFERENCES sigco.cat_categorias_personal(categoria_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.pd_personal_hh
    ADD CONSTRAINT fk_pd_hh_area
    FOREIGN KEY (area_codigo) REFERENCES sigco.cat_areas_frentes(area_codigo);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_pd_hh_pd ON sigco.pd_personal_hh(pd_id);

-- Equipos HM
CREATE TABLE IF NOT EXISTS sigco.pd_equipos_hm (
  id_registro       bigserial PRIMARY KEY,
  pd_id             varchar NOT NULL,
  equipo_id         varchar NOT NULL,
  horas_maquina     numeric(12,2) NOT NULL,
  area_codigo       varchar,
  observacion       text
);

DO $$
BEGIN
  ALTER TABLE sigco.pd_equipos_hm
    ADD CONSTRAINT fk_pd_hm_header
    FOREIGN KEY (pd_id) REFERENCES sigco.pd_header(pd_id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.pd_equipos_hm
    ADD CONSTRAINT fk_pd_hm_equipo
    FOREIGN KEY (equipo_id) REFERENCES sigco.cat_equipos(equipo_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.pd_equipos_hm
    ADD CONSTRAINT fk_pd_hm_area
    FOREIGN KEY (area_codigo) REFERENCES sigco.cat_areas_frentes(area_codigo);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_pd_hm_pd ON sigco.pd_equipos_hm(pd_id);

-- Restricciones
CREATE TABLE IF NOT EXISTS sigco.pd_restricciones (
  id_registro        bigserial PRIMARY KEY,
  pd_id              varchar NOT NULL,
  restriccion_id     varchar NOT NULL,
  horas_impacto      numeric(12,2),
  area_codigo        varchar,
  descripcion_evento text,
  accion_tomada      text
);

DO $$
BEGIN
  ALTER TABLE sigco.pd_restricciones
    ADD CONSTRAINT fk_pd_res_header
    FOREIGN KEY (pd_id) REFERENCES sigco.pd_header(pd_id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.pd_restricciones
    ADD CONSTRAINT fk_pd_res_restr
    FOREIGN KEY (restriccion_id) REFERENCES sigco.cat_restricciones(restriccion_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$
BEGIN
  ALTER TABLE sigco.pd_restricciones
    ADD CONSTRAINT fk_pd_res_area
    FOREIGN KEY (area_codigo) REFERENCES sigco.cat_areas_frentes(area_codigo);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_pd_res_pd ON sigco.pd_restricciones(pd_id);

