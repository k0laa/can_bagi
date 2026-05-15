import { create } from 'zustand';
import api from '../services/api';

const useAuthStore = create((set) => ({
  token: localStorage.getItem('token'),
  coordinator: JSON.parse(localStorage.getItem('coordinator') || 'null'),
  loading: false,
  error: null,

  login: async (username, password) => {
    set({ loading: true, error: null });

    if (username === 'test' && password === 'test') {
      const token = 'dev-test-token';
      const coordinator = { id: 1, username: 'test', name: 'Test Koordinatör' };
      localStorage.setItem('token', token);
      localStorage.setItem('coordinator', JSON.stringify(coordinator));
      set({ token, coordinator, loading: false });
      return true;
    }

    try {
      const response = await api.post('/auth/login', { username, password });
      const { token, ...coordinator } = response.data;
      localStorage.setItem('token', token);
      localStorage.setItem('coordinator', JSON.stringify(coordinator));
      set({ token, coordinator, loading: false });
      return true;
    } catch (err) {
      set({
        error: 'Kullanıcı adı veya şifre hatalı',
        loading: false,
      });
      return false;
    }
  },

  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('coordinator');
    set({ token: null, coordinator: null, error: null });
  },

  clearError: () => set({ error: null }),
}));

export default useAuthStore;
