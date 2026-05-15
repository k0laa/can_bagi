# MeshAid React - Faz 4
> Yönetim Paneli: Görev Yönetimi, Toplanma Noktaları, Node Durumu

---

## Faz 1-3'ten Gelenler
- Tema, routing, JWT sistemi hazır
- Harita tam çalışıyor (gerçek WS verisi ile)
- Toast, ses bildirimleri çalışıyor
- SosList sidebar çalışıyor

---

## Bu Fazda Yapılacaklar

### 1. TasksPage - Görev Yönetimi
```
Route: /tasks

Layout:
  AppTopBar: "GÖREV YÖNETİMİ"
  Üst sağ: [+ YENİ GÖREV] butonu (turuncu)

İki sütun layout:
  Sol (2/3): Görev listesi
  Sağ (1/3): Görev oluşturma formu (toggle ile açılır)
```

**Görev Listesi:**
```jsx
// GET /dashboard/tasks
// Durum filtresi: Tümü | Bekliyor | Atandı | Tamamlandı

<TaskCard
  title="Yardım Dağıtımı"
  assembly_point="Atatürk İlkokulu"
  status="pending|assigned|completed"
  assigned_to="Ahmet Y."    // varsa
  created_at="10:23"
  onStatusChange={handleStatusChange}
/>

// TaskCard sol border rengi:
// pending: sarı
// assigned: turuncu
// completed: yeşil
```

**Görev Oluşturma Formu (TaskForm):**
```jsx
// POST /dashboard/tasks

Form alanları:
  - Görev Türü (select):
    Yemek Hazırlama, Su/Malzeme Taşıma, Yardım Dağıtımı,
    Temizlik, Refakat, Yönlendirme
  - Toplanma Noktası (select, GET /assembly-points'ten dolu)
  - Başlangıç Saati (time input)
  - Bitiş Saati (time input)
  - Gerekli Kişi Sayısı (number, min:1)
  - Açıklama (textarea, opsiyonel)
  - [GÖREV OLUŞTUR] butonu (turuncu)

Submit:
  POST /dashboard/tasks
  Başarılı → Toast "Görev oluşturuldu" → liste güncellenir
```

**Görev Durum Güncelleme:**
```jsx
// Her görev kartında durum dropdown:
// pending → assigned → completed
// PUT /dashboard/tasks/{id}
// { "status": "assigned" }
```

### 2. AssemblyPage - Toplanma Noktaları
```
Route: /assembly

Layout:
  Sol (1/2): Harita (mini, sadece toplanma noktaları)
  Sağ (1/2): Noktalar listesi + form
```

**Noktalar Listesi:**
```jsx
// GET /assembly-points

<AssemblyCard
  name="Atatürk İlkokulu"
  lat={39.6500}
  lon={27.8800}
  capacity={200}
  current_count={45}
  onDelete={handleDelete}
  onEdit={handleEdit}
/>
```

**Toplanma Noktası Ekleme (AssemblyForm):**
```jsx
// POST /assembly-points

Form alanları:
  - Nokta Adı (text, zorunlu)
  - Kapasite (number, min:1)
  - Konum (haritadan tıklayarak seç veya lat/lon manuel gir)
  - [NOKTA EKLE] butonu (turuncu)

Haritadan seçme:
  Butona basınca harita "seçim moduna" girer
  Tıklanan nokta lat/lon'a otomatik dolar
```

**Nokta Silme:**
```jsx
// DELETE /assembly-points/{id}
// Silme öncesi Modal: "Bu noktayı silmek istediğinize emin misiniz?"
// Başarılı → Toast "Nokta silindi" → liste güncellenir
```

### 3. NodesPage - Node Durumu
```
Route: /nodes

Layout:
  Üst: İstatistik bar (toplam/aktif/pasif node sayısı)
  Alt: Node kartları grid (3 sütun)
```

**StatsBar:**
```jsx
<div className="grid grid-cols-3 gap-4 mb-6">
  <StatCard label="TOPLAM NODE" value={nodes.length} color="info" />
  <StatCard label="AKTİF" value={activeCount} color="success" />
  <StatCard label="PASİF" value={inactiveCount} color="danger" />
</div>
```

