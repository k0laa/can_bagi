# MeshAid React - Faz 3
> Gerçek Zamanlı: WebSocket, Canlı Harita, Ses Bildirimi, SOS Listesi

---

## Faz 1-2'den Gelenler
- Tema, routing, JWT sistemi hazır
- Harita tam çalışıyor (mock data ile)
- Tüm marker tipleri ve popup'lar hazır
- Filtreler çalışıyor
- MapStore hazır

---

## Bu Fazda Yapılacaklar

### 1. WebSocket Servisi
```javascript
// src/services/wsService.js

class WebSocketService {
  constructor() {
    this.ws = null;
    this.reconnectInterval = 3000;
    this.listeners = {};
  }

  connect(token) {
    // ws://[BACKEND_IP]:8000/ws/dashboard?token={jwt}
    this.ws = new WebSocket(`${WS_URL}?token=${token}`);

    this.ws.onopen = () => {
      console.log('WS bağlandı');
      this._emit('connected');
    };

    this.ws.onmessage = (event) => {
      const { event: type, data } = JSON.parse(event.data);
      this._emit(type, data);
    };

    this.ws.onclose = () => {
      console.log('WS koptu, yeniden bağlanıyor...');
      this._emit('disconnected');
      setTimeout(() => this.connect(token), this.reconnectInterval);
    };

    this.ws.onerror = (err) => {
      console.error('WS hata:', err);
    };
  }

  on(event, callback) {
    if (!this.listeners[event]) this.listeners[event] = [];
    this.listeners[event].push(callback);
  }

  _emit(event, data) {
    (this.listeners[event] || []).forEach(cb => cb(data));
  }

  disconnect() {
    if (this.ws) this.ws.close();
  }
}

export default new WebSocketService();
```

### 2. useWebSocket Hook
```javascript
// src/hooks/useWebSocket.js

export const useWebSocket = () => {
  const { token } = useAuthStore();
  const { addSOS, addRequest, updateNode } = useMapStore();
  const [status, setStatus] = useState('disconnected');

  useEffect(() => {
    wsService.connect(token);

    wsService.on('connected', () => setStatus('connected'));
    wsService.on('disconnected', () => setStatus('disconnected'));

    wsService.on('NEW_SOS', (data) => {
      addSOS(data);
      playSound('sos');
      showToast('🔴 Yeni SOS Çağrısı!', 'danger');
    });

    wsService.on('NEW_REQUEST', (data) => {
      addRequest(data);
      playSound('request');
      showToast(`🟠 Yeni ${getCategoryLabel(data.category)} Talebi`, 'warning');
    });

    wsService.on('NODE_STATUS', (data) => {
      updateNode(data);
      if (data.status === 'inactive') {
        playSound('nodeDown');
        showToast(`⚠️ NODE ${data.node_id} çevrimdışı`, 'warning');
      }
    });

    return () => wsService.disconnect();
  }, [token]);

  return { status };
};
```

### 3. Ses Bildirimleri
```javascript
// src/utils/soundUtils.js

const sounds = {
  sos: new Audio('/sounds/sos_alert.mp3'),       // acil alarm
  request: new Audio('/sounds/notification.mp3'), // normal bildirim
  nodeDown: new Audio('/sounds/warning.mp3'),     // uyarı sesi
};

export const playSound = (type) => {
  const sound = sounds[type];
  if (sound) {
    sound.currentTime = 0;
    sound.play().catch(() => {
      // Tarayıcı autoplay politikası - ilk kullanıcı etkileşiminden sonra çalışır
    });
  }
};

// public/sounds/ klasörüne ekle:
// sos_alert.mp3, notification.mp3, warning.mp3
// Ücretsiz: mixkit.co veya freesound.org
```

### 4. WebSocketStatus Component
```jsx
// TopBar'da sağ köşede gösterilir
const WebSocketStatus = ({ status }) => (
  <div className="flex items-center gap-2">
    <div className={`w-2 h-2 rounded-full ${
      status === 'connected' ? 'bg-mesh-success animate-pulse' : 'bg-mesh-danger'
    }`} />
    <span className="font-nunito text-xs text-mesh-muted">
      {status === 'connected' ? 'Canlı' : 'Bağlantı Yok'}
    </span>
  </div>
);
```

### 5. Toast Sistemi
```jsx
// src/components/ui/ToastContainer.jsx
// Sağ üst köşe, fixed position

const ToastContainer = () => {
  const { toasts } = useToastStore();

  return (
    <div className="fixed top-4 right-4 z-[9999] flex flex-col gap-2">
      {toasts.map(toast => (
        <Toast key={toast.id} {...toast} />
      ))}
    </div>
  );
};

// Toast Component:
// Görünüm: #1B2E45 arka plan + kategori rengi sol border
// Animasyon: sağdan kayarak girer, 4sn sonra kayarak çıkar
// İçerik: ikon + mesaj + zaman
// Birden fazla toast stack'lenir (max 5)
```

