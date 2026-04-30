import { prisma } from '../lib/prisma.js';
import { Frequency } from '@prisma/client';

// ─── Crear hábito ─────────────────────────────────────────────

export async function createHabit(
  userId: string,
  data: {
    name: string;
    description?: string;
    trigger?: string;
    frequency?: Frequency;
    color?: string;
    icon?: string;
  }
) {
  return prisma.habit.create({
    data: {
      userId,
      name: data.name,
      description: data.description || null,
      trigger: data.trigger || null,
      frequency: data.frequency || 'DAILY',
      color: data.color || '#018ABE',
      icon: data.icon || null,
    },
  });
}

// ─── Actualizar hábito ────────────────────────────────────────

export async function updateHabit(
  habitId: string,
  userId: string,
  data: {
    name?: string;
    description?: string;
    trigger?: string;
    frequency?: Frequency;
    color?: string;
    icon?: string;
    shields?: number;
  }
) {
  // Verificar que el hábito pertenece al usuario
  const habit = await prisma.habit.findFirst({
    where: { id: habitId, userId },
  });

  if (!habit) {
    throw new Error('HABIT_NOT_FOUND');
  }

  return prisma.habit.update({
    where: { id: habitId },
    data,
  });
}

// ─── Eliminar hábito ──────────────────────────────────────────

export async function deleteHabit(habitId: string, userId: string) {
  const habit = await prisma.habit.findFirst({
    where: { id: habitId, userId },
  });

  if (!habit) {
    throw new Error('HABIT_NOT_FOUND');
  }

  return prisma.habit.delete({ where: { id: habitId } });
}
