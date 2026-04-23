#!/bin/bash

# Detener el script si algo sale mal
set -e

echo "🚀 Iniciando configuración de HabitOS con Bun..."

# 1. Validar que Bun esté instalado
if ! command -v bun &> /dev/null; then
    echo "❌ Error: Bun no está instalado. Instálalo con: curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

# 2. Instalar dependencias
echo "📦 Instalando dependencias globales y locales..."
bun install

# 3. Configurar variables de entorno (.env) de forma segura
echo "🔑 Configurando archivos .env..."
if [ ! -f backend/.env ]; then
  # Usamos 'cat' para evitar problemas con los saltos de línea en macOS
  cat <<EOT >> backend/.env
PORT=4000
DATABASE_URL="postgresql://admin:admin123@localhost:5432/habitOS_db?schema=public"
EOT
  echo "✅ Archivo .env del Backend creado con éxito."
else
  echo "ℹ️ El archivo .env ya existe, saltando configuración."
fi

# 4. Levantar Infraestructura con Docker
echo "🐳 Levantando contenedores de Docker..."
# 'docker compose' sin el guion es el estándar actual
docker compose up -d

# 5. Esperar a que PostgreSQL esté listo para recibir conexiones
echo "⏳ Esperando 5 segundos a que la base de datos despierte..."
sleep 5

# 6. Preparar Prisma
echo "🏗️ Sincronizando base de datos con Prisma..."
cd backend
# Genera los tipos de TypeScript
bunx prisma generate 
# Empuja el esquema a la DB de Docker sin necesidad de migraciones manuales
bunx prisma db push 
cd ..

echo "----------------------------------------------------"
echo "✨ ¡Entorno configurado correctamente!"
echo "🚀 Ejecuta 'bun run dev' para arrancar el proyecto."
echo "💡 Tip: Puedes ver tus datos en http://localhost:8080 (pgAdmin)"
echo "----------------------------------------------------"