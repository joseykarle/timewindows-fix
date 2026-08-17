---
name: Pull Request
about: Enviar cambios para revisión
title: ""
labels: ""
assignees: ""
---

## Resumen

Una descripción breve del cambio.

## Problema que resuelve

Closes #<issue>

## Cambios

- Lista de cambios puntuales
- Documentos tocados

## Verificaciones

- [ ] `npx markdownlint-cli2 "*.md" "docs/**/*.md" "references/**/*.md" "**/*.md"` — 0 errores
- [ ] Enlaces internos válidos (todo archivo referenciado existe)
- [ ] Versión uniforme (declarada en `CHANGELOG.md`) donde corresponde
- [ ] Convenciones del repo respetadas (idioma, kebab-case, LF, ≤ 200 líneas)
- [ ] Sin secretos ni datos personales

## Reglas aplicadas

- [ ] No se debilita la coherencia del proyecto (referencias cruzadas actualizadas)
- [ ] Trazabilidad: el cambio mapea a una entrada del `CHANGELOG.md`

## Checklist del revisor

- [ ] La contribución no fue validada por quien la escribió (regla de oro de contribución)
