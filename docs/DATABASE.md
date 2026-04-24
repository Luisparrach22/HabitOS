# Diseño de Base de Datos HabitOS

Este documento detalla la estructura y el razonamiento detrás de los modelos definidos en Prisma para HabitOS.

## Modelo Actual (Base)

Por el momento, el archivo `schema.prisma` contiene un modelo semilla muy básico para verificar la conexión.

```prisma
model Habit {
  id    Int    @id @default(autoincrement())
  name  String
}
```

### Explicación de Campos Actuales:

*   **`id` (Int):** 
    *   **Atributos:** `@id @default(autoincrement())`
    *   **Razón:** Todo registro necesita una llave primaria única e irrepetible. Utilizar enteros autoincrementales es una forma clásica, rápida y eficiente de indexar la tabla en PostgreSQL. A futuro, si la aplicación escala mucho, podría considerarse migrar a `UUID` o `CUID`, pero para iniciar es la solución más limpia.
*   **`name` (String):** 
    *   **Razón:** Almacena el nombre principal del hábito (ej. "Beber Agua", "Leer 10 páginas"). Es el campo mínimo indispensable para representar la entidad.

*(Nota: Este documento debe expandirse a medida que se agreguen relaciones como Usuarios, Frecuencias de Hábitos, Seguimiento Diario (Tracking), etc.)*
