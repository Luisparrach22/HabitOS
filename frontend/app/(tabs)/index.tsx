import React, { useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Pressable,
  ActivityIndicator,
  StatusBar,
  Alert,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { colors, radius, shadows, typography, spacing } from '@/constants/theme';
import { useAuth } from '@/context/AuthContext';
import { useHabits, useCheckinHabit, type Habit } from '@/hooks/useHabits';
import HabitCard from '@/components/HabitCard';
import ProgressBar from '@/components/ProgressBar';

// ─── Icon mapping (emoji fallback, replace with Lucide when installed) ─

const HABIT_ICONS: Record<string, string> = {
  water: '💧',
  book: '📖',
  sleep: '🌙',
  exercise: '🏃',
  meditate: '🧘',
  default: '⭐',
};

function getHabitIcon(icon: string | null): string {
  if (!icon) return HABIT_ICONS.default;
  return HABIT_ICONS[icon.toLowerCase()] || HABIT_ICONS.default;
}

function getTimeLabel(frequency: string, trigger: string | null): string {
  if (trigger) return trigger;
  switch (frequency) {
    case 'DAILY': return 'Anytime';
    case 'WEEKLY': return 'Weekly';
    default: return 'Custom';
  }
}

// ─── Component ────────────────────────────────────────────────

export default function DashboardScreen() {
  const insets = useSafeAreaInsets();
  const router = useRouter();
  const { user, refreshUser } = useAuth();
  const { data: habits, isLoading, error } = useHabits();
  const checkinMutation = useCheckinHabit();

  // Derived data
  const totalHabits = habits?.length || 0;
  const completedCount = habits?.filter((h) => h.completedToday).length || 0;

  // Max streak across all habits for the progress card
  const maxCurrentStreak = useMemo(() => {
    if (!habits || habits.length === 0) return 0;
    return Math.max(...habits.map((h) => h.currentStreak));
  }, [habits]);

  // Greeting based on time of day
  const greeting = useMemo(() => {
    const hour = new Date().getHours();
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }, []);

  // Date string
  const dateString = useMemo(() => {
    return new Date().toLocaleDateString('en-US', {
      weekday: 'long',
      month: 'short',
      day: 'numeric',
    });
  }, []);

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
    } catch (error: any) {
      const message =
        error.response?.data?.error || 'Failed to check in. Try again.';
      Alert.alert('Error', message);
    }
  };

  // ─── Loading state ──────────────────────────────────────────

  if (isLoading) {
    return (
      <View style={[styles.container, styles.centered]}>
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    );
  }

  // ─── Error state ────────────────────────────────────────────

  if (error) {
    return (
      <View style={[styles.container, styles.centered]}>
        <Text style={styles.errorText}>Failed to load habits.</Text>
      </View>
    );
  }

  // ─── Main render ────────────────────────────────────────────

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
          <ProgressBar
            completed={completedCount}
            total={totalHabits}
            currentStreak={maxCurrentStreak}
          />
        </View>

        {/* Today's Habits */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Today's Habits</Text>
          <Pressable>
            <Text style={styles.seeAllLink}>See all</Text>
          </Pressable>
        </View>

        {/* Habit List */}
        {habits && habits.length > 0 ? (
          habits.map((habit) => (
            <Pressable
              key={habit.id}
              onLongPress={() => router.push(`/(tabs)/habits/${habit.id}`)}
            >
              <HabitCard
                id={habit.id}
                name={habit.name}
                icon={<Text style={styles.habitIcon}>{getHabitIcon(habit.icon)}</Text>}
                streak={habit.currentStreak}
                timeLabel={getTimeLabel(habit.frequency, habit.trigger)}
                completedToday={habit.completedToday}
                onCheckin={handleCheckin}
              />
            </Pressable>
          ))
        ) : (
          <View style={styles.emptyContainer}>
            <Text style={styles.emptyIcon}>🌱</Text>
            <Text style={styles.emptyText}>
              No habits yet.{'\n'}Start building your routine!
            </Text>
          </View>
        )}
      </ScrollView>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  centered: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: spacing.xl,
    paddingBottom: 120,
  },

  // Header
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  headerText: {
    flex: 1,
  },
  dateText: {
    ...typography.subhead,
    color: colors.primary,
    marginBottom: 2,
  },
  greetingText: {
    ...typography.title1,
    color: colors.textPrimary,
  },
  avatar: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: colors.cardMuted,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: colors.border,
  },
  avatarText: {
    ...typography.headline,
    color: colors.textPrimary,
  },

  // Progress
  progressSection: {
    marginBottom: spacing['2xl'],
  },

  // Section header
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.lg,
  },
  sectionTitle: {
    ...typography.title3,
    color: colors.textPrimary,
  },
  seeAllLink: {
    ...typography.subhead,
    color: colors.primary,
  },

  // Habit icons
  habitIcon: {
    fontSize: 22,
  },

  // Empty state
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: spacing['4xl'],
  },
  emptyIcon: {
    fontSize: 48,
    marginBottom: spacing.lg,
  },
  emptyText: {
    ...typography.body,
    color: colors.textMuted,
    textAlign: 'center',
  },

  // Error
  errorText: {
    ...typography.body,
    color: colors.danger,
    textAlign: 'center',
  },
});
