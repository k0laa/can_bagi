# MeshAid React - Faz 2
> Harita Çekirdeği: Leaflet, Offline Tile, Mock İkonlar, Popup, Filtreler

---

## Faz 1'den Gelenler
- Tema, routing, JWT sistemi hazır
- PageLayout (sidebar + topbar) çalışıyor
- Tüm temel UI componentler hazır
- Koordinatör girişi çalışıyor

---

## Paket Kurulumu
```bash
npm install leaflet react-leaflet
npm install leaflet.offline
npm install leaflet.markercluster
```

---

## Bu Fazda Yapılacaklar

### 1. DashboardPage Layout
```jsx
// Tam ekran harita
// Sol sidebar (SidebarNav) haritanın üzerinde float eder
// Sağ sidebar (SosList) haritanın üzerinde float eder
// Filtreler haritanın üstünde overlay bar
// Harita z-index en altta

<div className="relative w-full h-screen">
  <MapContainer />           {/* tam ekran */}
  <SidebarNav />             {/* absolute, sol */}
  <SosList />                {/* absolute, sağ */}
  <MapFilters />             {/* absolute, üst orta */}
  <TopBar />                 {/* absolute, en üst */}
</div>
```

### 2. MapContainer Component
```jsx
// react-leaflet MapContainer
// Başlangıç koordinatı: Balıkesir (39.6484, 27.8826)
// Zoom: 13
// Tam ekran: width 100vw, height 100vh
// Koyu tema için tile stili seç

// Tile URL (koyu/gece teması):
// https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png
// Attribution: © OpenStreetMap contributors © CARTO
```

### 3. Offline Tile Cache (OfflineTileLayer)
```jsx
import 'leaflet.offline';

// Uygulama yüklenince Balıkesir bölgesini cache'le
// Zoom 10-16 arası
// Cache yoksa normal online tile kullan
// Cache varsa offline çalış

const OfflineTileLayer = () => {
  useEffect(() => {
    // leaflet.offline ile tile'ları indir
    // Progress göster (isteğe bağlı)
  }, []);

  return (
    <TileLayerOffline
      url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
      // offline fallback otomatik
    />
  );
};
```

### 4. Harita İkonları

**Custom İkon Boyutları:**
```javascript
// Leaflet custom icon
const createIcon = (color, size = 32) => L.divIcon({
  html: `<div style="
    width: ${size}px; height: ${size}px;
    background: ${color};
    border-radius: 50%;
    border: 3px solid white;
    box-shadow: 0 0 8px ${color}88;
  "></div>`,
  iconSize: [size, size],
  className: ''
});

const icons = {
  sos:          createIcon('#E63946', 36),  // kırmızı, büyük
  request:      createIcon('#FF6B35', 28),  // turuncu
  assembly:     createIcon('#2DC653', 28),  // yeşil
  distribution: createIcon('#4A9EFF', 28),  // mavi
  node:         createIcon('#9B59B6', 24),  // mor, küçük
};
```

### 5. Mock Data (Faz 2 için)
```javascript
// Gerçek WebSocket Faz 3'te gelecek
// Şimdilik mock data kullan

const mockSOS = [
  { id: 1, node_id: "NODE_01", lat: 39.6484, lon: 27.8826, ts: Date.now() },
  { id: 2, node_id: "NODE_02", lat: 39.6520, lon: 27.8900, ts: Date.now() },
];

const mockRequests = [
  { id: 1, category: "MEDICAL", lat: 39.6450, lon: 27.8750, people_count: 3, details: "Test" },
  { id: 2, category: "FOOD", lat: 39.6510, lon: 27.8850, people_count: 5, details: "Test" },
];

const mockNodes = [
  { node_id: "NODE_01", status: "active", lat: 39.6484, lon: 27.8826 },
  { node_id: "NODE_02", status: "active", lat: 39.6520, lon: 27.8900 },
  { node_id: "NODE_03", status: "inactive", lat: 39.6460, lon: 27.8780 },
];

const mockAssembly = [
  { id: 1, name: "Atatürk İlkokulu", lat: 39.6500, lon: 27.8800 },
  { id: 2, name: "Merkez Park", lat: 39.6470, lon: 27.8840 },
];
```

### 6. MarkerPopup Component
```jsx
// Her marker tıklanınca Leaflet Popup açılır
// Popup arka plan: #1B2E45
// Popup border: kategori rengi

