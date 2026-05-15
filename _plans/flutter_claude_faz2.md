# MeshAid Flutter - Faz 2
> SOS Çekirdeği: Buton, Animasyon, HTTP POST, Confirmation

---

## Faz 1'den Gelenler
- AppColors, AppTextStyles, ThemeData hazır
- go_router navigasyon kurulu
- AppBottomNav çalışıyor
- ConnectionProvider (internet/ESP32/none) çalışıyor
- LocationProvider (konum izni durumu) çalışıyor

---

## Bu Fazda Yapılacaklar

### 1. SosButton Component
```
Görünüm:
- Büyük daire, kırmızı (#E63946)
- İçinde "ACİL SOS" (Bebas Neue, 48px, beyaz)
- Altında "3 saniye basılı tutun" (Nunito, 14px, #8899AA)
- Ekranın ortasında konumlu

Animasyon (SADECE basılınca):
- GestureDetector onLongPressStart ile başla
- Turuncu (#FF6B35) halka dışarı doğru genişler
- Eş zamanlı geri sayım: 3 → 2 → 1
- Her sayıda telefon titreşir (HapticFeedback)
- 3 saniye dolunca SOS gönderilir
- Bırakılırsa animasyon sıfırlanır

Bekleme durumu:
- Animasyon yok, sadece kırmızı buton
- Konum izni yoksa üstte küçük ⚠️ turuncu ikon
```

### 2. CountdownRing Component
```dart
// AnimationController ile 3 saniye
// CustomPainter ile turuncu halka
// Halka dışarı doğru genişler (0 → butonun 1.5 katı)
// Opaklık azalır (1.0 → 0.0)
// Ortada büyük sayı gösterir (3, 2, 1)
```

### 3. Waterfall Bağlantı Sistemi
```dart
Future<void> sendSOS({double? lat, double? lon}) async {
  final payload = {
    "type": "SOS",
    "node_id": "MOBILE",
    "ts": DateTime.now().millisecondsSinceEpoch,
    "lat": lat,   // null olabilir
    "lon": lon,   // null olabilir
  };

  // 1. İnternet var mı?
  if (connectionProvider.type == ConnectionType.internet) {
    return await _postToBackend(payload);
  }

  // 2. ESP32 bağlı mı?
  if (connectionProvider.type == ConnectionType.esp32) {
    return await _postToESP32(payload);
  }

  // 3. Hiçbiri yok
  throw NoConnectionException();
}

// Backend URL: http://[BACKEND_IP]:8000/mesh/sos
// ESP32 URL:   http://192.168.4.1/sos
```

### 4. Konum Akışı (SOS öncesi)
```
SOS tetiklendi (3sn doldu)
    ↓
Konum izni var mı?
    ✓ → GPS konum al → SOS gönder (lat/lon ile)
    ✗ → Dialog aç:
        "Konumunuz olmadan kurtarma ekipleri
         sizi bulamaz. İzin vermek ister misiniz?"
        [İzin Ver] → izin iste → konum al → gönder
        [İzinsiz Gönder] → lat:null, lon:null ile gönder
```

### 5. Confirmation Ekranı
```
Response:
{
  "status": "ok",
  "id": 1,
  "message": "SOS sinyaliniz alındı. Kurtarma ekipleri bilgilendirildi.",
  "received_at": "2026-05-15T18:30:00"
}

Ekran tasarımı:
- Arka plan: #0D1B2A
- Ortada büyük yeşil checkmark animasyonu
- "Sinyal İletildi" (Bebas Neue, 32px, yeşil)
- response.message (Nunito, 16px, beyaz)
- "Çağrı No: #1" (Nunito, 14px, gri)
- "2026-05-15 18:30" (Nunito, 14px, gri)
- [Tamam] butonu (turuncu) → ana sayfaya döner
```

### 6. Hata Ekranı
```
Bağlantı yoksa:
- Kırmızı X animasyonu
- "Bağlantı Kurulamadı" (Bebas Neue, 32px, kırmızı)
- "İnternet bağlantınız yok ve ESP32 cihazı bulunamadı"
- [Tekrar Dene] butonu (turuncu)
- [İptal] butonu (outline)
```

### 7. HomeScreen Güncellemesi
```
Ana Sayfa layout:
- AppTopBar: "ACİL YARDIM" başlığı
- ConnectionStatus widget (üstte)
- SosButton (ekranın ortasında, büyük alan kaplasın)
- Alt kısımda küçük bilgi metni:
  "Enkaz altındaysanız bu butona 3 saniye basın"
  (Nunito, 14px, #8899AA)
```

---

## Yeni Componentler

### SosButton
```
lib/features/home/widgets/sos_button.dart
```

### CountdownRing
```
lib/features/home/widgets/countdown_ring.dart
```

### ConfirmationScreen
```
lib/features/home/screens/confirmation_screen.dart
Router: /confirmation → argüman olarak response alır
```

### SosService
```
lib/features/home/services/sos_service.dart
sendSOS() metodu
_postToBackend() metodu
_postToESP32() metodu
```

---

## Faz 2 Test Kriterleri

```
✅ SOS butonuna kısa basınca hiçbir şey olmuyor
✅ 3 saniye basılı tutunca animasyon başlıyor
✅ Geri sayım 3→2→1 görünüyor
✅ Her sayıda telefon titreşiyor
✅ Bırakılınca animasyon sıfırlanıyor
✅ İnternet varken backend'e POST gidiyor
✅ Response'taki message ekranda görünüyor
✅ Çağrı numarası (#id) görünüyor
✅ Konum izni yoksa dialog çıkıyor
✅ "İzinsiz Gönder" ile lat/lon null gönderiliyor
✅ Bağlantı yoksa hata ekranı çıkıyor
✅ [Tekrar Dene] çalışıyor
```

---

## Önemli Notlar
- ESP32 IP adresi sabit: 192.168.4.1
- Backend IP: app_constants.dart'tan al, hardcode yazma
- Timeout: 10 saniye, sonra hata ekranı
- SOS gönderilirken buton disable olsun, çift gönderim önle
- Confirmation sonrası geri tuşu ana sayfaya gitsin, confirmation'a dönmesin
