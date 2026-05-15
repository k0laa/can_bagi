# MeshAid React - Faz 5
> UI Polish: Hata Yönetimi, Loading States, Responsive, Son Dokunuşlar

---

## Faz 1-4'ten Gelenler
- Tüm sayfalar ve özellikler çalışıyor
- WebSocket canlı güncelleme çalışıyor
- Görev, toplanma noktası, node yönetimi çalışıyor

---

## Bu Fazda Yapılacaklar

### 1. Global Hata Yönetimi
```javascript
// src/services/api.js - axios interceptor

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      // Token expired → logout → /login
      useAuthStore.getState().logout();
      window.location.href = '/login';
    }

    if (error.response?.status === 500) {
      showToast('Sunucu hatası oluştu', 'error');
    }

    if (!error.response) {
      // Network error
      showToast('Bağlantı hatası', 'error');
    }

    return Promise.reject(error);
  }
);
```

### 2. Loading States
Her veri yüklenen yerde tutarlı loading göster:

```jsx
// Sayfa yüklenirken:
if (isLoading) return <PageLoader />;

// Buton yüklenirken:
<Button loading={isSubmitting}>KAYDET</Button>

// Liste yüklenirken:
<SkeletonList count={5} />

// Harita marker'ları yüklenirken:
// Harita boşken overlay spinner
```

**SkeletonLoader Component:**
```jsx
// Kart şeklinde gri animasyonlu placeholder
// animate-pulse tailwind class

const SkeletonCard = () => (
  <div className="bg-mesh-card rounded-lg p-4 animate-pulse">
    <div className="h-4 bg-mesh-disabled rounded w-3/4 mb-2" />
    <div className="h-3 bg-mesh-disabled rounded w-1/2" />
  </div>
);
```

### 3. Boş Durum Ekranları (Empty States)
```jsx
// Her liste için boş durum:

const EmptyState = ({ icon, title, description }) => (
  <div className="flex flex-col items-center justify-center h-64">
    <span className="text-6xl mb-4">{icon}</span>
    <h3 className="font-bebas text-xl text-mesh-muted">{title}</h3>
    <p className="font-nunito text-sm text-mesh-disabled">{description}</p>
  </div>
);

// Kullanım:
// Görev yok: <EmptyState icon="✅" title="GÖREV YOK" description="Henüz görev oluşturulmadı" />
// SOS yok: <EmptyState icon="🟢" title="AKTİF SOS YOK" description="Şu an aktif çağrı bulunmuyor" />
// Node yok: <EmptyState icon="📡" title="NODE BULUNAMADI" description="Bağlı ESP32 node yok" />
```

### 4. Responsive Düzenlemeler
```jsx
// Dashboard (büyük ekran):
// Sol sidebar 240px | Harita tam | Sağ sidebar 320px

// Dashboard (orta ekran, tablet):
// Sol sidebar collapsed (sadece ikonlar, 60px)
// Sağ sidebar toggle ile

// Dashboard (küçük ekran):
// Sol sidebar gizli, hamburger ile açılır
// Sağ sidebar gizli, FAB butonu ile açılır

// Tailwind breakpoints:
// lg: sidebar tam açık
// md: sidebar collapsed
// sm: sidebar overlay
```

### 5. Harita İyileştirmeleri

**Animated Marker (Yeni SOS için):**
```jsx
// Yeni SOS gelince marker 3 kez yanıp söner
// CSS animation ile

const SosMarker = ({ data, isNew }) => (
  <Marker
    position={[data.lat, data.lon]}
    icon={isNew ? animatedSosIcon : sosIcon}
  />
);

// CSS:
// @keyframes markerPulse { 0%,100% { opacity:1 } 50% { opacity:0.3 } }
// Yeni marker 3sn boyunca animasyon, sonra normal
```

