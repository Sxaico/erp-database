# PLAN — Hitos y próximos pasos

## Hitos completados (MVP)
1. **Infra local** con Docker Compose: Postgres 16 + pgAdmin + API + Web.
2. **DB**: tablas de usuarios/roles/organizaciones/departamentos/proyectos/tareas + vista agregada + `proyecto_miembros`.
3. **Auth**: login JWT, `/auth/refresh`, guards por roles/permisos.
4. **Projects/Tasks**: endpoints CRUD mínimos + membresías + reporte por estado.
5. **UI mínima**: Login + rutas protegidas + llamadas a health; corrección import `ProtectedRoute`.
6. **Seeds útiles**: admin + colaboradores de prueba.

## Gap review rápido
- UI aún básica (falta listado/tabla/edición “linda”).
- Migraciones no gestionadas con Alembic (solo scripts init).
- Falta hardening para prod (SECRET_KEY/HTTPS/backup/monitoring).

## Próximos pasos a **pre-producción**
1. **Alembic** para migraciones (crear carpeta `alembic/`, `env.py`, `script.py.mako`).
2. **UI mínima operable**:
   - Listado de proyectos y tareas con filtros.
   - Crear/editar desde UI + **refresco instantáneo** de listas (React Query).
   - Cambio libre de estado de tareas (no solo “HECHA”).
3. **Dashboard MVP**:
   - Tarjetas: proyectos activos, tareas por estado, últimas anotaciones.
   - Gráfico simple (Recharts) por progreso/estado.
4. **Seguridad y prod**:
   - SECRET_KEY/creds fuertes, `DEBUG=false`, CORS dominio.
   - Nginx + Certbot; backups cron de Postgres.
5. **Observabilidad**:
   - Access/error logs centralizados.
   - Healthcheck + endpoint `/metrics` (opcional con Prometheus FastAPI).

## Roadmap a **producción**
- **UI full** (role-based): páginas de admin, permisos granulares.
- **Dashboard ejecutivo** con KPIs (tiempos, costos, avance vs plan).
- **Anotaciones/mediciones** (modelo y UI) + agregados por proyecto/área/tiempo.
- **Notificaciones** (email/webhooks).
- **Auditoría** (tabla de eventos, quién cambió qué/cuándo).
- **CI/CD** (GitHub Actions: build + test + push images + deploy).