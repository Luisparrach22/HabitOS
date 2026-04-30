import { Request, Response } from 'express';
import { signupService, loginService, getProfileService } from '../services/auth.service.js';
import type { AuthenticatedRequest } from '../types/index.js';

// ─── POST /api/auth/signup ────────────────────────────────────
export const signup = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password, name, timezone } = req.body;

    // Validación básica
    if (!email || !password) {
      res.status(400).json({ success: false, error: 'Email y contraseña son requeridos.' });
      return;
    }

    if (password.length < 6) {
      res.status(400).json({ success: false, error: 'La contraseña debe tener al menos 6 caracteres.' });
      return;
    }

    const result = await signupService(email, password, name, timezone);
    res.status(201).json({ success: true, data: result });
  } catch (error: any) {
    if (error.message === 'DUPLICATE_EMAIL') {
      res.status(409).json({ success: false, error: 'Ya existe una cuenta con ese email.' });
      return;
    }
    console.error('Error en signup:', error);
    res.status(500).json({ success: false, error: 'Error interno del servidor.' });
  }
};

// ─── POST /api/auth/login ─────────────────────────────────────
export const login = async (req: Request, res: Response): Promise<void> => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      res.status(400).json({ success: false, error: 'Email y contraseña son requeridos.' });
      return;
    }

    const result = await loginService(email, password);
    res.status(200).json({ success: true, data: result });
  } catch (error: any) {
    if (error.message === 'INVALID_CREDENTIALS') {
      res.status(401).json({ success: false, error: 'Credenciales incorrectas.' });
      return;
    }
    console.error('Error en login:', error);
    res.status(500).json({ success: false, error: 'Error interno del servidor.' });
  }
};

// ─── GET /api/auth/me ─────────────────────────────────────────
export const getMe = async (req: AuthenticatedRequest, res: Response): Promise<void> => {
  try {
    const userId = req.userId!;
    const user = await getProfileService(userId);
    res.status(200).json({ success: true, data: user });
  } catch (error: any) {
    if (error.message === 'USER_NOT_FOUND') {
      res.status(404).json({ success: false, error: 'Usuario no encontrado.' });
      return;
    }
    console.error('Error en getMe:', error);
    res.status(500).json({ success: false, error: 'Error interno del servidor.' });
  }
};
