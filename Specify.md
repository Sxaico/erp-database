# SPECIFY — ERP MVP

## Resumen
MVP de ERP enfocado en **gestión de proyectos y tareas** con **control de acceso por roles**. Permite crear/listar/actualizar proyectos y tareas, gestionar membresías de proyecto, y obtener un **reporte simple por estado**. UI mínima para login, listado básico y verificación de salud.

## Objetivo
Entregar una base limpia, **extensible** y **desplegable** que permita evolucionar hacia:
- **Dashboard ejecutivo** con métricas y KPIs operativos.
- Gestión avanzada de tareas (asignaciones, tiempos, costos).
- Reportes y vistas analíticas.
- Seguridad, auditoría y trazabilidad.

## Usuarios & Roles
- **Super Admin / Admin**: gestión global (usuarios, proyectos).
- **Gerente de Proyecto / Líder de Equipo**: CRUD de proyectos/tareas, reportes.
- **Colaborador**: lectura y ejecución de tareas propias / del proyecto.

## Alcance actual (MVP)
- Autenticación JWT + `/auth/refresh`.
- Roles y permisos (guards en API).
- CRUD mínimo de proyectos y tareas.
- Miembros de proyecto (alta/baja, acceso condicionado).
- Reporte por estado (vista `vw_resumen_tareas_por_estado`).
- UI mínima (login + rutas protegidas).

## No-Alcance (MVP)
- UI completa de administración.
- Tableros (kanban), notificaciones, comentarios.
- Auditoría, bitácoras avanzadas.
- Integraciones externas (ERP/BI/SSO).
- Móvil / offline.

## Visión futura
- **Dashboard**: progreso, productividad, costos, “anotaciones de métricas” (p.ej. *metros lineales de bandeja galvanizada por área*), agregaciones temporales, comparativas y desviaciones.
- **Planificación**: hitos, dependencias, Gantt básico, criticidad.
- **Colaboración**: comentarios/adjuntos/mencciones.
- **Automatizaciones**: recordatorios, SLA, webhooks.
- **Datos**: materialized views y ETL a almacén analítico.
- **Seguridad**: RBAC fino, auditoría, hardening, SSO.

## Restricciones
- SQLAlchemy 2.x, FastAPI.
- Migraciones iniciales por scripts `init-scripts/` (todo ok para dev); en prod se sugiere **Alembic**.
- Stack 100% contenedorizado (Docker Compose).

## Métricas de éxito
- Tiempo de despliegue < 20 min.
- Flujo login → crear proyecto → crear tareas → ver reporte, 100% OK.
- 0 errores en healthcheck y logs limpios al boot.
````
