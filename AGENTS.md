# AGENTS

## Alcance
Estas instrucciones aplican a todo el repositorio.

## Objetivo del repo
Mantener un stack MVP local con Docker Compose para PostgreSQL, Directus, Metabase y Appsmith.

## Reglas de trabajo
- Mantén el `docker-compose.yml` alineado con los puertos del MVP (5432/8055/3000/8080).
- Si agregas o cambias servicios, actualiza el `README.md` con URLs y variables necesarias.
- Los scripts SQL en `init-scripts/` deben ser idempotentes.
- Evita credenciales hardcodeadas fuera de ejemplos locales.

## Skills locales
- `skills/mvp-stack/SKILL.md`: guía para actualizar el stack y documentación asociada.
