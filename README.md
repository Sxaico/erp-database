
# ERP MVP — PostgreSQL + Directus + Metabase + Appsmith (local)

MVP local para **formularios, API, tableros y DB única** usando **Docker Compose**.  
Stack MVP: **PostgreSQL**, **Directus**, **Metabase**, **Appsmith**.

---

## 🚀 Quick Start (local, sin Nginx)

```bash
# 1) Clonar
git clone <TU_REPO.git> erp-mvp
cd erp-mvp

# 2) Levantar stack
docker compose up -d --build

# 3) Verificar
# Directus:
http://localhost:8055
# Metabase:
http://localhost:3000
# Appsmith:
http://localhost:8080
```

> Si cambias puertos, ajústalos en `docker-compose.yml`.

---

## 🧱 Servicios (local)

| Servicio  | URL                      | Notas                               |
| --------- | ------------------------ | ----------------------------------- |
| Postgres  | `localhost:5432`         | DB única (volumen local)            |
| Directus  | `http://localhost:8055`  | Admin/CRUD/API                      |
| Metabase  | `http://localhost:3000`  | BI/KPIs (metadata por defecto en H2)|
| Appsmith  | `http://localhost:8080`  | Apps internas (persistencia volumen)|

> **pgAdmin** es opcional en este stack y corre en `http://localhost:8081`.

---

## 🔑 Cuentas de prueba (seeds)

| Email                  | Password   | Rol         |
| ---------------------- | ---------- | ----------- |
| `admin@miempresa.com`  | `admin123` | Super Admin |
| `colab1@miempresa.com` | `user123`  | Colaborador |
| `colab2@miempresa.com` | `user123`  | Colaborador |
| `colab3@miempresa.com` | `user123`  | Colaborador |

> Los seeds se cargan con `init-scripts/*` en el primer arranque.
> Si ya existe `./pgdata/`, Postgres **no** los re-ejecuta (ver “Reset DB” abajo).

---

## 📦 Estructura (resumen)

```bash
.
├─ init-scripts/ (DDL + seeds + roles)
├─ docker-compose.yml
├─ directus-data/ (volumen local)
├─ metabase-data/ (volumen local)
└─ appsmith-stacks/ (volumen local)
```

---

## 🔐 Variables de entorno (MVP)

Variables principales (definidas en `docker-compose.yml`):

* **Postgres**: `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
* **Directus**: `ADMIN_EMAIL`, `ADMIN_PASSWORD`, `DB_*`, `KEY`, `SECRET`
* **Metabase**: sin variables obligatorias para MVP (usa H2 interna)
* **Appsmith**: sin variables obligatorias (persistencia en volumen)

---

> En **producción**, cambia `KEY`, `SECRET` y contraseñas.

---

## ✅ Prueba E2E en 10 minutos

1. **Directus**: crea una colección `tareas` con campos básicos (área, estado, fechas) y carga 2–3 registros.
2. **Metabase**: conecta a PostgreSQL con `bi_reader` y crea una pregunta “tareas por estado”.
3. **Appsmith**:
   - Crea un formulario de alta con `app_writer`.
   - Crea una vista de reportes (tabla o iframe con Metabase).

Si ves datos en Metabase y podés crear/editar desde Appsmith, el MVP está OK.

---

## 🧰 Roles mínimos en Postgres

En el primer arranque se crean:

* `bi_reader` (solo lectura)
* `app_writer` (lectura + escritura)

Para cambiar passwords edita `init-scripts/09-roles-bi-app.sql`.

---

## 🧰 Troubleshooting

* **Puertos ocupados**: libera 5432/8055/3000/8080 o ajusta puertos.
* **Seeds no corren**: si existe `./pgdata/`, no se re-ejecutan.
* **Reset DB** (⚠️ borra datos locales):

 ```bash
 docker compose down
 rm -rf ./pgdata
 docker compose up -d --build
 ```

* **Logs**:

 ```bash
 docker compose logs -f directus
 docker compose logs -f metabase
 docker compose logs -f appsmith
 docker compose logs -f postgres
 ```

---

## 🚢 Despliegue recomendado (Debian 12)

**Opción ganadora (simple y robusta)**: *Docker Compose + Nginx reverse proxy + Certbot (TLS)*

1. **Servidor** (Debian 12, usuario no-root con sudo).
2. **Instalar Docker & Compose**:

 ```bash
 sudo apt update
 sudo apt install -y ca-certificates curl gnupg
 sudo install -m 0755 -d /etc/apt/keyrings
 curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
 echo \
 "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
 https://download.docker.com/linux/debian $(. /etc/os-release && echo $VERSION_CODENAME) stable" \
 | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
 sudo apt update
 sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
 sudo usermod -aG docker $USER
 newgrp docker
 ```
  
3. **Clonar repo** y crear secretos reales para Directus (`KEY`, `SECRET`, credenciales admin).
4. **Ajustar `docker-compose.yml`**: cambia puertos si usas Nginx (ver más abajo).
5. **Nginx + Certbot**:

   ```bash
   sudo apt install -y nginx certbot python3-certbot-nginx ufw
   sudo ufw allow OpenSSH
   sudo ufw allow 'Nginx Full'
   sudo ufw enable
   ```

   Virtual hosts (Directus, Metabase, Appsmith) apuntando a los puertos publicados por tus contenedores.
   Emite certificados:

   ```bash
   sudo certbot --nginx -d tu-dominio.com -d api.tu-dominio.com
   ```
6. **Arrancar**:

   ```bash
   docker compose up -d --build
   ```
7. **Backups de Postgres** (cron):

   ```bash
   mkdir -p ~/db_backups
   crontab -e
   # cada noche 02:00
   0 2 * * * docker compose exec -T postgres pg_dump -U erp_user erp_db > ~/db_backups/erp_db_$(date +\%F).sql
   ```

**Alternativa más simple**: *Caddy reverse proxy* en lugar de Nginx (auto-TLS con DNS correcto).
**Alternativa más directa** (sin proxy): abrir puertos 8055/3000/8080 y usar HTTP plano (no recomendado para prod).

---

## 🔒 Check de seguridad básico (prod)

* Cambia `KEY`, `SECRET` y **todas** las contraseñas.
* Habilita firewall (UFW) solo 80/443/22.
* Backups diarios y retención (7/14/30 días).

````

---

# Specify.md

```md
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

