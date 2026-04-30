import { prisma } from '../lib/prisma.js';
import { getDayBoundsForTimezone } from './checkin.service.js';

/**
 * Algoritmo de Gestión de Escudos (Shields)
 *
 * Se ejecuta al final del día (vía cron) para cada usuario.
 * Para cada hábito DAILY que NO tenga un HabitLog hoy:
 *   - Si tiene shields > 0 → Resta 1, crea ShieldUsage, mantiene racha
 *   - Si NO tiene shields  → Resetea currentStreak a 0
 *
 * Para hábitos WEEKLY, se verifica al final de la semana.
 */
export async function processEndOfDayShields(): Promise<{
  processed: number;
  shieldsUsed: number;
  streaksReset: number;
}> {
  let shieldsUsed = 0;
  let streaksReset = 0;

  // Obtenemos todos los usuarios con sus timezones
  const users = await prisma.user.findMany({
    select: { id: true, timezone: true },
  });

  for (const user of users) {
    const timezone = user.timezone || 'UTC';

    // Solo procesamos si ya es "fin del día" en la timezone del usuario
    // (el cron corre cada hora, aquí filtramos quién ya terminó su día)
    if (!isDayEndingForTimezone(timezone)) {
      continue;
    }

    const { startOfDay, endOfDay } = getDayBoundsForTimezone(timezone);

    // Obtener hábitos diarios del usuario con sus logs de hoy
    const dailyHabits = await prisma.habit.findMany({
      where: {
        userId: user.id,
        frequency: 'DAILY',
      },
      include: {
        logs: {
          where: {
            completedAt: { gte: startOfDay, lte: endOfDay },
          },
          take: 1,
        },
      },
    });

    for (const habit of dailyHabits) {
      const completedToday = habit.logs.length > 0;

      if (completedToday) {
        // Hábito cumplido — no hacer nada
        continue;
      }

      // Hábito NO cumplido hoy
      if (habit.shields > 0) {
        // TIENE escudos → usar uno
        await prisma.$transaction(async (tx) => {
          await tx.habit.update({
            where: { id: habit.id },
            data: { shields: habit.shields - 1 },
          });

          await tx.shieldUsage.create({
            data: {
              habitId: habit.id,
              usedAt: new Date(),
              reason: `Escudo automático: día sin completar (${new Date().toISOString().split('T')[0]})`,
            },
          });
        });

        shieldsUsed++;
        console.log(`🛡️ Escudo usado para hábito "${habit.name}" (${habit.id}). Quedan: ${habit.shields - 1}`);
      } else {
        // NO tiene escudos → resetear racha
        await prisma.habit.update({
          where: { id: habit.id },
          data: { currentStreak: 0 },
        });

        streaksReset++;
        console.log(`💔 Racha reseteada para hábito "${habit.name}" (${habit.id}).`);
      }
    }
  }

  const processed = users.length;
  console.log(`\n📊 Resumen del cron de shields:`);
  console.log(`   Usuarios procesados: ${processed}`);
  console.log(`   Escudos usados: ${shieldsUsed}`);
  console.log(`   Rachas reseteadas: ${streaksReset}\n`);

  return { processed, shieldsUsed, streaksReset };
}

/**
 * Verifica si estamos en la última hora del día para una timezone dada.
 * El cron corre cada hora; solo procesamos cuando son las 23:XX locales.
 */
function isDayEndingForTimezone(timezone: string): boolean {
  const now = new Date();
  const formatter = new Intl.DateTimeFormat('en-US', {
    timeZone: timezone,
    hour: 'numeric',
    hour12: false,
  });
  const localHour = parseInt(formatter.format(now), 10);
  return localHour === 23;
}
