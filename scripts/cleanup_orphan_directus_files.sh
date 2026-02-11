#!/usr/bin/env bash
set -euo pipefail

# === Config por defecto (podés override con variables de entorno) ===
DIRECTUS_URL="${DIRECTUS_URL:-http://localhost:8055}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@miempresa.com}"
ADMIN_PASS="${ADMIN_PASS:-admin123}"

POSTGRES_CONTAINER="${POSTGRES_CONTAINER:-erp_postgres}"
PG_DB="${PG_DB:-erp_db}"
PG_USER="${PG_USER:-erp_user}"

# Solo borra imágenes por defecto (más seguro)
ONLY_IMAGES="${ONLY_IMAGES:-true}"

echo "==> Logueando a Directus: ${DIRECTUS_URL}"
TOKEN=$(
  curl -s "${DIRECTUS_URL}/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"${ADMIN_EMAIL}\",\"password\":\"${ADMIN_PASS}\"}" \
  | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['access_token'])"
)

if [[ -z "${TOKEN}" ]]; then
  echo "ERROR: no se pudo obtener access_token."
  exit 1
fi

echo "==> Token OK"

echo "==> Buscando archivos huérfanos en Postgres (no referenciados por sigco.pd_produccion_fotos)..."

SQL_COMMON=$(cat <<'SQL'
WITH refs AS (
  -- referencias actuales del módulo SIGCO
  SELECT pf.file_id::uuid AS id
  FROM sigco.pd_produccion_fotos pf
  WHERE pf.file_id IS NOT NULL

  UNION
  -- excluir avatars (no tocar)
  SELECT u.avatar::uuid AS id
  FROM public.directus_users u
  WHERE u.avatar IS NOT NULL

  UNION
  -- excluir assets de settings del proyecto (si existen columnas)
  SELECT s.project_logo::uuid AS id
  FROM public.directus_settings s
  WHERE s.project_logo IS NOT NULL

  UNION
  SELECT s.public_favicon::uuid AS id
  FROM public.directus_settings s
  WHERE s.public_favicon IS NOT NULL

  UNION
  SELECT s.public_background::uuid AS id
  FROM public.directus_settings s
  WHERE s.public_background IS NOT NULL
)
SELECT f.id
FROM public.directus_files f
LEFT JOIN refs r ON r.id = f.id
WHERE r.id IS NULL
  AND f.storage = 'local'
SQL
)

if [[ "${ONLY_IMAGES}" == "true" ]]; then
  SQL="${SQL_COMMON}
  AND f.type LIKE 'image/%'
ORDER BY f.uploaded_on DESC;"
else
  SQL="${SQL_COMMON}
ORDER BY f.uploaded_on DESC;"
fi

ORPHANS_FILE="/tmp/directus_orphans_$(date +%s).txt"

docker exec -i "${POSTGRES_CONTAINER}" psql -U "${PG_USER}" -d "${PG_DB}" -t -A -c "${SQL}" > "${ORPHANS_FILE}"

COUNT=$(grep -c . "${ORPHANS_FILE}" || true)
echo "==> Encontrados: ${COUNT} archivos huérfanos"
echo "==> Lista guardada en: ${ORPHANS_FILE}"

if [[ "${COUNT}" -eq 0 ]]; then
  echo "==> Nada para borrar. Fin."
  exit 0
fi

echo "==> Borrando huérfanos via Directus API (DELETE /files/:id)..."

OK=0
FAIL=0

while IFS= read -r FILE_ID; do
  [[ -z "${FILE_ID}" ]] && continue

  # DELETE /files/:id (borra DB + disco si storage=local)
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X DELETE \
    "${DIRECTUS_URL}/files/${FILE_ID}" \
    -H "Authorization: Bearer ${TOKEN}")

  if [[ "${HTTP_CODE}" == "200" || "${HTTP_CODE}" == "204" ]]; then
    OK=$((OK+1))
  else
    echo "  !! FAIL ${FILE_ID} (HTTP ${HTTP_CODE})"
    FAIL=$((FAIL+1))
  fi
done < "${ORPHANS_FILE}"

echo "==> Resultado: OK=${OK} FAIL=${FAIL}"
echo "==> Listado usado: ${ORPHANS_FILE}"

