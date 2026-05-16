// Demo simulator: backend yokken WS olaylarını taklit eder.
// Test token (dev-test-token) ile login olunduğunda devreye girer.

import wsService from '../services/wsService';

const BALIKESIR = { lat: 39.6484, lon: 27.8826 };
const CATEGORIES = ['MEDICAL', 'RESCUE', 'FOOD', 'SHELTER', 'CLOTHES', 'VULNERABLE'];
const NODES = ['NODE_01', 'NODE_02', 'NODE_03', 'NODE_04', 'NODE_05'];

let timers = [];
let idCounter = 1000;

const rand = (min, max) => Math.random() * (max - min) + min;
const pick = (arr) => arr[Math.floor(Math.random() * arr.length)];

const randomNearbyCoord = () => ({
  lat: BALIKESIR.lat + rand(-0.02, 0.02),
  lon: BALIKESIR.lon + rand(-0.02, 0.02),
});

const fireSos = () => {
  const c = randomNearbyCoord();
  wsService._emit('NEW_SOS', {
    id: ++idCounter,
    node_id: pick(NODES),
    lat: c.lat,
    lon: c.lon,
    ts: Date.now(),
  });
};

const fireRequest = () => {
  const c = randomNearbyCoord();
  wsService._emit('NEW_REQUEST', {
    id: ++idCounter,
    node_id: pick(NODES),
    category: pick(CATEGORIES),
    lat: c.lat,
    lon: c.lon,
    people_count: Math.floor(rand(1, 8)),
    details: 'Demo talep',
    ts: Date.now(),
  });
};

const fireNodeDown = () => {
  wsService._emit('NODE_STATUS', {
    node_id: pick(NODES),
    status: 'inactive',
    last_seen: new Date().toISOString(),
  });
};

export const startDemoSimulator = () => {
  stopDemoSimulator();

  // 2 saniye sonra "bağlandı" sinyali ver
  timers.push(setTimeout(() => wsService._emit('connected'), 1500));

  // İlk SOS 8sn sonra
  timers.push(setTimeout(fireSos, 8000));
  // İlk Request 4sn sonra
  timers.push(setTimeout(fireRequest, 4000));

  // Periyodik olaylar
  timers.push(setInterval(fireRequest,  18000));
  timers.push(setInterval(fireSos,      28000));
  timers.push(setInterval(fireNodeDown, 45000));
};

export const stopDemoSimulator = () => {
  timers.forEach((t) => {
    clearTimeout(t);
    clearInterval(t);
  });
  timers = [];
};
