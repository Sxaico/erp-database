from datetime import date
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, text
from ..database import get_async_db
from ..utils.dependencies import (
    get_current_active_user,
    require_permissions
)
from .models import Proyecto, Tarea
from .schemas import (
    ProyectoCreate, ProyectoUpdate, ProyectoResponse,
    TareaCreate, TareaUpdate, TareaResponse, ResumenEstadoItem,
    ProyectoSummary, ProyectoStateUpdate
)

router = APIRouter()

# ---- PROYECTOS ----
@router.post("", response_model=ProyectoResponse, dependencies=[Depends(require_permissions("write:projects"))])
async def create_project(
    data: ProyectoCreate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
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


@router.get("", response_model=list[ProyectoResponse], dependencies=[Depends(require_permissions("read:projects"))])
async def list_projects(
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
):
    result = await db.execute(select(Proyecto).where(Proyecto.deleted_at.is_(None)))
    items = result.scalars().all()
    return [ProyectoResponse.model_validate(i) for i in items]


@router.get("/{project_id}", response_model=ProyectoResponse, dependencies=[Depends(require_permissions("read:projects"))])
async def get_project(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
):
    result = await db.execute(select(Proyecto).where(Proyecto.id == project_id, Proyecto.deleted_at.is_(None)))
    p = result.scalar_one_or_none()
    if not p:
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")
    return ProyectoResponse.model_validate(p)


@router.patch("/{project_id}", response_model=ProyectoResponse, dependencies=[Depends(require_permissions("write:projects"))])
async def update_project(
    project_id: int,
    data: ProyectoUpdate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
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
@router.post("/tasks", response_model=TareaResponse, dependencies=[Depends(require_permissions("write:tasks"))])
async def create_task(
    data: TareaCreate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
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


@router.get("/{project_id}/tasks", response_model=list[TareaResponse], dependencies=[Depends(require_permissions("read:tasks"))])
async def list_tasks(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
):
    result = await db.execute(select(Tarea).where(Tarea.proyecto_id == project_id, Tarea.deleted_at.is_(None)))
    items = result.scalars().all()
    return [TareaResponse.model_validate(i) for i in items]


@router.patch("/tasks/{task_id}", response_model=TareaResponse, dependencies=[Depends(require_permissions("write:tasks"))])
async def update_task(
    task_id: int,
    data: TareaUpdate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
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
@router.get("/{project_id}/report/estado", response_model=list[ResumenEstadoItem], dependencies=[Depends(require_permissions("read:reports"))])
async def resumen_por_estado(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
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

# ==============================
# OPCIONALES (conveniencia MVP)
# ==============================

@router.get("/{project_id}/summary", response_model=ProyectoSummary, dependencies=[Depends(require_permissions("read:projects"))])
async def project_summary(
    project_id: int,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
):
    # proyecto
    res_p = await db.execute(select(Proyecto).where(Proyecto.id == project_id, Proyecto.deleted_at.is_(None)))
    p = res_p.scalar_one_or_none()
    if not p:
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")

    # tareas
    res_t = await db.execute(select(Tarea).where(Tarea.proyecto_id == project_id, Tarea.deleted_at.is_(None)))
    tareas = res_t.scalars().all()

    # conteos por estado
    counts: dict[str, int] = {}
    for t in tareas:
        counts[t.estado] = counts.get(t.estado, 0) + 1

    return ProyectoSummary(
        proyecto=ProyectoResponse.model_validate(p),
        total_tareas=len(tareas),
        por_estado=counts,
        tareas=[TareaResponse.model_validate(x) for x in tareas],
    )


@router.patch("/{project_id}/state", response_model=ProyectoResponse, dependencies=[Depends(require_permissions("write:projects"))])
async def change_project_state(
    project_id: int,
    body: ProyectoStateUpdate,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
):
    res = await db.execute(select(Proyecto).where(Proyecto.id == project_id, Proyecto.deleted_at.is_(None)))
    p = res.scalar_one_or_none()
    if not p:
        raise HTTPException(status_code=404, detail="Proyecto no encontrado")
    if body.estado is not None:
        p.estado = body.estado
    await db.commit()
    await db.refresh(p)
    return ProyectoResponse.model_validate(p)


@router.patch("/tasks/{task_id}/done", response_model=TareaResponse, dependencies=[Depends(require_permissions("write:tasks"))])
async def mark_task_done(
    task_id: int,
    db: AsyncSession = Depends(get_async_db),
    user=Depends(get_current_active_user)
):
    res = await db.execute(select(Tarea).where(Tarea.id == task_id, Tarea.deleted_at.is_(None)))
    t = res.scalar_one_or_none()
    if not t:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    t.estado = "HECHA"
    t.fecha_fin_real = date.today()
    await db.commit()
    await db.refresh(t)
    return TareaResponse.model_validate(t)
