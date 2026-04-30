import { Request } from 'express';

// ─── JWT ─────────────────────────────────────────────────────
export interface JwtPayload {
  userId: string;
  email: string;
}

// Augment Express Request to carry authenticated user info
export interface AuthenticatedRequest extends Request {
  userId?: string;
}

// ─── Gamificación ─────────────────────────────────────────────
export const GAMIFICATION = {
  /** XP base por cada check-in completado */
  XP_PER_CHECKIN: 10,
  /** Bonus XP por cada 7 días de racha consecutiva */
  STREAK_BONUS_INTERVAL: 7,
  /** XP extra cuando se alcanza un múltiplo del streak bonus */
  STREAK_BONUS_XP: 25,
  /** Fórmula: XP necesario para subir de nivel N → N+1 */
  xpForLevel: (level: number): number => level * 100,
} as const;

// ─── API Response helpers ────────────────────────────────────
export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
}
