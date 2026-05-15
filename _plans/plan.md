# MeshAid - Frontend Geliştirme Planı
> EBST Hackathon 2026 | "Afetlere Hazırlık ve Dijital Dayanıklılık"

---

## Proje Özeti
İnternet ve GSM altyapısının çöktüğü afet anlarında, ESP32 tabanlı mesh ağı üzerinden çalışan acil durum koordinasyon sistemi. Deprem çantasına yerleştirilen ESP32 modülü ile enkaz altındaki kişiler internet olmadan kurtarma ekiplerine ulaşabilir.

---

## Mimari

```
[Saha - İnternet Yok]                    [Komuta Merkezi]

Flutter Mobil App                         React Web Dashboard
  - ACİL SOS (kayıtsız)                    - Leaflet Harita (offline)
  - Yardım Talepleri (kayıtlı)             - Canlı SOS/Request listesi
  - Görev Sayfası (kayıtlı)               - Node durumu
  - Profil                                 - Görev yönetimi
        ↓                                  - Koordinatör paneli
  İnternet varsa → Backend direkt               ↑ WebSocket
  İnternet yoksa → ESP32 WiFi AP          ws://backend/ws/dashboard
        ↓
  ESP32 Node-1  ←mesh→  ESP32 Node-2
  ESP32 Node-3  ←mesh→  ESP32 Node-4
                              ↓
                        ESP32 Gateway
                              ↓
                        FastAPI Backend
                        MySQL Veritabanı
```

---

## Teknik Stack

