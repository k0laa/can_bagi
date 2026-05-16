import { create } from 'zustand';

const useMapStore = create((set) => ({
  sosList: [],
  requestList: [],
  nodeList: [],
  assemblyList: [],
  activeFilter: 'all',

  setFilter: (filter) => set({ activeFilter: filter }),

  addSOS: (sos) => set((state) => {
    if (sos?.id != null && state.sosList.find((s) => s.id === sos.id)) {
      return { sosList: state.sosList.map((s) => (s.id === sos.id ? { ...s, ...sos } : s)) };
    }
    return { sosList: [sos, ...state.sosList] };
  }),

  removeSOS: (id) => set((state) => ({
    sosList: state.sosList.filter((s) => s.id !== id),
  })),

  updateSOS: (id, patch) => set((state) => ({
    sosList: state.sosList.map((s) => (s.id === id ? { ...s, ...patch } : s)),
  })),

  addRequest: (req) => set((state) => {
    if (req?.id != null && state.requestList.find((r) => r.id === req.id)) {
      return { requestList: state.requestList.map((r) => (r.id === req.id ? { ...r, ...req } : r)) };
    }
    return { requestList: [req, ...state.requestList] };
  }),

  removeRequest: (id) => set((state) => ({
    requestList: state.requestList.filter((r) => r.id !== id),
  })),

  updateRequest: (id, patch) => set((state) => ({
    requestList: state.requestList.map((r) => (r.id === id ? { ...r, ...patch } : r)),
  })),

  updateNode: (node) => set((state) => {
    const exists = state.nodeList.find((n) => n.node_id === node.node_id);
    if (exists) {
      return {
        nodeList: state.nodeList.map((n) =>
          n.node_id === node.node_id ? { ...n, ...node } : n
        ),
      };
    }
    return { nodeList: [...state.nodeList, node] };
  }),

  removeNode: (id) => set((state) => ({
    nodeList: state.nodeList.filter((n) => n.node_id !== id),
  })),

  setAssemblyList: (list) => set({ assemblyList: list }),
  setSosList: (list) => set({ sosList: list }),
  setRequestList: (list) => set({ requestList: list }),
  setNodeList: (list) => set({ nodeList: list }),

  addAssembly: (point) =>
    set((state) => {
      const id = state.assemblyList.reduce((m, p) => Math.max(m, p.id || 0), 0) + 1;
      return {
        assemblyList: [
          ...state.assemblyList,
          { current_count: 0, ...point, id },
        ],
      };
    }),

  removeAssembly: (id) =>
    set((state) => ({
      assemblyList: state.assemblyList.filter((p) => p.id !== id),
    })),

  mapInstance: null,
  setMapInstance: (map) => set({ mapInstance: map }),
}));

export default useMapStore;
