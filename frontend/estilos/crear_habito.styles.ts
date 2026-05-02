import { StyleSheet, Platform } from 'react-native';

// Colores del diseño de Figma
const designColors = {
  darkText: '#001B48',
  mutedText: '#02457A',
  primary: '#018ABE',
  borderLight: '#97CADB',
  bgLight: '#D6E8EE',
  white: '#ffffff',
};

export const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: designColors.white, // O usar el color de fondo general si lo prefieres, pero el figma sugiere fondo blanco/claro
    paddingHorizontal: 24,
    paddingTop: Platform.OS === 'ios' ? 12 : 24,
    paddingBottom: 32,
  },
  
  // Header
  headerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 24,
  },
  closeButton: {
    width: 40,
    height: 40,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: designColors.borderLight,
    backgroundColor: designColors.white,
    alignItems: 'center',
    justifyContent: 'center',
  },
  headerTitle: {
    color: designColors.darkText,
    fontSize: 17,
    fontWeight: '700',
  },
  headerSpacer: {
    width: 40,
  },

  // Content
  contentContainer: {
    flex: 1,
  },
  scrollGap: {
    paddingBottom: 20,
    gap: 20,
  },
  
  // Section Structure
  sectionContainer: {
    marginBottom: 20,
  },
  sectionLabel: {
    color: designColors.mutedText,
    fontSize: 12,
    fontWeight: '600',
    letterSpacing: 0.5,
    marginBottom: 8,
    paddingHorizontal: 4,
    textTransform: 'uppercase',
  },

  // Text Inputs
  inputContainer: {
    backgroundColor: designColors.white,
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: designColors.borderLight,
  },
  inputText: {
    color: designColors.darkText,
    fontSize: 16,
    fontWeight: '500',
  },

  // Icons Picker
  iconsRow: {
    flexDirection: 'row',
    backgroundColor: designColors.white,
    paddingHorizontal: 12,
    paddingVertical: 12,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: designColors.borderLight,
    justifyContent: 'space-between',
  },
  iconBox: {
    width: 44,
    height: 44,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
  },
  iconBoxActive: {
    backgroundColor: designColors.primary,
  },
  iconBoxInactive: {
    backgroundColor: designColors.bgLight,
  },

  // Frequency Picker
  frequencyGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
    justifyContent: 'space-between',
  },
  frequencyPill: {
    width: '48%',
    paddingVertical: 12,
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 18,
  },
  frequencyPillActive: {
    backgroundColor: designColors.primary,
  },
  frequencyPillInactive: {
    backgroundColor: designColors.white,
    borderWidth: 1,
    borderColor: designColors.borderLight,
  },
  frequencyTextActive: {
    color: designColors.white,
    fontSize: 14,
    fontWeight: '600',
  },
  frequencyTextInactive: {
    color: designColors.darkText,
    fontSize: 14,
    fontWeight: '600',
  },

  // Reminder Box
  reminderBox: {
    flexDirection: 'row',
    backgroundColor: designColors.white,
    paddingHorizontal: 16,
    paddingVertical: 16,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: designColors.borderLight,
    alignItems: 'center',
  },
  reminderIconBox: {
    width: 40,
    height: 40,
    borderRadius: 12,
    backgroundColor: designColors.bgLight,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: 12,
  },
  reminderTextContainer: {
    flex: 1,
  },
  reminderTime: {
    color: designColors.darkText,
    fontSize: 14,
    fontWeight: '600',
  },
  reminderDesc: {
    color: designColors.mutedText,
    fontSize: 12,
    marginTop: 2,
  },

  // Custom Toggle Switch
  toggleTrack: {
    width: 48,
    height: 28,
    borderRadius: 14,
    justifyContent: 'center',
    paddingHorizontal: 3,
  },
  toggleTrackActive: {
    backgroundColor: designColors.primary,
  },
  toggleTrackInactive: {
    backgroundColor: '#cbd5e1', // Slate-300 fallback
  },
  toggleThumb: {
    width: 22,
    height: 22,
    borderRadius: 11,
    backgroundColor: designColors.white,
  },

  // Action Button
  createButton: {
    backgroundColor: designColors.primary,
    paddingVertical: 16,
    borderRadius: 24,
    alignItems: 'center',
    marginTop: 16,
    shadowColor: designColors.primary,
    shadowOffset: { width: 0, height: 12 },
    shadowOpacity: 0.5,
    shadowRadius: 24,
    elevation: 8,
  },
  createButtonText: {
    color: designColors.white,
    fontSize: 16,
    fontWeight: '600',
  },
});
