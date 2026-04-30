import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  StatusBar,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { colors, radius, shadows, typography, spacing } from '@/constants/theme';
import ActionButton from '@/components/ActionButton';
import FeatureBadge from '@/components/FeatureBadge';

const { width } = Dimensions.get('window');

export default function OnboardingScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();

  return (
    <View style={[styles.container, { paddingTop: insets.top + 40 }]}>
      <StatusBar barStyle="dark-content" />

      {/* App Logo */}
      <View style={styles.logoContainer}>
        <View style={styles.logoBox}>
          <Text style={styles.logoIcon}>✦</Text>
        </View>
      </View>

      {/* Hero Copy */}
      <View style={styles.heroContainer}>
        <Text style={styles.heroTitle}>
          Small habits,{'\n'}profound change.
        </Text>
        <Text style={styles.heroDescription}>
          HabitOS uses behavioral science to help{'\n'}you build routines that actually stick.
        </Text>
      </View>

      {/* Feature Badges */}
      <View style={styles.badgesContainer}>
        <FeatureBadge
          icon={<Text style={styles.badgeIcon}>🧠</Text>}
          label="Science-backed nudges"
        />
        <FeatureBadge
          icon={<Text style={styles.badgeIcon}>📈</Text>}
          label="Streak momentum tracking"
        />
      </View>

      {/* CTAs */}
      <View style={[styles.ctaContainer, { paddingBottom: insets.bottom + 20 }]}>
        <ActionButton
          title="Get Started"
          onPress={() => router.push('/login')}
          variant="primary"
          style={styles.primaryButton}
        />
        <ActionButton
          title="I already have an account"
          onPress={() => router.push('/login')}
          variant="ghost"
        />
      </View>
    </View>
  );
}

// ─── Styles ───────────────────────────────────────────────────

const styles = StyleSheet.create({
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
