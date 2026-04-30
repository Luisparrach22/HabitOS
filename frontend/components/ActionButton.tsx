import React from 'react';
import { Pressable, Text, StyleSheet, ViewStyle, TextStyle } from 'react-native';
import { colors, radius, shadows, typography, spacing } from '@/constants/theme';

// ─── Types ────────────────────────────────────────────────────

interface ActionButtonProps {
  title: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary' | 'ghost';
  disabled?: boolean;
  style?: ViewStyle;
  textStyle?: TextStyle;
  icon?: React.ReactNode;
}

// ─── Component ────────────────────────────────────────────────

export default function ActionButton({
  title,
  onPress,
  variant = 'primary',
  disabled = false,
  style,
  textStyle,
  icon,
}: ActionButtonProps) {
  const buttonStyles = variantStyles[variant];

  return (
    <Pressable
      style={({ pressed }) => [
        styles.base,
        buttonStyles.container,
        pressed && styles.pressed,
        disabled && styles.disabled,
        style,
      ]}
      onPress={onPress}
      disabled={disabled}
    >
      {icon && icon}
      <Text style={[styles.baseText, buttonStyles.text, textStyle]}>
        {title}
      </Text>
    </Pressable>
  );
}

// ─── Styles ───────────────────────────────────────────────────

const styles = StyleSheet.create({
  base: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius['2xl'],
    paddingVertical: spacing.lg,
    paddingHorizontal: spacing['2xl'],
    gap: spacing.sm,
  },
  baseText: {
    ...typography.headline,
    fontWeight: '700',
  },
  pressed: {
    transform: [{ scale: 0.97 }],
    opacity: 0.9,
  },
  disabled: {
    opacity: 0.5,
  },
});

const variantStyles = {
  primary: StyleSheet.create({
    container: {
      backgroundColor: colors.primary,
      ...shadows.card,
    },
    text: {
      color: colors.textWhite,
    },
  }),
  secondary: StyleSheet.create({
    container: {
      backgroundColor: colors.card,
      borderWidth: 1.5,
      borderColor: colors.border,
    },
    text: {
      color: colors.textPrimary,
    },
  }),
  ghost: StyleSheet.create({
    container: {
      backgroundColor: 'transparent',
    },
    text: {
      color: colors.textMuted,
      fontWeight: '500',
    },
  }),
};
