# Changelog HabitOS

Aquí se registra el progreso diario y las actualizaciones del proyecto.

## [2026-04-23] - Limpieza y Configuración Inicial

### Realizado:
- **Limpieza de Entorno:**
  - Se purgó por completo las carpetas `node_modules` en todo el proyecto.
  - Se eliminaron archivos `.DS_Store` temporales de macOS.
  - Se resolvió un conflicto de gestores borrando `package-lock.json` del backend, unificando todo bajo `bun`.

- **Configuración Monorepo:**
  - Se corrigió la declaración del workspace en el `package.json` raíz de `Backend` a `backend`.
  - Se instalaron de cero las dependencias utilizando `bun install` desde la raíz.

- **Infraestructura Backend:**
  - Se inicializó y verificó el contenedor de **Docker** para PostgreSQL y pgAdmin.
  - Se creó la ruta base del servidor Express en `backend/src/index.ts` con soporte CORS y configuración de entorno (`dotenv`).
  - Se generó la respuesta base "Hello World" en el puerto 4000.

- **Integración Frontend:**
  - Se limpió el diseño boilerplate del `index.tsx` de Expo Router.
  - Se programó un `fetch` hacia el endpoint local del backend, validando exitosamente el ciclo de respuesta full-stack en el simulador de iOS.

- **Documentación:**
  - Se creó la estructura de documentación en `/docs` (Arquitectura, Changelog, Base de Datos).
  - Cambios respaldados y pusheados a la rama principal en GitHub.
