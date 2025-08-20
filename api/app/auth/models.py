"""
Modelos SQLAlchemy para autenticación (relaciones desambiguadas)
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..database import Base
import uuid


class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid.uuid4, unique=True, index=True)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    nombre = Column(String(100), nullable=False)
    apellido = Column(String(100), nullable=False)
    telefono = Column(String(20))
    activo = Column(Boolean, default=True)
    ultimo_login = Column(DateTime(timezone=True))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True))

    # ---- Relaciones con Roles ----
    # Asignaciones (tabla puente) para crear/borrar
    usuario_roles = relationship(
        "UsuarioRol",
        back_populates="usuario",
        foreign_keys="UsuarioRol.usuario_id",
        cascade="all, delete-orphan",
        lazy="selectin",
        overlaps="usuario,usuarios,roles"
    )
    # Vista M2M de roles (solo lectura)
    roles = relationship(
        "Rol",
        secondary="usuario_roles",
        primaryjoin="Usuario.id == UsuarioRol.usuario_id",
        secondaryjoin="Rol.id == UsuarioRol.rol_id",
        back_populates="usuarios",
        viewonly=True,
        lazy="selectin",
        overlaps="usuario_roles,usuarios"
    )

    # ---- Relaciones con Departamentos ----
    usuario_departamentos = relationship(
        "UsuarioDepartamento",
        back_populates="usuario",
        foreign_keys="UsuarioDepartamento.usuario_id",
        cascade="all, delete-orphan",
        lazy="selectin",
        overlaps="usuario,usuarios,departamentos"
    )
    departamentos = relationship(
        "Departamento",
        secondary="usuario_departamentos",
        primaryjoin="Usuario.id == UsuarioDepartamento.usuario_id",
        secondaryjoin="Departamento.id == UsuarioDepartamento.departamento_id",
        back_populates="usuarios",
        viewonly=True,
        lazy="selectin",
        overlaps="usuario_departamentos,usuarios"
    )

    def __repr__(self):
        return f"<Usuario(id={self.id}, email='{self.email}', nombre='{self.nombre}')>"

    @property
    def nombre_completo(self) -> str:
        return f"{self.nombre} {self.apellido}"


class Rol(Base):
    __tablename__ = "roles"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(50), unique=True, nullable=False)
    descripcion = Column(Text)
    activo = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True))

    # Asignaciones (tabla puente)
    usuario_roles = relationship(
        "UsuarioRol",
        back_populates="rol",
        lazy="selectin",
        cascade="all, delete-orphan",
        overlaps="rol,roles,usuarios"
    )
    # Usuarios con este rol (solo lectura)
    usuarios = relationship(
        "Usuario",
        secondary="usuario_roles",
        primaryjoin="Rol.id == UsuarioRol.rol_id",
        secondaryjoin="Usuario.id == UsuarioRol.usuario_id",
        back_populates="roles",
        viewonly=True,
        lazy="selectin",
        overlaps="usuario_roles,roles"
    )

    def __repr__(self):
        return f"<Rol(id={self.id}, nombre='{self.nombre}')>"


class UsuarioRol(Base):
    __tablename__ = "usuario_roles"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id", ondelete="CASCADE"), nullable=False)
    rol_id = Column(Integer, ForeignKey("roles.id", ondelete="CASCADE"), nullable=False)
    asignado_por = Column(Integer, ForeignKey("usuarios.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relaciones
    usuario = relationship(
        "Usuario",
        foreign_keys=[usuario_id],
        back_populates="usuario_roles",
        overlaps="roles,usuarios"
    )
    rol = relationship(
        "Rol",
        back_populates="usuario_roles",
        overlaps="usuarios,roles"
    )
    asignado_por_usuario = relationship(
        "Usuario",
        foreign_keys=[asignado_por]
    )

    def __repr__(self):
        return f"<UsuarioRol(usuario_id={self.usuario_id}, rol_id={self.rol_id})>"


class Organizacion(Base):
    __tablename__ = "organizaciones"

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid.uuid4, unique=True, index=True)
    nombre = Column(String(255), nullable=False)
    razon_social = Column(String(255))
    rfc = Column(String(20))
    telefono = Column(String(20))
    email = Column(String(255))
    direccion = Column(Text)
    ciudad = Column(String(100))
    estado = Column(String(100))
    codigo_postal = Column(String(10))
    pais = Column(String(100), default="Argentina")
    activa = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True))

    departamentos = relationship("Departamento", back_populates="organizacion", lazy="selectin")

    def __repr__(self):
        return f"<Organizacion(id={self.id}, nombre='{self.nombre}')>"


class Departamento(Base):
    __tablename__ = "departamentos"

    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid.uuid4, unique=True, index=True)
    nombre = Column(String(100), nullable=False)
    descripcion = Column(Text)
    organizacion_id = Column(Integer, ForeignKey("organizaciones.id", ondelete="CASCADE"))
    departamento_padre_id = Column(Integer, ForeignKey("departamentos.id"))
    responsable_id = Column(Integer, ForeignKey("usuarios.id"))
    activo = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True))

    organizacion = relationship("Organizacion", back_populates="departamentos", lazy="joined")
    responsable = relationship("Usuario")
    departamento_padre = relationship("Departamento", remote_side="Departamento.id")
    # Asignaciones (tabla puente)
    usuarios_asignaciones = relationship(
        "UsuarioDepartamento",
        back_populates="departamento",
        lazy="selectin",
        cascade="all, delete-orphan",
        overlaps="departamento,usuarios"
    )
    # Usuarios (solo lectura)
    usuarios = relationship(
        "Usuario",
        secondary="usuario_departamentos",
        primaryjoin="Departamento.id == UsuarioDepartamento.departamento_id",
        secondaryjoin="Usuario.id == UsuarioDepartamento.usuario_id",
        back_populates="departamentos",
        viewonly=True,
        lazy="selectin",
        overlaps="usuarios_asignaciones,departamentos"
    )

    def __repr__(self):
        return f"<Departamento(id={self.id}, nombre='{self.nombre}')>"


class UsuarioDepartamento(Base):
    __tablename__ = "usuario_departamentos"

    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id", ondelete="CASCADE"))
    departamento_id = Column(Integer, ForeignKey("departamentos.id", ondelete="CASCADE"))
    es_responsable = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    usuario = relationship(
        "Usuario",
        back_populates="usuario_departamentos",
        foreign_keys=[usuario_id],
        overlaps="departamentos,usuarios"
    )
    departamento = relationship(
        "Departamento",
        back_populates="usuarios_asignaciones",
        foreign_keys=[departamento_id],
        overlaps="usuarios,departamentos"
    )

    def __repr__(self):
        return f"<UsuarioDepartamento(usuario_id={self.usuario_id}, departamento_id={self.departamento_id})>"
