-- 30-pd-produccion-fotos.sql
BEGIN;

SET search_path TO sigco, public;

CREATE TABLE IF NOT EXISTS sigco.pd_produccion_fotos (
  id_registro     BIGSERIAL PRIMARY KEY,
  produccion_id   BIGINT NOT NULL,
  file_id         UUID NOT NULL,
  descripcion     TEXT,
  orden           INTEGER DEFAULT 1,
  created_at      TIMESTAMPTZ DEFAULT NOW(),

  CONSTRAINT fk_pd_prod_foto_produccion
    FOREIGN KEY (produccion_id)
    REFERENCES sigco.pd_produccion (id_registro)
    ON DELETE CASCADE,

  CONSTRAINT fk_pd_prod_foto_file
    FOREIGN KEY (file_id)
    REFERENCES public.directus_files (id)
);

CREATE INDEX IF NOT EXISTS idx_pd_prod_foto_produccion
  ON sigco.pd_produccion_fotos (produccion_id);

COMMIT;
