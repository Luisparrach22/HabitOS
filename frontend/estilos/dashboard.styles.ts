import { StyleSheet } from 'react-native';
import { colors, radius, shadows, typography, spacing } from '@/constantes/tema';

export const dashboardStyles = StyleSheet.create({
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

  // ─── Header ──────────────────────────────────────────────────

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

  // ─── Progress ────────────────────────────────────────────────

  progressSection: {
    marginBottom: spacing['2xl'],
  },

  // ─── Section Header ──────────────────────────────────────────

  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.md,
    marginTop: spacing.sm,
  },
  sectionTitle: {
    ...typography.title3,
    color: colors.textPrimary,
  },
  sectionCount: {
    ...typography.subhead,
    color: colors.textMuted,
  },

  // ─── Completed Section ───────────────────────────────────────

  completedHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.md,
    marginTop: spacing['2xl'],
    paddingTop: spacing.lg,
    borderTopWidth: 1,
    borderTopColor: colors.borderLight,
  },
  completedTitle: {
    ...typography.headline,
    color: colors.success,
  },
  completedToggle: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
  },
  completedToggleText: {
    ...typography.footnote,
    color: colors.textMuted,
  },

  // ─── Empty State ─────────────────────────────────────────────

  emptyContainer: {
    alignItems: 'center',
    paddingVertical: spacing['4xl'],
    backgroundColor: colors.card,
    borderRadius: radius['2xl'],
    ...shadows.soft,
  },
  emptyText: {
    ...typography.body,
    color: colors.textMuted,
    textAlign: 'center',
    marginTop: spacing.md,
  },

  // ─── Error ───────────────────────────────────────────────────

  errorText: {
    ...typography.body,
    color: colors.danger,
    textAlign: 'center',
  },
});
