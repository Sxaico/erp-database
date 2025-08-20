CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ===== Usuarios / Roles =====
CREATE TABLE IF NOT EXISTS usuarios (
  id             SERIAL PRIMARY KEY,
  uuid           UUID NOT NULL DEFAULT gen_random_uuid(),
  email          TEXT NOT NULL UNIQUE,
  password_hash  TEXT NOT NULL,
  nombre         TEXT NOT NULL,
  apellido       TEXT NOT NULL,
  telefono       TEXT,
  activo         BOOLEAN NOT NULL DEFAULT TRUE,
  ultimo_login   TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at     TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS roles (
  id          SERIAL PRIMARY KEY,
  nombre      TEXT NOT NULL UNIQUE,
  descripcion TEXT,
  activo      BOOLEAN NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at  TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS usuario_roles (
  id           SERIAL PRIMARY KEY,
  usuario_id   INT NOT NULL REFERENCES usuarios(id) ON DELETE CASCADE,
  rol_id       INT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
  asignado_por INT REFERENCES usuarios(id),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- garantizar que no se dupliquen asignaciones usuario-rol
CREATE UNIQUE INDEX IF NOT EXISTS uq_usuario_roles_usuario_rol
  ON usuario_roles(usuario_id, rol_id);

-- Índices útiles
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON usuarios(email);
CREATE INDEX IF NOT EXISTS idx_usuarios_activo ON usuarios(activo) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_usuario_roles_usuario ON usuario_roles(usuario_id);
CREATE INDEX IF NOT EXISTS idx_usuario_roles_rol ON usuario_roles(rol_id);

-- ===== Organización / Departamentos =====
CREATE TABLE IF NOT EXISTS organizaciones (
  id            SERIAL PRIMARY KEY,
  uuid          UUID NOT NULL DEFAULT gen_random_uuid(),
  nombre        TEXT NOT NULL,
  razon_social  TEXT,
  rfc           TEXT,
  telefono      TEXT,
  email         TEXT,
  direccion     TEXT,
  ciudad        TEXT,
  estado        TEXT,
  codigo_postal TEXT,
  pais          TEXT NOT NULL DEFAULT 'Argentina',
  activa        BOOLEAN NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at    TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS departamentos (
  id                     SERIAL PRIMARY KEY,
  uuid                   UUID NOT NULL DEFAULT gen_random_uuid(),
  nombre                 TEXT NOT NULL,
  descripcion            TEXT,
  organizacion_id        INT REFERENCES organizaciones(id) ON DELETE CASCADE,
  departamento_padre_id  INT REFERENCES departamentos(id),
  responsable_id         INT REFERENCES usuarios(id),
  activo                 BOOLEAN NOT NULL DEFAULT TRUE,
  created_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at             TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS usuario_departamentos (
  id               SERIAL PRIMARY KEY,
  usuario_id       INT REFERENCES usuarios(id) ON DELETE CASCADE,
  departamento_id  INT REFERENCES departamentos(id) ON DELETE CASCADE,
  es_responsable   BOOLEAN NOT NULL DEFAULT FALSE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Índices parciales para soft delete
CREATE INDEX IF NOT EXISTS idx_orgs_activas ON organizaciones(id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_deptos_activos ON departamentos(id) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_usuario_deptos_usuario ON usuario_departamentos(usuario_id);
CREATE INDEX IF NOT EXISTS idx_usuario_deptos_depto ON usuario_departamentos(departamento_id);
