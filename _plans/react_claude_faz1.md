# MeshAid React - Faz 1
> Temel Altyapı: Kurulum, Routing, Tema, Koordinatör Girişi, JWT

---

## Sen Kimsin
Sen bir React geliştiricisisin. MeshAid afet koordinasyon sisteminin web dashboard'unu geliştiriyorsun. Bu dashboard sadece yetkili koordinatörler tarafından kullanılır. Faz 1'de temel altyapıyı kuruyorsun.

---

## Proje Hakkında
MeshAid web dashboard'u, afet bölgesindeki ESP32 mesh ağından gelen SOS çağrılarını, yardım taleplerini ve node durumlarını gerçek zamanlı harita üzerinde gösterir. Koordinatörler buradan görev oluşturur, toplanma noktalarını yönetir.

---

## Teknik Stack
```
React 18 + Vite
react-router-dom v6: routing
axios: HTTP istekleri
zustand: state management
tailwindcss: styling
google-fonts: Bebas Neue + Nunito
```

---

## Tasarım Sistemi

### Renkler (tailwind.config.js'e ekle)
```javascript
colors: {
  'mesh-bg':      '#0D1B2A',
  'mesh-card':    '#1B2E45',
  'mesh-accent':  '#FF6B35',
  'mesh-danger':  '#E63946',
  'mesh-success': '#2DC653',
  'mesh-info':    '#4A9EFF',
  'mesh-warning': '#FFB703',
  'mesh-text':    '#FFFFFF',
  'mesh-muted':   '#8899AA',
  'mesh-disabled':'#445566',
}
```

### Tipografi (index.css'e ekle)
```css
@import url('https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Nunito:wght@400;500;600;700&display=swap');

.font-bebas { font-family: 'Bebas Neue', cursive; }
.font-nunito { font-family: 'Nunito', sans-serif; }

body { 
  font-family: 'Nunito', sans-serif;
  background-color: #0D1B2A;
  color: #FFFFFF;
}
```

---

## Klasör Yapısı
```
src/
  components/
    ui/
      Button.jsx
      Card.jsx
      Badge.jsx
      Input.jsx
      Select.jsx
      Modal.jsx
      Toast.jsx
      Loader.jsx
    layout/
      SidebarNav.jsx
      TopBar.jsx
      SosList.jsx
      PageLayout.jsx
  pages/
    LoginPage.jsx
    DashboardPage.jsx
    TasksPage.jsx
    NodesPage.jsx
    AssemblyPage.jsx
  store/
    authStore.js
    mapStore.js
    wsStore.js
  services/
    api.js
    wsService.js
  hooks/
    useAuth.js
    useWebSocket.js
  utils/
    constants.js
```

---

## Bu Fazda Yapılacaklar

### 1. Proje Kurulumu
```bash
npm create vite@latest meshaid-web -- --template react
cd meshaid-web
npm install react-router-dom axios zustand
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### 2. Tailwind + Tema Kurulumu
- tailwind.config.js'e mesh renkleri ekle
- index.css'e fontları + body stili ekle

### 3. Routing (react-router-dom)
```jsx
// Korumalı route yapısı
<Routes>
  <Route path="/login" element={<LoginPage />} />
  <Route path="/" element={<ProtectedRoute><PageLayout /></ProtectedRoute>}>
    <Route index element={<DashboardPage />} />
    <Route path="tasks" element={<TasksPage />} />
    <Route path="nodes" element={<NodesPage />} />
    <Route path="assembly" element={<AssemblyPage />} />
  </Route>
</Routes>

// ProtectedRoute: token yoksa /login'e redirect
```

### 4. AuthStore (zustand)
```javascript
const useAuthStore = create((set) => ({
  token: localStorage.getItem('token'),
  coordinator: JSON.parse(localStorage.getItem('coordinator') || 'null'),

  login: async (username, password) => {
    // POST /auth/login
    // token → localStorage
    // coordinator → localStorage
  },

  logout: () => {
    localStorage.removeItem('token');
    localStorage.removeItem('coordinator');
    set({ token: null, coordinator: null });
  },
}));
```

### 5. LoginPage
```
Tam ekran: arka plan #0D1B2A
Ortada kart (#1B2E45, max-width: 400px):
  - Logo / "MeshAid" (Bebas Neue, 48px, turuncu)
  - "KOMİTA MERKEZİ" (Bebas Neue, 24px, gri)
  - Kullanıcı adı input
  - Şifre input
  - [GİRİŞ YAP] butonu (turuncu, tam genişlik)
  - Hata mesajı (kırmızı, Nunito 14px)

Submit:
  POST /auth/login
  Başarılı → token kaydet → / 'e redirect
  Hata → "Kullanıcı adı veya şifre hatalı"
```

### 6. Temel UI Componentler

**Button**
```jsx
// Varyantlar: primary (turuncu), danger (kırmızı), success (yeşil), outline, ghost
// Size: sm, md, lg
// Bebas Neue font
// disabled + loading state
```

**Card**
```jsx
// Arka plan: mesh-card (#1B2E45)
// border-radius: 12px
// padding: 16px
// Opsiyonel: accent border (turuncu)
```

**Badge**
```jsx
// Varyantlar: danger, warning, success, info
// Küçük pill shape
// Nunito 12px
```

**Input**
```jsx
// Arka plan: #0D1B2A (card içinde daha koyu)
// Border: #445566, focus: turuncu
// Nunito 16px
// Label üstte, hata mesajı altta
```

**Toast**
```jsx
// Sağ üst köşe, fixed position
// Varyantlar: success (yeşil), error (kırmızı), warning (sarı), info (mavi)
// 4 saniye görünür, sonra kaybolur
// Birden fazla toast stack'lenir
```

**Loader**
```jsx
// Spinner, turuncu renk
// Size: sm, md, lg
// Tam ekran overlay versiyonu da olsun
```

### 7. PageLayout
```jsx
// Sol: SidebarNav (açılır/kapanır, varsayılan açık)
// Üst: TopBar
// Sağ: SosList (açılır/kapanır, varsayılan açık)
// Orta: <Outlet /> (sayfa içeriği)

// SidebarNav menü öğeleri:
// 🗺️ Harita (/)
// ✅ Görevler (/tasks)
// 📡 Node Durumu (/nodes)
// 📍 Toplanma Noktaları (/assembly)
```

### 8. TopBar
```jsx
// Sol: hamburger → SidebarNav toggle
// Orta: "MESHAİD KOMİTA MERKEZİ" (Bebas Neue)
// Sağ: WebSocket bağlantı durumu + koordinatör adı + çıkış butonu
```

---

## Faz 1 Test Kriterleri

```
✅ /login sayfası açılıyor
✅ Doğru bilgiyle giriş yapılıyor
✅ Token localStorage'a kaydediliyor
✅ Giriş sonrası dashboard'a yönlendiriliyor
✅ /login'e tekrar gitmeye çalışınca dashboard'a döndürüyor
✅ Token silinince /login'e yönlendiriyor
✅ SidebarNav açılıp kapanıyor
✅ Sayfalar arası geçiş çalışıyor (routes)
✅ Tema renkleri doğru
✅ Bebas Neue ve Nunito fontlar yüklü
✅ Çıkış yapınca /login'e gidiyor
```

---

## Önemli Kurallar
- Tüm renkler tailwind custom class ile yaz (bg-mesh-bg, text-mesh-accent vb.)
- Hardcode renk yazma
- Her component kendi dosyasında olsun
- API base URL: constants.js'ten al
- Token her axios isteğine otomatik eklensin (axios interceptor)
