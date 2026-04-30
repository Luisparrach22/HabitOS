import { Response } from 'express';
import { checkinHabit, getHabitsWithStatus } from '../services/checkin.service.js';
import { createHabit, updateHabit, deleteHabit } from '../services/habit.service.js';
import type { AuthenticatedRequest } from '../types/index.js';

// ─── GET /api/habits ──────────────────────────────────────────
export const getHabits = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId!;
    const habits = await getHabitsWithStatus(userId);
    res.status(200).json({ success: true, data: habits });
  } catch (error) {
    console.error('Error al obtener los hábitos:', error);
    res.status(500).json({ success: false, error: 'Error al obtener los hábitos.' });
  }
};

// ─── POST /api/habits ─────────────────────────────────────────
export const createHabitController = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId!;
    const { name, description, trigger, frequency, color, icon } = req.body;

    if (!name || name.trim().length === 0) {
      res.status(400).json({ success: false, error: 'El nombre del hábito es requerido.' });
      return;
    }

    const habit = await createHabit(userId, { name, description, trigger, frequency, color, icon });
    res.status(201).json({ success: true, data: habit });
  } catch (error) {
    console.error('Error al crear hábito:', error);
    res.status(500).json({ success: false, error: 'Error al crear el hábito.' });
  }
};

// ─── PUT /api/habits/:id ──────────────────────────────────────
export const updateHabitController = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId!;
    const habitId = req.params.id as string;
    const data = req.body;

    const habit = await updateHabit(habitId, userId, data);
    res.status(200).json({ success: true, data: habit });
  } catch (error: any) {
    if (error.message === 'HABIT_NOT_FOUND') {
      res.status(404).json({ success: false, error: 'Hábito no encontrado.' });
      return;
    }
    console.error('Error al actualizar hábito:', error);
    res.status(500).json({ success: false, error: 'Error al actualizar el hábito.' });
  }
};

// ─── DELETE /api/habits/:id ───────────────────────────────────
export const deleteHabitController = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId!;
    const habitId = req.params.id as string;

    await deleteHabit(habitId, userId);
    res.status(200).json({ success: true, message: 'Hábito eliminado correctamente.' });
  } catch (error: any) {
    if (error.message === 'HABIT_NOT_FOUND') {
      res.status(404).json({ success: false, error: 'Hábito no encontrado.' });
      return;
    }
    console.error('Error al eliminar hábito:', error);
    res.status(500).json({ success: false, error: 'Error al eliminar el hábito.' });
  }
};

// ─── POST /api/habits/:id/checkin ─────────────────────────────
export const checkinController = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId!;
    const habitId = req.params.id as string;

    const result = await checkinHabit(habitId, userId);
    res.status(200).json({ success: true, data: result });
  } catch (error: any) {
    if (error.message === 'HABIT_NOT_FOUND') {
      res.status(404).json({ success: false, error: 'Hábito no encontrado.' });
      return;
    }
    if (error.message === 'ALREADY_COMPLETED_TODAY') {
      res.status(409).json({ success: false, error: 'Este hábito ya fue completado hoy.' });
      return;
    }
    if (error.message === 'ALREADY_COMPLETED_THIS_WEEK') {
      res.status(409).json({ success: false, error: 'Este hábito ya fue completado esta semana.' });
      return;
    }
    console.error('Error en check-in:', error);
    res.status(500).json({ success: false, error: 'Error al registrar el check-in.' });
  }
};
