export const mockSOS = [
  { id: 1, node_id: 'NODE_01', lat: 39.6484, lon: 27.8826, ts: Date.now() - 60000 },
  { id: 2, node_id: 'NODE_02', lat: 39.6520, lon: 27.8900, ts: Date.now() - 120000 },
];

export const mockRequests = [
  { id: 1, node_id: 'NODE_01', category: 'MEDICAL', lat: 39.6450, lon: 27.8750, people_count: 3, details: 'Bacak kırığı var', ts: Date.now() - 90000 },
  { id: 2, node_id: 'NODE_03', category: 'FOOD', lat: 39.6510, lon: 27.8850, people_count: 5, details: 'Gıda ihtiyacı', ts: Date.now() - 180000 },
  { id: 3, node_id: 'NODE_02', category: 'RESCUE', lat: 39.6530, lon: 27.8780, people_count: 2, details: 'Enkaz altında', ts: Date.now() - 45000 },
];

export const mockNodes = [
  { node_id: 'NODE_01', status: 'active', lat: 39.6484, lon: 27.8826, free_heap: 210000, last_seen: new Date().toISOString() },
  { node_id: 'NODE_02', status: 'active', lat: 39.6520, lon: 27.8900, free_heap: 185000, last_seen: new Date().toISOString() },
  { node_id: 'NODE_03', status: 'inactive', lat: 39.6460, lon: 27.8780, free_heap: 0, last_seen: new Date(Date.now() - 300000).toISOString() },
  { node_id: 'GATEWAY', status: 'active', lat: 39.6495, lon: 27.8810, free_heap: 220000, last_seen: new Date().toISOString() },
];

export const mockAssembly = [
  { id: 1, name: 'Atatürk İlkokulu', lat: 39.6500, lon: 27.8800, capacity: 200, current_count: 45 },
  { id: 2, name: 'Merkez Park', lat: 39.6470, lon: 27.8840, capacity: 500, current_count: 120 },
  { id: 3, name: 'Balıkesir Stadyumu', lat: 39.6440, lon: 27.8900, capacity: 1000, current_count: 0 },
];

// Backend task type enum: FOOD, TRANSPORT, DISTRIBUTION, CLEANING, ESCORT, GUIDANCE, MEDICAL, RESCUE, LOGISTICS
export const taskTypeLabels = {
  FOOD: '🍞 Gıda',
  TRANSPORT: '📦 Taşıma',
  DISTRIBUTION: '🚚 Dağıtım',
  CLEANING: '🧹 Temizlik',
  ESCORT: '🤝 Refakat',
  GUIDANCE: '🧭 Yönlendirme',
  MEDICAL: '🏥 Tıbbi',
  RESCUE: '� Kurtarma',
  LOGISTICS: '📋 Lojistik',
};

export const mockTasks = [
  {
    id: 1,
    title: 'Gıda paketi dağıtımı',
    type: 'FOOD',
    lat: 39.6500,
    lon: 27.8800,
    status: 'pending',
    assigned_to: null,
    created_at: new Date(Date.now() - 1800000).toISOString(),
  },
  {
    id: 2,
    title: 'Su şişesi taşıma',
    type: 'TRANSPORT',
    lat: 39.6470,
    lon: 27.8840,
    status: 'assigned',
    assigned_to: 'Ahmet Y.',
    created_at: new Date(Date.now() - 3600000).toISOString(),
  },
  {
    id: 3,
    title: 'Toplanma alanı temizliği',
    type: 'CLEANING',
    lat: 39.6440,
    lon: 27.8900,
    status: 'completed',
    assigned_to: 'Mehmet K.',
    created_at: new Date(Date.now() - 7200000).toISOString(),
  },
];
