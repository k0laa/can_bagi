import api from './api';

export const needsService = {
  list: () => api.get('/needs/').then((r) => r.data),
  detail: (id) => api.get(`/needs/${id}`).then((r) => r.data),
  create: (payload) => api.post('/needs/', payload).then((r) => r.data),
  setStatus: (id, status) =>
    api.put(`/needs/${id}/status`, null, { params: { status } }).then((r) => r.data),
  remove: (id) => api.delete(`/needs/${id}`).then((r) => r.data),
};

export default needsService;
