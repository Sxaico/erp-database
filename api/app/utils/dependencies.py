# api/app/utils/dependencies.py
from typing import Optional, Callable
import logging
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload
from sqlalchemy import select

from ..database import get_async_db
from ..auth.models import Usuario
from ..utils.security import get_user_id_from_token

logger = logging.getLogger(__name__)

security = HTTPBearer(auto_error=True)
optional_security = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_async_db),
) -> Usuario:
    """
    Devuelve el usuario autenticado a partir del token.
    """
    try:
        user_id = get_user_id_from_token(credentials.credentials)

        stmt = (
            select(Usuario)
            .options(
                selectinload(Usuario.roles),
                selectinload(Usuario.departamentos),
            )
            .where(Usuario.id == user_id, Usuario.activo == True)
        )

        result = await db.execute(stmt)
        user = result.scalar_one_or_none()
        if user is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Usuario no encontrado o inactivo",
            )
        return user
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Error obteniendo usuario actual: %s", e)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Credenciales inválidas"
        ) from e


async def get_current_active_user(
    current_user: Usuario = Depends(get_current_user),
) -> Usuario:
    if not current_user.activo:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Usuario inactivo"
        )
    return current_user


def require_roles(*required_roles: str) -> Callable[..., Usuario]:
    """
    Dependencia para exigir uno de los roles indicados.
    """
    async def checker(
        current_user: Usuario = Depends(get_current_active_user),
    ) -> Usuario:
        user_roles = [r.nombre for r in current_user.roles if r and r.activo]
        if not any(role in user_roles for role in required_roles):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Se requiere uno de los roles: {', '.join(required_roles)}",
            )
        return current_user

    return checker


def require_permissions(*permissions: str) -> Callable[..., Usuario]:
    """
    Dependencia sencilla basada en roles -> permisos.
    """
    perm_map = {
        "read:users": ["Admin", "Gerente de Proyecto", "Líder de Equipo"],
        "write:users": ["Super Admin", "Admin"],
        "read:projects": ["Admin", "Gerente de Proyecto", "Líder de Equipo", "Colaborador"],
        "write:projects": ["Admin", "Gerente de Proyecto"],
        "read:tasks": ["Admin", "Gerente de Proyecto", "Líder de Equipo", "Colaborador"],
        "write:tasks": ["Admin", "Gerente de Proyecto", "Líder de Equipo"],
        "read:reports": ["Admin", "Gerente de Proyecto"],
        "write:reports": ["Admin", "Gerente de Proyecto"],
    }

    async def checker(
        current_user: Usuario = Depends(get_current_active_user),
    ) -> Usuario:
        user_roles = [r.nombre for r in current_user.roles if r and r.activo]
        if "Super Admin" in user_roles:
            return current_user

        for p in permissions:
            allowed = perm_map.get(p, [])
            if not any(r in user_roles for r in allowed):
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"Permisos insuficientes. Falta: {p}",
                )
        return current_user

    return checker


async def get_optional_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(optional_security),
    db: AsyncSession = Depends(get_async_db),
) -> Optional[Usuario]:
    """
    Devuelve el usuario si trae token; si no, None.
    """
    if not credentials:
        return None
    try:
        return await get_current_user(credentials, db)
    except Exception:
        return None


class Pagination:
    """
    Paginación simple: limita per_page a [1..100]
    """
    def __init__(self, page: int = 1, per_page: int = 50):
        self.page = max(1, page)
        self.per_page = min(max(1, per_page), 100)
        self.offset = (self.page - 1) * self.per_page

    def params(self) -> dict:
        return {"limit": self.per_page, "offset": self.offset}


def get_pagination(page: int = 1, per_page: int = 50) -> Pagination:
    """
    Dependencia que devuelve un objeto Pagination.
    """
    return Pagination(page, per_page)
