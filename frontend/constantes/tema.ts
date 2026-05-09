/**
 * HabitOS Design System
 * Paleta de azules (#D6E8EE → #001B48), Soft-UI, 24pt corners
 */

export const colors = {
  // Primarios
  background: '#D6E8EE',
  primary: '#018ABE',
  textDark: '#001B48',
  accentDeep: '#02457A',
  blueLight: '#97CADB',

  // Superficies
  card: '#FFFFFF',
  cardMuted: '#EFF7FA',
  cardDeep: '#018ABE',

  // Texto
  textPrimary: '#001B48',
  textSecondary: '#02457A',
  textMuted: '#5A8A9E',
  textWhite: '#FFFFFF',
  textLight: '#97CADB',

  // Estados
  success: '#2DD4A8',
  warning: '#F5A623',
  danger: '#EF4444',

  // Bordes / Separadores
  border: '#D6E8EE',
  borderLight: 'rgba(1, 138, 190, 0.15)',
} as const;

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  '2xl': 24,
  '3xl': 32,
  '4xl': 40,
} as const;

export const radius = {
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  '2xl': 24,
  full: 9999,
} as const;

export const shadows = {
  card: {
    shadowColor: '#001B48',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 16,
    elevation: 3,
  },
  cardHeavy: {
    shadowColor: '#001B48',
    shadowOffset: { width: 0, height: 8 },
    shadowOpacity: 0.1,
    shadowRadius: 24,
    elevation: 5,
  },
  soft: {
    shadowColor: '#001B48',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04,
    shadowRadius: 8,
    elevation: 2,
  },
} as const;

export const typography = {
  largeTitle: {
    fontFamily: 'Outfit-Bold',
    fontSize: 32,
    fontWeight: '700' as const,
    lineHeight: 38,
    letterSpacing: -0.5,
  },
  title1: {
    fontFamily: 'Outfit-Bold',
    fontSize: 26,
    fontWeight: '700' as const,
    lineHeight: 32,
    letterSpacing: -0.3,
  },
  title2: {
    fontFamily: 'Outfit-SemiBold',
    fontSize: 22,
    fontWeight: '600' as const,
    lineHeight: 28,
  },
  title3: {
    fontFamily: 'Outfit-SemiBold',
    fontSize: 18,
    fontWeight: '600' as const,
    lineHeight: 24,
  },
  headline: {
    fontFamily: 'Outfit-SemiBold',
    fontSize: 16,
    fontWeight: '600' as const,
    lineHeight: 22,
  },
  body: {
    fontFamily: 'Outfit-Regular',
    fontSize: 15,
    fontWeight: '400' as const,
    lineHeight: 22,
  },
  callout: {
    fontFamily: 'Outfit-Regular',
    fontSize: 14,
    fontWeight: '400' as const,
    lineHeight: 20,
  },
  subhead: {
    fontFamily: 'Outfit-Medium',
    fontSize: 13,
    fontWeight: '500' as const,
    lineHeight: 18,
  },
  footnote: {
    fontFamily: 'Outfit-Regular',
    fontSize: 12,
    fontWeight: '400' as const,
    lineHeight: 16,
  },
  caption: {
    fontFamily: 'Outfit-Medium',
    fontSize: 11,
    fontWeight: '500' as const,
    lineHeight: 14,
    letterSpacing: 0.5,
    textTransform: 'uppercase' as const,
  },
} as const;
