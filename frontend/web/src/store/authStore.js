import { create } from 'zustand';
import api from '../services/api';

const useAuthStore = create((set) => ({
  token: localStorage.getItem('token'),
  coordinator: JSON.parse(localStorage.getItem('coordinator') || 'null'),
  loading: false,
  error: null,

  login: async (phone, password) => {
    set({ loading: true, error: null });

    // Demo modu (backend yokken)
    if (phone === 'test' && password === 'test') {
      const token = 'dev-test-token';
      const coordinator = { id: 1, phone: 'test', name: 'Test Koordinatör' };
      localStorage.setItem('token', token);
      localStorage.setItem('coordinator', JSON.stringify(coordinator));
      set({ token, coordinator, loading: false });
      return true;
    }

    try {
      const response = await api.post('/auth/coordinator/login', { phone, password });
      const token = response.data.access_token;
      const coordinator = response.data.user || { phone };
      if (!token) throw new Error('Token alınamadı');
      localStorage.setItem('token', token);
      localStorage.setItem('coordinator', JSON.stringify(coordinator));
      set({ token, coordinator, loading: false });
      return true;
    } catch (err) {
      const msg = err.response?.data?.detail || err.response?.data?.message;
      set({
        error: msg || 'Telefon veya şifre hatalı',
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
