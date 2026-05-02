import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, radius, shadows, typography, spacing } from '@/constantes/tema';

// ─── Types ────────────────────────────────────────────────────

interface BarraProgresoProps {
  completed: number;
  total: number;
  currentStreak: number;
}

// ─── Component ────────────────────────────────────────────────

export default function BarraProgreso({
  completed,
  total,
  currentStreak,
}: BarraProgresoProps) {
  const progress = total > 0 ? completed / total : 0;

  return (
    <View style={styles.container}>
      {/* Header row */}
      <View style={styles.headerRow}>
        <View style={styles.streakBadge}>
          <Text style={styles.streakIcon}>🔥</Text>
          <Text style={styles.streakLabel}>CURRENT STREAK</Text>
        </View>
        <View style={styles.dayBadge}>
          <Text style={styles.dayText}>Day {currentStreak}</Text>
        </View>
      </View>

      {/* Main text */}
      <Text style={styles.mainText}>
        You've completed{' '}
        <Text style={styles.mainTextBold}>{completed}</Text>
        {'\n'}of{' '}
        <Text style={styles.mainTextBold}>{total}</Text>
        {' '}habits today
      </Text>

      {/* Progress bar */}
      <View style={styles.barTrack}>
        <View style={[styles.barFill, { width: `${progress * 100}%` }]} />
      </View>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.accentDeep,
    borderRadius: radius['2xl'],
    padding: spacing.xl,
    ...shadows.cardHeavy,
  },
  headerRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  streakBadge: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  streakIcon: {
    fontSize: 14,
    marginRight: 6,
  },
  streakLabel: {
    ...typography.caption,
    color: colors.textWhite,
    opacity: 0.9,
  },
  dayBadge: {
    backgroundColor: 'rgba(255, 255, 255, 0.15)',
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
    borderRadius: radius.md,
  },
  dayText: {
    ...typography.subhead,
    color: colors.textWhite,
  },
  mainText: {
    ...typography.title2,
    color: colors.textWhite,
    marginBottom: spacing.lg,
  },
  mainTextBold: {
    fontWeight: '800',
  },
  barTrack: {
    height: 6,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    borderRadius: 3,
    overflow: 'hidden',
  },
  barFill: {
    height: '100%',
    backgroundColor: colors.textWhite,
    borderRadius: 3,
  },
});
