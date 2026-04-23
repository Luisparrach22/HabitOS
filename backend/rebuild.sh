#!/bin/bash

echo "☢️ Iniciando reconstrucción total del Backend..."

# 1. Crear un package.json limpio (ESM puro)
cat <<EOT > package.json
{
  "name": "habitos-backend",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "dev": "bun --hot src/index.ts",
    "db:push": "bunx prisma db push",
    "db:studio": "bunx prisma studio"
  },
  "dependencies": {
    "@prisma/client": "^7.8.0",
    "express": "^5.0.0",
    "cors": "^2.8.5",
    "dotenv": "^16.4.0"
  },
  "devDependencies": {
    "prisma": "^7.8.0",
    "@types/node": "latest",
    "@types/express": "latest",
    "@types/cors": "latest",
    "typescript": "latest"
  }
}
EOT

# 2. Crear un tsconfig.json que NO de errores
cat <<EOT > tsconfig.json
{
  "compilerOptions": {
    "target": "ESNext",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "types": ["node"],
    "strict": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "noEmit": true,
    "allowImportingTsExtensions": true
  },
  "include": ["src/**/*.ts", "prisma.config.ts", ".env"]
}
EOT

# 3. Crear el prisma.config.ts (Estándar Prisma 7)
cat <<EOT > prisma.config.ts
import { defineConfig } from "@prisma/config";

export default defineConfig({
  datasource: {
    url: process.env.DATABASE_URL,
  },
});
EOT

# 4. Asegurar que el esquema no tenga la URL (Regla de Prisma 7)
mkdir -p prisma
cat <<EOT > prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
}

model Habit {
  id    Int    @id @default(autoincrement())
  name  String
}
EOT

# 5. Ejecutar la magia
echo "📦 Instalando y sincronizando..."
bun install
bunx prisma generate
bunx prisma db push

echo "✅ ¡RECONSTRUCCIÓN COMPLETADA!"
echo "💡 Si ves rojo en VS Code, presiona Cmd+Shift+P -> 'Restart TS Server'"