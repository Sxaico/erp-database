-- init-scripts/04-data-demo.sql
WITH upsert AS (
  INSERT INTO proyectos (codigo, nombre, estado, prioridad, presupuesto_monto)
  VALUES ('DEMO-2024-001','Implementación de Sistema ERP','EN_PROGRESO',2,500000)
  ON CONFLICT (codigo) DO NOTHING
  RETURNING id
)
INSERT INTO tareas (proyecto_id, titulo, estado, prioridad, estimado_horas)
SELECT COALESCE((SELECT id FROM upsert), (SELECT id FROM proyectos WHERE codigo='DEMO-2024-001' LIMIT 1)),
       t.titulo, t.estado, t.prioridad, t.est
FROM (VALUES
  ('Análisis de Requerimientos','HECHA',2,16),
  ('Diseño de Base de Datos','EN_PROGRESO',2,24),
  ('API de Autenticación','EN_PROGRESO',2,20),
  ('Gestión de Proyectos (CRUD)','PENDIENTE',3,20),
  ('Reporte básico','PENDIENTE',3,12)
) AS t(titulo, estado, prioridad, est);
