import api from './api';

export const userService = {
  // Mevcut kullanıcı profili (TOKEN)
  myProfile: () => api.get('/user/profile').then((r) => r.data),

  // PUT /user/profile?name=...&surname=...&blood_type=...&skills=...&lat=...&lon=...
  updateMyProfile: (params) =>
    api.put('/user/profile', null, { params }).then((r) => r.data),

  // Tüm kullanıcılar (COORD)
  list: () => api.get('/user/').then((r) => r.data),
  remove: (userId) => api.delete(`/user/${userId}`).then((r) => r.data),

  // Rol yönetimi (SUPER)
  makeCoordinator: (userId) => api.post(`/auth/make-coordinator/${userId}`).then((r) => r.data),
  makeUser: (userId) => api.post(`/auth/make-user/${userId}`).then((r) => r.data),
};

export default userService;
