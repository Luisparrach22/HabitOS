import { Router } from 'express';
import {
  getHabits,
  createHabitController,
  updateHabitController,
  deleteHabitController,
  checkinController,
} from '../controllers/habit.controller.js';
import { authMiddleware } from '../middleware/auth.middleware.js';

const router = Router();

// Todas las rutas de hábitos requieren autenticación
router.use(authMiddleware);

router.get('/habits', getHabits);
router.post('/habits', createHabitController);
router.put('/habits/:id', updateHabitController);
router.delete('/habits/:id', deleteHabitController);

// Motor de check-in
router.post('/habits/:id/checkin', checkinController);

export default router;
