import api from './api';

export const sosService = {
  list:        ()  => api.get('/sos/').then((r) => r.data),
  prioritized: ()  => api.get('/sos/prioritized').then((r) => r.data),
  resolve:     (id) => api.put(`/sos/${id}/resolve`).then((r) => r.data),
  remove:      (id) => api.delete(`/sos/${id}`).then((r) => r.data),
};

export default sosService;
