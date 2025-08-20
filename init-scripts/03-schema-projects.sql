-- init-scripts/03-schema-projects.sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS proyectos (
  id                 SERIAL PRIMARY KEY,
  uuid               UUID NOT NULL DEFAULT gen_random_uuid(),
  codigo             TEXT UNIQUE,
  nombre             TEXT NOT NULL,
  descripcion        TEXT,
  organizacion_id    INT REFERENCES organizaciones(id) ON DELETE SET NULL,
  gerente_proyecto_id INT REFERENCES usuarios(id) ON DELETE SET NULL,
  sponsor_id         INT REFERENCES usuarios(id) ON DELETE SET NULL,
  prioridad          SMALLINT NOT NULL DEFAULT 3,
  estado             TEXT NOT NULL DEFAULT 'EN_PROGRESO',
  presupuesto_monto  NUMERIC(14,2) DEFAULT 0,
  avance_pct         NUMERIC(5,2)  DEFAULT 0,
  fecha_inicio       DATE,
  fecha_fin_plan     DATE,
  fecha_fin_real     DATE,
  activo             BOOLEAN NOT NULL DEFAULT TRUE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at         TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_proy_codigo ON proyectos(codigo) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_proy_estado ON proyectos(estado) WHERE deleted_at IS NULL;

CREATE TABLE IF NOT EXISTS tareas (
  id              SERIAL PRIMARY KEY,
  uuid            UUID NOT NULL DEFAULT gen_random_uuid(),
  proyecto_id     INT NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
  titulo          TEXT NOT NULL,
  descripcion     TEXT,
  estado          TEXT NOT NULL DEFAULT 'PENDIENTE',
  prioridad       SMALLINT NOT NULL DEFAULT 3,
  asignado_a      INT REFERENCES usuarios(id) ON DELETE SET NULL,
  estimado_horas  NUMERIC(10,2) DEFAULT 0,
  real_horas      NUMERIC(10,2) DEFAULT 0,
  fecha_inicio    DATE,
  fecha_fin_plan  DATE,
  fecha_fin_real  DATE,
  activo          BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at      TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_tareas_proyecto ON tareas(proyecto_id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_tareas_estado ON tareas(estado) WHERE deleted_at IS NULL;

CREATE OR REPLACE VIEW vw_resumen_tareas_por_estado AS
SELECT
  p.id AS proyecto_id,
  p.nombre AS proyecto,
  t.estado,
  COUNT(*)::int AS cantidad
FROM proyectos p
JOIN tareas t ON t.proyecto_id = p.id AND t.deleted_at IS NULL
WHERE p.deleted_at IS NULL
GROUP BY p.id, p.nombre, t.estado
ORDER BY p.id, t.estado;
