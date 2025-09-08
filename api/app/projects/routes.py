# api/app/projects/routes.py
from fastapi import APIRouter, Depends, HTTPException, status, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from typing import Optional, List
from pydantic import BaseModel, EmailStr

from ..database import get_async_db
from ..utils.dependencies import get_current_active_user, require_permissions
from .models import Proyecto, Tarea
from .schemas import (
    ProyectoCreate, ProyectoUpdate, ProyectoResponse,
    TareaCreate, TareaUpdate, TareaResponse, ResumenEstadoItem
)

# IMPORTANTE: mantenemos este nombre porque main.py hace `from .projects import router`
router = APIRouter()

# --------------------------- Helpers de membresía/seguridad ---------------------------

async def _is_admin(db: AsyncSession, user_id: int) -> bool:
    q = text("""
        SELECT 1
        FROM usuario_roles ur
        JOIN roles r ON r.id = ur.rol_id
        WHERE ur.usuario_id = :uid AND r.nombre IN ('Super Admin','Admin')
        LIMIT 1
    """)
    return (await db.execute(q, {"uid": user_id})).scalar() is not None

async def _project_exists(db: AsyncSession, project_id: int) -> bool:
    q = text("SELECT 1 FROM proyectos WHERE id = :pid AND deleted_at IS NULL")
    return (await db.execute(q, {"pid": project_id})).scalar() is not None

async def _is_member(db: AsyncSession, project_id: int, user_id: int) -> bool:
    q = text("SELECT 1 FROM proyecto_miembros WHERE proyecto_id = :pid AND usuario_id = :uid")
    return (await db.execute(q, {"pid": project_id, "uid": user_id})).scalar() is not None

# --------------------------- Proyectos ---------------------------

@router.post("", response_model=ProyectoResponse)
async def create_project(
    data: ProyectoCreate,
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("write:projects"))
):
    p = Proyecto(
        codigo=data.codigo,
        nombre=data.nombre,
        descripcion=data.descripcion,
        prioridad=data.prioridad or 3
    )
    db.add(p)
    await db.flush()
    await db.commit()
    await db.refresh(p)
    return ProyectoResponse.model_validate(p)

@router.get("", response_model=list[ProyectoResponse], summary="Listar proyectos visibles")
async def list_projects(
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("read:projects"))
):
    # Admin ve todos; colaborador solo los que es miembro
    if await _is_admin(db, user.id):
        result = await db.execute(select(Proyecto).where(Proyecto.deleted_at.is_(None)))
        items = result.scalars().all()
        return [ProyectoResponse.model_validate(i) for i in items]
    else:
        q = text("""
            SELECT id, uuid, codigo, nombre, estado, prioridad, avance_pct, presupuesto_monto
            FROM proyectos p
            WHERE p.deleted_at IS NULL
              AND EXISTS (SELECT 1 FROM proyecto_miembros pm
                          WHERE pm.proyecto_id = p.id AND pm.usuario_id = :uid)
            ORDER BY id
        """)
        rows = (await db.execute(q, {"uid": user.id})).mappings().all()
        return [ProyectoResponse(**dict(r)) for r in rows]

@router.get("/{project_id}", response_model=ProyectoResponse, summary="Obtener proyecto si hay acceso")
async def get_project(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("read:projects"))
):
    if not await _project_exists(db, project_id):
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")

    if not (await _is_admin(db, user.id) or await _is_member(db, project_id, user.id)):
        raise HTTPException(status_code=403, detail="Sin acceso a este proyecto")

    result = await db.execute(select(Proyecto).where(Proyecto.id == project_id, Proyecto.deleted_at.is_(None)))
    p = result.scalar_one_or_none()
    if not p:
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")
    return ProyectoResponse.model_validate(p)

@router.patch("/{project_id}", response_model=ProyectoResponse)
async def update_project(
    project_id: int,
    data: ProyectoUpdate,
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("write:projects"))
):
    result = await db.execute(select(Proyecto).where(Proyecto.id == project_id, Proyecto.deleted_at.is_(None)))
    p = result.scalar_one_or_none()
    if not p:
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(p, k, v)
    await db.commit()
    await db.refresh(p)
    return ProyectoResponse.model_validate(p)

# --------------------------- Tareas ---------------------------

@router.post("/tasks", response_model=TareaResponse)
async def create_task(
    data: TareaCreate,
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("write:tasks"))
):
    # validar proyecto
    result = await db.execute(select(Proyecto.id).where(Proyecto.id == data.proyecto_id, Proyecto.deleted_at.is_(None)))
    if not result.scalar_one_or_none():
        raise HTTPException(status_code=404, detail="Proyecto no existe")
    t = Tarea(
        proyecto_id=data.proyecto_id,
        titulo=data.titulo,
        descripcion=data.descripcion,
        prioridad=data.prioridad or 3
    )
    db.add(t)
    await db.flush()
    await db.commit()
    await db.refresh(t)
    return TareaResponse.model_validate(t)