**Marker Cluster:**
```jsx
// Yakın marker'lar gruplanır
// Zoom artınca ayrılır
import MarkerClusterGroup from 'react-leaflet-cluster';

<MarkerClusterGroup>
  {sosList.map(sos => <SosMarker key={sos.id} data={sos} />)}
</MarkerClusterGroup>
```

### 6. Dashboard İstatistik Bar
```jsx
// TopBar altında ince istatistik şeridi

<div className="flex gap-6 px-4 py-2 bg-mesh-card border-b border-mesh-disabled">
  <StatItem icon="🔴" label="Aktif SOS" value={sosList.length} color="danger" />
  <StatItem icon="🟠" label="Bekleyen Talep" value={pendingRequests} color="accent" />
  <StatItem icon="🟢" label="Aktif Node" value={activeNodes} color="success" />
  <StatItem icon="✅" label="Tamamlanan Görev" value={completedTasks} color="info" />
</div>
```

### 7. Keyboard Shortcuts
```javascript
// Hızlı navigasyon için
useEffect(() => {
  const handler = (e) => {
    if (e.key === '1') navigate('/');
    if (e.key === '2') navigate('/tasks');
    if (e.key === '3') navigate('/nodes');
    if (e.key === '4') navigate('/assembly');
    if (e.key === 'Escape') closeAllModals();
  };
  window.addEventListener('keydown', handler);
  return () => window.removeEventListener('keydown', handler);
}, []);
```

### 8. Son Kontroller

**Türkçe Karakter Kontrolü:**
```
Tüm metinlerde ş, ğ, ü, ö, ç, ı doğru görünüyor mu?
```

**Renk Tutarlılığı:**
```
Tüm renkler tailwind custom class kullanıyor mu?
Hardcode hex kalmadı mı?
```

**Console Hataları:**
```
Leaflet ikon hatası düzeltildi mi?
React key prop uyarıları yok mu?
WS bağlantı hataları handle ediliyor mu?
```

**Demo Hazırlığı:**
```jsx
// Demo için seed data butonu (sadece geliştirme modunda)
// Birkaç mock SOS ve request ekler
// Demo sırasında gerçek ESP32 çalışacak ama yedek plan

if (import.meta.env.DEV) {
  // "Demo Data Ekle" butonu göster
}
```

---

## Faz 5 Test Kriterleri

```
✅ 401 hatada otomatik logout ve login'e redirect
✅ 500 hatada toast gösteriliyor
✅ Bağlantı kopunca toast gösteriliyor
✅ Tüm sayfalarda loading state var
✅ Skeleton loader görünüyor
✅ Boş listeler için empty state var
✅ Tablet ekranda sidebar collapsed çalışıyor
✅ Yeni SOS marker'ı 3sn yanıp sönüyor
✅ Yakın marker'lar cluster'lıyor
✅ İstatistik bar doğru sayıları gösteriyor
✅ Keyboard shortcuts çalışıyor
✅ Console'da hata yok
✅ Türkçe karakterler doğru görünüyor
✅ Tüm modal'lar Escape ile kapanıyor
```

---

## Demo Öncesi Kontrol Listesi

```
□ Backend IP/URL constants.js'te doğru mu?
□ WS URL doğru mu?
□ Ses dosyaları public/sounds/ klasöründe var mı?
□ Offline tile cache çalışıyor mu?
□ Koordinatör giriş bilgileri hazır mı?
□ Demo seed data butonu çalışıyor mu?
□ Tüm fazların test kriterleri geçti mi?
□ Sunum için demo senaryosu hazır mı?
```

---

## Sunum İçin Son Notlar

- Demo başlamadan önce koordinatör olarak giriş yap
- Harita Balıkesir bölgesini gösteriyor olsun
- WS bağlantısı "Canlı" yeşil dot gösteriyor olsun
- Ses ses açık olsun (SOS toast sesi etkileyici)
- Toplanma noktaları haritada hazır olsun
- Node'lar aktif görünüyor olsun