// SOS Popup:
<Popup>
  <div className="bg-mesh-card p-3 rounded-lg min-w-48">
    <h3 className="font-bebas text-mesh-danger text-xl">🔴 ACİL SOS</h3>
    <p className="font-nunito text-mesh-muted text-sm">Node: NODE_01</p>
    <p className="font-nunito text-mesh-muted text-sm">10:23:45</p>
    <button className="mt-2 w-full bg-mesh-accent ...">Görev Oluştur</button>
  </div>
</Popup>

// Request Popup:
<Popup>
  <h3>🟠 Tıbbi Yardım</h3>
  <p>3 kişi</p>
  <p>"Bacak kırığı var"</p>
  <button>Görev Oluştur</button>
</Popup>

// Node Popup:
<Popup>
  <h3>🟣 NODE_01</h3>
  <p>Durum: Aktif</p>
  <p>Heap: 210,000 byte</p>
  <p>Son görülme: 10:23:45</p>
</Popup>

// Assembly Popup:
<Popup>
  <h3>🟢 Atatürk İlkokulu</h3>
  <p>Toplanma Noktası</p>
  <button>Noktayı Düzenle</button>
</Popup>
```

### 7. MapFilters Component
```jsx
// Haritanın üstünde, ortada, overlay
// Arka plan: #1B2E45 + blur efekti
// Yatay buton grubu:

[Tümü] [🔴 SOS] [🟠 Talepler] [🟢 Toplanma] [🔵 Dağıtım] [🟣 Nodlar]

// Aktif filtre: turuncu border
// Pasif: gri
// "Tümü" seçilince hepsi görünür
// Diğerleri seçilince sadece o kategori
```

### 8. MapStore (zustand)
```javascript
const useMapStore = create((set) => ({
  sosList: [],
  requestList: [],
  nodeList: [],
  assemblyList: [],
  activeFilter: 'all', // all|sos|request|assembly|distribution|node

  setFilter: (filter) => set({ activeFilter: filter }),
  addSOS: (sos) => set((state) => ({ sosList: [...state.sosList, sos] })),
  addRequest: (req) => set((state) => ({ requestList: [...state.requestList, req] })),
  updateNode: (node) => set((state) => ({
    nodeList: state.nodeList.map(n => n.node_id === node.node_id ? node : n)
  })),
}));
```

---

## Yeni Dosyalar

```
src/
  components/
    map/
      MapContainer.jsx
      OfflineTileLayer.jsx
      SosMarker.jsx
      RequestMarker.jsx
      AssemblyMarker.jsx
      DistributionMarker.jsx
      NodeMarker.jsx
      MarkerPopup.jsx
      MapFilters.jsx
    layout/
      SosList.jsx       (Faz 3'te doldurulacak, şimdi placeholder)
  store/
    mapStore.js
  utils/
    mapIcons.js
    mockData.js
```

---

## Faz 2 Test Kriterleri

```
✅ Harita açılıyor, Balıkesir bölgesi görünüyor
✅ Koyu (gece) tema tile yükleniyor
✅ Mock SOS ikonları kırmızı, doğru konumda
✅ Mock Request ikonları turuncu, doğru konumda
✅ Mock Node ikonları mor, doğru konumda
✅ Mock Assembly ikonları yeşil, doğru konumda
✅ İkonlara tıklanınca popup açılıyor
✅ Her popup doğru bilgileri gösteriyor
✅ Filtreler çalışıyor (SOS seçince sadece SOS görünüyor)
✅ "Tümü" seçince hepsi görünüyor
✅ SidebarNav haritanın üzerinde float ediyor
✅ Harita tam ekran kaplıyor
```

---

## Önemli Notlar
- Leaflet CSS import: `import 'leaflet/dist/leaflet.css'` main.jsx'e ekle
- Leaflet default icon bug: `delete L.Icon.Default.prototype._getIconUrl` ekle
- Popup custom stil için CSS override gerekebilir
- Mock data Faz 3'te gerçek WebSocket verisiyle değiştirilecek
- Offline tile cache internet bağlantısı olan ortamda önceden indirilir
