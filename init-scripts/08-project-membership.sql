-- 08-project-membership.sql
-- Relación proyecto <-> usuario (membresías)
CREATE TABLE IF NOT EXISTS proyecto_miembros (
  id SERIAL PRIMARY KEY,
  proyecto_id INTEGER NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
  usuario_id INTEGER NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  rol_en_proyecto VARCHAR(30) DEFAULT 'MIEMBRO',
  creado_en TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (proyecto_id, usuario_id)
);

-- Índices útiles
CREATE INDEX IF NOT EXISTS idx_proyecto_miembros_proyecto ON proyecto_miembros(proyecto_id);
CREATE INDEX IF NOT EXISTS idx_proyecto_miembros_usuario ON proyecto_miembros(usuario_id);
