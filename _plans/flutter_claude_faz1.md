# MeshAid Flutter - Faz 1
> Temel Altyapı: Kurulum, Navigasyon, Tema, Konum İzni, Bağlantı Kontrolü

---

## Sen Kimsin
Sen bir Flutter geliştiricisisin. MeshAid adlı afet acil yardım uygulamasının Faz 1'ini geliştiriyorsun. Bu faz sadece temel altyapıyı kurar, hiçbir API çağrısı yoktur.

---

## Proje Hakkında
MeshAid, afet anında internet olmadan ESP32 mesh ağı üzerinden çalışan acil yardım koordinasyon sistemi. Kullanıcılar enkaz altından SOS gönderebilir, yardım talep edebilir, gönüllü görev alabilir.

---

## Teknik Stack
```
Flutter (latest stable)
Paketler:
  - go_router: navigasyon
  - provider: state management
  - permission_handler: konum izni
  - connectivity_plus: internet kontrolü
  - geolocator: GPS konum
  - google_fonts: Bebas Neue + Nunito
  - shared_preferences: local storage
```

---

## Tasarım Sistemi

### Renkler
```dart
class AppColors {
  static const background = Color(0xFF0D1B2A);
  static const card = Color(0xFF1B2E45);
  static const accent = Color(0xFFFF6B35);      // turuncu
  static const danger = Color(0xFFE63946);       // kırmızı SOS
  static const success = Color(0xFF2DC653);      // yeşil
  static const info = Color(0xFF4A9EFF);         // mavi
  static const warning = Color(0xFFFFB703);      // sarı
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF8899AA);
  static const textDisabled = Color(0xFF445566);
}
```

### Tipografi
```dart
// Bebas Neue → başlıklar, butonlar
// Nunito → gövde, formlar

class AppTextStyles {
  static TextStyle hero = GoogleFonts.bebasNeue(fontSize: 48, color: AppColors.textPrimary);
  static TextStyle pageTitle = GoogleFonts.bebasNeue(fontSize: 32, color: AppColors.textPrimary);
  static TextStyle cardTitle = GoogleFonts.bebasNeue(fontSize: 24, color: AppColors.textPrimary);
  static TextStyle buttonText = GoogleFonts.bebasNeue(fontSize: 20, color: AppColors.textPrimary);
  static TextStyle label = GoogleFonts.bebasNeue(fontSize: 18, color: AppColors.textPrimary);
  static TextStyle body = GoogleFonts.nunito(fontSize: 16, color: AppColors.textPrimary);
  static TextStyle caption = GoogleFonts.nunito(fontSize: 14, color: AppColors.textSecondary);
  static TextStyle small = GoogleFonts.nunito(fontSize: 12, color: AppColors.textSecondary);
}
```

### Tema
```dart
ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: ColorScheme.dark(
    primary: AppColors.accent,
    error: AppColors.danger,
    surface: AppColors.card,
  ),
);
```

---

## Klasör Yapısı
```
lib/
  core/
    constants/
      app_colors.dart
      app_text_styles.dart
      app_constants.dart
    router/
      app_router.dart
    providers/
      connection_provider.dart
      location_provider.dart
      auth_provider.dart
  features/
    home/
      screens/
        home_screen.dart
    help/
      screens/
        help_screen.dart
    tasks/
      screens/
        tasks_screen.dart
    profile/
      screens/
        profile_screen.dart
  shared/
    widgets/
      app_button.dart
      app_card.dart
      app_top_bar.dart
      app_bottom_nav.dart
      app_loader.dart
      app_toast.dart
      connection_status.dart
      location_permission.dart
```

---

## Bu Fazda Yapılacaklar

### 1. Proje Kurulumu
- Flutter projesi oluştur
- pubspec.yaml paketleri ekle
- Klasör yapısını kur
- AppColors, AppTextStyles tanımla
- ThemeData kur

### 2. Navigasyon (go_router)
4 ana sayfa:
```dart
/ → HomeScreen (Ana Sayfa - SOS)
/help → HelpScreen (Yardım)
/tasks → TasksScreen (Görevler)
/profile → ProfileScreen (Profil)
```

### 3. AppBottomNav
```
İkon + yazı kombinasyonu
4 sekme: Ana Sayfa, Yardım, Görevler, Profil
Aktif sekme: turuncu (#FF6B35)
Pasif sekme: gri (#8899AA)
Arka plan: #1B2E45
```

### 4. Placeholder Ekranlar
Her sayfa için sadece başlık + "Yakında" metni. Gerçek içerik sonraki fazlarda gelecek.

### 5. Konum İzni (LocationPermission)
```
Uygulama ilk açılışta:
  → Konum izni popup
  → "Acil SOS için konumunuz gerekli"
  → [İzin Ver] [Şimdi Değil]

İzin verilmezse:
  → SOS butonunda ⚠️ ikonu
  → SOS'a basınca tekrar sor
  → "İzinsiz Gönder" seçeneği var

İzin akışı shared_preferences'a kaydedilir
```

### 6. Bağlantı Kontrolü (ConnectionProvider)
```dart
// Waterfall bağlantı sistemi
enum ConnectionType { internet, esp32, none }

class ConnectionProvider extends ChangeNotifier {
  ConnectionType _type = ConnectionType.none;

  // connectivity_plus ile internet kontrolü
  // ESP32 AP SSID kontrolü: "MESHAID-" ile başlayan ağlar
  // Her 5 saniyede bir kontrol
}
```

### 7. ConnectionStatus Widget
```
Üst bar altında küçük gösterge:
🟢 "İnternet Bağlı"
🟡 "ESP32 Bağlı (MESHAID-NODE01)"
🔴 "Bağlantı Yok"
```

---

## Temel Componentler

### AppButton
```dart
// Varyantlar: primary (turuncu), danger (kırmızı), success (yeşil), outline
// Bebas Neue font, 20px
// Border radius: 12
// Height: 56
```

### AppCard
```dart
// Arka plan: #1B2E45
// Border radius: 16
// Padding: 16
// Opsiyonel border: accent renk
```

### AppTopBar
```dart
// Arka plan: #0D1B2A
// Başlık: Bebas Neue 24px
// Geri butonu opsiyonel
// Sağda opsiyonel aksiyon
```

### AppLoader
```dart
// CircularProgressIndicator
// Renk: turuncu (#FF6B35)
```

### AppToast
```dart
// Başarı: yeşil
// Hata: kırmızı
// Uyarı: sarı
// Nunito 14px
// 3 saniye görünür
```

---

## Faz 1 Test Kriterleri
Aşağıdakilerin hepsi çalışıyorsa Faz 2'ye geç:

```
✅ Uygulama açılıyor, siyah ekran yok
✅ 4 sekme arası geçiş çalışıyor
✅ Bottom nav aktif sekmeyi turuncu gösteriyor
✅ Konum izni popup'ı ilk açılışta çıkıyor
✅ İzin verilince bir daha çıkmıyor
✅ ConnectionStatus üstte görünüyor
✅ İnternet açık/kapalı değişince güncelleniyor
✅ Tema renkleri doğru (koyu lacivert arka plan)
✅ Bebas Neue ve Nunito fontlar yüklü
```

---

## Önemli Kurallar
- Tüm renkler AppColors'dan kullan, hardcode renk yazma
- Tüm text style'lar AppTextStyles'dan kullan
- Her widget ayrı dosyada olsun
- Provider ile state yönet, setState sadece local UI için
- Türkçe karakter desteği kontrol et (ş, ğ, ü, ö, ç, ı)
