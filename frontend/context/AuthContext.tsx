import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import * as SecureStore from 'expo-secure-store';
import { authApi, TOKEN_KEY } from '../services/api';

// ─── Types ────────────────────────────────────────────────────

interface User {
  id: string;
  email: string;
  name: string | null;
  totalXp: number;
  level: number;
  timezone: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  isAuthenticated: boolean;
}

interface AuthContextType extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  signup: (email: string, password: string, name?: string, timezone?: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
}

// ─── Context ──────────────────────────────────────────────────

const AuthContext = createContext<AuthContextType | undefined>(undefined);

// ─── Provider ─────────────────────────────────────────────────

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [state, setState] = useState<AuthState>({
    user: null,
    token: null,
    isLoading: true,
    isAuthenticated: false,
  });

  // Al montar, intentar restaurar sesión desde SecureStore
  useEffect(() => {
    restoreSession();
  }, []);

  const restoreSession = async () => {
    try {
      const storedToken = await SecureStore.getItemAsync(TOKEN_KEY);
      if (storedToken) {
        // Verificar que el token siga siendo válido
        const response = await authApi.getMe();
        const user = response.data.data;

        setState({
          user,
          token: storedToken,
          isLoading: false,
          isAuthenticated: true,
        });
      } else {
        setState((prev) => ({ ...prev, isLoading: false }));
      }
    } catch (error) {
      // Token expirado o inválido — limpiar
      await SecureStore.deleteItemAsync(TOKEN_KEY);
      setState({ user: null, token: null, isLoading: false, isAuthenticated: false });
    }
  };

  const login = useCallback(async (email: string, password: string) => {
    const response = await authApi.login(email, password);
    const { token, user } = response.data.data;

    await SecureStore.setItemAsync(TOKEN_KEY, token);

    setState({
      user,
      token,
      isLoading: false,
      isAuthenticated: true,
    });
  }, []);

  const signup = useCallback(async (email: string, password: string, name?: string, timezone?: string) => {
    const response = await authApi.signup(email, password, name, timezone);
    const { token, user } = response.data.data;

    await SecureStore.setItemAsync(TOKEN_KEY, token);

    setState({
      user,
      token,
      isLoading: false,
      isAuthenticated: true,
    });
  }, []);

  const logout = useCallback(async () => {
    await SecureStore.deleteItemAsync(TOKEN_KEY);
    setState({ user: null, token: null, isLoading: false, isAuthenticated: false });
  }, []);

  const refreshUser = useCallback(async () => {
    try {
      const response = await authApi.getMe();
      const user = response.data.data;
      setState((prev) => ({ ...prev, user }));
    } catch (error) {
      console.error('Error al refrescar usuario:', error);
    }
  }, []);

  return (
    <AuthContext.Provider value={{ ...state, login, signup, logout, refreshUser }}>
      {children}
    </AuthContext.Provider>
  );
}

// ─── Hook ─────────────────────────────────────────────────────

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth debe usarse dentro de un AuthProvider.');
  }
  return context;
}
