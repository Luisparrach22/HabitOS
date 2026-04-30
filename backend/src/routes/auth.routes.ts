import { Router } from 'express';
import { signup, login, getMe } from '../controllers/auth.controller.js';
import { authMiddleware } from '../middleware/auth.middleware.js';

const router = Router();

// Rutas públicas
router.post('/signup', signup);
router.post('/login', login);

// Rutas protegidas
router.get('/me', authMiddleware, getMe);

export default router;
