# MeshAid Flutter - Faz 5
> Görev Sistemi: Liste, Mesafe/Yön, Kabul/Tamamla

---

## Faz 1-4'ten Gelenler
- Tema, navigasyon, tüm componentler hazır
- AuthProvider, token sistemi çalışıyor
- SOS ve yardım talepleri tam çalışıyor
- Soft gate sistemi çalışıyor

---

## Bu Fazda Yapılacaklar

### 1. TasksScreen Ana Sayfa
```
AppTopBar: "GÖREVLER"

Üstte bilgi kartı:
  "Yakınındaki toplanma noktalarındaki görevleri görüyorsunuz"
  (Nunito, 14px, #8899AA)

Görev listesi:
  GET /tasks/nearby → konum ile filtrele
  Loading: AppLoader
  Boş liste: "Yakında görev bulunamadı" (Nunito, 16px, gri)
  Hata: "Görevler yüklenemedi" + [Tekrar Dene]

Liste yapısı:
  Toplanma noktasına göre grupla
  Her grup: noktanın adı (Bebas Neue, 20px, turuncu)
  Altında: o noktaya ait görev kartları
```

### 2. TaskCard Component
```
Görünüm:
  AppCard (arka plan: #1B2E45)
  Sol taraf: görev ikon (emoji, 32px)
  Sağ taraf:
    Görev adı (Bebas Neue, 18px, beyaz)
    DirectionIndicator (mesafe + yön)
  Sağ köşe: ok ikonu (>)
  Tıklanabilir → TaskDetailSheet açılır

Görev ikonları:
  🍳 Yemek Hazırlama
  💧 Su/Malzeme Taşıma
  📦 Yardım Dağıtımı
  🧹 Temizlik
  👴 Refakat
  📢 Yönlendirme
```

### 3. DirectionIndicator Component
```dart
// Haversine formülü ile mesafe hesapla
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371000.0; // metre
  final phi1 = lat1 * pi / 180;
  final phi2 = lat2 * pi / 180;
  final dphi = (lat2 - lat1) * pi / 180;
  final dlambda = (lon2 - lon1) * pi / 180;
  final a = sin(dphi/2)*sin(dphi/2) + cos(phi1)*cos(phi2)*sin(dlambda/2)*sin(dlambda/2);
  final c = 2 * atan2(sqrt(a), sqrt(1-a));
  return R * c;
}

// atan2 ile yön hesapla
String calculateDirection(double lat1, double lon1, double lat2, double lon2) {
  final y = sin((lon2-lon1) * pi/180) * cos(lat2 * pi/180);
  final x = cos(lat1*pi/180)*sin(lat2*pi/180) - sin(lat1*pi/180)*cos(lat2*pi/180)*cos((lon2-lon1)*pi/180);
  final bearing = atan2(y, x) * 180 / pi;
  final normalized = (bearing + 360) % 360;

  if (normalized < 22.5 || normalized >= 337.5) return "↑ Kuzey";
  if (normalized < 67.5)  return "↗ Kuzeydoğu";
  if (normalized < 112.5) return "→ Doğu";
  if (normalized < 157.5) return "↘ Güneydoğu";
  if (normalized < 202.5) return "↓ Güney";
  if (normalized < 247.5) return "↙ Güneybatı";
  if (normalized < 292.5) return "← Batı";
  return "↖ Kuzeybatı";
}

// Görünüm:
// ↗ Kuzeydoğu  •  380 metre
// (Nunito, 14px, turuncu)
// Tamamen offline çalışır, internet gerektirmez
```

