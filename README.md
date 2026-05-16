# Can Bağı
![logo](assets/logo_192.png)

Can Bağı, internet ve GSM bağlantısının kesildiği afet senaryolarında acil durum haberleşmesini sağlamak için tasarlanmış bir prototip sistemdir. Projede ESP32 tabanlı mesh ağı, Python/FastAPI backend, Flutter mobil uygulama ve React web dashboard birlikte çalışır..

## Neden Can Bağı?

Afet anında klasik iletişim altyapıları yıkıldığında hayatta kalma şartları eskisi kadar değişir. Can Bağı:

- enkaz altındaki kişilerin acil SOS ve ihtiyaç taleplerini alır,
- yerel ESP32 mesh ağı üzerinden bu bilgileri gateway'e iletir,
- gateway veriyi backend sunucusuna taşır,
- kurtarma koordinatörleri web dashboard üzerinden durumu takip eder.

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

1. **Saha Node'ları (`firmware/node_firmware`)**
    - Kurban veya saha görevlisi telefonu ile bağlanır
    - SOS ve yardım talebi gönderir
    - Mesh ağına yayarak diğer ESP32 cihazlara iletir

2. **Gateway (`firmware/gateway_firmware`)**
    - Mesh mesajlarını alır
    - USB/Serial üzerinden bilgisayara iletir
    - Backend bu veriyi işler

3. **Backend (`backend`)**
    - FastAPI tabanlı REST ve WebSocket servisi
    - SQLite veritabanı kullanır (`backend/meshaid.db`)
    - API, kayıt/giriş, SOS, ihtiyaç talepleri, görevler ve node durumu yönetir

4. **React Dashboard (`frontend/web`)**
    - Koordinasyon paneli
    - Harita, canlı SOS/Request listesi, node durumu

5. **Flutter Mobil Uygulama (`frontend/mobile`)**
    - Kayıtsız kullanıcı için ACİL SOS
    - Kayıtlı kullanıcı için ihtiyaç talebi ve görev takibi

## Teknik Detay

| Katman   | Teknoloji                                                  |
|----------|------------------------------------------------------------|
| Mobil    | Flutter - dio - provider - geolocator - shared_preferences |
| Web      | React - Vite - Tailwind CSS - Leaflet - axios - Zustand    |
| Backend  | FastAPI - SQLAlchemy - SQLite - JWT                        |
| Realtime | WebSocket (ws://backend/ws/dashboard)                      |
| Donanım  | ESP32 - painlessMesh - AsyncWebServer - ArduinoJson        |

## Teknik Notlar

- Backend: FastAPI, SQLAlchemy, SQLite, JWT
- Mobil: Flutter, dio, provider, geolocator, shared_preferences
- Web: React, Vite, Tailwind CSS, Leaflet, axios, Zustand
- Firmware: ESP32, painlessMesh, AsyncWebServer, ArduinoJson

## Ana Klasör Yapısı

- `backend/` : API sunucusu, veritabanı ve WebSocket yönetimi
- `frontend/`
    - `mobile/` : Flutter mobil uygulaması
    - `web/` : React + Vite web dashboard
- `firmware/`
    - `gateway_firmware/` : ESP32 gateway kodu
    - `node_firmware/` : saha node kodu
- `plan.md` : proje hedefleri, tasarım sistemi ve endpoint planı

## Nasıl Çalışır?

1. Mobil uygulama veya doğrudan ESP32 node HTTP isteği ile SOS/request gönderir.
2. Node mesajı mesh üzerinden gateway'e iletir.
3. Gateway, mesajı USB/Serial ile bilgisayara aktarır.
4. Backend, mesajı alıp veritabanına kaydeder ve `dashboard` WebSocket kanalına yayınlar.
5. Web dashboard, canlı bildirim ve harita üzerinde bilgileri gösterir.

## Hızlı Başlangıç

### Backend

1. `cd backend`
2. `pip install -r requirements.txt`
3. `uvicorn main:app --reload --host 0.0.0.0 --port 8000`

### Web Dashboard

1. `cd frontend/web`
2. `npm install`
3. `npm run dev`

### Mobil Uygulama

1. `cd frontend/mobile`
2. `flutter pub get`
3. Emülatör veya gerçek cihaz ile çalıştırın

### Firmware

1. `firmware/gateway_firmware/gateway_firmware.ino` ve
   `firmware/node_firmware/node_firmware.ino` dosyalarını Arduino IDE veya PlatformIO ile açın
2. ESP32 kart ayarlarını yapın
3. Kodları uygun cihazlara yükleyin

## Daha Fazla Detay

> Alt klasörlerdeki README dosyaları her bölümün çalışma şeklini açıklar
