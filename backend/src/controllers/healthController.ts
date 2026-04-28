import { Request, Response } from 'express';

export const getHealth = (req: Request, res: Response) => {
  res.json({
    status: 'success',
    message: 'Hello World! El backend de HabitOS está funcionando correctamente 🚀'
  });
};
