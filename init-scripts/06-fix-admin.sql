-- init-scripts/06-fix-admin.sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Roles base
INSERT INTO roles (nombre, descripcion) VALUES
('Super Admin','Administrador del sistema con todos los permisos'),
('Admin','Administrador con permisos de gestión'),
('Gerente de Proyecto','Gestor de proyectos y equipos'),
('Líder de Equipo','Líder de equipos de trabajo'),
('Colaborador','Usuario colaborador básico')
ON CONFLICT (nombre) DO NOTHING;

-- Admin inicial
INSERT INTO usuarios (email, password_hash, nombre, apellido, activo)
VALUES ('admin@miempresa.com', crypt('admin123', gen_salt('bf')), 'Administrador', 'Sistema', TRUE)
ON CONFLICT (email) DO UPDATE
SET password_hash = EXCLUDED.password_hash,
    nombre = EXCLUDED.nombre,
    apellido = EXCLUDED.apellido,
    activo = TRUE;

-- Rol "Super Admin" para el admin
INSERT INTO usuario_roles (usuario_id, rol_id)
SELECT u.id, r.id
FROM usuarios u
JOIN roles r ON r.nombre = 'Super Admin'
WHERE u.email = 'admin@miempresa.com'
AND NOT EXISTS (
  SELECT 1 FROM usuario_roles ur WHERE ur.usuario_id = u.id AND ur.rol_id = r.id
);
