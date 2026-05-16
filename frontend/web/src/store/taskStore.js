import { create } from "zustand";

let _localId = 100000;
const nextLocalId = () => ++_localId;

// Backend task schema: { id, title, type, lat, lon, status, assigned_to, created_at, ai_score, ai_suggestion }

const useTaskStore = create((set) => ({
  tasks: [],
  assignments: {}, // { [taskId]: { [userId]: status } }

  setTasks: (list) => set({ tasks: list || [] }),

  addTask: (task) =>
    set((state) => ({
      tasks: [
        {
          id: task.id ?? nextLocalId(),
          status: "pending",
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
          tasks: state.tasks.map((t) =>
            t.id === task.id ? { ...t, ...task } : t,
          ),
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

  // Görev atanınca çağrılır
  handleTaskAssigned: (taskData) =>
    set((state) => ({
      tasks: [taskData, ...state.tasks],
    })),

  // Görev reddedilince atamayı güncelle
  handleTaskRejected: (taskId, userId) =>
    set((state) => ({
      assignments: {
        ...state.assignments,
        [taskId]: {
          ...(state.assignments[taskId] || {}),
          [userId]: "rejected",
        },
      },
    })),

  // Assignments listesini güncelle
  setTaskAssignments: (taskId, assignments) =>
    set((state) => ({
      assignments: {
        ...state.assignments,
        [taskId]: assignments || {},
      },
    })),
}));

export default useTaskStore;
