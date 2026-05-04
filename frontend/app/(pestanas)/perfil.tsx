import React from "react";
import {
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  SafeAreaView,
} from "react-native";
import { Feather } from "@expo/vector-icons";
import { styles } from "../../estilos/perfil.styles";
import { colors } from "../../constantes/tema";

const settings = [
  { icon: "bell", label: "Notificaciones", hint: "Diario 7:00 AM" },
  { icon: "moon", label: "Apariencia", hint: "Sistema" },
  { icon: "shield", label: "Privacidad", hint: "" },
  { icon: "help-circle", label: "Ayuda y Soporte", hint: "" },
];

export default function ProfileScreen() {
  return (
    <SafeAreaView style={styles.safeArea}>
      <ScrollView
        style={styles.container}
        contentContainerStyle={styles.contentContainer}
      >
        <Text style={styles.headerTitle}>Perfil</Text>

        {/* Tarjeta de Perfil */}
        <View style={styles.profileCard}>
          <View style={styles.avatarContainer}>
            <Text style={styles.avatarText}>A</Text>
          </View>
          <View style={styles.profileInfo}>
            <Text style={styles.nameText}>Alex Morgan</Text>
            <Text style={styles.emailText}>alex@habitos.app</Text>
            <View style={styles.premiumBadge}>
              <Feather name="award" color={colors.primary} size={14} />
              <Text style={styles.premiumText}>Miembro Premium</Text>
            </View>
          </View>
        </View>

        {/* Estadísticas */}
        <View style={styles.statsContainer}>
          {[
            { val: "12", label: "Hábitos" },
            { val: "47", label: "Racha" },
            { val: "834", label: "Check-ins" },
          ].map((s, index) => (
            <View key={index} style={styles.statCard}>
              <Text style={styles.statValue}>{s.val}</Text>
              <Text style={styles.statLabel}>{s.label}</Text>
            </View>
          ))}
        </View>

        {/* Ajustes */}
        <View style={styles.settingsContainer}>
          {settings.map((s, i) => (
            <TouchableOpacity
              key={i}
              style={[
                styles.settingRow,
                i < settings.length - 1 && styles.settingRowBorder,
              ]}
            >
              <View style={styles.settingIconContainer}>
                <Feather
                  name={s.icon as keyof typeof Feather.glyphMap}
                  color={colors.primary}
                  size={20}
                />
              </View>
              <Text style={styles.settingLabel}>{s.label}</Text>
              {s.hint ? <Text style={styles.settingHint}>{s.hint}</Text> : null}
              <Feather
                name="chevron-right"
                color={colors.blueLight}
                size={20}
              />
            </TouchableOpacity>
          ))}
        </View>

        <Text style={styles.versionText}>HabitOS v2.4.1</Text>
      </ScrollView>
    </SafeAreaView>
  );
}
