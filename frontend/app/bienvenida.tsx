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
import { colors, radius, shadows, typography, spacing } from '@/constantes/tema';
import BotonAccion from '@/componentes/BotonAccion';
import InsigniaCaracteristica from '@/componentes/InsigniaCaracteristica';
import { styles } from '@/estilos/bienvenida.styles';

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
        <InsigniaCaracteristica
          icon={<Text style={styles.badgeIcon}>🧠</Text>}
          label="Science-backed nudges"
        />
        <InsigniaCaracteristica
          icon={<Text style={styles.badgeIcon}>📈</Text>}
          label="Streak momentum tracking"
        />
      </View>

      {/* CTAs */}
      <View style={[styles.ctaContainer, { paddingBottom: insets.bottom + 20 }]}>
        <BotonAccion
          title="Get Started"
          onPress={() => router.push('/acceso')}
          variant="primary"
          style={styles.primaryButton}
        />
        <BotonAccion
          title="I already have an account"
          onPress={() => router.push('/acceso')}
          variant="ghost"
        />
      </View>
    </View>
  );
}

// ─── Componente Estilos ───────────────────────────────────────────
