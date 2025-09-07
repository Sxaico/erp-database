"""
Rutas de autenticación
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from sqlalchemy import select, and_
from datetime import datetime, timezone
from typing import List
import logging

from ..database import get_async_db
from ..utils.security import (
    verify_password, get_password_hash,
    create_access_token, create_refresh_token,
    get_user_id_from_refresh_token
)
from ..utils.dependencies import get_current_active_user, require_roles, get_pagination, Pagination
from ..config import settings
from .models import Usuario, Rol, UsuarioRol
from .schemas import (
    LoginRequest, LoginResponse, UsuarioCreate, UsuarioUpdate, UsuarioResponse,
    MessageResponse, ChangePasswordRequest, RolCreate, RolResponse, RolUpdate,
    RefreshTokenRequest
)

logger = logging.getLogger(__name__)

auth_router = APIRouter()


@auth_router.post("/login", response_model=LoginResponse)
async def login(
    login_data: LoginRequest,
    db: AsyncSession = Depends(get_async_db)
):
    try:
        stmt = (
            select(Usuario)
            .options(
                selectinload(Usuario.roles),
                selectinload(Usuario.departamentos),
            )
            .where(
                and_(
                    Usuario.email == login_data.email.lower(),
                    Usuario.activo == True
                )
            )
        )

        result = await db.execute(stmt)
        user = result.scalar_one_or_none()

        if not user or not verify_password(login_data.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Credenciales incorrectas",
                headers={"WWW-Authenticate": "Bearer"},
            )

        user.ultimo_login = datetime.now(timezone.utc)
        await db.commit()

        access_token = create_access_token(data={"sub": str(user.id)})
        refresh_token = create_refresh_token(user.id)

        user_response = UsuarioResponse.model_validate(user)
        logger.info(f"Usuario {user.email} autenticado correctamente")

        return LoginResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=settings.access_token_expire_minutes * 60,
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


@auth_router.post("/refresh", response_model=LoginResponse)
async def refresh_token(
    data: RefreshTokenRequest,
    db: AsyncSession = Depends(get_async_db)
):
    """
    Recibe refresh_token válido, devuelve nuevo access_token y **rota** refresh_token.
    """
    try:
        user_id = get_user_id_from_refresh_token(data.refresh_token)

        stmt = (
            select(Usuario)
            .options(
                selectinload(Usuario.roles),
                selectinload(Usuario.departamentos),
            )
            .where(and_(Usuario.id == user_id, Usuario.activo == True))
        )
        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        if not user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Refresh inválido o usuario inactivo"
            )

        # Generar tokens
        access_token = create_access_token({"sub": str(user.id)})
        new_refresh_token = create_refresh_token(user.id)

        return LoginResponse(
            access_token=access_token,
            refresh_token=new_refresh_token,  # rotación
            expires_in=settings.access_token_expire_minutes * 60,
            user=UsuarioResponse.model_validate(user)
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error en refresh: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Refresh token inválido o expirado"
        )


@auth_router.get("/me", response_model=UsuarioResponse)
async def get_current_user_info(
    current_user: Usuario = Depends(get_current_active_user)
):
    return UsuarioResponse.model_validate(current_user)


@auth_router.put("/me", response_model=UsuarioResponse)
async def update_current_user(
    user_update: UsuarioUpdate,
    current_user: Usuario = Depends(get_current_active_user),
    db: AsyncSession = Depends(get_async_db)
):
    try:
        update_data = user_update.model_dump(exclude_unset=True)

        for field, value in update_data.items():
            if field == "email":
                stmt = select(Usuario).where(
                    and_(Usuario.email == value.lower(), Usuario.id != current_user.id)
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
    try:
        if not verify_password(password_data.current_password, current_user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Contraseña actual incorrecta"
            )

        if password_data.new_password != password_data.confirm_password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Las contraseñas nuevas no coinciden"
            )

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
    try:
        if user_data.password != user_data.confirm_password:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Las contraseñas no coinciden"
            )

        stmt = select(Usuario).where(Usuario.email == user_data.email.lower())
        result = await db.execute(stmt)
        if result.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="El email ya está registrado"
            )

        new_user = Usuario(
            email=user_data.email.lower(),
            password_hash=get_password_hash(user_data.password),
            nombre=user_data.nombre,
            apellido=user_data.apellido,
            telefono=user_data.telefono
        )
        db.add(new_user)
        await db.flush()

        # Asignar roles
        for role_id in (user_data.roles or []):
            role = (await db.execute(select(Rol).where(and_(Rol.id == role_id, Rol.activo == True)))).scalar_one_or_none()
            if role:
                db.add(UsuarioRol(usuario_id=new_user.id, rol_id=role_id, asignado_por=current_user.id))

        await db.commit()
        await db.refresh(new_user)

        new_user = (await db.execute(
            select(Usuario)
            .options(selectinload(Usuario.roles), selectinload(Usuario.departamentos))
            .where(Usuario.id == new_user.id))
        ).scalar_one()

        logger.info(f"Usuario creado: {new_user.email} por {current_user.email}")
        return UsuarioResponse.model_validate(new_user)

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
    try:
        stmt = (
            select(Usuario)
            .options(selectinload(Usuario.roles), selectinload(Usuario.departamentos))
            .offset(pagination.offset).limit(pagination.per_page)
        )
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
# GESTIÓN DE ROLES
# ============================================

@auth_router.get("/roles", response_model=List[RolResponse])
async def list_roles(
    db: AsyncSession = Depends(get_async_db),
    current_user: Usuario = Depends(get_current_active_user)
):
    try:
        roles = (await db.execute(select(Rol).where(Rol.activo == True))).scalars().all()
        return [RolResponse.model_validate(role) for role in roles]
    except Exception as e:
        logger.error(f"Error al listar roles: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al obtener roles"
        )
