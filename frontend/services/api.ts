const API_URL = 'http://localhost:4000';

export const api = {
  getHello: async () => {
    try {
      const response = await fetch(`${API_URL}/`);
      return await response.json();
    } catch (error) {
      console.error('API Error:', error);
      throw error;
    }
  }
};
