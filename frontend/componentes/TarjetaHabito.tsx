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
  color?: string;
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
  color,
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
        <Text style={styles.name} numberOfLines={1} ellipsizeMode="tail">{name}</Text>
        <View style={styles.metaRow}>
          <Text style={styles.metaText} numberOfLines={1} ellipsizeMode="tail">
            {timeLabel}
          </Text>
        </View>
      </View>

      {/* Right Side */}
      <View style={styles.rightSide}>
        {streak > 0 && (
          <View style={styles.streakBadge}>
            <Text style={styles.streakBadgeText}>{streak}</Text>
            <Text style={styles.streakBadgeIcon}>🔥</Text>
          </View>
        )}
        
        {/* Checkbox */}
        <View style={styles.checkboxContainer}>
        {completedToday ? (
          <View style={styles.checkboxDone}>
            <Text style={styles.checkmark}>✓</Text>
          </View>
        ) : (
          <View style={[styles.checkboxEmpty, color ? { borderColor: color } : null]} />
        )}
        </View>
      </View>
    </Pressable>
  );
}

// ─── Componente Estilos ───────────────────────────────────────────
