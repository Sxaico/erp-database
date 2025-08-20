-- init-scripts/05-initial-data.sql (FIX)

-- Roles básicos
INSERT INTO roles (nombre, descripcion) VALUES
('Super Admin','Administrador del sistema con todos los permisos'),
('Admin','Administrador con permisos de gestión'),
('Gerente de Proyecto','Gestor de proyectos y equipos'),
('Líder de Equipo','Líder de equipos de trabajo'),
('Colaborador','Usuario colaborador básico')
ON CONFLICT (nombre) DO NOTHING;

-- Usuario admin consistente con la API (usa pgcrypto para bcrypt)
-- Email: admin@miempresa.com  |  Pass: admin123
INSERT INTO usuarios (email, password_hash, nombre, apellido)
VALUES ('admin@miempresa.com', crypt('admin123', gen_salt('bf')), 'Administrador', 'Sistema')
ON CONFLICT (email) DO UPDATE
SET password_hash = EXCLUDED.password_hash,
    nombre = EXCLUDED.nombre,
    apellido = EXCLUDED.apellido,
    activo = TRUE;

-- Asignar rol Super Admin al admin
INSERT INTO usuario_roles (usuario_id, rol_id)
SELECT u.id, r.id
FROM usuarios u
JOIN roles r ON r.nombre = 'Super Admin'
WHERE u.email = 'admin@miempresa.com'
-- si vuelves a correr, evita duplicar con un filtro
AND NOT EXISTS (
  SELECT 1 FROM usuario_roles ur WHERE ur.usuario_id = u.id AND ur.rol_id = r.id
);

-- Org demo
INSERT INTO organizaciones (nombre, razon_social, pais)
VALUES ('Mi Empresa S.A.', 'Mi Empresa Sociedad Anónima', 'Argentina')
ON CONFLICT DO NOTHING;

-- Depto demo
INSERT INTO departamentos (nombre, descripcion, organizacion_id)
SELECT 'Sistemas', 'Departamento de Tecnología', o.id
FROM organizaciones o
WHERE o.nombre = 'Mi Empresa S.A.'
AND NOT EXISTS (
  SELECT 1 FROM departamentos d WHERE d.nombre = 'Sistemas' AND d.organizacion_id = o.id
);
