import dotenv from 'dotenv';
dotenv.config();

export const jwtConfig = {
  secret: process.env.JWT_SECRET || 'fallback-secret-do-not-use',
  expiresIn: process.env.JWT_EXPIRES_IN || '7d',
} as const;
