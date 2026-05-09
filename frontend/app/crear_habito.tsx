import React, { useState, useCallback } from 'react';
import { StatusBar } from 'expo-status-bar';
import {
  Platform,
  View,
  Text,
  TextInput,
  Pressable,
  ScrollView,
  Alert,
  ActivityIndicator,
  Modal,
  KeyboardAvoidingView,
} from 'react-native';
import { useRouter } from 'expo-router';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { FontAwesome5, Feather } from '@expo/vector-icons';
import { spacing } from '@/constantes/tema';
import { styles } from '@/estilos/crear_habito.styles';
import { useCreateHabit } from '@/hooks/usarHabitos';
import {
  DEFAULT_QUICK_ICONS,
  ICON_CATEGORIES,
  HABIT_COLORS,
  FREQUENCY_OPTIONS,
} from '@/constantes/iconos';

// ─── Component ────────────────────────────────────────────────

export default function CrearHabitoScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const createHabitMutation = useCreateHabit();

  // Form state
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [selectedIcon, setSelectedIcon] = useState('heartbeat');
  const [selectedColor, setSelectedColor] = useState(HABIT_COLORS[0].value);
  const [selectedFrequency, setSelectedFrequency] = useState('DAILY');
  const [trigger, setTrigger] = useState('');
  const [reminderEnabled, setReminderEnabled] = useState(false);

  // Modal state
  const [showIconModal, setShowIconModal] = useState(false);
  const [showTimeModal, setShowTimeModal] = useState(false);

  // Time picker state
  const [hour, setHour] = useState(7);
  const [minute, setMinute] = useState(0);
  const [isPM, setIsPM] = useState(false);

  // Custom days state
  const [customDays, setCustomDays] = useState<string[]>(['Mon', 'Wed', 'Fri']);
  const WEEK_DAYS = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // ─── Handlers ──────────────────────────────────────────────

  const handleCreate = useCallback(async () => {
    const trimmedName = name.trim();
    if (!trimmedName) {
      Alert.alert('Missing Name', 'Please give your habit a name.');
      return;
    }

    try {
      // Build final trigger string if custom frequency
      let finalTrigger = trigger.trim();
      if (selectedFrequency === 'CUSTOM') {
        const daysStr = customDays.join(', ');
        finalTrigger = finalTrigger ? `${finalTrigger} (Days: ${daysStr})` : `Days: ${daysStr}`;
      }
      
      await createHabitMutation.mutateAsync({
        name: trimmedName,
        description: description.trim() || undefined,
        icon: selectedIcon,
        color: selectedColor,
        frequency: selectedFrequency,
        trigger: finalTrigger || undefined,
      });
      router.back();
    } catch (err: any) {
      const msg = err.response?.data?.error || 'Could not create habit. Try again.';
      Alert.alert('Error', msg);
    }
  }, [name, description, selectedIcon, selectedColor, selectedFrequency, trigger]);

  const quickIcons = [...new Set([...DEFAULT_QUICK_ICONS, selectedIcon])].slice(0, 5);
  const isPending = createHabitMutation.isPending;

  const formattedTime = `${hour === 0 ? 12 : hour}:${minute.toString().padStart(2, '0')} ${isPM ? 'PM' : 'AM'}`;

  const toggleCustomDay = (day: string) => {
    setCustomDays(prev => 
      prev.includes(day) ? prev.filter(d => d !== day) : [...prev, day]
    );
  };

  // ─── Render ────────────────────────────────────────────────

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      {/* Header */}
      <View style={[
        styles.headerContainer,
        { paddingTop: Math.max(insets.top, spacing.lg) }
      ]}>
        <Pressable style={styles.closeButton} onPress={() => router.back()}>
          <Feather name="x" size={18} color="#001B48" />
        </Pressable>
        <Text style={styles.headerTitle}>New Habit</Text>
        <View style={styles.headerSpacer} />
      </View>

      <ScrollView
        style={styles.contentContainer}
        contentContainerStyle={styles.scrollContent}
        showsVerticalScrollIndicator={false}
        keyboardShouldPersistTaps="handled"
      >
        {/* ── Name ── */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>NAME</Text>
          <View style={styles.inputCard}>
            <TextInput
              style={styles.inputText}
              value={name}
              onChangeText={setName}
              placeholder="e.g. Drink 8 glasses of water"
              placeholderTextColor="#97CADB"
              maxLength={60}
            />
          </View>
        </View>

        {/* ── Description (optional) ── */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>DESCRIPTION</Text>
          <View style={styles.inputCard}>
            <TextInput
              style={styles.descriptionInput}
              value={description}
              onChangeText={setDescription}
              placeholder="Why does this habit matter to you?"
              placeholderTextColor="#97CADB"
              multiline
              maxLength={200}
            />
          </View>
        </View>

        {/* ── Icon Picker (Quick Row) ── */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>ICON</Text>
          <View style={styles.iconsRow}>
            {quickIcons.map((iconName) => {
              const isActive = iconName === selectedIcon;
              return (
                <Pressable
                  key={iconName}
                  onPress={() => setSelectedIcon(iconName)}
                  style={[
                    styles.iconBox,
                    isActive ? styles.iconBoxActive : styles.iconBoxInactive,
                  ]}
                >
                  <FontAwesome5
                    name={iconName}
                    size={20}
                    color={isActive ? '#ffffff' : selectedColor}
                  />
                </Pressable>
              );
            })}

            {/* (+) More icons */}
            <Pressable
              onPress={() => setShowIconModal(true)}
              style={[styles.iconBox, styles.iconBoxPlus]}
            >
              <Feather name="plus" size={20} color="#02457A" />
            </Pressable>
          </View>
        </View>

        {/* ── Color ── */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>COLOR</Text>
          <View style={styles.colorRow}>
            {HABIT_COLORS.map((c) => {
              const isActive = c.value === selectedColor;
              return (
                <Pressable
                  key={c.value}
                  onPress={() => setSelectedColor(c.value)}
                  style={[
                    styles.colorDot,
                    { backgroundColor: c.value },
                    isActive && styles.colorDotActive,
                  ]}
                >
                  {isActive && (
                    <View style={styles.colorCheckmark}>
                      <Feather name="check" size={14} color="#ffffff" />
                    </View>
                  )}
                </Pressable>
              );
            })}
          </View>
        </View>

        {/* ── Frequency ── */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>FREQUENCY</Text>
          <View style={styles.frequencyRow}>
            {FREQUENCY_OPTIONS.map((opt) => {
              const isActive = opt.value === selectedFrequency;
              return (
                <Pressable
                  key={opt.value}
                  onPress={() => setSelectedFrequency(opt.value)}
                  style={[
                    styles.frequencyPill,
                    isActive ? styles.frequencyPillActive : styles.frequencyPillInactive,
                  ]}
                >
                  <Feather
                    name={opt.icon as any}
                    size={16}
                    color={isActive ? '#ffffff' : '#02457A'}
                    style={styles.frequencyIcon}
                  />
                  <Text style={isActive ? styles.frequencyTextActive : styles.frequencyTextInactive}>
                    {opt.label}
                  </Text>
                </Pressable>
              );
            })}
          </View>
          
          {/* Custom Days Selector */}
          {selectedFrequency === 'CUSTOM' && (
            <View style={styles.daysContainer}>
              <View style={styles.daysRow}>
                {WEEK_DAYS.map((day) => {
                  const isActive = customDays.includes(day);
                  return (
                    <Pressable
                      key={day}
                      onPress={() => toggleCustomDay(day)}
                      style={[
                        styles.dayCircle,
                        isActive && styles.dayCircleActive,
                      ]}
                    >
                      <Text style={isActive ? styles.dayTextActive : styles.dayText}>
                        {day[0]}
                      </Text>
                    </Pressable>
                  );
                })}
              </View>
            </View>
          )}
        </View>

        {/* ── Habit Stack (trigger) ── */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>HABIT STACK</Text>
          <View style={styles.inputCard}>
            <TextInput
              style={styles.inputText}
              value={trigger}
              onChangeText={setTrigger}
              placeholder="After I pour my morning coffee..."
              placeholderTextColor="#97CADB"
              maxLength={100}
            />
          </View>
        </View>

        {/* ── Reminder ── */}
        <View style={styles.sectionContainer}>
          <Text style={styles.sectionLabel}>REMINDER</Text>
          <Pressable 
            style={styles.reminderCard}
            onPress={() => reminderEnabled && setShowTimeModal(true)}
          >
            <View style={[styles.reminderIconBox, !reminderEnabled && { opacity: 0.5 }]}>
              <Feather name="bell" size={18} color={reminderEnabled ? selectedColor : '#97CADB'} />
            </View>
            <View style={styles.reminderTextContainer}>
              <Text style={[styles.reminderTime, !reminderEnabled && { color: '#97CADB' }]}>
                {reminderEnabled ? formattedTime : 'Off'}
              </Text>
              <Text style={styles.reminderDesc}>
                {reminderEnabled ? 'Tap to change time' : 'Enable notifications'}
              </Text>
            </View>
            <Pressable
              onPress={() => setReminderEnabled(!reminderEnabled)}
              style={[
                styles.toggleTrack,
                reminderEnabled ? styles.toggleTrackActive : styles.toggleTrackInactive,
                { alignItems: reminderEnabled ? 'flex-end' : 'flex-start' },
              ]}
            >
              <View style={styles.toggleThumb} />
            </Pressable>
          </Pressable>
        </View>
      </ScrollView>

      {/* ── CTA ── */}
      <Pressable
        style={[styles.createButton, isPending && { opacity: 0.6 }]}
        onPress={handleCreate}
        disabled={isPending}
      >
        {isPending ? (
          <ActivityIndicator color="#ffffff" />
        ) : (
          <Text style={styles.createButtonText}>Create Habit</Text>
        )}
      </Pressable>

      {/* ── Icon Selection Modal ── */}
      <Modal
        visible={showIconModal}
        animationType="slide"
        transparent
        onRequestClose={() => setShowIconModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={styles.modalContent}>
            <View style={styles.modalHandle} />

            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Choose Icon</Text>
              <Pressable style={styles.closeButton} onPress={() => setShowIconModal(false)}>
                <Feather name="x" size={18} color="#001B48" />
              </Pressable>
            </View>

            <ScrollView
              showsVerticalScrollIndicator={false}
              contentContainerStyle={{ paddingBottom: 30 }}
            >
              {ICON_CATEGORIES.map((category) => (
                <View key={category.label} style={styles.categorySection}>
                  <Text style={styles.categoryLabel}>{category.label}</Text>
                  <View style={styles.iconGrid}>
                    {category.icons.map((iconName) => {
                      const isActive = iconName === selectedIcon;
                      return (
                        <Pressable
                          key={iconName}
                          onPress={() => {
                            setSelectedIcon(iconName);
                            setShowIconModal(false);
                          }}
                          style={[
                            styles.modalIconBox,
                            isActive
                              ? styles.modalIconBoxActive
                              : styles.modalIconBoxInactive,
                          ]}
                        >
                          <FontAwesome5
                            name={iconName}
                            size={20}
                            color={isActive ? '#ffffff' : '#02457A'}
                          />
                        </Pressable>
                      );
                    })}
                  </View>
                </View>
              ))}
            </ScrollView>
          </View>
        </View>
      </Modal>

      {/* ── Time Picker Modal ── */}
      <Modal
        visible={showTimeModal}
        animationType="slide"
        transparent
        onRequestClose={() => setShowTimeModal(false)}
      >
        <View style={styles.modalOverlay}>
          <View style={[styles.modalContent, { paddingBottom: Platform.OS === 'ios' ? 44 : 32 }]}>
            <View style={styles.modalHandle} />
            
            <View style={styles.modalHeader}>
              <Text style={styles.modalTitle}>Set Reminder Time</Text>
              <Pressable style={styles.closeButton} onPress={() => setShowTimeModal(false)}>
                <Feather name="check" size={18} color="#001B48" />
              </Pressable>
            </View>

            <View style={styles.timePickerContainer}>
              {/* Hours */}
              <View style={{ alignItems: 'center' }}>
                <Pressable onPress={() => setHour(h => (h === 12 ? 1 : h + 1))} style={{ padding: 10 }}>
                  <Feather name="chevron-up" size={32} color="#02457A" />
                </Pressable>
                <Text style={styles.timeTextActive}>{hour === 0 ? 12 : hour}</Text>
                <Pressable onPress={() => setHour(h => (h === 1 ? 12 : h - 1))} style={{ padding: 10 }}>
                  <Feather name="chevron-down" size={32} color="#02457A" />
                </Pressable>
              </View>

              <Text style={styles.timeSeparator}>:</Text>

              {/* Minutes */}
              <View style={{ alignItems: 'center' }}>
                <Pressable onPress={() => setMinute(m => (m + 5) % 60)} style={{ padding: 10 }}>
                  <Feather name="chevron-up" size={32} color="#02457A" />
                </Pressable>
                <Text style={styles.timeTextActive}>{minute.toString().padStart(2, '0')}</Text>
                <Pressable onPress={() => setMinute(m => (m - 5 < 0 ? 55 : m - 5))} style={{ padding: 10 }}>
                  <Feather name="chevron-down" size={32} color="#02457A" />
                </Pressable>
              </View>

              {/* AM/PM */}
              <View style={styles.amPmSelector}>
                <Pressable 
                  style={[styles.amPmButton, !isPM && styles.amPmButtonActive]} 
                  onPress={() => setIsPM(false)}
                >
                  <Text style={!isPM ? styles.amPmTextActive : styles.amPmText}>AM</Text>
                </Pressable>
                <Pressable 
                  style={[styles.amPmButton, isPM && styles.amPmButtonActive]} 
                  onPress={() => setIsPM(true)}
                >
                  <Text style={isPM ? styles.amPmTextActive : styles.amPmText}>PM</Text>
                </Pressable>
              </View>
            </View>

            <Pressable style={styles.modalPrimaryButton} onPress={() => setShowTimeModal(false)}>
              <Text style={styles.modalPrimaryButtonText}>Confirm Time</Text>
            </Pressable>
          </View>
        </View>
      </Modal>

      <StatusBar style={Platform.OS === 'ios' ? 'dark' : 'auto'} />
    </KeyboardAvoidingView>
  );
}