### 6. SosList Component (Sağ Sidebar)
```jsx
// Varsayılan açık, toggle butonu ile kapanır
// Genişlik: 320px
// Arka plan: #1B2E45 + blur

<div className="absolute right-0 top-0 h-full w-80 bg-mesh-card/90 backdrop-blur">
  {/* Header */}
  <div className="flex justify-between p-4 border-b border-mesh-disabled">
    <h2 className="font-bebas text-xl">AKTİF ÇAĞRILAR</h2>
    <button onClick={toggle}>✕</button>
  </div>

  {/* Sekme: SOS | Talepler */}
  <div className="flex border-b border-mesh-disabled">
    <button className="flex-1 py-2 font-bebas text-mesh-danger">SOS ({sosList.length})</button>
    <button className="flex-1 py-2 font-bebas text-mesh-accent">Talepler ({requestList.length})</button>
  </div>

  {/* Liste */}
  <div className="overflow-y-auto h-full">
    {activeTab === 'sos' && sosList.map(sos => <SosCard key={sos.id} data={sos} />)}
    {activeTab === 'requests' && requestList.map(req => <RequestCard key={req.id} data={req} />)}
  </div>
</div>
```

### 7. SosCard Component
```jsx
// Sol border: kırmızı (SOS) veya turuncu (Request)
// Tıklanınca haritada o noktaya zoom yap

<div
  className="p-3 border-l-4 border-mesh-danger cursor-pointer hover:bg-mesh-bg"
  onClick={() => map.flyTo([data.lat, data.lon], 16)}
>
  <div className="flex justify-between">
    <span className="font-bebas text-mesh-danger">🔴 ACİL SOS</span>
    <span className="font-nunito text-xs text-mesh-muted">{formatTime(data.ts)}</span>
  </div>
  <p className="font-nunito text-sm text-mesh-muted">Node: {data.node_id}</p>
</div>
```

### 8. Harita Canlı Güncelleme
```jsx
// DashboardPage'de useWebSocket hook'u çağır
// MapStore güncellenince marker'lar otomatik yeniden render olur
// Yeni SOS gelince harita o noktaya zoom yapar (opsiyonel)

const DashboardPage = () => {
  const { status } = useWebSocket(); // WS bağlantısını başlat
  const { sosList, requestList, nodeList } = useMapStore();

  return (
    <div className="relative w-full h-screen">
      <MapContainer>
        {sosList.map(sos => <SosMarker key={sos.id} data={sos} />)}
        {requestList.map(req => <RequestMarker key={req.id} data={req} />)}
        {nodeList.map(node => <NodeMarker key={node.node_id} data={node} />)}
      </MapContainer>
      <SosList />
      <MapFilters />
    </div>
  );
};
```

---

## Yeni Dosyalar

```
src/
  services/
    wsService.js
  hooks/
    useWebSocket.js
  utils/
    soundUtils.js
  store/
    toastStore.js
  components/
    ui/
      ToastContainer.jsx  (güncellendi)
    layout/
      SosList.jsx         (güncellendi, gerçek data)
    map/
      SosCard.jsx
      RequestCard.jsx
  pages/
    DashboardPage.jsx     (güncellendi, WS entegrasyonu)
public/
  sounds/
    sos_alert.mp3
    notification.mp3
    warning.mp3
```

---

## Faz 3 Test Kriterleri

```
✅ WebSocket bağlanıyor
✅ TopBar'da "Canlı" yeşil dot görünüyor
✅ WS kopunca "Bağlantı Yok" kırmızı dot
✅ WS kopunca otomatik yeniden bağlanıyor
✅ Yeni SOS gelince haritada kırmızı ikon anlık çıkıyor
✅ Yeni SOS gelince ses çalıyor
✅ Yeni SOS gelince sağ üst toast çıkıyor
✅ Yeni Request gelince turuncu ikon çıkıyor
✅ Node inactive olunca uyarı toast çıkıyor
✅ SosList'te SOS ve talepler listeleniyor
✅ Listedeki karta tıklanınca harita o noktaya zoom yapıyor
✅ SosList açılıp kapanıyor
✅ Birden fazla toast stack'leniyor
```

---

## Önemli Notlar
- WS URL: constants.js'ten al
- Tarayıcı autoplay politikası: ses sadece kullanıcı bir kere tıkladıktan sonra çalışır, bu normaldir
- WS token expire olursa /login'e redirect et
- Mock data Faz 2'den kaldırılabilir veya WS yokken fallback olarak tutulabilir
