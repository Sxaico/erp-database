# api/app/projects/routes.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text

from ..database import get_async_db
from ..utils.dependencies import get_current_active_user, require_permissions
from .models import Proyecto, Tarea
from .schemas import (
    ProyectoCreate, ProyectoUpdate, ProyectoResponse,
    TareaCreate, TareaUpdate, TareaResponse, ResumenEstadoItem
)

router = APIRouter()

# ---- PROYECTOS ----
@router.post("", response_model=ProyectoResponse)
async def create_project(
    data: ProyectoCreate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("write:projects"))
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


@router.get("", response_model=list[ProyectoResponse])
async def list_projects(
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("read:projects"))
):
    result = await db.execute(select(Proyecto).where(Proyecto.deleted_at.is_(None)))
    items = result.scalars().all()
    return [ProyectoResponse.model_validate(i) for i in items]


@router.get("/{project_id}", response_model=ProyectoResponse)
async def get_project(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("read:projects"))
):
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
    user=Depends(require_permissions("write:projects"))
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

# ---- TAREAS ----
@router.post("/tasks", response_model=TareaResponse)
async def create_task(
    data: TareaCreate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("write:tasks"))
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
    user=Depends(require_permissions("read:tasks"))
):
    result = await db.execute(select(Tarea).where(Tarea.proyecto_id == project_id, Tarea.deleted_at.is_(None)))
    items = result.scalars().all()
    return [TareaResponse.model_validate(i) for i in items]


@router.patch("/tasks/{task_id}", response_model=TareaResponse)
async def update_task(
    task_id: int,
    data: TareaUpdate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("write:tasks"))
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

# ---- Reporte simple (vista) ----
@router.get("/{project_id}/report/estado", response_model=list[ResumenEstadoItem])
async def resumen_por_estado(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("read:reports"))
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
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from ..database import get_async_db
from ..utils.dependencies import get_current_active_user, require_permissions
from .models import Proyecto, Tarea
from .schemas import (
    ProyectoCreate, ProyectoUpdate, ProyectoResponse,
    TareaCreate, TareaUpdate, TareaResponse, ResumenEstadoItem
)

router = APIRouter()

# ---- PROYECTOS ----
@router.post("", response_model=ProyectoResponse)
async def create_project(
    data: ProyectoCreate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("write:projects"))
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

@router.get("", response_model=list[ProyectoResponse])
async def list_projects(
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("read:projects"))
):
    result = await db.execute(select(Proyecto).where(Proyecto.deleted_at.is_(None)))
    items = result.scalars().all()
    return [ProyectoResponse.model_validate(i) for i in items]

@router.get("/{project_id}", response_model=ProyectoResponse)
async def get_project(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("read:projects"))
):
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
    user=Depends(require_permissions("write:projects"))
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

# ---- TAREAS ----
@router.post("/tasks", response_model=TareaResponse)
async def create_task(
    data: TareaCreate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("write:tasks"))
):
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
    user=Depends(require_permissions("read:tasks"))
):
    result = await db.execute(select(Tarea).where(Tarea.proyecto_id == project_id, Tarea.deleted_at.is_(None)))
    items = result.scalars().all()
    return [TareaResponse.model_validate(i) for i in items]

@router.patch("/tasks/{task_id}", response_model=TareaResponse)
async def update_task(
    task_id: int,
    data: TareaUpdate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("write:tasks"))
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

# ---- Reporte simple (vista) ----
@router.get("/{project_id}/report/estado", response_model=list[ResumenEstadoItem])
async def resumen_por_estado(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(require_permissions("read:reports"))
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
