import { create } from 'zustand';

const useMapStore = create((set) => ({
  sosList: [],
  requestList: [],
  nodeList: [],
  assemblyList: [],
  activeFilter: 'all',

  setFilter: (filter) => set({ activeFilter: filter }),

  addSOS: (sos) => set((state) => ({
    sosList: [sos, ...state.sosList],
  })),

  addRequest: (req) => set((state) => ({
    requestList: [req, ...state.requestList],
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
