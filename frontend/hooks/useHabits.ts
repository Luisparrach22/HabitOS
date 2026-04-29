import { useState, useEffect } from 'react';
import { api } from '../services/api';

// Interfaz alineada con el schema de Prisma
export interface Habit {
  id: string;
  userId: string;
  name: string;
  description: string | null;
  trigger: string | null;
  frequency: string;
  color: string | null;
  icon: string | null;
  currentStreak: number;
  maxStreak: number;
  shields: number;
}

export const useHabits = () => {
  const [habits, setHabits] = useState<Habit[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchHabits = async () => {
      try {
        setLoading(true);
        const data = await api.getHabits();
        setHabits(data);
        setError(null);
      } catch (err) {
        setError('Error al cargar los hábitos. Verifica la conexión.');
      } finally {
        setLoading(false);
      }
    };

    fetchHabits();
  }, []);

  return { habits, loading, error };
};
