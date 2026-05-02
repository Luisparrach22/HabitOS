import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, radius, typography, spacing, shadows } from '@/constantes/tema';

// ─── Types ────────────────────────────────────────────────────

interface GraficoSemanalProps {
  /** Array of 7 completion values (0 to 1) for Mon–Sun */
  data: number[];
  /** Label for the date range, e.g. "Apr 20 – 26" */
  dateRange: string;
}

const DAYS = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
const BAR_MAX_HEIGHT = 80;

// ─── Component ────────────────────────────────────────────────

export default function GraficoSemanal({ data, dateRange }: GraficoSemanalProps) {
  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.title}>This Week</Text>
        <Text style={styles.dateRange}>{dateRange}</Text>
      </View>

      {/* Bars */}
      <View style={styles.barsContainer}>
        {DAYS.map((day, index) => {
          const value = data[index] ?? 0;
          const barHeight = Math.max(value * BAR_MAX_HEIGHT, 6);
          const isActive = value > 0;

          return (
            <View key={`${day}-${index}`} style={styles.barColumn}>
              <View style={styles.barTrack}>
                <View
                  style={[
                    styles.barFill,
                    {
                      height: barHeight,
                      backgroundColor: isActive
                        ? colors.primary
                        : colors.border,
                    },
                  ]}
                />
              </View>
              <Text style={[styles.dayLabel, isActive && styles.dayLabelActive]}>
                {day}
              </Text>
            </View>
          );
        })}
      </View>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.card,
    borderRadius: radius['2xl'],
    padding: spacing.xl,
    ...shadows.soft,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  title: {
    ...typography.headline,
    color: colors.textPrimary,
  },
  dateRange: {
    ...typography.subhead,
    color: colors.primary,
  },
  barsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-end',
    height: BAR_MAX_HEIGHT + 24,
  },
  barColumn: {
    flex: 1,
    alignItems: 'center',
  },
  barTrack: {
    justifyContent: 'flex-end',
    height: BAR_MAX_HEIGHT,
  },
  barFill: {
    width: 24,
    borderRadius: 6,
  },
  dayLabel: {
    ...typography.footnote,
    color: colors.textMuted,
    marginTop: spacing.sm,
  },
  dayLabelActive: {
    color: colors.textPrimary,
    fontWeight: '600',
  },
});
