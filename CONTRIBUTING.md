# Guía de Contribución — <NOMBRE_DEL_REPO>

Gracias por querer contribuir. <FRASE_DE_CONTEXTO_DEL_PROYECTO_SI_APLICA>.

## Flujo de trabajo

1. **Abre un issue** (plantilla de bug report o feature request) describiendo el problema o mejora.
2. **Espera aprobación de arquitectura**: para cambios no triviales, primero una propuesta en el issue; los cambios estructurales son bloqueantes y requieren revisión.
3. **Crea tu rama** desde `main`: `git checkout -b feat/<descripcion>` o `fix/<descripcion>`.
4. **Implementa** siguiendo las reglas duras del proyecto.
5. **Verifica localmente** antes de abrir el PR (ver sección "Verificación").
6. **Abre el Pull Request** con la plantilla `PULL_REQUEST_TEMPLATE.md`.

## Reglas duras (aplican a toda contribución)

- **Nadie se auto-aprueba**: quien escribe el cambio no lo valida; lo revisa otra persona.
- **Coherencia del proyecto**: cualquier cambio debe mantener la consistencia entre archivos y documentación. Un cambio sin actualizar sus referencias es un defecto.
- **Cero secretos**: nunca commits de credenciales, claves o datos personales reales.
- **Trazabilidad**: cada cambio de comportamiento debe mapear a una entrada del `CHANGELOG.md`.
- **Sin emojis**: salvo los confirmadores ✅/❌/⚠️ ya establecidos en el proyecto.

## Verificación (antes del PR)

```bash
# 1. Lint de markdown (obligatorio, 0 errores)
npx markdownlint-cli2 "*.md" "docs/**/*.md" "references/**/*.md" "**/*.md"

# 2. Enlaces internos: todo archivo referenciado debe existir
#    (verificar manualmente o con un checker de links)

# 3. Scan de secretos: gitleaks o equivalente
gitleaks detect
```

Todo debe pasar antes de abrir el PR.

## Estilo de commits

Conventional Commits, sujeto ≤ 50 caracteres:

```text
feat: añadir nueva funcionalidad
fix: corregir error en módulo X
docs: documentar integración con Y
refactor: unificar manejo de Z
test: cubrir caso límite de W
```

Tipos permitidos: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`, `ci`.

## Estilo de código

- **Contenido**: <IDIOMA_DEL_PROYECTO>; nombres de archivos en inglés (kebab-case).
- **Encabezados**: jerárquicos; un `#` por documento (título del documento).
- **Tablas**: para estructuras y mapeos; sin celdas vacías si se puede evitar.
- **Rutas y referencias**: con backticks; relativas a la raíz del repo.
- **Archivos**: ≤ 200 líneas por archivo, fin de línea LF, sin BOM, markdownlint limpio.
- **Emojis**: solo ✅/❌/⚠️ como confirmadores establecidos; nunca decorativos.

## Código de conducta

Toda contribución está sujeta a [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md).

## Dudas

Revisa primero [docs/USER_GUIDE.md](docs/USER_GUIDE.md) (cómo funciona el proyecto) y `ROADMAP.md` (mejoras pendientes — quizá tu idea ya está listada). Si la duda persiste, pregúntala en el issue.
