import axios from 'axios';
import { API_BASE_URL } from '../utils/constants';
import useToastStore from '../store/toastStore';

const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    const status = error.response?.status;

    const addToast = useToastStore.getState().addToast;
    if (status === 401) {
      addToast({ type: 'warning', title: 'Oturum sona erdi', message: 'Tekrar giriş yapın' });
    } else if (status >= 500) {
      addToast({ type: 'error', title: 'Sunucu hatası', message: 'Lütfen tekrar deneyin' });
    } else if (!error.response && error.code !== 'ERR_CANCELED') {
      addToast({ type: 'error', title: 'Bağlantı hatası', message: 'Sunucuya ulaşılamıyor' });
    }

    if (status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('coordinator');
      if (window.location.pathname !== '/login') {
        window.location.href = '/login';
      }
    }
    return Promise.reject(error);
  }
);

export default api;