---

# Plan.md

```md
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
```

---

# Tasks.md

```md
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
```

---

# Guía modular para aprender y ampliar (con ejemplo del dashboard/“anotaciones”)

**Objetivo:** que puedas agregar features **vos mismo** con apoyo de IA.

## Módulo 1 — Base del stack (1–2 días)

* **Docker & Compose**: redes, volúmenes, logs.
* **FastAPI**: routers, dependencias, pydantic v2, manejo de errores.
* **SQLAlchemy 2.x**: ORM moderno, `selectinload`, sesiones async.
* **JWT**: access vs refresh, expiración, guardas en rutas.
* **React + Vite + TS**: hooks, rutas, componentes controlados.

## Módulo 2 — Data & API (2–3 días)

* **Modelado**: entidades y relaciones básicas; vistas SQL.
* **Migrations**: **Alembic** (indispensable para prod).
* **Consultas**: filtros, paginación, agregaciones.
* **Pruebas**: `pytest` + `httpx` para endpoints críticos.

## Módulo 3 — UI productiva (2–3 días)

* **TanStack Query**: `useQuery`/`useMutation` + **invalidations para refrescar** tras crear/editar.
* **Forms**: controlled inputs, validación mínima, UX.
* **Componentes**: tablas, paginación, toasts, loaders.
* **Autorización**: ProtectedRoute, ocultar acciones por rol.

## Módulo 4 — Dashboards & Reporting (2–3 días)

* **Recharts**: barras/líneas/pie para KPIs simples.
* **Vistas/materialized**: pre-agregados por fecha/proyecto.
* **Diseño de métricas**: *tipo* (ej. “bandeja galvanizada”), *unidad* (m), *cantidad*, *área* (4110), *fecha*.

## Módulo 5 — Prod & Seguridad (2–3 días)

* **Nginx + TLS** con Certbot; CORS; logs y backups.
* **Hardening**: secretos, mínimos privilegios, UFW.

### Ejemplo concreto: “Anotaciones de tareas clave / métricas”

1. **DB** (nueva tabla):

   ```sql
   CREATE TABLE metric_logs (
     id SERIAL PRIMARY KEY,
     proyecto_id INT NOT NULL REFERENCES proyectos(id) ON DELETE CASCADE,
     area TEXT NOT NULL,            -- ej. "4110"
     tipo TEXT NOT NULL,            -- ej. "bandeja_galvanizada"
     unidad TEXT NOT NULL,          -- ej. "m"
     cantidad NUMERIC(12,2) NOT NULL,
     fecha DATE NOT NULL DEFAULT CURRENT_DATE,
     notas TEXT,
     created_at TIMESTAMPTZ DEFAULT now()
   );
   CREATE INDEX idx_metric_logs_proyecto_fecha ON metric_logs(proyecto_id, fecha);
   ```
2. **API**:

   * `POST /api/metrics` (crear anotación)
   * `GET /api/metrics?proyecto_id=&area=&tipo=&from=&to=` (listar/filtrar)
   * `GET /api/metrics/summary?proyecto_id=&group_by=area|tipo|fecha` (agregados)
3. **UI**:

   * Form simple: proyecto, área, tipo, unidad, cantidad, fecha, notas.
   * Tabla filtrable por proyecto/área/fecha.
   * **Dashboard**: tarjeta “Total m bandeja (área 4110) este mes”, gráfico de barras por día/semana.
4. **TanStack Query**:

   * `useMutation(createMetric)` + `queryClient.invalidateQueries(['metrics', filters])` para refrescar.
