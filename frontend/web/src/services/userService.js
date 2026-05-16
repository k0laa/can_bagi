import api from './api';

export const userService = {
  list: () => api.get('/user/').then((r) => r.data),
  makeCoordinator: (userId) => api.post(`/auth/make-coordinator/${userId}`).then((r) => r.data),
  makeUser:        (userId) => api.post(`/auth/make-user/${userId}`).then((r) => r.data),
};

export default userService;
