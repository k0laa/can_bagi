# Can Bağı Web Dashboard

![logo](../../assets/logo_192.png)

React tabanlı web dashboard, koordinatörlerin sahadaki acil durumları ve görevleri izlemesini sağlar.

## Temel Özellikler

- Canlı SOS/istek listesini gösterme
- Node durumunu izleme
- Görev oluşturma ve güncelleme
- Harita üzerinde konum gösterimi
- Kullanıcı kimlik doğrulaması

## Teknik Yapı

- `src/App.jsx` : uygulama kabuğu
- `src/main.jsx` : React uygulamasını başlatır
- `src/components/layout/` : temel sayfa düzeni
- `src/components/map/` : harita bileşenleri
- `src/pages/` : sayfa içerikleri
- `src/services/api.js` : backend API isteği yönetimi
- `src/store/` : Zustand mağazaları
- `src/utils/` : sabitler ve yardımcı fonksiyonlar

## Kullanılan Paketler

- `react`, `react-dom`
- `react-router-dom`
- `axios`
- `zustand`
- `leaflet`, `react-leaflet`
- `tailwindcss`
- `vite`

## Çalıştırma

1. `cd frontend/web`
2. `npm install`
3. `npm run dev`

## Sayfalar

- `LoginPage.jsx` : koordinatör girişi
- `DashboardPage.jsx` : genel durum panosu
- `NodesPage.jsx` : bağlı mesh node listesi
- `TasksPage.jsx` : görev yönetimi
- `AssemblyPage.jsx` : muhtemel toplanma noktaları

## API Entegrasyonu

Dashboard aşağıdaki API noktalarını kullanır:

- `POST /auth/login`
- `GET /dashboard/sos`
- `GET /dashboard/requests`
- `GET /dashboard/nodes`
- `GET /dashboard/tasks`
- `POST /dashboard/tasks`
- `PUT /dashboard/tasks/{id}`
- `GET /assembly-points`
- `POST /assembly-points`
- `DELETE /assembly-points/{id}`

> Not: Bu uç noktalar plan kapsamında tanımlanmıştır. Mevcut backend kodunda bazı endpointler `tasks`, `sos`, `needs`, `nodes` gibi temel rotalar altında yer alır.
