import api from './api';

export const nodesService = {
  list: () => api.get('/nodes/').then((r) => r.data),
  detail: (id) => api.get(`/nodes/${id}`).then((r) => r.data),
  remove: (id) => api.delete(`/nodes/${id}`).then((r) => r.data),
};

export default nodesService;
