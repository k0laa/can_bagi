# Can Bağı Mobile App

![logo](../../assets/logo_192.png)

Flutter ile geliştirilmiş mobil uygulama, afet anında saha kullanıcılarının hızlı SOS ve yardım talebi göndermesini sağlar.

## Temel Özellikler

- **ACİL SOS**: Kayıtsız kullanıcılar bile tek dokunuşla SOS gönderebilir
- **Yardım Talepleri**: Kayıtlı kullanıcılar ihtiyaç kategorisi ile birlikte talep oluşturabilir
- **Profil**: Kullanıcı bilgisi, kan grubu ve yetenekler saklanır
- **Görevler**: Yakın görevler listelenir, kabul edilir ve tamamlanır
- **Çevrimdışı Hazır**: İnternet yoksa ESP32 node AP'ye bağlanarak lokal iletişim sağlar

## Teknik Yapı

- `lib/main.dart` : uygulama başlangıcı
- `lib/core/router/app_router.dart` : sayfa geçişleri
- `lib/core/providers/` : uygulama durumu yönetimi
- `lib/features/auth/` : giriş, kayıt, kimlik yönetimi
- `lib/features/help/` : SOS ve talep formu
- `lib/features/home/` : ana ekran, dashboard widget'ları
- `lib/features/tasks/` : görev listesi ve detayları
- `lib/shared/widgets/` : ortak UI bileşenleri

## Kullanılan Paketler

- `go_router` : yönlendirme
- `provider` : state yönetimi
- `dio` : HTTP istemci
- `geolocator` : konum bilgisi
- `permission_handler` : izin yönetimi
- `shared_preferences` : yerel depolama

## Çalıştırma

1. `cd frontend/mobile`
2. `flutter pub get`
3. `flutter run`

## Öne Çıkan Akışlar

- SOS gönderme: `lib/features/help/`
- Yardım gönderme: `lib/features/help/`
- Görev listesi: `lib/features/tasks/`
- Profil güncelleme: `lib/features/profile/`

## API Entegrasyonu

Mobil uygulama backend ile HTTP üzerinden konuşur:

- `POST /auth/register`
- `POST /auth/login`
- `GET /user/profile`
- `PUT /user/profile`
- `POST /sos/`
- `POST /needs/`
- `GET /tasks/`
- `POST /tasks/{id}/accept`
- `POST /tasks/{id}/complete`
