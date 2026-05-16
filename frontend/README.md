# Can Bağı Frontend

![logo](../assets/logo_192.png)

Frontend, kullanıcıların ve koordinatörlerin sistemle etkileşime geçtiği iki ana uygulamayı içerir.

## İki Ana Uygulama

- `frontend/mobile/` : Flutter ile hazırlanmış mobil uygulama
- `frontend/web/` : React + Vite ile hazırlanmış web dashboard

## Hedef Kullanıcılar

- **Saha kullanıcısı** : acil SOS gönderme, yardım talebi oluşturma, görevleri görüntüleme
- **Koordinatör** : gelen SOS/istekleri izleme, görev yönetimi, node durumunu görme

## Genel Akış

1. Mobil uygulama veya doğrudan node, API ile backend'e veriyi gönderir.
2. Web dashboard canlı verileri backend'ten çeker.
3. Mobil uygulama kayıtlı kullanıcının konumunu ve talebini gösterir.
4. Web dashboard, harita ve liste üzerinde sonuçları sunar.

## Çalıştırma

### Mobile

1. `cd frontend/mobile`
2. `flutter pub get`
3. `flutter run`

### Web

1. `cd frontend/web`
2. `npm install`
3. `npm run dev`

## Not

Bu dizin, `frontend/mobile/README.md` ve `frontend/web/README.md` dosyaları ile her platformun özel detaylarını açıklar.
