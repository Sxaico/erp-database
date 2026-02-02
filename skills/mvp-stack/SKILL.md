---
name: mvp-stack
description: Maintain the local MVP Docker Compose stack (PostgreSQL, Directus, Metabase, Appsmith) and aligned documentation.
---

## Propósito
Mantener el stack MVP local con Docker Compose y documentación coherente.

## Cuándo usar
- Cuando se agregan o modifican servicios en `docker-compose.yml`.
- Cuando se actualiza la guía de instalación/URLs en `README.md`.
- Cuando se agregan scripts en `init-scripts/`.

## Checklist
1. Verificar puertos: Postgres 5432, Directus 8055, Metabase 3000, Appsmith 8080.
2. Revisar variables de entorno mínimas para Directus.
3. Ajustar `README.md` con URLs y pasos de verificación.
4. Confirmar que scripts SQL sean idempotentes.
5. Si se agregan roles, documentar su uso en el README.

## Plantilla de actualización (README)
- Servicios y URLs
- Variables de entorno necesarias
- Pasos de arranque con `docker compose`
- Notas de troubleshooting
