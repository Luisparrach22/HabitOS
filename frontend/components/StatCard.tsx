import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, radius, typography, spacing } from '@/constants/theme';

// ─── Types ────────────────────────────────────────────────────

interface StatCardProps {
  value: string | number;
  label: string;
  icon?: React.ReactNode;
}

// ─── Component ────────────────────────────────────────────────

export default function StatCard({ value, label, icon }: StatCardProps) {
  return (
    <View style={styles.container}>
      {icon && <View style={styles.iconRow}>{icon}</View>}
      <Text style={styles.value}>{value}</Text>
      <Text style={styles.label}>{label}</Text>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    backgroundColor: colors.card,
    borderRadius: radius.xl,
    paddingVertical: spacing.lg,
    paddingHorizontal: spacing.sm,
  },
  iconRow: {
    marginBottom: spacing.xs,
  },
  value: {
    ...typography.title1,
    color: colors.textPrimary,
    fontWeight: '800',
  },
  label: {
    ...typography.footnote,
    color: colors.textMuted,
    marginTop: 2,
  },
});
