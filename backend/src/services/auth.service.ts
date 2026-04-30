import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../lib/prisma.js';
import { jwtConfig } from '../config/jwt.js';
import type { JwtPayload } from '../types/index.js';

const SALT_ROUNDS = 12;

// ─── Helpers ──────────────────────────────────────────────────

function generateToken(payload: JwtPayload): string {
  return jwt.sign(payload, jwtConfig.secret, {
    expiresIn: jwtConfig.expiresIn as any,
  });
}

function sanitizeUser(user: { id: string; email: string; name: string | null; totalXp: number; level: number; timezone: string }) {
  return {
    id: user.id,
    email: user.email,
    name: user.name,
    totalXp: user.totalXp,
    level: user.level,
    timezone: user.timezone,
  };
}

// ─── Signup ───────────────────────────────────────────────────

export async function signupService(
  email: string,
  password: string,
  name?: string,
  timezone?: string
) {
  // 1. Verificar que el email no exista
  const existingUser = await prisma.user.findUnique({ where: { email } });
  if (existingUser) {
    throw new Error('DUPLICATE_EMAIL');
  }

  // 2. Hashear la contraseña
  const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);

  // 3. Crear el usuario
  const user = await prisma.user.create({
    data: {
      email,
      passwordHash,
      name: name || null,
      timezone: timezone || 'UTC',
    },
  });

  // 4. Generar JWT
  const token = generateToken({ userId: user.id, email: user.email });

  return {
    token,
    user: sanitizeUser(user),
  };
}

// ─── Login ────────────────────────────────────────────────────

export async function loginService(email: string, password: string) {
  // 1. Buscar al usuario
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    throw new Error('INVALID_CREDENTIALS');
  }

  // 2. Comparar contraseñas
  const isMatch = await bcrypt.compare(password, user.passwordHash);
  if (!isMatch) {
    throw new Error('INVALID_CREDENTIALS');
  }

  // 3. Generar JWT
  const token = generateToken({ userId: user.id, email: user.email });

  return {
    token,
    user: sanitizeUser(user),
  };
}

// ─── Get Profile (para rehidratar sesión) ─────────────────────

export async function getProfileService(userId: string) {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true,
      email: true,
      name: true,
      totalXp: true,
      level: true,
      timezone: true,
    },
  });

  if (!user) {
    throw new Error('USER_NOT_FOUND');
  }

  return user;
}
