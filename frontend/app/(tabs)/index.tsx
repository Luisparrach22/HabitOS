import React from 'react';
import {
  StyleSheet,
  ActivityIndicator,
  FlatList,
  Pressable,
  Alert,
} from 'react-native';
import { Text, View } from '@/components/Themed';
import { useHabits, useCheckinHabit, type Habit } from '@/hooks/useHabits';
import { useAuth } from '@/context/AuthContext';
import FontAwesome from '@expo/vector-icons/FontAwesome';

export default function DashboardScreen() {
  const { data: habits, isLoading, error } = useHabits();
  const checkinMutation = useCheckinHabit();
  const { user, refreshUser } = useAuth();

  const handleCheckin = async (habit: Habit) => {
    if (habit.completedToday) return;

    try {
      const result = await checkinMutation.mutateAsync(habit.id);

      // Refrescar datos del usuario (XP, nivel)
      await refreshUser();

      if (result.leveledUp) {
        Alert.alert(
          '🎉 ¡Subiste de nivel!',
          `¡Felicidades! Ahora eres nivel ${result.newLevel}.`,
          [{ text: '¡Genial!' }]
        );
      }
    } catch (error: any) {
      const message =
        error.response?.data?.error || 'Error al registrar el check-in.';
      Alert.alert('Error', message);
    }
  };

  if (isLoading) {
    return (
      <View style={[styles.container, styles.center]}>
        <ActivityIndicator size="large" color="#018ABE" />
      </View>
    );
  }

  if (error) {
    return (
      <View style={[styles.container, styles.center]}>
        <Text style={styles.errorText}>Error al cargar los hábitos.</Text>
      </View>
    );
  }

  // Calcular progreso del día
  const totalHabits = habits?.length || 0;
  const completedCount = habits?.filter((h) => h.completedToday).length || 0;
  const progressPercent = totalHabits > 0 ? Math.round((completedCount / totalHabits) * 100) : 0;

  return (
    <View style={styles.container}>
      {/* Header con stats */}
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <View style={styles.headerTextContainer}>
            <Text style={styles.greeting}>
              Hola, {user?.name || 'Héroe'} 👋
            </Text>
            <Text style={styles.levelBadge}>
              Nivel {user?.level || 1} · {user?.totalXp || 0} XP
            </Text>
          </View>
        </View>

        {/* Barra de progreso */}
        <View style={styles.progressContainer}>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: `${progressPercent}%` }]} />
          </View>
          <Text style={styles.progressText}>
            {completedCount}/{totalHabits} completados hoy
          </Text>
        </View>
      </View>

      {/* Lista de hábitos */}
      <Text style={styles.sectionTitle}>Mis Hábitos</Text>

      {!habits || habits.length === 0 ? (
        <View style={styles.center}>
          <Text style={styles.emptyText}>
            Aún no tienes hábitos registrados. 🌱
          </Text>
        </View>
      ) : (
        <FlatList
          data={habits}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          showsVerticalScrollIndicator={false}
          renderItem={({ item }) => (
            <Pressable
              style={({ pressed }) => [
                styles.card,
                { borderLeftColor: item.color || '#018ABE' },
                item.completedToday && styles.cardCompleted,
                pressed && styles.cardPressed,
              ]}
              onPress={() => handleCheckin(item)}
              disabled={item.completedToday}
            >
              <View style={styles.cardContent}>
                <View style={styles.cardLeft}>
                  <Text style={[styles.cardTitle, item.completedToday && styles.cardTitleCompleted]}>
                    {item.name}
                  </Text>
                  {item.description ? (
                    <Text style={styles.cardDescription}>{item.description}</Text>
                  ) : null}
                  <View style={styles.statsRow}>
                    <Text style={styles.statBadge}>
                      🔥 {item.currentStreak}
                    </Text>
                    {item.shields > 0 && (
                      <Text style={styles.statBadge}>
                        🛡️ {item.shields}
                      </Text>
                    )}
                    <Text style={styles.statBadge}>
                      📊 {item.totalCompletions}
                    </Text>
                  </View>
                </View>

                <View style={styles.checkContainer}>
                  {item.completedToday ? (
                    <View style={styles.checkDone}>
                      <FontAwesome name="check" size={18} color="#FFF" />
                    </View>
                  ) : (
                    <View style={styles.checkEmpty} />
                  )}
                </View>
              </View>
            </Pressable>
          )}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#D6E8EE',
  },
  center: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: 'transparent',
  },
  header: {
    backgroundColor: '#001B48',
    paddingTop: 60,
    paddingBottom: 24,
    paddingHorizontal: 20,
    borderBottomLeftRadius: 24,
    borderBottomRightRadius: 24,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'transparent',
  },
  headerTextContainer: {
    backgroundColor: 'transparent',
  },
  greeting: {
    fontSize: 24,
    fontWeight: '700',
    color: '#FFFFFF',
  },
  levelBadge: {
    fontSize: 14,
    color: '#97BFD5',
    marginTop: 4,
    fontWeight: '600',
  },
  progressContainer: {
    marginTop: 16,
    backgroundColor: 'transparent',
  },
  progressBar: {
    height: 8,
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#018ABE',
    borderRadius: 4,
  },
  progressText: {
    fontSize: 12,
    color: '#97BFD5',
    marginTop: 6,
    fontWeight: '500',
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#001B48',
    marginTop: 20,
    marginBottom: 12,
    paddingHorizontal: 20,
  },
  list: {
    paddingHorizontal: 20,
    paddingBottom: 100,
  },
  card: {
    backgroundColor: '#FFFFFF',
    padding: 16,
    borderRadius: 16,
    marginBottom: 12,
    borderLeftWidth: 5,
    shadowColor: '#001B48',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 2,
  },
  cardCompleted: {
    backgroundColor: '#EFF7FA',
    opacity: 0.85,
  },
  cardPressed: {
    transform: [{ scale: 0.98 }],
  },
  cardContent: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: 'transparent',
  },
  cardLeft: {
    flex: 1,
    backgroundColor: 'transparent',
  },
  cardTitle: {
    fontSize: 17,
    fontWeight: '700',
    color: '#001B48',
  },
  cardTitleCompleted: {
    textDecorationLine: 'line-through',
    opacity: 0.6,
  },
  cardDescription: {
    fontSize: 13,
    color: '#555',
    marginTop: 4,
  },
  statsRow: {
    flexDirection: 'row',
    marginTop: 8,
    gap: 8,
    backgroundColor: 'transparent',
  },
  statBadge: {
    fontSize: 12,
    color: '#02457A',
    backgroundColor: '#EFF7FA',
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 8,
    overflow: 'hidden',
    fontWeight: '600',
  },
  checkContainer: {
    marginLeft: 12,
    backgroundColor: 'transparent',
  },
  checkDone: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: '#018ABE',
    alignItems: 'center',
    justifyContent: 'center',
  },
  checkEmpty: {
    width: 36,
    height: 36,
    borderRadius: 18,
    borderWidth: 2.5,
    borderColor: '#97BFD5',
  },
  errorText: {
    color: '#D32F2F',
    fontSize: 16,
    textAlign: 'center',
    paddingHorizontal: 20,
  },
  emptyText: {
    fontSize: 16,
    color: '#001B48',
    opacity: 0.7,
    textAlign: 'center',
  },
});