| Katman | Teknoloji |
|--------|-----------|
| Mobil | Flutter |
| Web | React + Leaflet.js + leaflet.offline |
| Backend | FastAPI + MySQL |
| Realtime | WebSocket (ws://backend/ws/dashboard) |
| Donanım | 4x ESP32 Node + 1x ESP32 Gateway |
| Auth | JWT Token |

---

## Tasarım Sistemi

### Renkler
```
Arka plan:        #0D1B2A  (koyu lacivert)
Kart:             #1B2E45  (açık koyu)
Ana aksan:        #FF6B35  (turuncu)
SOS/Tehlike:      #E63946  (kırmızı)
Onay/Güvenli:     #2DC653  (yeşil)
Bilgi/Normal:     #4A9EFF  (mavi)
Uyarı:            #FFB703  (sarı)
Birincil metin:   #FFFFFF
İkincil metin:    #8899AA
Devre dışı:       #445566
```

### Tipografi
```
Başlık/Buton:  Bebas Neue
Gövde/Form:    Nunito

Bebas Neue boyutları:
  Hero:          48px
  Sayfa başlığı: 32px
  Kart başlığı:  24px
  Buton:         20px
  Etiket:        18px

Nunito boyutları:
  Normal metin:  16px
  Alt açıklama:  14px
  Küçük bilgi:   12px
```

---

## API Endpointleri

### ESP32 → Backend
```
POST /mesh/sos
POST /mesh/request
POST /mesh/heartbeat
GET  /mesh/nodes
```

### Flutter → Backend
```
POST /auth/register
POST /auth/login
GET  /user/profile
PUT  /user/profile
POST /request/create
GET  /request/nearby
GET  /tasks/nearby
POST /tasks/{id}/accept
POST /tasks/{id}/complete
```

### React → Backend
```
POST /auth/login
GET  /dashboard/sos
GET  /dashboard/requests
GET  /dashboard/nodes
GET  /dashboard/tasks
POST /dashboard/tasks
PUT  /dashboard/tasks/{id}
GET  /assembly-points
POST /assembly-points
DELETE /assembly-points/{id}
```

### WebSocket Event Formatları
```json
// Yeni SOS
{
  "event": "NEW_SOS",
  "data": {
    "id": 1,
    "node_id": "NODE_01",
    "lat": 41.0152,
    "lon": 28.9795,
    "ts": 1234567890
  }
}

// Yeni Request
{
  "event": "NEW_REQUEST",
  "data": {
    "id": 2,
    "node_id": "NODE_01",
    "category": "MEDICAL",
    "lat": 41.0152,
    "lon": 28.9795,
    "people_count": 2,
    "details": "Bacak kırığı var",
    "ts": 1234567890
  }
}

// Node Durumu
{
  "event": "NODE_STATUS",
  "data": {
    "node_id": "NODE_01",
    "status": "active",
    "free_heap": 210000,
    "ts": 1234567890
  }
}
```

### SOS/Request Response
```json
{
  "status": "ok",
  "id": 1,
  "message": "SOS sinyaliniz alındı. Kurtarma ekipleri bilgilendirildi.",
  "received_at": "2026-05-15T18:30:00"
}
```

---

## Veri Modelleri

### SOS
```json
{
  "id": 1,
  "node_id": "NODE_01",
  "lat": 41.0152,
  "lon": 28.9795,
  "ts": 1234567890,
  "status": "active",
  "created_at": "2026-05-15T18:30:00"
}
```

### Request
```json
{
  "id": 2,
  "node_id": "NODE_01",
  "type": "REQUEST",
  "category": "MEDICAL|RESCUE|FOOD|SHELTER|CLOTHES|VULNERABLE",
  "lat": 41.0152,
  "lon": 28.9795,
  "people_count": 2,
  "details": "Bacak kırığı var",
  "ts": 1234567890,
  "status": "pending|assigned|resolved",
  "created_at": "2026-05-15T18:30:00"
}
```

### Node
```json
{
  "node_id": "NODE_01",
  "status": "active|inactive",
  "free_heap": 210000,
  "last_seen": "2026-05-15T18:30:00"
}
```

### User
```json
{
  "id": 1,
  "name": "Ahmet",
  "surname": "Yılmaz",
  "phone": "05551234567",
  "blood_type": "A+",
  "token": "jwt_token_here"
}
```

---

## Flutter - Ekran Listesi

### Ana Sayfa
- ACİL SOS butonu (3sn basılı tutma)
- Basılınca turuncu halka animasyonu + geri sayım
- Waterfall bağlantı: İnternet → ESP32 → Uyarı
- Konum izni: İlk açılışta iste, vermezse SOS'a basınca tekrar sor
- Konumsuz gönderim seçeneği (lat/lon null)
- Confirmation ekranı: id, message, received_at

### Yardım Talepleri (Soft Gate)
- 2 sütun grid, 6 kategori
- 🚨 Kurtarma, 🏥 Tıbbi, 🍞 Gıda&Su
- 🏕️ Barınma, 👕 Giysi, 👶 Kırılgan Grup
- Her kategoride: kişi sayısı + detay alanı + GPS konum

### Görevler (Soft Gate)
- Toplanma noktası bazlı görev listesi
- Kart: başlık + mesafe + yön (Haversine + atan2)
- Tıklayınca bottom sheet detay
- Görev türleri: Yemek, Taşıma, Dağıtım, Temizlik, Refakat, Yönlendirme
- [Görevi Kabul Et] → [Tamamlandı]

### Profil
- Kayıtsız: Giriş/Kayıt ekranı + avantajlar listesi
- Kayıtlı: Form (isim, soyisim, telefon, kan grubu)
- Offline JWT token local storage

---

## React - Sayfa Listesi

### Giriş
- Koordinatör kullanıcı adı + şifre
- JWT token → localStorage

### Ana Dashboard
- Tam ekran Leaflet harita + offline OSM tile cache
- Sol sidebar navigasyon (açılır/kapanır)
- Sağ sidebar SOS listesi (açılır/kapanır)
- Harita ikonları:
  - 🔴 Kırmızı → Aktif SOS
  - 🟠 Turuncu → Kurtarma/Yardım talebi
  - 🟢 Yeşil → Toplanma noktası
  - 🔵 Mavi → Yardım dağıtım noktası
  - 🟣 Mor → Aktif ESP32 Node
- Tıklayınca popup detay
- Kategori bazlı filtreler
- WebSocket canlı güncelleme
- Sağ üst toast bildirimi + ses

### Görev Yönetimi
- Açık görevler listesi
- Manuel görev oluşturma
- Durum: bekliyor/atandı/tamamlandı

### Node Durumu
- Aktif/Pasif node listesi
- Son heartbeat, free_heap
- Son 2dk heartbeat yok → pasif

### Toplanma Noktaları
- AFAD açık verisi seed data
- Koordinatör panelinden ekle/kaldır
- Kapasite yönetimi

---

## Flutter Componentler

### Temel
| Component | Kullanım |
|-----------|---------|
| AppButton | Tüm butonlar (turuncu/kırmızı/yeşil varyant) |
| AppTextField | Form alanları |
| AppCard | Görev, kategori, profil kartları |
| AppBottomNav | Alt navigasyon, 4 sekme |
| AppTopBar | Üst bar |
| AppBadge | Bildirim, durum etiketi |
| AppToast | Başarı/hata bildirimi |
| AppLoader | Yükleme animasyonu |
| AppDialog | Onay popup |

### Özel
| Component | Kullanım |
|-----------|---------|
| SosButton | Ana sayfa, 3sn + halka animasyonu |
| CountdownRing | Geri sayım animasyonu |
| ConnectionStatus | İnternet/ESP32 durum göstergesi |
| CategoryGrid | 6 kategori, 2 sütun |
| CategoryCard | Tek kategori kartı |
| TaskCard | Görev kartı, mesafe + yön |
| TaskDetailSheet | Görev detay bottom sheet |
| DirectionIndicator | Yön oku + mesafe |
| ConfirmationScreen | SOS/Request onay ekranı |
| SoftGateSheet | Kayıt yönlendirme |
| LocationPermission | Konum izni ekranı |
| ProfileForm | Profil formu |

---

## React Componentler

### Temel
| Component | Kullanım |
|-----------|---------|
| Button | Tüm butonlar |
| Card | Dashboard kartları |
| Badge | Durum etiketleri |
| Toast | Sağ üst bildirimler |
| Modal | Onay/detay popup |
| Loader | Yükleme durumu |
| Input | Form alanları |
| Select | Dropdown |

### Layout
| Component | Kullanım |
|-----------|---------|
| SidebarNav | Sol navigasyon, açılır/kapanır |
| TopBar | Üst bar + bağlantı durumu |
| SosList | Sağ sidebar, açılır/kapanır |
| PageLayout | Sayfa wrapper |

### Harita
| Component | Kullanım |
|-----------|---------|
| MapContainer | Ana harita wrapper |
| SosMarker | Kırmızı SOS ikonu |
| RequestMarker | Turuncu talep ikonu |
| AssemblyMarker | Yeşil toplanma ikonu |
| DistributionMarker | Mavi dağıtım ikonu |
| NodeMarker | Mor ESP32 node ikonu |
| MarkerPopup | Tıklama detay popup |
| MapFilters | Kategori filtre butonları |
| OfflineTileLayer | Offline OSM tile |

### Dashboard
| Component | Kullanım |
|-----------|---------|
| SosCard | SOS listesi kartı |
| RequestCard | Talep listesi kartı |
| NodeCard | Node durum kartı |
| TaskCard | Görev listesi kartı |
| TaskForm | Görev oluşturma formu |
| AssemblyForm | Toplanma noktası ekleme |
| StatsBar | Aktif SOS/node sayısı |
| WebSocketStatus | Bağlantı durumu |

---

## Faz Planları

### Flutter

| Faz | İçerik | Test Kriteri |
|-----|--------|-------------|
| Faz 1 | Kurulum, navigasyon, tema, konum izni, bağlantı kontrolü | Uygulama açılıyor, sayfalar arası geçiş çalışıyor |
| Faz 2 | SOS ekranı, animasyon, HTTP POST, confirmation | SOS gönderiliyor, response ekranda görünüyor |
| Faz 3 | Kayıt/Giriş, offline token, soft gate, profil | Kayıt/giriş çalışıyor, token saklanıyor |
| Faz 4 | 6 kategori, formlar, API entegrasyonu | Talepler backend'e gidiyor |
| Faz 5 | Görev listesi, mesafe/yön, kabul/tamamla | Görevler listeniyor, mesafe doğru |

### React

| Faz | İçerik | Test Kriteri |
|-----|--------|-------------|
| Faz 1 | Kurulum, routing, tema, koordinatör girişi, JWT | Giriş çalışıyor, yetkisiz redirect |
| Faz 2 | Leaflet harita, offline tile, mock ikonlar, popup, filtreler | Harita açılıyor, ikonlar görünüyor |
| Faz 3 | WebSocket, canlı güncelleme, ses bildirimi, SOS listesi | Yeni SOS haritaya düşüyor, toast çıkıyor |
| Faz 4 | Görev yönetimi, toplanma noktaları, node durumu | Görev oluşturuluyor, noktalar görünüyor |
| Faz 5 | UI polish, hata yönetimi, loading states | Tüm hata durumları yönetiliyor |

---

## Demo Senaryosu (7 Dakika)

```
0:00 → ESP32 node'lar açık, mesh kurulu
0:30 → Telefon ESP32 WiFi AP'sine otomatik bağlanıyor
1:00 → Flutter ACİL SOS'a 3 saniye basılıyor
         Turuncu halka animasyonu + geri sayım
         "Sinyal İletildi #1" ekranı
1:30 → React haritada kırmızı ikon anlık düşüyor
         Toast bildirimi + ses
         Sağ sidebar'a ekleniyor
2:00 → Koordinatör ikona tıklıyor → popup
         [Görev Oluştur] butonuna basıyor
2:30 → Flutter'dan tıbbi yardım talebi gönderiliyor
         Haritada turuncu ikon
3:00 → Node durumu gösterimi
         Mor ikonlar + heartbeat canlı
3:30 → Toplanma noktası haritadan ekleniyor
4:00 → Sunum: LoRa + özel PCB vizyonu anlatılıyor
```

---

## Önemli Notlar

- ESP32 WiFi AP bağlantısı otomatik (captive portal)
- lat/lon null gelebilir (konum izni verilmemişse)
- ts alanı ESP32 millis(), sadece loglama için
- Offline harita: leaflet.offline ile OSM tile cache
- Toplanma noktaları: AFAD açık verisi seed + koordinatör paneli
- Mesafe/yön: Haversine + atan2, tamamen offline
- WebSocket kopunca otomatik yeniden bağlan
- Geçmiş görevler şimdilik yok, sonraki versiyona bırakıldı
