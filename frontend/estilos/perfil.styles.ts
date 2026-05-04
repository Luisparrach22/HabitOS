import { StyleSheet } from "react-native";
import {
  colors,
  shadows,
  spacing,
  typography,
  radius,
} from "../constantes/tema";

export const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  container: {
    flex: 1,
  },
  contentContainer: {
    paddingHorizontal: spacing.xl,
    paddingTop: spacing.lg,
    paddingBottom: 120, // Espacio extra para que no lo tape la TabBar global
  },
  headerTitle: {
    ...typography.title1,
    color: colors.textDark,
    marginBottom: spacing.xl,
  },
  profileCard: {
    backgroundColor: colors.card,
    padding: spacing.xl,
    marginBottom: spacing.xl,
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    borderRadius: radius["2xl"],
    borderWidth: 1,
    borderColor: colors.borderLight,
    ...shadows.card,
  },
  avatarContainer: {
    width: 64,
    height: 64,
    borderRadius: radius.xl,
    backgroundColor: colors.primary,
    alignItems: "center",
    justifyContent: "center",
    shadowColor: colors.primary,
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.5,
    shadowRadius: 10,
    elevation: 8,
  },
  avatarText: {
    color: colors.textWhite,
    fontSize: 24,
    fontWeight: "700",
  },
  profileInfo: {
    flex: 1,
  },
  nameText: {
    ...typography.title3,
    color: colors.textDark,
  },
  emailText: {
    ...typography.callout,
    color: colors.textSecondary,
    marginTop: 2,
  },
  premiumBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    marginTop: 6,
  },
  premiumText: {
    ...typography.subhead,
    color: colors.primary,
  },
  statsContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: spacing.xl,
    gap: spacing.md,
  },
  statCard: {
    flex: 1,
    backgroundColor: colors.card,
    paddingVertical: spacing.lg,
    alignItems: "center",
    borderRadius: radius["2xl"],
    borderWidth: 1,
    borderColor: colors.borderLight,
    ...shadows.soft,
  },
  statValue: {
    ...typography.title2,
    color: colors.primary,
    fontWeight: "700",
  },
  statLabel: {
    ...typography.caption,
    color: colors.textSecondary,
    marginTop: 4,
    letterSpacing: 0,
    textTransform: "none",
  },
  settingsContainer: {
    backgroundColor: colors.card,
    borderRadius: radius["2xl"],
    borderWidth: 1,
    borderColor: colors.borderLight,
    marginBottom: spacing.xl,
    overflow: "hidden",
    ...shadows.soft,
  },
  settingRow: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    gap: spacing.md,
  },
  settingRowBorder: {
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  settingIconContainer: {
    width: 40,
    height: 40,
    borderRadius: radius.md,
    backgroundColor: colors.background,
    alignItems: "center",
    justifyContent: "center",
  },
  settingLabel: {
    ...typography.body,
    flex: 1,
    color: colors.textDark,
    fontWeight: "600",
  },
  settingHint: {
    ...typography.subhead,
    color: colors.textSecondary,
  },
  versionText: {
    ...typography.footnote,
    textAlign: "center",
    color: colors.textSecondary,
    marginTop: spacing.sm,
  },
});
