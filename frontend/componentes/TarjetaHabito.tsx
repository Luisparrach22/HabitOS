import React from 'react';
import { View, Text, Pressable, StyleSheet } from 'react-native';
import { colors, radius, shadows, typography, spacing } from '@/constantes/tema';
import { styles } from '@/estilos/TarjetaHabito.styles';

// ─── Types ────────────────────────────────────────────────────

interface TarjetaHabitoProps {
  id: string;
  name: string;
  icon: React.ReactNode;
  streak: number;
  timeLabel: string;
  completedToday: boolean;
  onCheckin: (id: string) => void;
}

// ─── Component ────────────────────────────────────────────────

export default function TarjetaHabito({
  id,
  name,
  icon,
  streak,
  timeLabel,
  completedToday,
  onCheckin,
}: TarjetaHabitoProps) {
  return (
    <Pressable
      style={({ pressed }) => [
        styles.container,
        pressed && !completedToday && styles.pressed,
      ]}
      onPress={() => !completedToday && onCheckin(id)}
      disabled={completedToday}
    >
      {/* Icon */}
      <View style={styles.iconContainer}>
        {icon}
      </View>

      {/* Info */}
      <View style={styles.infoContainer}>
        <Text style={styles.name}>{name}</Text>
        <View style={styles.metaRow}>
          <Text style={styles.streakIcon}>🔥</Text>
          <Text style={styles.metaText}>
            {streak} day streak · {timeLabel}
          </Text>
        </View>
      </View>

      {/* Checkbox */}
      <View style={styles.checkboxContainer}>
        {completedToday ? (
          <View style={styles.checkboxDone}>
            <Text style={styles.checkmark}>✓</Text>
          </View>
        ) : (
          <View style={styles.checkboxEmpty} />
        )}
      </View>
    </Pressable>
  );
}

// ─── Componente Estilos ───────────────────────────────────────────
