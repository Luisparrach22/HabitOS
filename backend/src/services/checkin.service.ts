import { prisma } from '../lib/prisma.js';
import { GAMIFICATION } from '../types/index.js';

// ─── Helpers de Timezone ──────────────────────────────────────

/**
 * Obtiene el inicio y fin del día actual en la timezone del usuario.
 * Esto es CRUCIAL para que las rachas no se rompan al viajar.
 *
 * Estrategia: Convertimos "ahora" a la hora local del usuario,
 * obtenemos el inicio/fin de ese día local, y luego lo convertimos
 * de vuelta a UTC para las queries de Prisma.
 */
function getDayBoundsForTimezone(timezone: string): { startOfDay: Date; endOfDay: Date } {
  const now = new Date();

  // Formateamos la fecha en la timezone del usuario para obtener YYYY-MM-DD
  const formatter = new Intl.DateTimeFormat('en-CA', {
    timeZone: timezone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  const localDateStr = formatter.format(now); // "2026-04-30"

  // Construimos las fechas en la timezone del usuario
  // Nota: Usamos una técnica con Intl para calcular el offset
  const startLocal = new Date(`${localDateStr}T00:00:00`);
  const endLocal = new Date(`${localDateStr}T23:59:59.999`);

  // Calculamos el offset UTC de la timezone del usuario
  const offsetMs = getTimezoneOffsetMs(timezone);

  // Convertimos a UTC restando el offset
  const startOfDay = new Date(startLocal.getTime() - offsetMs);
  const endOfDay = new Date(endLocal.getTime() - offsetMs);

  return { startOfDay, endOfDay };
}

/**
 * Obtiene el offset en milisegundos de una timezone IANA respecto a UTC.
 */
function getTimezoneOffsetMs(timezone: string): number {
  const now = new Date();
  const utcStr = now.toLocaleString('en-US', { timeZone: 'UTC' });
  const tzStr = now.toLocaleString('en-US', { timeZone: timezone });
  return new Date(tzStr).getTime() - new Date(utcStr).getTime();
}

function getWeekBoundsForTimezone(timezone: string): { startOfWeek: Date; endOfWeek: Date } {
  const now = new Date();
  const formatter = new Intl.DateTimeFormat('en-CA', {
    timeZone: timezone,
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  const localDateStr = formatter.format(now);
  const localDate = new Date(`${localDateStr}T00:00:00`);

  // Lunes como inicio de semana (ISO)
  const dayOfWeek = localDate.getDay();
  const diffToMonday = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;

  const startOfWeek = new Date(localDate);
  startOfWeek.setDate(localDate.getDate() + diffToMonday);

  const endOfWeek = new Date(startOfWeek);
  endOfWeek.setDate(startOfWeek.getDate() + 6);
  endOfWeek.setHours(23, 59, 59, 999);

  const offsetMs = getTimezoneOffsetMs(timezone);
  return {
    startOfWeek: new Date(startOfWeek.getTime() - offsetMs),
    endOfWeek: new Date(endOfWeek.getTime() - offsetMs),
  };
}

// ─── Cálculo de XP ───────────────────────────────────────────

function calculateXpReward(newStreak: number): number {
  let xp = GAMIFICATION.XP_PER_CHECKIN;

  // Bonus por racha: cada 7 días consecutivos da 25 XP extra
  if (newStreak > 0 && newStreak % GAMIFICATION.STREAK_BONUS_INTERVAL === 0) {
    xp += GAMIFICATION.STREAK_BONUS_XP;
  }

  return xp;
}

/**
 * Calcula el nivel del usuario basado en XP total.
 * Nivel N requiere: sum(i=1..N-1) de i*100 XP
 * Simplificado: Nivel = floor(sqrt(totalXp / 50)) + 1
 */
function calculateLevel(totalXp: number): number {
  return Math.floor(Math.sqrt(totalXp / 50)) + 1;
}

// ─── Servicio principal de Check-in ──────────────────────────

export async function checkinHabit(habitId: string, userId: string) {
  // 1. Obtener hábito con datos del usuario
  const habit = await prisma.habit.findFirst({
    where: { id: habitId, userId },
    include: { user: { select: { timezone: true, totalXp: true, level: true } } },
  });

  if (!habit) {
    throw new Error('HABIT_NOT_FOUND');
  }

  const timezone = habit.user.timezone || 'UTC';

  // 2. Validar frecuencia — no se puede completar más veces de las permitidas
  if (habit.frequency === 'DAILY') {
    const { startOfDay, endOfDay } = getDayBoundsForTimezone(timezone);
    const existingLog = await prisma.habitLog.findFirst({
      where: {
        habitId,
        completedAt: { gte: startOfDay, lte: endOfDay },
      },
    });
    if (existingLog) {
      throw new Error('ALREADY_COMPLETED_TODAY');
    }
  } else if (habit.frequency === 'WEEKLY') {
    const { startOfWeek, endOfWeek } = getWeekBoundsForTimezone(timezone);
    const existingLog = await prisma.habitLog.findFirst({
      where: {
        habitId,
        completedAt: { gte: startOfWeek, lte: endOfWeek },
      },
    });
    if (existingLog) {
      throw new Error('ALREADY_COMPLETED_THIS_WEEK');
    }
  }

  // 3. Calcular nueva racha y XP
  const newStreak = habit.currentStreak + 1;
  const newMaxStreak = Math.max(newStreak, habit.maxStreak);
  const xpEarned = calculateXpReward(newStreak);
  const newTotalXp = habit.user.totalXp + xpEarned;
  const newLevel = calculateLevel(newTotalXp);
  const leveledUp = newLevel > habit.user.level;

  // 4. TRANSACCIÓN ATÓMICA — Todo o nada
  const result = await prisma.$transaction(async (tx) => {
    // 4a. Crear el HabitLog
    const log = await tx.habitLog.create({
      data: {
        habitId,
        completedAt: new Date(),
        value: 1,
      },
    });

    // 4b. Actualizar racha del hábito
    const updatedHabit = await tx.habit.update({
      where: { id: habitId },
      data: {
        currentStreak: newStreak,
        maxStreak: newMaxStreak,
      },
    });

    // 4c. Actualizar XP y nivel del usuario
    const updatedUser = await tx.user.update({
      where: { id: userId },
      data: {
        totalXp: newTotalXp,
        level: newLevel,
      },
      select: {
        id: true,
        totalXp: true,
        level: true,
      },
    });

    return { log, updatedHabit, updatedUser };
  });

  return {
    log: result.log,
    habit: {
      id: result.updatedHabit.id,
      name: result.updatedHabit.name,
      currentStreak: result.updatedHabit.currentStreak,
      maxStreak: result.updatedHabit.maxStreak,
    },
    user: result.updatedUser,
    xpEarned,
    leveledUp,
    newLevel: result.updatedUser.level,
  };
}

// ─── Obtener hábitos con estado de "completado hoy" ──────────

export async function getHabitsWithStatus(userId: string) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: { timezone: true },
  });

  const timezone = user?.timezone || 'UTC';
  const { startOfDay, endOfDay } = getDayBoundsForTimezone(timezone);

  const habits = await prisma.habit.findMany({
    where: { userId },
    include: {
      logs: {
        where: {
          completedAt: { gte: startOfDay, lte: endOfDay },
        },
        take: 1,
      },
      _count: {
        select: { logs: true },
      },
    },
    orderBy: { createdAt: 'asc' },
  });

  return habits.map((habit) => ({
    id: habit.id,
    name: habit.name,
    description: habit.description,
    trigger: habit.trigger,
    frequency: habit.frequency,
    color: habit.color,
    icon: habit.icon,
    currentStreak: habit.currentStreak,
    maxStreak: habit.maxStreak,
    shields: habit.shields,
    completedToday: habit.logs.length > 0,
    totalCompletions: habit._count.logs,
    createdAt: habit.createdAt,
  }));
}

// Exportar helpers para el cron job de shields
export { getDayBoundsForTimezone, getTimezoneOffsetMs };
