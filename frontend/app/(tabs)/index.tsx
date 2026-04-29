import { StyleSheet, ActivityIndicator, FlatList } from 'react-native';
import { Text, View } from '@/components/Themed';
import { useHabits } from '@/hooks/useHabits';

export default function TabOneScreen() {
  const { habits, loading, error } = useHabits();

  if (loading) {
    return (
      <View style={[styles.container, styles.center]}>
        <ActivityIndicator size="large" color="#018ABE" />
      </View>
    );
  }

  if (error) {
    return (
      <View style={[styles.container, styles.center]}>
        <Text style={styles.errorText}>{error}</Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Mis Hábitos</Text>
      {habits.length === 0 ? (
        <View style={styles.center}>
          <Text style={styles.emptyText}>Aún no tienes hábitos registrados.</Text>
        </View>
      ) : (
        <FlatList
          data={habits}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          renderItem={({ item }) => (
            <View style={[styles.card, { borderLeftColor: item.color || '#018ABE' }]}>
              <Text style={styles.cardTitle}>{item.name}</Text>
              {item.description ? (
                <Text style={styles.cardDescription}>{item.description}</Text>
              ) : null}
              {item.trigger ? (
                <Text style={styles.cardTrigger}>🔄 {item.trigger}</Text>
              ) : null}
            </View>
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
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#001B48',
    marginTop: 60,
    marginBottom: 20,
    paddingHorizontal: 20,
  },
  list: {
    paddingHorizontal: 20,
    paddingBottom: 20,
  },
  card: {
    backgroundColor: '#FFFFFF',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
    borderLeftWidth: 6,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 4,
    elevation: 2,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#001B48',
  },
  cardDescription: {
    fontSize: 14,
    color: '#555',
    marginTop: 4,
  },
  cardTrigger: {
    fontSize: 12,
    color: '#018ABE',
    marginTop: 8,
    fontWeight: '500',
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
