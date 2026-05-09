import axios from 'axios';
import * as SecureStore from 'expo-secure-store';

const API_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:4000/api';

export const TOKEN_KEY = 'habitos_auth_token';

/**
 * Instancia de Axios preconfigurada.
 * Inyecta automáticamente el token JWT en cada request.
 */
const apiClient = axios.create({
  baseURL: API_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor: adjunta el token a cada request
apiClient.interceptors.request.use(
  async (config) => {
    try {
      const token = await SecureStore.getItemAsync(TOKEN_KEY);
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
    } catch (error) {
      // SecureStore puede fallar en web — silenciar
      console.warn('SecureStore no disponible:', error);
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Interceptor de respuesta: manejo global de errores
apiClient.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expirado o inválido — se maneja en ContextoAuth
      console.warn('Token expirado. Redirigiendo a login...');
    }
    return Promise.reject(error);
  }
);

export default apiClient;

// ─── API Functions ─────────────────────────────────────────────

// Auth
export const authApi = {
  signup: (email: string, password: string, name?: string, timezone?: string) =>
    apiClient.post('/auth/signup', { email, password, name, timezone }),

  login: (email: string, password: string) =>
    apiClient.post('/auth/login', { email, password }),

  getMe: () =>
    apiClient.get('/auth/me'),
};

// Habits
export const habitsApi = {
  getAll: () =>
    apiClient.get('/habits'),

  create: (data: {
    name: string;
    description?: string;
    trigger?: string;
    frequency?: string;
    color?: string;
    icon?: string;
  }) =>
    apiClient.post('/habits', data),

  update: (id: string, data: Record<string, unknown>) =>
    apiClient.put(`/habits/${id}`, data),

  delete: (id: string) =>
    apiClient.delete(`/habits/${id}`),

  checkin: (id: string) =>
    apiClient.post(`/habits/${id}/checkin`),
};
