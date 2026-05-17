import api from "./api";

export const tasksService = {
  list: () => api.get("/tasks/").then((r) => r.data),
  detail: (id) => api.get(`/tasks/${id}`).then((r) => r.data),
  create: (payload) => api.post("/tasks/", payload).then((r) => r.data),
  match: (id) => api.get(`/tasks/${id}/match`).then((r) => r.data),
  update: (id, patch) => api.put(`/tasks/${id}`, patch).then((r) => r.data),
  remove: (id) => api.delete(`/tasks/${id}`).then((r) => r.data),

  // Yeni endpoint'ler
  myTasks: () => api.get("/tasks/my").then((r) => r.data),
  prioritized: () => api.get("/tasks/prioritized").then((r) => r.data),
  getAssignments: (id) =>
    api.get(`/tasks/${id}/assignments`).then((r) => r.data),
  reject: (id) => api.post(`/tasks/${id}/reject`).then((r) => r.data),
  assign: (taskId, userId) => api.post(`/tasks/${taskId}/assign/${userId}`).then((r) => r.data),
};

export default tasksService;
