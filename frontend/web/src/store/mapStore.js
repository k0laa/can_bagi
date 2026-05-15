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
}));

export default useMapStore;
