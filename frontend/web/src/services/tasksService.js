import api from './api';

export const tasksService = {
  list:    ()        => api.get('/tasks/').then((r) => r.data),
  create:  (payload) => api.post('/tasks/', payload).then((r) => r.data),
  match:   (id)      => api.get(`/tasks/${id}/match`).then((r) => r.data),
  update:  (id, patch) => api.put(`/tasks/${id}`, patch).then((r) => r.data),
  remove:  (id)      => api.delete(`/tasks/${id}`).then((r) => r.data),
};

export default tasksService;
