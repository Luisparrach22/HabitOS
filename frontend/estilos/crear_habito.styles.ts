import { StyleSheet, Platform, Dimensions } from 'react-native';
import { colors, typography, spacing, radius, shadows } from '@/constantes/tema';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

// ─── Design Tokens (locales a esta pantalla) ──────────────────

const tokens = {
  darkText: colors.textPrimary,    // #001B48
  mutedText: colors.textSecondary, // #02457A
  primary: colors.primary,        // #018ABE
  borderLight: colors.blueLight,   // #97CADB
  bgLight: colors.cardMuted,       // #EFF7FA
  bgScreen: colors.background,     // #D6E8EE
  white: colors.card,              // #FFFFFF
};

export const styles = StyleSheet.create({

  // ─── Layout ──────────────────────────────────────────────────

  container: {
    flex: 1,
    backgroundColor: tokens.bgScreen,
  },
  contentContainer: {
    flex: 1,
  },
  scrollContent: {
    paddingHorizontal: spacing.xl,
    paddingTop: spacing.md,
    paddingBottom: 40,
    gap: spacing.xl,
  },

  // ─── Header ──────────────────────────────────────────────────

  headerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: spacing.xl,
    paddingBottom: spacing.md,
    backgroundColor: tokens.bgScreen,
    zIndex: 10,
  },
  closeButton: {
    width: 40,
    height: 40,
    borderRadius: radius.md,
    backgroundColor: tokens.white,
    alignItems: 'center',
    justifyContent: 'center',
    ...shadows.soft,
  },
  headerTitle: {
    ...typography.headline,
    fontSize: 18,
    color: tokens.darkText,
    fontWeight: '700',
  },
  headerSpacer: {
    width: 40,
  },

  // ─── Section ─────────────────────────────────────────────────

  sectionContainer: {},
  sectionLabel: {
    ...typography.caption,
    color: tokens.mutedText,
    marginBottom: spacing.sm,
    paddingHorizontal: spacing.xs,
  },

  // ─── Input Fields ────────────────────────────────────────────

  inputCard: {
    backgroundColor: tokens.white,
    paddingHorizontal: spacing.lg,
    paddingVertical: 14,
    borderRadius: radius.xl,
    ...shadows.soft,
  },
  inputText: {
    ...typography.headline,
    color: tokens.darkText,
    padding: 0, // Reset default padding on Android
  },
  descriptionInput: {
    ...typography.body,
    color: tokens.darkText,
    padding: 0,
    minHeight: 60,
    textAlignVertical: 'top',
  },

  // ─── Icon Picker (Fila rápida) ───────────────────────────────

  iconsRow: {
    flexDirection: 'row',
    backgroundColor: tokens.white,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    borderRadius: radius.xl,
    justifyContent: 'space-between',
    alignItems: 'center',
    ...shadows.soft,
  },
  iconBox: {
    width: 46,
    height: 46,
    borderRadius: radius.lg,
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconBoxActive: {
    backgroundColor: tokens.primary,
    ...shadows.card,
    shadowColor: tokens.primary,
  },
  iconBoxInactive: {
    backgroundColor: tokens.bgLight,
  },
  iconBoxPlus: {
    backgroundColor: tokens.bgLight,
    borderWidth: 1.5,
    borderColor: tokens.borderLight,
    borderStyle: 'dashed',
  },

  // ─── Color Picker ────────────────────────────────────────────

  colorRow: {
    flexDirection: 'row',
    backgroundColor: tokens.white,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.md,
    borderRadius: radius.xl,
    justifyContent: 'space-between',
    alignItems: 'center',
    ...shadows.soft,
  },
  colorDot: {
    width: 32,
    height: 32,
    borderRadius: 16,
  },
  colorDotActive: {
    borderWidth: 3,
    borderColor: tokens.white,
    ...shadows.card,
  },
  colorCheckmark: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    alignItems: 'center',
    justifyContent: 'center',
  },

  // ─── Frequency Picker ────────────────────────────────────────

  frequencyRow: {
    flexDirection: 'row',
    gap: spacing.sm,
  },
  frequencyPill: {
    flex: 1,
    paddingVertical: 14,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: radius.xl,
    ...shadows.soft,
  },
  frequencyPillActive: {
    backgroundColor: tokens.primary,
    shadowColor: tokens.primary,
  },
  frequencyPillInactive: {
    backgroundColor: tokens.white,
  },
  frequencyTextActive: {
    ...typography.subhead,
    color: tokens.white,
    fontWeight: '700',
  },
  frequencyTextInactive: {
    ...typography.subhead,
    color: tokens.darkText,
  },
  frequencyIcon: {
    marginBottom: 4,
  },

  // ─── Reminder ────────────────────────────────────────────────

  reminderCard: {
    flexDirection: 'row',
    backgroundColor: tokens.white,
    paddingHorizontal: spacing.lg,
    paddingVertical: 14,
    borderRadius: radius.xl,
    alignItems: 'center',
    ...shadows.soft,
  },
  reminderIconBox: {
    width: 42,
    height: 42,
    borderRadius: radius.md,
    backgroundColor: tokens.bgLight,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: spacing.md,
  },
  reminderTextContainer: {
    flex: 1,
  },
  reminderTime: {
    ...typography.headline,
    color: tokens.darkText,
  },
  reminderDesc: {
    ...typography.footnote,
    color: tokens.mutedText,
    marginTop: 1,
  },

  // ─── Toggle ──────────────────────────────────────────────────

  toggleTrack: {
    width: 50,
    height: 30,
    borderRadius: 15,
    justifyContent: 'center',
    paddingHorizontal: 3,
  },
  toggleTrackActive: {
    backgroundColor: tokens.primary,
  },
  toggleTrackInactive: {
    backgroundColor: '#CBD5E1',
  },
  toggleThumb: {
    width: 24,
    height: 24,
    borderRadius: 12,
    backgroundColor: tokens.white,
    ...shadows.soft,
  },

  // ─── CTA Button ──────────────────────────────────────────────

  createButton: {
    backgroundColor: tokens.primary,
    paddingVertical: 18,
    borderRadius: radius['2xl'],
    alignItems: 'center',
    marginHorizontal: spacing.xl,
    marginBottom: Platform.OS === 'ios' ? 36 : 24,
    marginTop: spacing.md,
    ...shadows.cardHeavy,
    shadowColor: tokens.primary,
  },
  createButtonText: {
    ...typography.headline,
    color: tokens.white,
    fontWeight: '700',
  },

  // ─── Modal (BottomSheet) ─────────────────────────────────────

  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0, 27, 72, 0.45)',
    justifyContent: 'flex-end',
  },
  modalContent: {
    backgroundColor: tokens.bgScreen,
    borderTopLeftRadius: 32,
    borderTopRightRadius: 32,
    paddingTop: spacing.md,
    paddingBottom: Platform.OS === 'ios' ? 44 : 24,
    maxHeight: '85%',
    ...shadows.cardHeavy,
  },
  modalHandle: {
    width: 40,
    height: 5,
    backgroundColor: tokens.borderLight,
    borderRadius: 10,
    alignSelf: 'center',
    marginBottom: spacing.lg,
  },
  modalHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.xl,
    marginBottom: spacing.lg,
  },
  modalTitle: {
    ...typography.title2,
    color: tokens.darkText,
  },

  // ─── Modal — Category Sections ───────────────────────────────

  categorySection: {
    marginBottom: spacing.xl,
    paddingHorizontal: spacing.xl,
  },
  categoryLabel: {
    ...typography.subhead,
    color: tokens.mutedText,
    marginBottom: spacing.md,
  },
  iconGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.sm,
  },
  modalIconBox: {
    width: (SCREEN_WIDTH - spacing.xl * 2 - spacing.sm * 4) / 5,
    aspectRatio: 1,
    borderRadius: radius.lg,
    alignItems: 'center',
    justifyContent: 'center',
  },
  modalIconBoxInactive: {
    backgroundColor: tokens.white,
    ...shadows.soft,
  },
  modalIconBoxActive: {
    backgroundColor: tokens.primary,
    ...shadows.card,
    shadowColor: tokens.primary,
  },

  // ─── Time Picker Modal ───────────────────────────────────────

  timePickerContainer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: spacing.xl,
    gap: spacing.md,
  },
  timeColumn: {
    width: 80,
    height: 180,
  },
  timeItem: {
    height: 60,
    justifyContent: 'center',
    alignItems: 'center',
  },
  timeText: {
    ...typography.title2,
    color: tokens.mutedText,
  },
  timeTextActive: {
    ...typography.largeTitle,
    color: tokens.primary,
  },
  timeSeparator: {
    ...typography.largeTitle,
    color: tokens.darkText,
    paddingBottom: 5,
  },
  amPmSelector: {
    flexDirection: 'column',
    gap: spacing.md,
    marginLeft: spacing.lg,
  },
  amPmButton: {
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    borderRadius: radius.md,
    backgroundColor: tokens.bgLight,
  },
  amPmButtonActive: {
    backgroundColor: tokens.primary,
    ...shadows.soft,
  },
  amPmText: {
    ...typography.headline,
    color: tokens.darkText,
  },
  amPmTextActive: {
    ...typography.headline,
    color: tokens.white,
  },
  modalPrimaryButton: {
    backgroundColor: tokens.primary,
    paddingVertical: 16,
    borderRadius: radius.xl,
    alignItems: 'center',
    marginTop: spacing.xl,
    ...shadows.soft,
  },
  modalPrimaryButtonText: {
    ...typography.headline,
    color: tokens.white,
  },

  // ─── Custom Frequency Days ───────────────────────────────────

  daysContainer: {
    marginTop: spacing.md,
    backgroundColor: tokens.white,
    padding: spacing.md,
    borderRadius: radius.xl,
    ...shadows.soft,
  },
  daysRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  dayCircle: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: tokens.bgLight,
    alignItems: 'center',
    justifyContent: 'center',
  },
  dayCircleActive: {
    backgroundColor: tokens.primary,
    ...shadows.soft,
  },
  dayText: {
    ...typography.headline,
    color: tokens.mutedText,
  },
  dayTextActive: {
    ...typography.headline,
    color: tokens.white,
  },
});