**NodeCard:**
```jsx
// GET /dashboard/nodes → her 30sn yenile (veya WS NODE_STATUS ile)

<NodeCard
  node_id="NODE_01"
  status="active|inactive"
  free_heap={210000}
  last_seen="10:23:45"
/>

// Görünüm:
// Aktif: yeşil border + yeşil dot animate-pulse
// Pasif: kırmızı border + kırmızı dot (son 2dk heartbeat yok)
// free_heap: "Bellek: 210 KB"
// last_seen: "Son: 10:23:45 (2dk önce)"
```

**Node Pasif Uyarısı:**
```jsx
// WS'den NODE_STATUS gelince
// status: "inactive" ise:
// Toast uyarısı (zaten Faz 3'te var)
// NodesPage'deki kart da güncellenir
```

### 4. Dashboard'da Popup'tan Görev Oluşturma
```jsx
// Haritada SOS veya Request popup'ında [Görev Oluştur] var
// Butona basınca TaskForm modal olarak açılır
// Konum otomatik dolar

const handleCreateTaskFromMap = (markerData) => {
  openTaskModal({
    source_type: markerData.type,  // SOS veya REQUEST
    source_id: markerData.id,
    lat: markerData.lat,
    lon: markerData.lon,
  });
};
```

---

## API İstekleri

### Görev Endpointleri
```javascript
// Görev listesi
GET /dashboard/tasks?status=all|pending|assigned|completed

// Görev oluştur
POST /dashboard/tasks
{
  "type": "FOOD_DISTRIBUTION",
  "assembly_point_id": 1,
  "start_time": "14:00",
  "end_time": "16:00",
  "people_needed": 3,
  "description": "Gıda paketi dağıtımı"
}

// Görev güncelle
PUT /dashboard/tasks/{id}
{ "status": "assigned", "assigned_to": "Ahmet Y." }
```

### Toplanma Noktası Endpointleri
```javascript
// Liste
GET /assembly-points

// Ekle
POST /assembly-points
{ "name": "Atatürk İlkokulu", "lat": 39.65, "lon": 27.88, "capacity": 200 }

// Sil
DELETE /assembly-points/{id}
```

### Node Endpointleri
```javascript
// Liste (son 2dk aktif filtresi backend'de)
GET /dashboard/nodes
```

---

## Yeni Dosyalar

```
src/
  pages/
    TasksPage.jsx
    AssemblyPage.jsx
    NodesPage.jsx
  components/
    dashboard/
      TaskCard.jsx
      TaskForm.jsx
      AssemblyCard.jsx
      AssemblyForm.jsx
      NodeCard.jsx
      StatsBar.jsx
      StatCard.jsx
    map/
      MiniMap.jsx        (AssemblyPage için küçük harita)
```

---

## Faz 4 Test Kriterleri

```
✅ /tasks sayfası görev listesi yüklüyor
✅ Durum filtreleri çalışıyor
✅ Görev oluşturma formu çalışıyor
✅ Yeni görev listede görünüyor
✅ Görev durumu güncellenebiliyor
✅ /assembly sayfası noktaları haritada ve listede gösteriyor
✅ Yeni toplanma noktası eklenebiliyor
✅ Haritadan konum seçimi çalışıyor
✅ Nokta silme confirm modal çalışıyor
✅ /nodes sayfası node'ları gösteriyor
✅ Aktif/pasif durum renkleri doğru
✅ Pasif node kırmızı border ile gösteriliyor
✅ Dashboard popup'tan görev oluşturma çalışıyor
✅ İstatistik bar doğru sayıları gösteriyor
```

---

## Önemli Notlar
- Tüm sayfalarda AppLoader kullan, veri yüklenirken tam ekran loader göster
- Boş liste durumlarını handle et (görev yok, node yok vb.)
- Form submit sonrası formu temizle
- Silme işlemleri geri alınamaz, confirm modal zorunlu
- Node sayfası 30sn'de bir otomatik yenilenir (veya WS ile anlık)
