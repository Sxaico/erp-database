-- Roles básicos
INSERT INTO roles (nombre, descripcion) VALUES
 ('Super Admin','Acceso total'),
 ('Admin','Administración del sistema'),
 ('Gerente de Proyecto','Gestión de proyectos y reportes'),
 ('Líder de Equipo','Gestión de tareas y carga de partes'),
 ('Colaborador','Carga operativa')
ON CONFLICT (nombre) DO NOTHING;

-- Usuario admin
INSERT INTO usuarios (email, password_hash, nombre, apellido, activo)
VALUES (
  'admin@miempresa.com',
  crypt('admin123', gen_salt('bf')),
  'Admin', 'ERP', TRUE
)
ON CONFLICT (email) DO NOTHING;

-- Asignar Super Admin
INSERT INTO usuario_roles (usuario_id, rol_id, asignado_por)
SELECT u.id, r.id, u.id
FROM usuarios u, roles r
WHERE u.email = 'admin@miempresa.com' AND r.nombre = 'Super Admin'
ON CONFLICT DO NOTHING;

-- Organización y departamento base
INSERT INTO organizaciones (nombre, razon_social, email)
VALUES ('Mi Empresa', 'Mi Empresa S.A.', 'info@miempresa.com')
ON CONFLICT DO NOTHING;

INSERT INTO departamentos (nombre, descripcion, organizacion_id, responsable_id)
SELECT 'Planificación y Control', 'PMO / Planificación', o.id, u.id
FROM organizaciones o, usuarios u
WHERE o.nombre='Mi Empresa' AND u.email='admin@miempresa.com'
LIMIT 1;
