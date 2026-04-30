import React, { useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Pressable,
  ActivityIndicator,
  StatusBar,
} from 'react-native';
import { useLocalSearchParams, useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { colors, radius, shadows, typography, spacing } from '@/constants/theme';
import { useHabits } from '@/hooks/useHabits';
import StatCard from '@/components/StatCard';
import WeeklyChart from '@/components/WeeklyChart';
import NudgeCard from '@/components/NudgeCard';

// ─── Behavioral nudges library ────────────────────────────────

const NUDGES: Record<string, string> = {
  water: 'Stack this habit after brushing teeth to boost consistency by 40%.',
  book: 'Reading before bed reduces screen time and improves sleep quality.',
  sleep: 'A consistent bedtime builds your circadian rhythm. Your body will thank you.',
  exercise: 'Morning workouts increase daily energy levels by up to 20%.',
  meditate: 'Just 5 minutes of mindfulness rewires your brain for focus.',
  default: 'Consistency beats intensity. Small daily actions create lasting change.',
};

const HABIT_ICONS: Record<string, string> = {
  water: '💧',
  book: '📖',
  sleep: '🌙',
  exercise: '🏃',
  meditate: '🧘',
  default: '⭐',
};

// ─── Component ────────────────────────────────────────────────

export default function HabitDetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { data: habits, isLoading } = useHabits();

  // Find the habit
  const habit = useMemo(
    () => habits?.find((h) => h.id === id),
    [habits, id]
  );

  // Calculate completion rate
  const completionRate = useMemo(() => {
    if (!habit) return 0;
    // Estimate based on streak vs total days since creation
    const daysSinceCreation = Math.max(
      1,
      Math.ceil(
        (Date.now() - new Date(habit.createdAt).getTime()) / (1000 * 60 * 60 * 24)
      )
    );
    return Math.min(
      100,
      Math.round((habit.totalCompletions / daysSinceCreation) * 100)
    );
  }, [habit]);

  // Mock weekly data (in production, fetch from API)
  const weeklyData = useMemo(() => {
    if (!habit) return [0, 0, 0, 0, 0, 0, 0];
    // Generate plausible data based on streak
    const today = new Date().getDay(); // 0=Sun, 1=Mon...
    const todayIdx = today === 0 ? 6 : today - 1; // Convert to Mon=0 index
    const data: number[] = [];

    for (let i = 0; i < 7; i++) {
      if (i <= todayIdx) {
        // Past days: filled based on streak probability
        data.push(habit.currentStreak > 0 ? 1 : Math.random() > 0.3 ? 1 : 0);
      } else {
        // Future days: empty
        data.push(0);
      }
    }
    return data;
  }, [habit]);

  // Date range string
  const dateRange = useMemo(() => {
    const now = new Date();
    const dayOfWeek = now.getDay();
    const monday = new Date(now);
    monday.setDate(now.getDate() - (dayOfWeek === 0 ? 6 : dayOfWeek - 1));
    const sunday = new Date(monday);
    sunday.setDate(monday.getDate() + 6);

    const fmt = (d: Date) =>
      d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    return `${fmt(monday)} – ${fmt(sunday)}`;
  }, []);

  // Nudge text
  const nudgeText = useMemo(() => {
    if (!habit) return NUDGES.default;
    const key = habit.icon?.toLowerCase() || 'default';
    return NUDGES[key] || NUDGES.default;
  }, [habit]);

  const habitIcon = HABIT_ICONS[habit?.icon?.toLowerCase() || 'default'] || HABIT_ICONS.default;

  // ─── Loading ────────────────────────────────────────────────

  if (isLoading || !habit) {
    return (
      <View style={[styles.container, styles.centered]}>
        <ActivityIndicator size="large" color={colors.primary} />
      </View>
    );
  }

  // ─── Render ─────────────────────────────────────────────────

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
        {/* Header Navigation */}
        <View style={styles.navRow}>
          <Pressable
            style={styles.navButton}
            onPress={() => router.back()}
          >
            <Text style={styles.navIcon}>‹</Text>
          </Pressable>
          <Pressable style={styles.navButton}>
            <Text style={styles.navDots}>•••</Text>
          </Pressable>
        </View>

        {/* Habit Icon & Title */}
        <View style={styles.heroSection}>
          <View style={styles.heroIconBox}>
            <Text style={styles.heroIcon}>{habitIcon}</Text>
          </View>
          <Text style={styles.heroTitle}>{habit.name}</Text>
          <Text style={styles.heroSubtitle}>
            {habit.frequency === 'DAILY' ? 'Daily' : habit.frequency === 'WEEKLY' ? 'Weekly' : 'Custom'}
            {habit.trigger ? ` · ${habit.trigger}` : ' · Anytime'}
          </Text>
        </View>

        {/* Stats Row */}
        <View style={styles.statsRow}>
          <StatCard
            value={habit.currentStreak}
            label="Streak"
            icon={<Text style={styles.statIcon}>🔥</Text>}
          />
          <View style={styles.statSpacer} />
          <StatCard
            value={`${completionRate}%`}
            label="Rate"
            icon={<Text style={styles.statIcon}>📊</Text>}
          />
          <View style={styles.statSpacer} />
          <StatCard
            value={habit.totalCompletions}
            label="Total"
            icon={<Text style={styles.statIcon}>✅</Text>}
          />
        </View>

        {/* Weekly Chart */}
        <View style={styles.chartSection}>
          <WeeklyChart data={weeklyData} dateRange={dateRange} />
        </View>

        {/* Behavioral Nudge */}
        <View style={styles.nudgeSection}>
          <NudgeCard
            title="Behavioral Nudge"
            message={nudgeText}
          />
        </View>
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
    paddingBottom: 40,
  },

  // Navigation
  navRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing['2xl'],
  },
  navButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: colors.card,
    alignItems: 'center',
    justifyContent: 'center',
    ...shadows.soft,
  },
  navIcon: {
    fontSize: 24,
    color: colors.textPrimary,
    fontWeight: '600',
    marginTop: -2,
  },
  navDots: {
    fontSize: 16,
    color: colors.textPrimary,
    fontWeight: '700',
    letterSpacing: 2,
  },

  // Hero section
  heroSection: {
    alignItems: 'center',
    marginBottom: spacing['2xl'],
  },
  heroIconBox: {
    width: 72,
    height: 72,
    borderRadius: radius['2xl'],
    backgroundColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.lg,
    ...shadows.card,
  },
  heroIcon: {
    fontSize: 32,
  },
  heroTitle: {
    ...typography.title1,
    color: colors.textPrimary,
    textAlign: 'center',
    marginBottom: spacing.xs,
  },
  heroSubtitle: {
    ...typography.callout,
    color: colors.textMuted,
  },

  // Stats
  statsRow: {
    flexDirection: 'row',
    marginBottom: spacing.xl,
  },
  statSpacer: {
    width: spacing.md,
  },
  statIcon: {
    fontSize: 18,
  },

  // Chart
  chartSection: {
    marginBottom: spacing.xl,
  },

  // Nudge
  nudgeSection: {
    marginBottom: spacing.xl,
  },
});
