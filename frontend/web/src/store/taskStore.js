import { create } from 'zustand';

let _localId = 100000;
const nextLocalId = () => ++_localId;

// Backend task schema: { id, title, type, lat, lon, status, assigned_to, created_at }

const useTaskStore = create((set) => ({
  tasks: [],

  setTasks: (list) => set({ tasks: list || [] }),

  addTask: (task) =>
    set((state) => ({
      tasks: [
        {
          id: task.id ?? nextLocalId(),
          status: 'pending',
          assigned_to: null,
          created_at: new Date().toISOString(),
          ...task,
        },
        ...state.tasks,
      ],
    })),

  upsertTask: (task) =>
    set((state) => {
      if (!task || task.id == null) return state;
      const exists = state.tasks.find((t) => t.id === task.id);
      if (exists) {
        return {
          tasks: state.tasks.map((t) => (t.id === task.id ? { ...t, ...task } : t)),
        };
      }
      return { tasks: [task, ...state.tasks] };
    }),

  updateTask: (id, patch) =>
    set((state) => ({
      tasks: state.tasks.map((t) => (t.id === id ? { ...t, ...patch } : t)),
    })),

  deleteTask: (id) =>
    set((state) => ({ tasks: state.tasks.filter((t) => t.id !== id) })),
}));

export default useTaskStore;
