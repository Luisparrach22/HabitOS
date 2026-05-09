import React, { useMemo, useState } from 'react';
import {
  View,
  Text,
  ScrollView,
  Pressable,
  ActivityIndicator,
  StatusBar,
  Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { FontAwesome5, Feather } from '@expo/vector-icons';
import { colors, spacing } from '@/constantes/tema';
import { useAuth } from '@/contextos/ContextoAuth';
import { usarHabitos, useCheckinHabito, type Habit } from '@/hooks/usarHabitos';
import TarjetaHabito from '@/componentes/TarjetaHabito';
import BarraProgreso from '@/componentes/BarraProgreso';
import { dashboardStyles as styles } from '@/estilos/dashboard.styles';

// ─── Helpers ──────────────────────────────────────────────────

function getTimeLabel(frequency: string, trigger: string | null): string {
  if (trigger) return trigger;
  switch (frequency) {
    case 'DAILY':  return 'Every day';
    case 'WEEKLY': return 'Weekly';
    default:       return 'Custom';
  }
}

// ─── Component ────────────────────────────────────────────────

export default function DashboardScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { user, refreshUser } = useAuth();
  const { data: habits, isLoading, error } = usarHabitos();
  const checkinMutation = useCheckinHabito();

  // Toggle para mostrar/ocultar completados
  const [showCompleted, setShowCompleted] = useState(true);

  // ── Derived data ─────────────────────────────────────────────

  const { pendingHabits, completedHabits } = useMemo(() => {
    if (!habits) return { pendingHabits: [], completedHabits: [] };
    return {
      pendingHabits: habits.filter((h) => !h.completedToday),
      completedHabits: habits.filter((h) => h.completedToday),
    };
  }, [habits]);

  const totalHabits = habits?.length || 0;
  const completedCount = completedHabits.length;

  const maxCurrentStreak = useMemo(() => {
    if (!habits || habits.length === 0) return 0;
    return Math.max(...habits.map((h) => h.currentStreak));
  }, [habits]);

  const greeting = useMemo(() => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }, []);

  const dateString = useMemo(() => {
    return new Date().toLocaleDateString('en-US', {
      weekday: 'long',
      month: 'short',
      day: 'numeric',
    });
  }, []);

  // ── Handlers ─────────────────────────────────────────────────

  const handleCheckin = async (habitId: string) => {
    try {
      const result = await checkinMutation.mutateAsync(habitId);
      await refreshUser();

      if (result.leveledUp) {
        Alert.alert(
          '🎉 Level Up!',
          `Congratulations! You're now level ${result.newLevel}.`,
          [{ text: 'Awesome!' }]
        );
      }
    } catch (err: any) {
      const message = err.response?.data?.error || 'Failed to check in. Try again.';
      Alert.alert('Error', message);
    }
  };

  // ── Loading / Error states ───────────────────────────────────

  if (isLoading) {
    return (
      <View style={[styles.container, styles.centered]}>
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    );
  }

  if (error) {
    return (
      <View style={[styles.container, styles.centered]}>
        <Text style={styles.errorText}>Failed to load habits.</Text>
      </View>
    );
  }

  // ── Render helper ────────────────────────────────────────────

  const renderHabitCard = (habit: Habit) => (
    <Pressable
      key={habit.id}
      onLongPress={() => router.push(`/(pestanas)/habitos/${habit.id}`)}
    >
      <TarjetaHabito
        id={habit.id}
        name={habit.name}
        icon={
          <FontAwesome5
            name={habit.icon || 'star'}
            size={22}
            color={habit.color || colors.primary}
          />
        }
        streak={habit.currentStreak}
        timeLabel={getTimeLabel(habit.frequency, habit.trigger)}
        completedToday={habit.completedToday}
        color={habit.color || undefined}
        onCheckin={handleCheckin}
      />
    </Pressable>
  );

  // ── Main render ──────────────────────────────────────────────

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={[
          styles.scrollContent,
          { paddingTop: insets.top + spacing.lg },
        ]}
        showsVerticalScrollIndicator={false}
      >
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.headerText}>
            <Text style={styles.dateText}>{dateString}</Text>
            <Text style={styles.greetingText}>
              {greeting}, {user?.name || 'there'}
            </Text>
          </View>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>
              {(user?.name || 'U')[0].toUpperCase()}
            </Text>
          </View>
        </View>

        {/* Progress Card */}
        <View style={styles.progressSection}>
          <BarraProgreso
            completed={completedCount}
            total={totalHabits}
            currentStreak={maxCurrentStreak}
          />
        </View>

        {/* ── Pending Habits ── */}
        {totalHabits > 0 ? (
          <>
            <View style={styles.sectionHeader}>
              <Text style={styles.sectionTitle}>To Do</Text>
              <Text style={styles.sectionCount}>
                {pendingHabits.length} remaining
              </Text>
            </View>

            {pendingHabits.length > 0 ? (
              pendingHabits.map(renderHabitCard)
            ) : (
              <View style={styles.emptyContainer}>
                <Feather name="check-circle" size={40} color={colors.success} />
                <Text style={styles.emptyText}>
                  All done for today! 🎉{'\n'}Great job!
                </Text>
              </View>
            )}

            {/* ── Completed Habits ── */}
            {completedHabits.length > 0 && (
              <>
                <Pressable
                  style={styles.completedHeader}
                  onPress={() => setShowCompleted(!showCompleted)}
                >
                  <Text style={styles.completedTitle}>
                    ✓ Completed ({completedHabits.length})
                  </Text>
                  <View style={styles.completedToggle}>
                    <Text style={styles.completedToggleText}>
                      {showCompleted ? 'Hide' : 'Show'}
                    </Text>
                    <Feather
                      name={showCompleted ? 'chevron-up' : 'chevron-down'}
                      size={16}
                      color={colors.textMuted}
                    />
                  </View>
                </Pressable>

                {showCompleted && completedHabits.map(renderHabitCard)}
              </>
            )}
          </>
        ) : (
          <View style={styles.emptyContainer}>
            <FontAwesome5 name="seedling" size={48} color={colors.textMuted} />
            <Text style={styles.emptyText}>
              No habits yet.{'\n'}Start building your routine!
            </Text>
          </View>
        )}
      </ScrollView>
    </View>
  );
}
