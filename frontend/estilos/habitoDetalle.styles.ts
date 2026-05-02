import { StyleSheet } from 'react-native';
import { colors, radius, shadows, typography, spacing } from '@/constantes/tema';

export const styles = StyleSheet.create({
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
