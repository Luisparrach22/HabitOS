import { defineConfig } from "@prisma/config";

// Esto fuerza a que se cargue el .env antes de que Prisma lo pida
export default defineConfig({
  datasource: {
    url:
      process.env.DATABASE_URL ||
      "postgresql://admin:admin123@localhost:5432/habitOS_db?schema=public",
  },
});