@router.get("/{project_id}/tasks", response_model=list[TareaResponse])
async def list_tasks(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("read:tasks"))
):
    # Nota: si quieres, puedes aplicar el mismo control de acceso que en get_project
    result = await db.execute(select(Tarea).where(Tarea.proyecto_id == project_id, Tarea.deleted_at.is_(None)))
    items = result.scalars().all()
    return [TareaResponse.model_validate(i) for i in items]

@router.patch("/tasks/{task_id}", response_model=TareaResponse)
async def update_task(
    task_id: int,
    data: TareaUpdate,
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("write:tasks"))
):
    result = await db.execute(select(Tarea).where(Tarea.id == task_id, Tarea.deleted_at.is_(None)))
    t = result.scalar_one_or_none()
    if not t:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(t, k, v)
    await db.commit()
    await db.refresh(t)
    return TareaResponse.model_validate(t)

# --------------------------- Reporte simple (vista) ---------------------------

@router.get("/{project_id}/report/estado", response_model=list[ResumenEstadoItem])
async def resumen_por_estado(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("read:reports"))
):
    q = text("""
        SELECT proyecto_id, proyecto, estado, cantidad
        FROM vw_resumen_tareas_por_estado
        WHERE proyecto_id = :pid
        ORDER BY estado
    """)
    result = await db.execute(q, {"pid": project_id})
    rows = result.mappings().all()
    return [ResumenEstadoItem(**dict(r)) for r in rows]

# --------------------------- Miembros del proyecto ---------------------------

class MemberCreate(BaseModel):
    usuario_id: Optional[int] = None
    email: Optional[EmailStr] = None

class MemberOut(BaseModel):
    id: int
    email: EmailStr
    nombre: Optional[str] = None
    apellido: Optional[str] = None
    rol_en_proyecto: str = "MIEMBRO"

@router.get("/{project_id}/members", response_model=List[MemberOut], summary="Listar miembros")
async def list_members(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("read:projects"))
):
    if not await _project_exists(db, project_id):
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")
    if not (await _is_admin(db, user.id) or await _is_member(db, project_id, user.id)):
        raise HTTPException(status_code=403, detail="Sin acceso a este proyecto")

    q = text("""
        SELECT u.id, u.email, u.nombre, u.apellido, pm.rol_en_proyecto
        FROM proyecto_miembros pm
        JOIN usuarios u ON u.id = pm.usuario_id
        WHERE pm.proyecto_id = :pid
        ORDER BY u.nombre, u.apellido, u.email
    """)
    rows = (await db.execute(q, {"pid": project_id})).mappings().all()
    return [MemberOut(**dict(r)) for r in rows]

@router.post("/{project_id}/members", response_model=MemberOut, status_code=201, summary="Agregar miembro (solo Admin)")
async def add_member(
    project_id: int,
    payload: MemberCreate,
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("write:projects"))
):
    if not await _project_exists(db, project_id):
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")
    if not await _is_admin(db, user.id):
        raise HTTPException(status_code=403, detail="Solo Admin puede agregar miembros")

    usuario_id = payload.usuario_id
    if not usuario_id and payload.email:
        uid = (await db.execute(text("SELECT id FROM usuarios WHERE email=:em"), {"em": payload.email})).scalar()
        if not uid:
            raise HTTPException(status_code=404, detail="Usuario no encontrado")
        usuario_id = uid
    if not usuario_id:
        raise HTTPException(status_code=422, detail="Debes enviar usuario_id o email")

    await db.execute(text("""
        INSERT INTO proyecto_miembros (proyecto_id, usuario_id)
        VALUES (:pid, :uid)
        ON CONFLICT (proyecto_id, usuario_id) DO NOTHING
    """), {"pid": project_id, "uid": usuario_id})
    await db.commit()

    q = text("""
        SELECT u.id, u.email, u.nombre, u.apellido, pm.rol_en_proyecto
        FROM proyecto_miembros pm
        JOIN usuarios u ON u.id = pm.usuario_id
        WHERE pm.proyecto_id = :pid AND pm.usuario_id = :uid
    """)
    row = (await db.execute(q, {"pid": project_id, "uid": usuario_id})).mappings().first()
    return MemberOut(**dict(row))

@router.delete("/{project_id}/members/{usuario_id}", status_code=204, summary="Quitar miembro (solo Admin)")
async def remove_member(
    project_id: int,
    usuario_id: int,
    db: AsyncSession = Depends(get_async_db),
    user = Depends(require_permissions("write:projects"))
):
    if not await _project_exists(db, project_id):
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")
    if not await _is_admin(db, user.id):
        raise HTTPException(status_code=403, detail="Solo Admin puede quitar miembros")

    res = await db.execute(text("""
        DELETE FROM proyecto_miembros
        WHERE proyecto_id = :pid AND usuario_id = :uid
    """), {"pid": project_id, "uid": usuario_id})
    if res.rowcount == 0:
        raise HTTPException(status_code=404, detail="Membresía no encontrada")
    await db.commit()
    return Response(status_code=204)
