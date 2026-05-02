import { StyleSheet } from 'react-native';
import { colors, radius, shadows, typography, spacing } from '@/constantes/tema';

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingHorizontal: spacing['2xl'],
  },

  // Logo
  logoContainer: {
    alignItems: 'center',
    marginBottom: spacing['3xl'],
  },
  logoBox: {
    width: 88,
    height: 88,
    borderRadius: radius['2xl'],
    backgroundColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    ...shadows.cardHeavy,
  },
  logoIcon: {
    fontSize: 40,
    color: colors.textWhite,
  },

  // Hero
  heroContainer: {
    alignItems: 'center',
    marginBottom: spacing['3xl'],
  },
  heroTitle: {
    ...typography.largeTitle,
    color: colors.textPrimary,
    textAlign: 'center',
    marginBottom: spacing.md,
  },
  heroDescription: {
    ...typography.body,
    color: colors.textMuted,
    textAlign: 'center',
    lineHeight: 22,
  },

  // Badges
  badgesContainer: {
    marginBottom: spacing['3xl'],
  },
  badgeIcon: {
    fontSize: 20,
  },

  // CTAs
  ctaContainer: {
    marginTop: 'auto',
  },
  primaryButton: {
    width: '100%',
    marginBottom: spacing.sm,
  },
});
