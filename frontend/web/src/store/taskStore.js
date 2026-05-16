import { create } from 'zustand';

let _id = 100;
const nextId = () => ++_id;

const useTaskStore = create((set) => ({
  tasks: [],

  setTasks: (list) => set({ tasks: list }),

  addTask: (task) =>
    set((state) => ({
      tasks: [
        {
          id: nextId(),
          status: 'pending',
          assigned_to: null,
          created_at: new Date().toISOString(),
          ...task,
        },
        ...state.tasks,
      ],
    })),

  updateTask: (id, patch) =>
    set((state) => ({
      tasks: state.tasks.map((t) => (t.id === id ? { ...t, ...patch } : t)),
    })),

  deleteTask: (id) =>
    set((state) => ({ tasks: state.tasks.filter((t) => t.id !== id) })),
}));

export default useTaskStore;
