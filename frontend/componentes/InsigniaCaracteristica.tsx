import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, radius, shadows, typography, spacing } from '@/constantes/tema';

// ─── Types ────────────────────────────────────────────────────

interface InsigniaCaracteristicaProps {
  icon: React.ReactNode;
  label: string;
}

// ─── Component ────────────────────────────────────────────────

export default function InsigniaCaracteristica({ icon, label }: InsigniaCaracteristicaProps) {
  return (
    <View style={styles.container}>
      <View style={styles.iconBox}>
        {icon}
      </View>
      <Text style={styles.label}>{label}</Text>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.card,
    borderRadius: radius['2xl'],
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    marginBottom: spacing.md,
    ...shadows.soft,
  },
  iconBox: {
    width: 40,
    height: 40,
    borderRadius: radius.md,
    backgroundColor: colors.cardMuted,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: spacing.md,
  },
  label: {
    ...typography.headline,
    color: colors.textPrimary,
  },
});
