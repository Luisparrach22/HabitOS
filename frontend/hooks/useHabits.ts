import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { habitsApi } from '../services/api';

// ─── Types ────────────────────────────────────────────────────

export interface Habit {
  id: string;
  name: string;
  description: string | null;
  trigger: string | null;
  frequency: string;
  color: string | null;
  icon: string | null;
  currentStreak: number;
  maxStreak: number;
  shields: number;
  completedToday: boolean;
  totalCompletions: number;
  createdAt: string;
}

interface CheckinResult {
  log: { id: string; habitId: string; completedAt: string };
  habit: { id: string; name: string; currentStreak: number; maxStreak: number };
  user: { id: string; totalXp: number; level: number };
  xpEarned: number;
  leveledUp: boolean;
  newLevel: number;
}

// ─── Query Keys ───────────────────────────────────────────────

export const habitKeys = {
  all: ['habits'] as const,
  detail: (id: string) => ['habits', id] as const,
};

// ─── Fetch Habits ─────────────────────────────────────────────

export function useHabits() {
  return useQuery({
    queryKey: habitKeys.all,
    queryFn: async (): Promise<Habit[]> => {
      const response = await habitsApi.getAll();
      return response.data.data;
    },
    staleTime: 1000 * 60 * 2, // 2 minutos
  });
}

// ─── Create Habit ─────────────────────────────────────────────

export function useCreateHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: {
      name: string;
      description?: string;
      trigger?: string;
      frequency?: string;
      color?: string;
      icon?: string;
    }) => {
      const response = await habitsApi.create(data);
      return response.data.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: habitKeys.all });
    },
  });
}

// ─── Update Habit ─────────────────────────────────────────────

export function useUpdateHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, data }: { id: string; data: Record<string, unknown> }) => {
      const response = await habitsApi.update(id, data);
      return response.data.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: habitKeys.all });
    },
  });
}

// ─── Delete Habit ─────────────────────────────────────────────

export function useDeleteHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: string) => {
      const response = await habitsApi.delete(id);
      return response.data;
    },
    // Optimistic: quitar de la lista inmediatamente
    onMutate: async (deletedId) => {
      await queryClient.cancelQueries({ queryKey: habitKeys.all });
      const previous = queryClient.getQueryData<Habit[]>(habitKeys.all);

      queryClient.setQueryData<Habit[]>(habitKeys.all, (old) =>
        old ? old.filter((h) => h.id !== deletedId) : []
      );

      return { previous };
    },
    onError: (_err, _vars, context) => {
      if (context?.previous) {
        queryClient.setQueryData(habitKeys.all, context.previous);
      }
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: habitKeys.all });
    },
  });
}

// ─── Check-in (OPTIMISTIC UPDATE) ────────────────────────────

export function useCheckinHabit() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (habitId: string): Promise<CheckinResult> => {
      const response = await habitsApi.checkin(habitId);
      return response.data.data;
    },

    // ✨ OPTIMISTIC UPDATE: La UI cambia al instante
    onMutate: async (habitId) => {
      // 1. Cancelar queries en vuelo para evitar sobreescrituras
      await queryClient.cancelQueries({ queryKey: habitKeys.all });

      // 2. Snapshot del estado anterior (para rollback)
      const previousHabits = queryClient.getQueryData<Habit[]>(habitKeys.all);

      // 3. Actualizar optimistamente la caché
      queryClient.setQueryData<Habit[]>(habitKeys.all, (old) =>
        old
          ? old.map((habit) =>
              habit.id === habitId
                ? {
                    ...habit,
                    completedToday: true,
                    currentStreak: habit.currentStreak + 1,
                    maxStreak: Math.max(habit.currentStreak + 1, habit.maxStreak),
                    totalCompletions: habit.totalCompletions + 1,
                  }
                : habit
            )
          : []
      );

      // 4. Devolver contexto para rollback
      return { previousHabits };
    },

    // Rollback en caso de error
    onError: (_err, _habitId, context) => {
      if (context?.previousHabits) {
        queryClient.setQueryData(habitKeys.all, context.previousHabits);
      }
    },

    // Siempre refrescar después de la mutación (éxito o error)
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: habitKeys.all });
    },
  });
}
