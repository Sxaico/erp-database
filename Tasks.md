# TASKS — backlog accionable

## A) Infra / Base de datos
1. **Alembic setup** (S): inicializar proyecto y primera migración desde esquema actual.
2. **Seeds en Alembic** (M): convertir seeds a “migraciones de datos” idempotentes (roles/admin).
3. **Backups** (S): script `pg_dump` diario + retención (cron).
4. **Indices & tuning** (M): revisar EXPLAIN en listados y vistas.

## B) API
5. **Endpoints UI-ready** (S): asegurar respuestas limpias y errores consistentes.
6. **Estados de tarea** (S): validar enum (`PENDIENTE|EN_PROGRESO|HECHA|BLOQUEADA|CANCELADA`).
7. **Members API** (S): ya funcional; sumar paginación/filtros (opcional).
8. **Reporte extendido** (M): endpoint de KPIs simples por proyecto (conteos + %).

## C) UI (React + Vite)
9. **Auth flow** (S): form login + guardar token + `/auth/refresh`.
10. **State/query** (S): integrar **TanStack Query** para fetch/cache/invalidations.
11. **Proyectos** (M): listado, crear/editar, **refrescar tras mutaciones**.
12. **Tareas** (M): listado por proyecto, crear/editar, cambio libre de estado, **refrescar**.
13. **Dashboard MVP** (M): tarjetas + gráfico Recharts con datos reales.
14. **Estilos base** (S): aplicar `styles.css` (tiny CSS adjunto).

## D) Seguridad / Prod
15. **SECRET_KEY + creds** (S): rotar y ocultar.
16. **CORS dominio** (S): `ALLOWED_ORIGINS="https://tu-dominio.com"`.
17. **Nginx + TLS** (M): conf. reverse proxy + Certbot.
18. **UFW** (S): solo 22/80/443.
19. **Monitoreo básico** (S): logs y alertas simples (disk full, container restart).

## E) Dashboard & Métricas (feature)
20. **Modelo “anotaciones”** (M): `metric_logs(id, proyecto_id, area, tipo, unidad, cantidad, fecha, notas)`.
21. **API anotaciones** (M): CRUD + agregados por proyecto/área/mes.
22. **UI anotaciones** (M): form rápido + tabla con filtros.
23. **Widgets dashboard** (M): total por tipo/unidad (p.ej. “m bandeja galvanizada”), líneas de tiempo.
24. **Materialized view** (M): resumen por día/semana para rendimiento en reportes.

> S=Small (≤0.5d) / M=Medium (≤2d) / L=Large (>2d) — Ajusta a tu ritmo.