"""
Schemas Pydantic para autenticación y validación
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List
from datetime import datetime
import uuid


# ============================================
# SCHEMAS DE AUTENTICACIÓN
# ============================================

class LoginRequest(BaseModel):
    """Schema para login"""
    email: EmailStr
    password: str = Field(..., min_length=6, description="Contraseña mínimo 6 caracteres")


class LoginResponse(BaseModel):
    """Schema de respuesta de login"""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int
    user: "UsuarioResponse"


class RefreshTokenRequest(BaseModel):
    """Schema para refresh token"""
    refresh_token: str


class ChangePasswordRequest(BaseModel):
    """Schema para cambio de contraseña"""
    current_password: str
    new_password: str = Field(..., min_length=6)
    confirm_password: str


# ============================================
# SCHEMAS DE USUARIO
# ============================================

class UsuarioBase(BaseModel):
    """Schema base de usuario"""
    email: EmailStr
    nombre: str = Field(..., min_length=2, max_length=100)
    apellido: str = Field(..., min_length=2, max_length=100)
    telefono: Optional[str] = Field(None, max_length=20)


class UsuarioCreate(UsuarioBase):
    """Schema para crear usuario"""
    password: str = Field(..., min_length=6, description="Contraseña mínimo 6 caracteres")
    confirm_password: str
    roles: Optional[List[int]] = Field(default=[], description="IDs de roles")
    departamentos: Optional[List[int]] = Field(default=[], description="IDs de departamentos")

    class Config:
        json_schema_extra = {
            "example": {
                "email": "usuario@empresa.com",
                "nombre": "Juan",
                "apellido": "Pérez",
                "telefono": "+52 55 1234-5678",
                "password": "password123",
                "confirm_password": "password123",
                "roles": [3],  # ID del rol "Colaborador"
                "departamentos": [2]  # ID del departamento
            }
        }


class UsuarioUpdate(BaseModel):
    """Schema para actualizar usuario"""
    email: Optional[EmailStr] = None
    nombre: Optional[str] = Field(None, min_length=2, max_length=100)
    apellido: Optional[str] = Field(None, min_length=2, max_length=100)
    telefono: Optional[str] = Field(None, max_length=20)
    activo: Optional[bool] = None


class UsuarioResponse(BaseModel):
    """Schema de respuesta de usuario"""
    id: int
    uuid: uuid.UUID
    email: str
    nombre: str
    apellido: str
    nombre_completo: str
    telefono: Optional[str]
    activo: bool
    ultimo_login: Optional[datetime]
    created_at: datetime
    roles: List["RolResponse"] = []
    departamentos: List["DepartamentoSimple"] = []

    class Config:
        from_attributes = True


# ============================================
# SCHEMAS DE ROL
# ============================================

class RolBase(BaseModel):
    """Schema base de rol"""
    nombre: str = Field(..., min_length=2, max_length=50)
    descripcion: Optional[str] = None


class RolCreate(RolBase):
    """Schema para crear rol"""
    pass


class RolUpdate(BaseModel):
    """Schema para actualizar rol"""
    nombre: Optional[str] = Field(None, min_length=2, max_length=50)
    descripcion: Optional[str] = None
    activo: Optional[bool] = None


class RolResponse(BaseModel):
    """Schema de respuesta de rol"""
    id: int
    nombre: str
    descripcion: Optional[str]
    activo: bool
    created_at: datetime

    class Config:
        from_attributes = True


# ============================================
# SCHEMAS DE ORGANIZACIÓN
# ============================================

class OrganizacionBase(BaseModel):
    """Schema base de organización"""
    nombre: str = Field(..., min_length=2, max_length=255)
    razon_social: Optional[str] = Field(None, max_length=255)
    rfc: Optional[str] = Field(None, max_length=20)
    telefono: Optional[str] = Field(None, max_length=20)
    email: Optional[EmailStr] = None
    direccion: Optional[str] = None
    ciudad: Optional[str] = Field(None, max_length=100)
    estado: Optional[str] = Field(None, max_length=100)
    codigo_postal: Optional[str] = Field(None, max_length=10)
    pais: str = Field(default="Argentina", max_length=100)


class OrganizacionCreate(OrganizacionBase):
    """Schema para crear organización"""
    pass


class OrganizacionUpdate(BaseModel):
    """Schema para actualizar organización"""
    nombre: Optional[str] = Field(None, min_length=2, max_length=255)
    razon_social: Optional[str] = Field(None, max_length=255)
    rfc: Optional[str] = Field(None, max_length=20)
    telefono: Optional[str] = Field(None, max_length=20)
    email: Optional[EmailStr] = None
    direccion: Optional[str] = None
    ciudad: Optional[str] = Field(None, max_length=100)
    estado: Optional[str] = Field(None, max_length=100)
    codigo_postal: Optional[str] = Field(None, max_length=10)
    pais: Optional[str] = Field(None, max_length=100)
    activa: Optional[bool] = None


class OrganizacionResponse(BaseModel):
    """Schema de respuesta de organización"""
    id: int
    uuid: uuid.UUID
    nombre: str
    razon_social: Optional[str]
    rfc: Optional[str]
    telefono: Optional[str]
    email: Optional[str]
    direccion: Optional[str]
    ciudad: Optional[str]
    estado: Optional[str]
    codigo_postal: Optional[str]
    pais: str
    activa: bool
    created_at: datetime

    class Config:
        from_attributes = True


# ============================================
# SCHEMAS DE DEPARTAMENTO
# ============================================

class DepartamentoBase(BaseModel):
    """Schema base de departamento"""
    nombre: str = Field(..., min_length=2, max_length=100)
    descripcion: Optional[str] = None


class DepartamentoCreate(DepartamentoBase):
    """Schema para crear departamento"""
    organizacion_id: int
    departamento_padre_id: Optional[int] = None
    responsable_id: Optional[int] = None


class DepartamentoUpdate(BaseModel):
    """Schema para actualizar departamento"""
    nombre: Optional[str] = Field(None, min_length=2, max_length=100)
    descripcion: Optional[str] = None
    responsable_id: Optional[int] = None
    activo: Optional[bool] = None


class DepartamentoSimple(BaseModel):
    """Schema simple de departamento"""
    id: int
    nombre: str
    descripcion: Optional[str]

    class Config:
        from_attributes = True


class DepartamentoResponse(BaseModel):
    """Schema de respuesta de departamento"""
    id: int
    uuid: uuid.UUID
    nombre: str
    descripcion: Optional[str]
    organizacion_id: int
    departamento_padre_id: Optional[int]
    responsable_id: Optional[int]
    activo: bool
    created_at: datetime
    responsable: Optional["UsuarioResponse"] = None

    class Config:
        from_attributes = True


# ============================================
# SCHEMAS GENERALES
# ============================================

class MessageResponse(BaseModel):
    """Schema para respuestas de mensaje"""
    message: str
    success: bool = True


class ErrorResponse(BaseModel):
    """Schema para respuestas de error"""
    detail: str
    error_code: Optional[str] = None
    success: bool = False


class PaginatedResponse(BaseModel):
    """Schema para respuestas paginadas"""
    items: List[BaseModel]
    total: int
    page: int = 1
    per_page: int = 50
    pages: int
    has_next: bool
    has_prev: bool


# ============================================
# CONFIGURAR FORWARD REFERENCES
# ============================================

# Actualizar forward references
UsuarioResponse.model_rebuild()
LoginResponse.model_rebuild()
DepartamentoResponse.model_rebuild()
