import { StyleSheet } from 'react-native';
import { colors, radius, shadows, typography, spacing } from '@/constantes/tema';

export const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.card,
    borderRadius: radius['2xl'],
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadows.card,
  },
  pressed: {
    transform: [{ scale: 0.98 }],
    opacity: 0.9,
  },
  iconContainer: {
    width: 44,
    height: 44,
    borderRadius: radius.lg,
    backgroundColor: colors.cardMuted,
    alignItems: 'center',
    justifyContent: 'center',
  },
  infoContainer: {
    flex: 1,
    marginLeft: spacing.md,
  },
  name: {
    ...typography.headline,
    color: colors.textPrimary,
  },
  metaRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: 2,
  },
  metaText: {
    ...typography.footnote,
    color: colors.textMuted,
    flex: 1,
  },
  rightSide: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  streakBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: 'rgba(245, 166, 35, 0.15)',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: radius.full,
  },
  streakBadgeText: {
    ...typography.caption,
    color: colors.warning,
    fontWeight: '700',
    marginRight: 2,
  },
  streakBadgeIcon: {
    fontSize: 12,
  },
  checkboxContainer: {
    marginLeft: spacing.md,
  },
  checkboxDone: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: colors.success,
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkmark: {
    color: colors.textWhite,
    fontSize: 16,
    fontWeight: '700',
  },
  checkboxEmpty: {
    width: 32,
    height: 32,
    borderRadius: 16,
    borderWidth: 2.5,
    borderColor: colors.blueLight,
  },
});
