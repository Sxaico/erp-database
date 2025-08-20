"""
Rutas de autenticación
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from sqlalchemy import select, and_
from datetime import datetime, timedelta
from typing import List
import logging

from ..database import get_async_db
from ..utils.security import verify_password, get_password_hash, create_access_token, create_refresh_token
from ..utils.dependencies import get_current_active_user, require_roles, get_pagination, Pagination
from ..config import settings
from .models import Usuario, Rol, UsuarioRol
from .schemas import (
    LoginRequest, LoginResponse, UsuarioCreate, UsuarioUpdate, UsuarioResponse,
    MessageResponse, ChangePasswordRequest, RolCreate, RolResponse, RolUpdate
)

logger = logging.getLogger(__name__)

# Router de autenticación
auth_router = APIRouter()


@auth_router.post("/login", response_model=LoginResponse)
async def login(
    login_data: LoginRequest,
    db: AsyncSession = Depends(get_async_db)
):
    """
    Autenticar usuario y generar tokens JWT
    """
    try:
        # Buscar usuario por email con sus roles
        stmt = select(Usuario).options(
            selectinload(Usuario.roles).selectinload("rol")
        ).where(
            and_(
                Usuario.email == login_data.email.lower(),
                Usuario.activo == True
            )
        )
        
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        
        # Verificar usuario y contraseña
        if not user or not verify_password(login_data.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Credenciales incorrectas",
                headers={"WWW-Authenticate": "Bearer"},
            )
        
        # Actualizar último login
        user.ultimo_login = datetime.utcnow()
        await db.commit()
        
        # Generar tokens
        access_token = create_access_token(data={"sub": str(user.id)})
        refresh_token = create_refresh_token(user.id)
        
        # Preparar respuesta
        user_response = UsuarioResponse.model_validate(user)
        
        logger.info(f"Usuario {user.email} autenticado correctamente")
        
        return LoginResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            user=user_response
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error en login: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error interno del servidor"
        )


@auth_router.get("/me", response_model=UsuarioResponse)
async def get_current_user_info(
    current_user: Usuario = Depends(get_current_active_user)
):
    """
    Obtener información del usuario actual
    """
    return UsuarioResponse.model_validate(current_user)


@auth_router.put("/me", response_model=UsuarioResponse)
async def update_current_user(
    user_update: UsuarioUpdate,
    current_user: Usuario = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_async_db)
):
    """
    Actualizar información del usuario actual
    """
    try:
        # Actualizar campos
        update_data = user_update.model_dump(exclude_unset=True)
        
        for field, value in update_data.items():
            if field == "email":
                # Verificar que el email no esté en uso
                stmt = select(Usuario).where(
                    and_(
                        Usuario.email == value.lower(),
                        Usuario.id != current_user.id
                    )
                )
                result = await db.execute(stmt)
                if result.scalar_one_or_none():
                    raise HTTPException(
                        status_code=status.HTTP_400_BAD_REQUEST,
                        detail="El email ya está en uso"
                    )
                setattr(current_user, field, value.lower())
            else:
                setattr(current_user, field, value)
        
        await db.commit()
        await db.refresh(current_user)
        
        logger.info(f"Usuario {current_user.email} actualizado")
        return UsuarioResponse.model_validate(current_user)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error al actualizar usuario: {str(e)}")
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al actualizar usuario"
        )


@auth_router.post("/change-password", response_model=MessageResponse)
async def change_password(
    password_data: ChangePasswordRequest,
    current_user: Usuario = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_async_db)
):
    """
    Cambiar contraseña del usuario actual
    """
    try:
        # Verificar contraseña actual
        if not verify_password(password_data.current_password, current_user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Contraseña actual incorrecta"
            )
        
        # Verificar que las contraseñas coincidan
        if password_data.new_password != password_data.confirm_password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Las contraseñas nuevas no coinciden"
            )
        
        # Actualizar contraseña
        current_user.password_hash = get_password_hash(password_data.new_password)
        await db.commit()
        
        logger.info(f"Contraseña cambiada para usuario {current_user.email}")
        return MessageResponse(message="Contraseña actualizada correctamente")
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error al cambiar contraseña: {str(e)}")
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al cambiar contraseña"
        )


# ============================================
# GESTIÓN DE USUARIOS (Solo Admins)
# ============================================

@auth_router.post("/users", response_model=UsuarioResponse)
async def create_user(
    user_data: UsuarioCreate,
    db: AsyncSession = Depends(get_async_db),
    current_user: Usuario = Depends(require_roles("Super Admin", "Admin"))
):
    """
    Crear nuevo usuario (Solo admins)
    """
    try:
        # Verificar que las contraseñas coincidan
        if user_data.password != user_data.confirm_password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Las contraseñas no coinciden"
            )
        
        # Verificar que el email no exista
        stmt = select(Usuario).where(Usuario.email == user_data.email.lower())
        result = await db.execute(stmt)
        if result.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El email ya está registrado"
            )
        
        # Crear usuario
        new_user = Usuario(
            email=user_data.email.lower(),
            password_hash=get_password_hash(user_data.password),
            nombre=user_data.nombre,
            apellido=user_data.apellido,
            telefono=user_data.telefono
        )
        
        db.add(new_user)
        await db.flush()  # Para obtener el ID
        
        # Asignar roles si se proporcionaron
        for role_id in user_data.roles:
            # Verificar que el rol existe
            stmt = select(Rol).where(and_(Rol.id == role_id, Rol.activo == True))
            result = await db.execute(stmt)
            role = result.scalar_one_or_none()
            
            if role:
                user_role = UsuarioRol(
                    usuario_id=new_user.id,
                    rol_id=role_id,
                    asignado_por=current_user.id
                )
                db.add(user_role)
        
        await db.commit()
        await db.refresh(new_user)
        
        # Cargar relaciones
        stmt = select(Usuario).options(
            selectinload(Usuario.roles).selectinload("rol")
        ).where(Usuario.id == new_user.id)
        result = await db.execute(stmt)
        user_with_relations = result.scalar_one()
        
        logger.info(f"Usuario creado: {new_user.email} por {current_user.email}")
        return UsuarioResponse.model_validate(user_with_relations)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error al crear usuario: {str(e)}")
        await db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al crear usuario"
        )


@auth_router.get("/users", response_model=List[UsuarioResponse])
async def list_users(
    pagination: Pagination = Depends(get_pagination),
    db: AsyncSession = Depends(get_async_db),
    current_user: Usuario = Depends(require_roles("Super Admin", "Admin"))
):
    """
    Listar usuarios (Solo admins)
    """
    try:
        stmt = select(Usuario).options(
            selectinload(Usuario.roles).selectinload("rol")
        ).offset(pagination.offset).limit(pagination.per_page)
        
        result = await db.execute(stmt)
        users = result.scalars().all()
        
        return [UsuarioResponse.model_validate(user) for user in users]
        
    except Exception as e:
        logger.error(f"Error al listar usuarios: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al obtener usuarios"
        )


# ============================================
# GESTIÓN DE ROLES (Solo Admins)
# ============================================

@auth_router.get("/roles", response_model=List[RolResponse])
async def list_roles(
    db: AsyncSession = Depends(get_async_db),
    current_user: Usuario = Depends(get_current_active_user)
):
    """
    Listar roles disponibles
    """
    try:
        stmt = select(Rol).where(Rol.activo == True)
        result = await db.execute(stmt)
        roles = result.scalars().all()
        
        return [RolResponse.model_validate(role) for role in roles]
        
    except Exception as e:
        logger.error(f"Error al listar roles: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al obtener roles"
        )