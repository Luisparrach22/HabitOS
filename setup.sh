#!/bin/bash

# Detener el script si algo sale mal
set -e

echo "🚀 Iniciando configuración a prueba de balas de HabitOS..."
echo "----------------------------------------------------"

# 0. Detectar Sistema Operativo
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*|MINGW*|MSYS*) MACHINE=Windows;;
    *)          MACHINE="UNKNOWN"
esac

echo "💻 Sistema Operativo detectado: $MACHINE"

# 1. Validar que Docker esté instalado y corriendo (VITAL para evitar el 'en mi máquina sí funciona')
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker no está instalado."
    echo "👉 Por favor, descarga e instala Docker Desktop desde: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo "❌ Error: Docker está instalado pero NO está corriendo."
    echo "👉 Por favor, abre la aplicación 'Docker' en tu computadora y vuelve a ejecutar este script."
    exit 1
fi

# 2. Validar que Bun esté instalado
if ! command -v bun &> /dev/null; then
    echo "⚠️ Bun no está instalado. Intentando instalarlo automáticamente..."
    
    if [ "$MACHINE" == "Windows" ]; then
        echo "🪟 Instalando Bun para Windows..."
        powershell -c "irm bun.sh/install.ps1 | iex"
    else
        echo "🍏/🐧 Instalando Bun para Mac/Linux..."
        curl -fsSL https://bun.sh/install | bash
    fi
    
    # Cargar bun al path actual para poder usarlo inmediatamente
    export PATH="$HOME/.bun/bin:$PATH"
    
    if ! command -v bun &> /dev/null; then
        echo "❌ Error: No se pudo instalar Bun automáticamente. Reinicia tu terminal e intenta de nuevo."
        exit 1
    fi
fi

# 3. Instalación limpia de dependencias
echo "📦 Limpiando cachés e instalando dependencias (Frontend y Backend)..."
# Borramos node_modules previos para evitar basura de otras máquinas
rm -rf node_modules frontend/node_modules backend/node_modules
bun install

# 4. Configurar variables de entorno (.env) de forma segura
echo "🔑 Configurando archivos .env..."
if [ ! -f backend/.env ]; then
  cat <<EOT >> backend/.env
PORT=4000
DATABASE_URL="postgresql://admin:admin123@localhost:5432/habitOS_db?schema=public"
EOT
  echo "✅ Archivo .env del Backend creado con éxito."
else
  echo "ℹ️ El archivo .env ya existe, perfecto."
fi

# 5. Levantar Infraestructura con Docker
echo "🐳 Levantando la base de datos (PostgreSQL) y pgAdmin..."
docker compose up -d

# 6. Esperar a que PostgreSQL esté listo de verdad
echo "⏳ Esperando a que la base de datos esté lista para recibir conexiones..."
sleep 5 # Pausa de seguridad

# 7. Preparar la Base de Datos con Prisma
echo "🏗️ Sincronizando el esquema de la base de datos..."
cd backend
bunx prisma generate 
bunx prisma db push 
cd ..

echo "----------------------------------------------------"
echo "✨ ¡ENTORNO CONFIGURADO CON ÉXITO! ✨"
echo "💡 Tip: Puedes ver tu base de datos en http://localhost:8080 (Email: admin@habitos.com | Pass: admin)"
echo "----------------------------------------------------"
echo "🚀 Arrancando HabitOS automáticamente..."
echo "👉 IMPORTANTE: Cuando veas el código QR, presiona 'i' en tu teclado para abrir el simulador de iPhone."

# 8. Ejecutar el proyecto automáticamente
bun run dev