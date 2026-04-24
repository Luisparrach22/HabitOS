# Arquitectura de HabitOS

Este documento describe cómo se estructuran y conectan las distintas piezas del proyecto HabitOS.

## Estructura del Monorepo

El proyecto está construido como un monorepo gestionado por **Bun**, dividiendo el código en dos carpetas principales:

1. **/frontend**: Aplicación móvil construida con React Native y **Expo Router**.
2. **/backend**: API REST construida con Node.js y **Express**.

## Flujo de Datos y Conexión

### 1. Cliente (Frontend)
- Utiliza **React Native** con **Expo** para una experiencia móvil fluida.
- Hace peticiones HTTP (mediante `fetch` o similares) hacia la API del backend.
- Durante el desarrollo local en emuladores/simuladores, apunta hacia la IP local o `localhost` en el puerto `4000`.

### 2. Servidor (Backend)
- Expone un servidor **Express** escuchando en el puerto `4000`.
- Cuenta con el middleware **CORS** habilitado para recibir peticiones sin problemas desde el frontend.
- Utiliza **Prisma ORM** como capa de acceso a los datos.

### 3. Base de Datos
- **PostgreSQL** corriendo dentro de un contenedor **Docker** (junto con pgAdmin en el puerto 8080 para administración visual).
- Expuesta en el puerto `5432` local para ser consumida por el Backend mediante una URL segura provista en el archivo `.env`.

---

## Arranque Rápido

Para iniciar toda la infraestructura local, ejecutamos desde la raíz del proyecto:
```bash
bun run dev
```
Esto lanza simultáneamente el servidor backend en modo "hot reload" y empaqueta el frontend con Metro/Expo.