### 4. TaskDetailSheet
```
Bottom sheet (DraggableScrollableSheet)
Arka plan: #1B2E45

İçerik:
  - Görev ikonu (büyük, 48px)
  - Görev adı (Bebas Neue, 28px)
  - Toplanma Noktası adı (Nunito, 16px, turuncu)
  - DirectionIndicator (büyük versiyon)
  - Süre: "14:00 - 16:00" (Nunito, 16px)
  - İhtiyaç: "2 kişi daha gerekiyor" (Nunito, 14px, sarı)
  - Açıklama (Nunito, 14px, gri)

Alt kısım:
  Görev kabul edilmemişse:
    [GÖREVI KABUL ET] butonu (turuncu, tam genişlik)
  Görev kabul edildiyse:
    "✓ Bu görevi kabul ettiniz" (yeşil)
    [TAMAMLANDI] butonu (yeşil, tam genişlik)
```

### 5. Görev Kabul / Tamamla
```dart
// Görevi Kabul Et
// POST /tasks/{id}/accept
// Header: Authorization: Bearer {token}
// Response: {"status": "ok", "message": "Görev kabul edildi"}

// Görevi Tamamla
// POST /tasks/{id}/complete
// Header: Authorization: Bearer {token}
// Response: {"status": "ok", "message": "Görev tamamlandı, teşekkürler!"}

// Akış:
// Kabul → AppToast "Görev kabul edildi" → kart güncellenir
// Tamamla → AppToast "Teşekkürler!" → görev listeden kalkar
```

### 6. Aktif Görev Göstergesi
```
TasksScreen üstünde (varsa):
  Turuncu card:
  "📦 Aktif Göreviniz Var"
  "Yardım Dağıtımı - Atatürk İlkokulu"
  [GÖREVE GİT] butonu
```

---

## API İstekleri

### Görev Listesi
```dart
// GET /tasks/nearby?lat=41.0152&lon=28.9795
// Header: Authorization: Bearer {token}

// Response
{
  "tasks": [
    {
      "id": 1,
      "type": "FOOD_DISTRIBUTION",
      "title": "Yardım Dağıtımı",
      "assembly_point": {
        "id": 1,
        "name": "Atatürk İlkokulu",
        "lat": 41.0180,
        "lon": 28.9810
      },
      "people_needed": 2,
      "start_time": "14:00",
      "end_time": "16:00",
      "description": "Gıda paketleri dağıtımı",
      "status": "open|accepted|completed",
      "accepted_by": null
    }
  ]
}
```

---

## Yeni Dosyalar

```
lib/
  features/
    tasks/
      screens/
        tasks_screen.dart     (güncellendi)
      widgets/
        task_card.dart
        task_detail_sheet.dart
        direction_indicator.dart
        active_task_banner.dart
      services/
        task_service.dart
      models/
        task_model.dart
        assembly_point_model.dart
      utils/
        location_utils.dart   (Haversine + atan2)
```

---

## Faz 5 Test Kriterleri

```
✅ Görev listesi API'den yükleniyor
✅ Toplanma noktasına göre gruplandı
✅ Her kartta mesafe doğru hesaplanıyor
✅ Her kartta yön doğru gösteriliyor (Haversine + atan2)
✅ Karta tıklanınca bottom sheet açılıyor
✅ Bottom sheet tüm detayları gösteriyor
✅ [GÖREVI KABUL ET] API'ye istek atıyor
✅ Kabul sonrası kart güncelleniyor
✅ [TAMAMLANDI] API'ye istek atıyor
✅ Tamamlanan görev listeden kalkıyor
✅ Aktif görev banner'ı görünüyor
✅ Kayıtsız basınca soft gate açılıyor
✅ Mesafe/yön hesabı internet gerektirmiyor
```

---

## Önemli Notlar
- Mesafe ve yön hesabı tamamen offline, hiçbir API veya internet gerektirmez
- Kullanıcının kendi konumu geolocator ile alınır, 30sn cache'lenir
- Konum alınamazsa mesafe/yön gösterilmez, görevler yine de listelenir
- Bir kullanıcı aynı anda sadece 1 aktif görev alabilir
- Görev kabul edilince diğer [KABUL ET] butonları disable olsun
