# MeshAid Flutter - Faz 3
> Kullanıcı Sistemi: Kayıt/Giriş, Offline Token, Soft Gate, Profil

---

## Faz 1-2'den Gelenler
- Tema, navigasyon, componentler hazır
- ConnectionProvider, LocationProvider çalışıyor
- SOS akışı tam çalışıyor
- Confirmation ekranı çalışıyor

---

## Bu Fazda Yapılacaklar

### 1. AuthProvider
```dart
class AuthProvider extends ChangeNotifier {
  User? _user;
  String? _token;

  bool get isLoggedIn => _token != null;
  User? get user => _user;

  // shared_preferences'tan token yükle
  Future<void> loadFromStorage() async {}

  // Login → token al → kaydet
  Future<void> login(String phone, String password) async {}

  // Register → token al → kaydet
  Future<void> register(RegisterRequest req) async {}

  // Logout → token sil
  Future<void> logout() async {}
}
```

### 2. Offline Token Sistemi
```
Giriş yapılınca:
  JWT token → shared_preferences'a kaydet
  User bilgisi → shared_preferences'a kaydet (JSON)

Uygulama açılınca:
  shared_preferences'tan token oku
  Token varsa → otomatik giriş (API çağrısı yok)
  Token yoksa → misafir mod

Token sadece logout'ta silinir
İnternet olmasa bile token geçerli
```

### 3. Soft Gate Sistemi
```dart
// SoftGateSheet - bottom sheet olarak açılır
// Kayıt gereken sayfalarda kullanım örneği:

// HelpScreen'de herhangi bir kategoriye basınca:
if (!authProvider.isLoggedIn) {
  showSoftGateSheet(context);
  return;
}
// Form sayfasına git

// SoftGateSheet içeriği:
// - "Bu özellik için giriş gerekli" (Bebas Neue, 24px)
// - Avantajlar listesi (Nunito, 14px):
//   ✓ Kan grubunuz kurtarma ekibine iletilir
//   ✓ Kronik ilaçlarınız bildirilir
//   ✓ Görev alabilirsiniz
// - [Giriş Yap] butonu (turuncu)
// - [Kayıt Ol] butonu (outline)
// - [Şimdi Değil] text butonu (gri)
```

### 4. Kayıt Ekranı
```
Route: /register

Form alanları (AppTextField):
  - İsim (zorunlu)
  - Soyisim (zorunlu)
  - Telefon (zorunlu, 05XX formatı)
  - Şifre (zorunlu, min 6 karakter)
  - Kan Grubu (dropdown: A+, A-, B+, B-, AB+, AB-, 0+, 0-)

Validasyon:
  - Boş alan kontrolü
  - Telefon format kontrolü
  - Şifre uzunluk kontrolü

Submit:
  POST /auth/register
  Başarılı → token kaydet → ProfileScreen'e git
  Hata → AppToast ile hata mesajı
```

### 5. Giriş Ekranı
```
Route: /login

Form alanları:
  - Telefon
  - Şifre
  - [Giriş Yap] butonu (turuncu)
  - [Kayıt Ol] text link

Submit:
  POST /auth/login
  Başarılı → token kaydet → önceki sayfaya dön
  Hata → AppToast ile "Telefon veya şifre hatalı"
```

### 6. Profil Ekranı
```
Kayıtsız kullanıcı görünümü:
  - "Hesabınız Yok" (Bebas Neue, 32px)
  - Avantajlar listesi
  - [Kayıt Ol] butonu (turuncu)
  - [Giriş Yap] butonu (outline)

Kayıtlı kullanıcı görünümü:
  - AppTopBar: "PROFİLİM"
  - Form (düzenlenebilir):
    İsim, Soyisim, Telefon (readonly), Kan Grubu
  - [Kaydet] butonu → PUT /user/profile
  - [Çıkış Yap] kırmızı text buton (altta)
  - Başarılı kayıt → AppToast "Profil güncellendi"
```

### 7. HelpScreen ve TasksScreen Soft Gate
```
Her iki sayfada da:
- Sayfa açılınca içerik görünür (sayfalar kilitlenmez)
- Herhangi bir aksiyon alınınca (kategori seç, görev kabul et):
  isLoggedIn kontrolü yap
  Değilse SoftGateSheet aç
  Evet ise devam et
```

---

## API İstekleri

### Register
```dart
// POST /auth/register
{
  "name": "Ahmet",
  "surname": "Yılmaz",
  "phone": "05551234567",
  "password": "123456",
  "blood_type": "A+"
}

// Response
{
  "status": "ok",
  "token": "jwt_token_here",
  "user": { "id": 1, "name": "Ahmet", ... }
}
```

### Login
```dart
// POST /auth/login
{
  "phone": "05551234567",
  "password": "123456"
}

// Response
{
  "status": "ok",
  "token": "jwt_token_here",
  "user": { "id": 1, "name": "Ahmet", ... }
}
```

### Profile Update
```dart
// PUT /user/profile
// Header: Authorization: Bearer {token}
{
  "name": "Ahmet",
  "surname": "Yılmaz",
  "blood_type": "A+"
}
```

---

## Yeni Dosyalar

```
lib/
  features/
    auth/
      screens/
        login_screen.dart
        register_screen.dart
      widgets/
        soft_gate_sheet.dart
      services/
        auth_service.dart
      models/
        user_model.dart
        register_request.dart
    profile/
      screens/
        profile_screen.dart  (güncellendi)
  core/
    providers/
      auth_provider.dart
```

---

## Faz 3 Test Kriterleri

```
✅ Kayıt formu validasyon çalışıyor
✅ Başarılı kayıt sonrası token saklanıyor
✅ Uygulama kapatılıp açılınca oturum devam ediyor
✅ Giriş çalışıyor
✅ Yanlış şifrede hata toast çıkıyor
✅ Soft gate: kategoriye basınca sheet açılıyor
✅ Sheet'ten giriş yapınca kategoriye devam ediyor
✅ Profil sayfası kayıtlı/kayıtsız doğru gösteriyor
✅ Profil güncellemesi çalışıyor
✅ Çıkış yapınca token siliniyor
✅ Çıkış sonrası profil sayfası misafir görünümü
```

---

## Önemli Notlar
- Token her API isteğine header olarak ekle: `Authorization: Bearer {token}`
- Phone numarası readonly olsun, değiştirilemez
- Kan grubu dropdown, text field değil
- SoftGateSheet navigasyonu bozmasın, sheet kapanınca kullanıcı aynı sayfada kalsın
- Logout confirm dialog çıkarsın: "Çıkış yapmak istediğinize emin misiniz?"
