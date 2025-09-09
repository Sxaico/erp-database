# ERP MVP (API + DB + UI)

MVP funcional para gestión básica de proyectos y tareas, con autenticación por roles.  
Stack: **FastAPI + PostgreSQL + pgAdmin + Vite/React** en Docker Compose.

---

## 🚀 Quick Start

```bash
# 1) Clonar el repo
git clone <TU_REPO.git> erp-database
cd erp-database

# 2) Levantar todo
docker compose up -d --build

# 3) Verificar
# API health:
http://localhost:8000/health
# UI mínima:
http://localhost:5173/
# pgAdmin:
http://localhost:8080/
````

> Si cambiaste puertos, ajústalos en `docker-compose.yml`.

---

## 🧱 Servicios & URLs

| Servicio  | URL                            | Notas                      |
| --------- | ------------------------------ | -------------------------- |
| API       | `http://localhost:8000`        | Docs en `/docs` y `/redoc` |
| Health    | `http://localhost:8000/health` | Estado DB y versión        |
| UI (Vite) | `http://localhost:5173`        | UI mínima “B” + Health API |
| pgAdmin   | `http://localhost:8080`        | Ver DB y diagramas         |

**pgAdmin (primera vez)**

* Usuario: `admin@miempresa.com`
* Password: `admin123`
* Agregar servidor:

  * Name: `ERP Postgres`
  * Host: `postgres`
  * Port: `5432`
  * DB: `erp_db`
  * User: `erp_user`
  * Pass: `erp_password123`

---

## 🔑 Cuentas de prueba (seeds)

| Email                  | Password   | Rol         |
| ---------------------- | ---------- | ----------- |
| `admin@miempresa.com`  | `admin123` | Super Admin |
| `colab1@miempresa.com` | `user123`  | Colaborador |
| `colab2@miempresa.com` | `user123`  | Colaborador |
| `colab3@miempresa.com` | `user123`  | Colaborador |

> Los seeds se cargan con los scripts en `init-scripts/`.
> Si el volumen `./pgdata/` ya existía, los scripts no se re-ejecutan automáticamente (ver “Reset DB” abajo).

---

## 📦 Estructura del proyecto (resumen)

```
.
├─ api/
│  ├─ .env
│  ├─ Dockerfile
│  ├─ requirements.txt
│  └─ app/
│     ├─ main.py
│     ├─ config.py
│     ├─ database.py
│     ├─ utils/
│     │  ├─ security.py
│     │  └─ dependencies.py
│     ├─ auth/
│     │  ├─ models.py
│     │  ├─ routes.py
│     │  └─ schemas.py
│     └─ projects/
│        ├─ models.py
│        ├─ routes.py
│        └─ schemas.py
├─ init-scripts/
│  ├─ 01-schema.sql
│  ├─ 02-datos-iniciales.sql
│  ├─ 03-schema-projects.sql
│  ├─ 04-data-demo.sql
│  ├─ 05-initial-data.sql
│  ├─ 06-fix-admin.sql
│  └─ 07-sample-collaborators.sql
├─ docker-compose.yml
└─ web/  (UI mínima React + Vite)
   ├─ package.json
   ├─ index.html
   ├─ vite.config.ts
   └─ src/
      ├─ main.tsx
      └─ App.tsx
```

---

## 🔐 Endpoints principales

**Auth**

* `POST /api/auth/login` → `{ access_token, refresh_token, expires_in, user }`
* `POST /api/auth/refresh` → `{ access_token, expires_in }`
* `GET /api/auth/me` (Bearer) → datos del usuario logueado
* `GET /api/auth/users` (Solo Admin/Super Admin) → lista de usuarios


**Projects & Tasks**

* `POST /api/projects` (Bearer) → crear proyecto
* `GET /api/projects` (Bearer) → listar proyectos
* `PATCH /api/projects/{id}` (Bearer) → actualizar proyecto
* `POST /api/projects/tasks` (Bearer) → crear tarea
* `PATCH /api/projects/tasks/{task_id}` (Bearer) → actualizar tarea
* `GET /api/projects/{id}/report/estado` (Bearer) → resumen por estado (vista)

---

## 🧪 Pruebas rápidas (PowerShell)

