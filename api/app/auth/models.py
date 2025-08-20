"""
Modelos SQLAlchemy para autenticación
"""

from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..database import Base
import uuid


class Usuario(Base):
    """Modelo de Usuario"""
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

    # Relaciones
    roles = relationship("UsuarioRol", back_populates="usuario")
    departamentos = relationship("UsuarioDepartamento", back_populates="usuario")

    def __repr__(self):
        return f"<Usuario(id={self.id}, email='{self.email}', nombre='{self.nombre}')>"

    @property
    def nombre_completo(self):
        return f"{self.nombre} {self.apellido}"


class Rol(Base):
    """Modelo de Rol"""
    __tablename__ = "roles"
    
    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String(50), unique=True, nullable=False)
    descripcion = Column(Text)
    activo = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True))

    # Relaciones
    usuarios = relationship("UsuarioRol", back_populates="rol")

    def __repr__(self):
        return f"<Rol(id={self.id}, nombre='{self.nombre}')>"


class UsuarioRol(Base):
    """Tabla intermedia Usuario-Rol"""
    __tablename__ = "usuario_roles"
    
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id", ondelete="CASCADE"), nullable=False)
    rol_id = Column(Integer, ForeignKey("roles.id", ondelete="CASCADE"), nullable=False)
    asignado_por = Column(Integer, ForeignKey("usuarios.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relaciones
    usuario = relationship("Usuario", foreign_keys=[usuario_id], back_populates="roles")
    rol = relationship("Rol", back_populates="usuarios")
    asignado_por_usuario = relationship("Usuario", foreign_keys=[asignado_por])

    def __repr__(self):
        return f"<UsuarioRol(usuario_id={self.usuario_id}, rol_id={self.rol_id})>"


class Organizacion(Base):
    """Modelo de Organización"""
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
    pais = Column(String(100), default="Argentina")  # Cambiado de México a Argentina
    activa = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True))

    # Relaciones
    departamentos = relationship("Departamento", back_populates="organizacion")

    def __repr__(self):
        return f"<Organizacion(id={self.id}, nombre='{self.nombre}')>"


class Departamento(Base):
    """Modelo de Departamento"""
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

    # Relaciones
    organizacion = relationship("Organizacion", back_populates="departamentos")
    responsable = relationship("Usuario")
    departamento_padre = relationship("Departamento", remote_side="Departamento.id")
    usuarios = relationship("UsuarioDepartamento", back_populates="departamento")

    def __repr__(self):
        return f"<Departamento(id={self.id}, nombre='{self.nombre}')>"


class UsuarioDepartamento(Base):
    """Tabla intermedia Usuario-Departamento"""
    __tablename__ = "usuario_departamentos"
    
    id = Column(Integer, primary_key=True, index=True)
    usuario_id = Column(Integer, ForeignKey("usuarios.id", ondelete="CASCADE"))
    departamento_id = Column(Integer, ForeignKey("departamentos.id", ondelete="CASCADE"))
    es_responsable = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relaciones
    usuario = relationship("Usuario", back_populates="departamentos")
    departamento = relationship("Departamento", back_populates="usuarios")

    def __repr__(self):
        return f"<UsuarioDepartamento(usuario_id={self.usuario_id}, departamento_id={self.departamento_id})>"