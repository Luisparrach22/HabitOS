import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors, radius, shadows, typography, spacing } from '@/constantes/tema';

// ─── Types ────────────────────────────────────────────────────

interface TarjetaSugerenciaProps {
  title?: string;
  message: string;
  icon?: React.ReactNode;
}

// ─── Component ────────────────────────────────────────────────

export default function TarjetaSugerencia({
  title = 'Behavioral Nudge',
  message,
  icon,
}: TarjetaSugerenciaProps) {
  return (
    <View style={styles.container}>
      {/* Icon */}
      <View style={styles.iconContainer}>
        {icon || <Text style={styles.defaultIcon}>💡</Text>}
      </View>

      {/* Text content */}
      <View style={styles.textContainer}>
        <Text style={styles.title}>{title}</Text>
        <Text style={styles.message}>{message}</Text>
      </View>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    backgroundColor: colors.primary,
    borderRadius: radius['2xl'],
    padding: spacing.lg,
    ...shadows.card,
  },
  iconContainer: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: spacing.md,
  },
  defaultIcon: {
    fontSize: 18,
  },
  textContainer: {
    flex: 1,
  },
  title: {
    ...typography.subhead,
    color: colors.textWhite,
    fontWeight: '700',
    marginBottom: 2,
  },
  message: {
    ...typography.callout,
    color: 'rgba(255, 255, 255, 0.85)',
    lineHeight: 19,
  },
});