```powershell
# Login admin
$resp = Invoke-RestMethod -Method POST -Uri "http://localhost:8000/api/auth/login" `
  -ContentType "application/json" `
  -Body '{"email":"admin@miempresa.com","password":"admin123"}'
$AT = $resp.access_token

# Me
Invoke-RestMethod -Method GET -Uri "http://localhost:8000/api/auth/me" `
  -Headers @{ Authorization = "Bearer $AT" } | ConvertTo-Json -Depth 6

# Crear proyecto
$createProjBody = @{ codigo="MVP-0001"; nombre="MVP Demo"; descripcion="Proyecto MVP e2e"; prioridad=2 } | ConvertTo-Json
$proj = Invoke-RestMethod -Method POST -Uri "http://localhost:8000/api/projects" `
  -Headers @{ Authorization = "Bearer $AT" } -ContentType "application/json" -Body $createProjBody
$PROJ_ID = $proj.id

# Crear tareas
$body1 = @{ proyecto_id=$PROJ_ID; titulo="Tarea 1"; descripcion="..."; prioridad=2 } | ConvertTo-Json
$body2 = @{ proyecto_id=$PROJ_ID; titulo="Tarea 2"; descripcion="..."; prioridad=2 } | ConvertTo-Json
$t1 = Invoke-RestMethod -Method POST -Uri "http://localhost:8000/api/projects/tasks" `
  -Headers @{ Authorization = "Bearer $AT" } -ContentType "application/json" -Body $body1
$t2 = Invoke-RestMethod -Method POST -Uri "http://localhost:8000/api/projects/tasks" `
  -Headers @{ Authorization = "Bearer $AT" } -ContentType "application/json" -Body $body2

# Cambiar estado
Invoke-RestMethod -Method PATCH -Uri "http://localhost:8000/api/projects/tasks/$($t1.id)" `
  -Headers @{ Authorization = "Bearer $AT" } -ContentType "application/json" `
  -Body (@{ estado="HECHA" } | ConvertTo-Json)

# Reporte por estado
Invoke-RestMethod -Method GET -Uri "http://localhost:8000/api/projects/$PROJ_ID/report/estado" `
  -Headers @{ Authorization = "Bearer $AT" } | ConvertTo-Json -Depth 6
```

---

## 🖥️ UI mínima

* `web/` sirve con Vite en `http://localhost:5173/`.
* Muestra un “landing” con verificación del **/health** de la API.
* CORS ya incluye `http://localhost:5173` en `api/.env`.

---

## 🐘 SQLAlchemy 2.x (nota)

Se usan `loader options` con **atributos de clase** (no strings), p.ej.:

```python
select(Usuario).options(selectinload(Usuario.roles))
```

---

## 🧰 Troubleshooting

* **Puertos ocupados**: cierra procesos locales en `5432`, `8000`, `8080`, `5173` o cambia puertos en `docker-compose.yml`.
* **Scripts de seed no corren**: si el volumen `./pgdata/` ya existe, Postgres no re-ejecuta `init-scripts/`.

  * **Reset DB** (⚠️ borra datos locales):

    ```bash
    docker compose down
    rm -rf ./pgdata
    docker compose up -d --build
    ```
  * **Aplicar script manualmente**:

    ```bash
    docker compose exec postgres psql -U erp_user -d erp_db -f /docker-entrypoint-initdb.d/07-sample-collaborators.sql
    ```
* **Rebuild API**:

  ```bash
  docker compose up -d --build api
  ```
* **Ver logs**:

  ```bash
  docker compose logs -f api
  docker compose logs -f web
  docker compose logs -f postgres
  ```

---

## 🗺️ Roadmap inmediato (MVP+)

1. **/auth/refresh** (JWT refresh endpoint).
2. **Guardas en UI por rol** (componente ProtectedRoute + ocultar acciones).
3. **Login UI simple** (form + persist token).
4. **Listado de proyectos y tareas** (UI mínima) + cambio de estado.
5. **Reporte básico en UI** (resumen por estado del proyecto).

> Todo esto mantiene el alcance MVP con impacto directo en usabilidad.

---

## 📄 Licencia

MIT (o la que prefieras).
