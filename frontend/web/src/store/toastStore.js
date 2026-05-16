import { create } from 'zustand';

let toastId = 0;

const useToastStore = create((set) => ({
  toasts: [],

  addToast: (payload, type = 'info', duration = 4000) => {
    const id = ++toastId;
    const toast =
      typeof payload === 'string'
        ? { id, type, message: payload, title: null, ts: Date.now() }
        : {
          id,
          type: payload.type || type,
          title: payload.title || null,
          message: payload.message || '',
          ts: Date.now(),
        };
    set((state) => ({
      toasts: [...state.toasts.slice(-4), toast],
    }));
    setTimeout(() => {
      set((state) => ({
        toasts: state.toasts.filter((t) => t.id !== id),
      }));
    }, duration);
  },

  removeToast: (id) =>
    set((state) => ({
      toasts: state.toasts.filter((t) => t.id !== id),
    })),
}));

export const showToast = (message, type) =>
  useToastStore.getState().addToast(message, type);

export default useToastStore;
