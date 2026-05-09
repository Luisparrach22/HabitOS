import React, { useState } from "react";
import { StatusBar } from "expo-status-bar";
import {
  Platform,
  View,
  Text,
  TextInput,
  Pressable,
  ScrollView,
  Alert,
  ActivityIndicator,
} from "react-native";
import { useRouter } from "expo-router";
import { FontAwesome5, Feather } from "@expo/vector-icons";
import { styles } from "@/estilos/crear_habito.styles";
import { useCreateHabit } from "@/hooks/usarHabitos";

const ICONS = ["tint", "book-open", "moon", "dumbbell", "brain", "leaf"];
const FREQUENCIES = ["Daily", "Weekly", "Mon–Fri", "Custom"];

export default function CrearHabitoScreen() {
  const router = useRouter();
  const createHabitMutation = useCreateHabit();
  
  const [habitName, setHabitName] = useState("");
  const [selectedIcon, setSelectedIcon] = useState(4); // Brain selected by default
  const [selectedFrequency, setSelectedFrequency] = useState(0); // Daily selected by default
  const [habitStack, setHabitStack] = useState("");
  const [reminderEnabled, setReminderEnabled] = useState(true);

  const handleCreateHabit = async () => {
    if (!habitName.trim()) {
      Alert.alert("Error", "Please enter a habit name.");
      return;
    }

    try {
      await createHabitMutation.mutateAsync({
        name: habitName.trim(),
        icon: ICONS[selectedIcon],
        frequency: FREQUENCIES[selectedFrequency] === "Weekly" ? "WEEKLY" : "DAILY",
        trigger: habitStack.trim() || undefined,
      });
      router.back();
    } catch (error: any) {
      const message = error.response?.data?.error || "Failed to create habit.";
      Alert.alert("Error", message);
    }
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.headerContainer}>
        <Pressable style={styles.closeButton} onPress={() => router.back()}>
          <Feather name="x" size={20} color="#001B48" />
        </Pressable>
        <Text style={styles.headerTitle}>New Habit</Text>
        <View style={styles.headerSpacer} />
      </View>

      <ScrollView
        style={styles.contentContainer}
        contentContainerStyle={styles.scrollGap}
        showsVerticalScrollIndicator={false}
      >
        {/* Habit Name */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>HABIT NAME</Text>
          <View style={styles.inputContainer}>
            <TextInput
              style={styles.inputText}
              value={habitName}
              onChangeText={setHabitName}
              placeholder="e.g. Drink Water"
              placeholderTextColor="#97CADB"
            />
          </View>
        </View>

        {/* Icon Picker */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>ICON</Text>
          <View style={styles.iconsRow}>
            {ICONS.map((iconName, index) => {
              const isActive = index === selectedIcon;
              return (
                <Pressable
                  key={index}
                  onPress={() => setSelectedIcon(index)}
                  style={[
                    styles.iconBox,
                    isActive ? styles.iconBoxActive : styles.iconBoxInactive,
                  ]}
                >
                  <FontAwesome5
                    name={iconName}
                    size={20}
                    color={isActive ? "#ffffff" : "#02457A"}
                  />
                </Pressable>
              );
            })}
          </View>
        </View>

        {/* Frequency Picker */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>FREQUENCY</Text>
          <View style={styles.frequencyGrid}>
            {FREQUENCIES.map((freq, index) => {
              const isActive = index === selectedFrequency;
              return (
                <Pressable
                  key={index}
                  onPress={() => setSelectedFrequency(index)}
                  style={[
                    styles.frequencyPill,
                    isActive
                      ? styles.frequencyPillActive
                      : styles.frequencyPillInactive,
                  ]}
                >
                  <Text
                    style={
                      isActive
                        ? styles.frequencyTextActive
                        : styles.frequencyTextInactive
                    }
                  >
                    {freq}
                  </Text>
                </Pressable>
              );
            })}
          </View>
        </View>

        {/* Reminder */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>REMINDER</Text>
          <View style={styles.reminderBox}>
            <View style={styles.reminderIconBox}>
              <Feather name="bell" size={18} color="#018ABE" />
            </View>
            <View style={styles.reminderTextContainer}>
              <Text style={styles.reminderTime}>7:00 AM</Text>
              <Text style={styles.reminderDesc}>Gentle notification</Text>
            </View>

            <Pressable
              onPress={() => setReminderEnabled(!reminderEnabled)}
              style={[
                styles.toggleTrack,
                reminderEnabled
                  ? styles.toggleTrackActive
                  : styles.toggleTrackInactive,
                { alignItems: reminderEnabled ? "flex-end" : "flex-start" },
              ]}
            >
              <View style={styles.toggleThumb} />
            </Pressable>
          </View>
        </View>

        {/* Habit Stack */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>HABIT STACK</Text>
          <View style={styles.inputContainer}>
            <TextInput
              style={styles.inputText}
              value={habitStack}
              onChangeText={setHabitStack}
              placeholder="After I..."
              placeholderTextColor="#97CADB"
            />
          </View>
        </View>
      </ScrollView>

      {/* Create Button */}
      <Pressable 
        style={[styles.createButton, createHabitMutation.isPending && { opacity: 0.7 }]} 
        onPress={handleCreateHabit}
        disabled={createHabitMutation.isPending}
      >
        {createHabitMutation.isPending ? (
          <ActivityIndicator color="#ffffff" />
        ) : (
          <Text style={styles.createButtonText}>Create Habit</Text>
        )}
      </Pressable>

      <StatusBar style={Platform.OS === "ios" ? "dark" : "auto"} />
    </View>
  );
}
