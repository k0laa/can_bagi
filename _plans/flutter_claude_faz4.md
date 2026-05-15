# MeshAid Flutter - Faz 4
> Yardım Talepleri: 6 Kategori, Formlar, API Entegrasyonu

---

## Faz 1-3'ten Gelenler
- Tema, navigasyon, componentler hazır
- AuthProvider, token sistemi çalışıyor
- Soft gate sistemi çalışıyor
- SOS akışı tam çalışıyor

---

## Bu Fazda Yapılacaklar

### 1. HelpScreen Ana Sayfa
```
AppTopBar: "YARDIM TALEBİ"

İçerik:
- Üstte küçük bilgi kartı (AppCard):
  "İnternet bağlantısı olmadan da talepte bulunabilirsiniz"
  (Nunito, 14px, #8899AA)

- 2 sütun Grid, 6 kategori kartı (CategoryCard)
- Her kart tıklanabilir
- Kayıtsız kullanıcı basınca SoftGateSheet
- Kayıtlı kullanıcı basınca CategoryFormScreen
```

### 2. CategoryCard Component
```
Görünüm:
  Arka plan: #1B2E45
  Border radius: 16
  Padding: 20
  İkon (büyük emoji veya SVG): ortada, 40px
  Kategori adı: Bebas Neue, 18px, beyaz, altta
  Aktif/hover durumu: turuncu border

Kategoriler:
  🚨 KURTARMA    → category: RESCUE
  🏥 TIBBİ       → category: MEDICAL
  🍞 GIDA & SU   → category: FOOD
  🏕️ BARINMA     → category: SHELTER
  👕 GİYSİ       → category: CLOTHES
  👶 KIRILGAN    → category: VULNERABLE
```

### 3. CategoryFormScreen
```
Route: /help/form (argüman: category)

AppTopBar: kategori adı (örn: "TIBBİ YARDIM")

Form alanları (hepsi AppTextField veya özel widget):

ORTAK ALANLAR (tüm kategoriler):
  - Kişi Sayısı (sayı, stepper: +/- butonlar, min:1 max:50)
  - Detay (text area, opsiyonel, max 200 karakter)
  - Konum (otomatik GPS, "Konum Alınıyor..." loader)

KATEGORİYE ÖZEL ALANLAR:
  RESCUE:
    - Enkaz Adresi (text field, zorunlu)
    - Yaklaşık Kat/Konum (text field, opsiyonel)

  MEDICAL:
    - Aciliyet (radio: 🔴 Acil / 🟡 Normal)
    - Yaralanma Türü (text field, opsiyonel)

  FOOD:
    - Bebek Maması Gerekiyor mu? (checkbox)

  SHELTER:
    - Çadır Gerekiyor mu? (checkbox)
    - Battaniye Gerekiyor mu? (checkbox)

  CLOTHES:
    - Yaş Grubu (dropdown: Bebek, Çocuk, Yetişkin, Yaşlı)
    - Beden (text field, opsiyonel)

  VULNERABLE:
    - Tür (dropdown: Yaşlı, Engelli, Hamile, Bebek)
    - Özel İhtiyaç (text field, opsiyonel)

Alt kısımda:
  [TALEP GÖNDER] butonu (turuncu, tam genişlik)
```

### 4. API İsteği
```dart
// POST /request/create
// Header: Authorization: Bearer {token}

{
  "type": "REQUEST",
  "node_id": "MOBILE",
  "ts": 1234567890,
  "category": "MEDICAL",
  "lat": 41.0152,      // null olabilir
  "lon": 28.9795,      // null olabilir
  "people_count": 2,
  "details": "Bacak kırığı var, acil"
}

// Response
{
  "status": "ok",
  "id": 2,
  "message": "Tıbbi yardım talebiniz alındı. Ekipler yönlendiriliyor.",
  "received_at": "2026-05-15T18:30:00"
}
```

### 5. Confirmation Ekranı (Yeniden Kullanım)
```
Faz 2'deki ConfirmationScreen aynı şekilde kullanılır
Sadece ikon rengi farklı:
  SOS → kırmızı
  RESCUE → turuncu
  MEDICAL → mavi
  FOOD → yeşil
  SHELTER → sarı
  CLOTHES → mavi
  VULNERABLE → mor
```

### 6. Bağlantı Kontrolü
```dart
// Waterfall sistemi aynı şekilde çalışır
// SOS ile aynı mantık:
// İnternet → /request/create
// ESP32 → http://192.168.4.1/request
// Hiçbiri → hata ekranı
```

---

## Yeni Dosyalar

```
lib/
  features/
    help/
      screens/
        help_screen.dart       (güncellendi)
        category_form_screen.dart
      widgets/
        category_card.dart
        category_grid.dart
        people_counter.dart    (stepper widget)
      services/
        request_service.dart
      models/
        request_model.dart
```

---

## Faz 4 Test Kriterleri

```
✅ 6 kategori grid doğru görünüyor
✅ Kayıtsız basınca soft gate açılıyor
✅ Her kategori doğru form ekranına gidiyor
✅ Kişi sayısı stepper çalışıyor (min 1, max 50)
✅ Konum otomatik alınıyor
✅ RESCUE formunda adres alanı var
✅ MEDICAL formunda aciliyet seçimi var
✅ FOOD formunda bebek maması checkbox var
✅ [TALEP GÖNDER] backend'e POST atıyor
✅ Response mesajı confirmation ekranında görünüyor
✅ Bağlantı yoksa hata ekranı çıkıyor
✅ Form submit edilince buton disabled oluyor (çift gönderim yok)
```

---

## Önemli Notlar
- Konum alınamıyorsa (timeout 5sn) → lat/lon null ile gönder, uyarı toast göster
- Form submit edilince [TALEP GÖNDER] butonu loader'a dönşsün
- Tüm formlar Türkçe placeholder kullan
- Detay alanında karakter sayacı göster (örn: "45/200")
- Başarılı gönderim sonrası form temizlensin, HelpScreen'e dön
