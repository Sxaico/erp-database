# api/app/projects/schemas.py
from pydantic import BaseModel, Field
from typing import Optional
from datetime import date
import uuid

class ProyectoCreate(BaseModel):
    codigo: Optional[str] = None
    nombre: str = Field(..., min_length=2)
    descripcion: Optional[str] = None
    prioridad: Optional[int] = 3

class ProyectoUpdate(BaseModel):
    nombre: Optional[str] = None
    descripcion: Optional[str] = None
    prioridad: Optional[int] = None
    estado: Optional[str] = None
    presupuesto_monto: Optional[float] = None
    avance_pct: Optional[float] = None
    fecha_inicio: Optional[date] = None
    fecha_fin_plan: Optional[date] = None
    fecha_fin_real: Optional[date] = None

class ProyectoResponse(BaseModel):
    id: int
    uuid: uuid.UUID
    codigo: Optional[str]
    nombre: str
    estado: str
    prioridad: int
    avance_pct: float | None
    presupuesto_monto: float | None
    class Config:
        from_attributes = True

class TareaCreate(BaseModel):
    proyecto_id: int
    titulo: str
    descripcion: Optional[str] = None
    prioridad: Optional[int] = 3

class TareaUpdate(BaseModel):
    titulo: Optional[str] = None
    descripcion: Optional[str] = None
    prioridad: Optional[int] = None
    estado: Optional[str] = None
    real_horas: Optional[float] = None
    fecha_fin_real: Optional[date] = None

class TareaResponse(BaseModel):
    id: int
    uuid: uuid.UUID
    proyecto_id: int
    titulo: str
    estado: str
    prioridad: int
    real_horas: float | None
    class Config:
        from_attributes = True

class ResumenEstadoItem(BaseModel):
    proyecto_id: int
    proyecto: str
    estado: str
    cantidad: int
