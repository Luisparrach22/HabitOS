import { Router } from 'express';
import { getHabits } from '../controllers/habit.controller.js';

const router = Router();

router.get('/habits', getHabits);

export default router;
