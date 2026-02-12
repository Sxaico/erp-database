-- SIGCO Migration 001 (UP): Estado de Parte (BORRADOR/CERRADO) + auditoría básica
-- Fecha: 2026-02-12
BEGIN;

ALTER TABLE sigco.pd_header
  ADD COLUMN IF NOT EXISTS estado         text        NOT NULL DEFAULT 'BORRADOR',
  ADD COLUMN IF NOT EXISTS cerrado_at     timestamptz,
  ADD COLUMN IF NOT EXISTS cerrado_por    text,
  ADD COLUMN IF NOT EXISTS reabierto_at   timestamptz,
  ADD COLUMN IF NOT EXISTS reabierto_por  text;

-- constraint de valores válidos (idempotente)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'pd_header_estado_chk'
  ) THEN
    ALTER TABLE sigco.pd_header
      ADD CONSTRAINT pd_header_estado_chk
      CHECK (estado IN ('BORRADOR','CERRADO'));
  END IF;
END $$;

-- Trigger: si cambia el estado, setea timestamps (por si el front no los manda)
CREATE OR REPLACE FUNCTION sigco.fn_pd_header_estado_audit()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.estado IS DISTINCT FROM OLD.estado THEN
    IF NEW.estado = 'CERRADO' THEN
      NEW.cerrado_at := COALESCE(NEW.cerrado_at, now());
    ELSIF NEW.estado = 'BORRADOR' THEN
      NEW.reabierto_at := COALESCE(NEW.reabierto_at, now());
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_pd_header_estado_audit ON sigco.pd_header;
CREATE TRIGGER trg_pd_header_estado_audit
BEFORE UPDATE OF estado ON sigco.pd_header
FOR EACH ROW
EXECUTE FUNCTION sigco.fn_pd_header_estado_audit();

COMMIT;

