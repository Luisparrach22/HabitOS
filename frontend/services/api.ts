const API_URL = process.env.EXPO_PUBLIC_API_URL || 'http://localhost:4000/api';

export const api = {
  getHabits: async () => {
    try {
      const response = await fetch(`${API_URL}/habits`);
      if (!response.ok) {
        throw new Error(`Error en la petición: ${response.statusText}`);
      }
      return await response.json();
    } catch (error) {
      console.error("Error al conectar con la API:", error);
      throw error;
    }
  }
};
