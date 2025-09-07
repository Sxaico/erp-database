-- 07-sample-collaborators.sql 
CREATE EXTENSION IF NOT EXISTS pgcrypto; 
-- Asegurar rol Colaborador 
INSERT INTO roles (nombre, descripcion) VALUES ('Colaborador','Usuario colaborador básico') ON CONFLICT (nombre) DO NOTHING;
-- Tres cuentas demo (password: user123) 
INSERT INTO usuarios (email, password_hash, nombre, apellido, activo) VALUES 
('colab1@miempresa.com', crypt('user123', gen_salt('bf')), 'Colab', 'Uno', TRUE), 
('colab2@miempresa.com', crypt('user123', gen_salt('bf')), 'Colab', 'Dos', TRUE), 
('colab3@miempresa.com', crypt('user123', gen_salt('bf')), 'Colab', 'Tres', TRUE) 
ON CONFLICT (email) DO NOTHING; 
-- Asignar rol Colaborador 
INSERT INTO usuario_roles (usuario_id, rol_id) 
SELECT u.id, r.id 
FROM usuarios u 
JOIN roles r ON r.nombre='Colaborador' 
WHERE u.email IN ('colab1@miempresa.com','colab2@miempresa.com','colab3@miempresa.com') 
ON CONFLICT (usuario_id, rol_id) DO NOTHING;