import { useEffect, useState } from 'react';
import { StyleSheet, ActivityIndicator } from 'react-native';

import { Text, View } from '@/components/Themed';

export default function TabOneScreen() {
  const [backendMessage, setBackendMessage] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetch('http://localhost:4000/')
      .then((response) => response.json())
      .then((data) => {
        setBackendMessage(data.message);
        setLoading(false);
      })
      .catch((error) => {
        console.error('Error conectando al backend:', error);
        setBackendMessage('Error al conectar con el Backend ❌');
        setLoading(false);
      });
  }, []);

  return (
    <View style={styles.container}>
      {loading ? (
        <ActivityIndicator size="large" color="#0000ff" />
      ) : (
        <Text style={styles.message}>{backendMessage}</Text>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  message: {
    fontSize: 18,
    fontWeight: '500',
    textAlign: 'center',
    paddingHorizontal: 20,
    color: '#2e78b7',
  },
});
