-- init-scripts/05-initial-data.sql

-- Roles básicos
INSERT INTO roles (nombre, descripcion) VALUES 
('Super Admin', 'Administrador del sistema con todos los permisos'),
('Admin', 'Administrador con permisos de gestión'),
('Gerente de Proyecto', 'Gestor de proyectos y equipos'),
('Líder de Equipo', 'Líder de equipos de trabajo'),
('Colaborador', 'Usuario colaborador básico')
ON CONFLICT (nombre) DO NOTHING;

-- Usuario admin inicial (password: admin123) usando pgcrypto (bcrypt)
INSERT INTO usuarios (email, password_hash, nombre, apellido, activo)
VALUES ('admin@miempresa.com', crypt('admin123', gen_salt('bf')), 'Administrador', 'Sistema', TRUE)
ON CONFLICT (email) DO UPDATE
  SET password_hash = EXCLUDED.password_hash,
      nombre = EXCLUDED.nombre,
      apellido = EXCLUDED.apellido,
      activo = TRUE;

-- Asignar rol Super Admin al admin
INSERT INTO usuario_roles (usuario_id, rol_id, asignado_por)
SELECT u.id, r.id, u.id
FROM usuarios u
JOIN roles r ON r.nombre = 'Super Admin'
WHERE u.email = 'admin@miempresa.com'
ON CONFLICT (usuario_id, rol_id) DO NOTHING;

-- Organización y Departamento demo
INSERT INTO organizaciones (nombre, razon_social, pais)
VALUES ('Mi Empresa S.A.', 'Mi Empresa Sociedad Anónima', 'Argentina')
ON CONFLICT DO NOTHING;

INSERT INTO departamentos (nombre, descripcion, organizacion_id)
SELECT 'Sistemas', 'Departamento de Tecnología', o.id
FROM organizaciones o
WHERE o.nombre = 'Mi Empresa S.A.'
ON CONFLICT DO NOTHING;