5. **Vistas**:

   ```sql
   CREATE MATERIALIZED VIEW mv_metrics_daily AS
   SELECT proyecto_id, area, tipo, unidad, fecha, SUM(cantidad)::numeric(12,2) total
   FROM metric_logs
   GROUP BY 1,2,3,4,5;
   -- REFRESH MATERIALIZED VIEW mv_metrics_daily;
   ```

> Con esto tenés el esqueleto para tu dashboard ejecutivo con “anotaciones”.

---

# Tiny CSS (rápido y sobrio)

Crea `web/src/styles.css` y **en `main.tsx`** importa `import "./styles.css";`

```css
/* web/src/styles.css */
:root {
  --bg: #0f172a;         /* slate-900 */
  --card: #111827;       /* gray-900 */
  --muted: #475569;      /* slate-500 */
  --text: #e5e7eb;       /* gray-200 */
  --primary: #22d3ee;    /* cyan-400 */
  --danger: #ef4444;
  --ok: #22c55e;
  --border: #1f2937;     /* gray-800 */
}

* { box-sizing: border-box; }
html, body, #root { height: 100%; }
body {
  margin: 0;
  background: linear-gradient(180deg, #0b1220 0%, #0f172a 100%);
  color: var(--text);
  font-family: ui-sans-serif, system-ui, -apple-system, Segoe UI, Roboto, Ubuntu, Cantarell, Noto Sans, 'Helvetica Neue', Arial;
}

.container { max-width: 1100px; margin: 24px auto; padding: 0 16px; }

.card {
  background: rgba(17,24,39,0.85);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 18px;
  box-shadow: 0 10px 30px rgba(0,0,0,.25);
  backdrop-filter: blur(6px);
}

h1,h2,h3 { margin: 8px 0 16px; }
h1 { font-size: 1.6rem; }
h2 { font-size: 1.3rem; color: var(--muted); }

label { display:block; font-size:.9rem; color: var(--muted); margin-bottom: 6px; }
input, select, textarea {
  width: 100%;
  background: #0b1220;
  color: var(--text);
  border: 1px solid var(--border);
  border-radius: 10px;
  padding: 10px 12px;
  outline: none;
}
input:focus, select:focus, textarea:focus {
  border-color: var(--primary);
  box-shadow: 0 0 0 3px rgba(34,211,238,.15);
}

.row { display: grid; gap: 12px; grid-template-columns: repeat(12,1fr); }
.col-6 { grid-column: span 6; } .col-4 { grid-column: span 4; } .col-12 { grid-column: span 12; }

.btn {
  display:inline-flex; align-items:center; gap:8px;
  padding: 10px 14px; border-radius: 12px;
  border: 1px solid var(--border);
  background: #0b1220; color: var(--text);
  cursor: pointer; text-decoration: none;
}
.btn:hover { border-color: var(--primary); }
.btn.primary { background: linear-gradient(90deg, #06b6d4, #22d3ee); color:#001018; font-weight:600; }
.btn.danger { background: #221216; border-color: #401016; color: #ffd6d6; }

.table { width: 100%; border-collapse: collapse; }
.table th, .table td { padding: 10px 12px; border-bottom: 1px solid var(--border); }
.table th { color: var(--muted); font-weight: 600; text-align: left; }
.badge { padding: 2px 8px; border-radius: 999px; border:1px solid var(--border); font-size: .8rem; }
.badge.ok { color: var(--ok); border-color: rgba(34,197,94,.5); }
.badge.warn { color: #f59e0b; border-color: rgba(245,158,11,.5); }
.badge.danger { color: var(--danger); border-color: rgba(239,68,68,.5); }
```

> Con esto ya se ve prolijo sin meter librerías.

---

## ¿Qué archivos están “al pedo”?

En el dump más reciente el set luce bastante coherente. Lo único a vigilar/limpiar periódicamente:

* `init-scripts/02-datos-iniciales.sql` (solo asegura extensión): puedes fusionarlo con `01-schema.sql` si querés menos archivos.
* Revisa que **no** queden `*.log`, `dist/`, `build/`, `.vite/` (ya ignorados).
* En `api/app/auth/routes.py` hay imports duplicados (dos veces `verify_password, get_password_hash, ...` y `RefreshTokenRequest`). No rompe, pero **limpiarlos** es sano.

---

## Estado final del checkpoint

* **MVP local** ✅ listo.
* **API** estable con auth/refresh, proyectos/tareas/miembros/reportes.
* **UI mínima** ✅, con `ProtectedRoute` corregido; queda pendiente listado/edición “lindo” y **refrescos tras crear/editar** usando React Query (lo dejé en el Tasks.md).
* **Deploy**: guía completa arriba.

Si querés, en un siguiente paso te doy el esqueleto de:

* **alembic init + primera migración**, y
* **endpoints/TS** para “anotaciones” + **widgets de dashboard** base.

Pero por ahora, con lo de arriba, **MVP: ✔️ FINALIZADO**.
