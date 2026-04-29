import { Request, Response } from 'express';
import { prisma } from '../lib/prisma.js';

export const getHabits = async (req: Request, res: Response) => {
  try {
    // Usamos un ID hardcodeado por ahora para pruebas
    const userId = "fixed-user-id";
    
    const habits = await prisma.habit.findMany({
      where: { userId }
    });

    res.status(200).json(habits);
  } catch (error) {
    console.error("Error al obtener los hábitos:", error);
    res.status(500).json({ error: "Ocurrió un error al procesar la solicitud. Por favor, intenta de nuevo más tarde." });
  }
};
