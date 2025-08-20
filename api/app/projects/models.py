# api/app/projects/models.py

from sqlalchemy import Column, Integer, String, Text, Boolean, Date, DateTime, Numeric, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from ..database import Base
import uuid


class Proyecto(Base):
    __tablename__ = "proyectos"
    
    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid.uuid4, unique=True, index=True)
    codigo = Column(String, unique=True)
    nombre = Column(String, nullable=False)
    descripcion = Column(Text)
    organizacion_id = Column(Integer, ForeignKey("organizaciones.id", ondelete="SET NULL"))
    gerente_proyecto_id = Column(Integer, ForeignKey("usuarios.id", ondelete="SET NULL"))
    sponsor_id = Column(Integer, ForeignKey("usuarios.id", ondelete="SET NULL"))
    prioridad = Column(Integer, default=3)
    estado = Column(String, default="EN_PROGRESO")
    presupuesto_monto = Column(Numeric(14, 2), default=0)
    avance_pct = Column(Numeric(5, 2), default=0)
    fecha_inicio = Column(Date)
    fecha_fin_plan = Column(Date)
    fecha_fin_real = Column(Date)
    activo = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True))

    # Relaciones
    tareas = relationship("Tarea", back_populates="proyecto")
    # Nota: Las relaciones con Usuario y Organizacion se definirán mediante foreign_keys
    # cuando se importen todos los modelos en main.py

    def __repr__(self):
        return f"<Proyecto(id={self.id}, nombre='{self.nombre}')>"


class Tarea(Base):
    __tablename__ = "tareas"
    
    id = Column(Integer, primary_key=True, index=True)
    uuid = Column(UUID(as_uuid=True), default=uuid.uuid4, unique=True, index=True)
    proyecto_id = Column(Integer, ForeignKey("proyectos.id", ondelete="CASCADE"), nullable=False)
    titulo = Column(String, nullable=False)
    descripcion = Column(Text)
    estado = Column(String, default="PENDIENTE")
    prioridad = Column(Integer, default=3)
    asignado_a = Column(Integer, ForeignKey("usuarios.id", ondelete="SET NULL"))
    estimado_horas = Column(Numeric(10, 2), default=0)
    real_horas = Column(Numeric(10, 2), default=0)
    fecha_inicio = Column(Date)
    fecha_fin_plan = Column(Date)
    fecha_fin_real = Column(Date)
    activo = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    deleted_at = Column(DateTime(timezone=True))

    # Relaciones
    proyecto = relationship("Proyecto", back_populates="tareas")
    # Relación con Usuario se definirá después

    def __repr__(self):
        return f"<Tarea(id={self.id}, titulo='{self.titulo}')>"