
-- 91-sigco-multiproyecto.sql (FIX PG: sin ADD CONSTRAINT IF NOT EXISTS)
CREATE SCHEMA IF NOT EXISTS sigco;

CREATE TABLE IF NOT EXISTS sigco.projects (
  project_id       varchar PRIMARY KEY,
  project_nombre   text NOT NULL,
  activo           boolean NOT NULL DEFAULT true,
  created_at       timestamptz NOT NULL DEFAULT now()
);

INSERT INTO sigco.projects (project_id, project_nombre)
VALUES ('P0001', 'PROYECTO DEFAULT')
ON CONFLICT (project_id) DO NOTHING;

-- wbs
ALTER TABLE IF EXISTS sigco.wbs
  ADD COLUMN IF NOT EXISTS project_id varchar;

UPDATE sigco.wbs SET project_id = 'P0001' WHERE project_id IS NULL;

ALTER TABLE IF EXISTS sigco.wbs
  ALTER COLUMN project_id SET DEFAULT 'P0001';

CREATE INDEX IF NOT EXISTS idx_sigco_wbs_project_id ON sigco.wbs(project_id);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE c.conname = 'fk_sigco_wbs_project'
      AND n.nspname = 'sigco'
      AND t.relname = 'wbs'
  ) THEN
    EXECUTE 'ALTER TABLE sigco.wbs
             ADD CONSTRAINT fk_sigco_wbs_project
             FOREIGN KEY (project_id) REFERENCES sigco.projects(project_id)
             NOT VALID';
  END IF;
END $$;

-- boq_control
ALTER TABLE IF EXISTS sigco.boq_control
  ADD COLUMN IF NOT EXISTS project_id varchar;

UPDATE sigco.boq_control SET project_id = 'P0001' WHERE project_id IS NULL;

ALTER TABLE IF EXISTS sigco.boq_control
  ALTER COLUMN project_id SET DEFAULT 'P0001';

CREATE INDEX IF NOT EXISTS idx_sigco_boq_project_id ON sigco.boq_control(project_id);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE c.conname = 'fk_sigco_boq_project'
      AND n.nspname = 'sigco'
      AND t.relname = 'boq_control'
  ) THEN
    EXECUTE 'ALTER TABLE sigco.boq_control
             ADD CONSTRAINT fk_sigco_boq_project
             FOREIGN KEY (project_id) REFERENCES sigco.projects(project_id)
             NOT VALID';
  END IF;
END $$;

-- pd_header
ALTER TABLE IF EXISTS sigco.pd_header
  ADD COLUMN IF NOT EXISTS project_id varchar;

UPDATE sigco.pd_header SET project_id = 'P0001' WHERE project_id IS NULL;

ALTER TABLE IF EXISTS sigco.pd_header
  ALTER COLUMN project_id SET DEFAULT 'P0001';

CREATE INDEX IF NOT EXISTS idx_sigco_pd_header_project_id ON sigco.pd_header(project_id);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE c.conname = 'fk_sigco_pd_project'
      AND n.nspname = 'sigco'
      AND t.relname = 'pd_header'
  ) THEN
    EXECUTE 'ALTER TABLE sigco.pd_header
             ADD CONSTRAINT fk_sigco_pd_project
             FOREIGN KEY (project_id) REFERENCES sigco.projects(project_id)
             NOT VALID';
  END IF;
END $$;

-- Cuando quieras “endurecer” integridad (fase 2):
-- ALTER TABLE sigco.wbs VALIDATE CONSTRAINT fk_sigco_wbs_project;
-- ALTER TABLE sigco.boq_control VALIDATE CONSTRAINT fk_sigco_boq_project;
-- ALTER TABLE sigco.pd_header VALIDATE CONSTRAINT fk_sigco_pd_project;

