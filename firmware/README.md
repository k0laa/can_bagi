# Can Bağı Firmware
![logo](../assets/logo_192.png)

Firmware klasörü ESP32 tabanlı saha cihazlarının çalıştırıldığı kodu içerir. Bu kodlar mesh ağı üzerinden haberleşmeyi ve mobil cihazlarla bağlantıyı sağlar.

## Klasör Yapısı

- `gateway_firmware/` : mesh ağından gelen mesajları USB/Serial aracılığıyla bilgisayara ileten gateway kodu
- `node_firmware/` : saha node'u kodu, mobil cihazlarla HTTP API üzerinden konuşur ve mesh ağına broadcast yapar

## Gateway Firmware

`gateway_firmware/gateway_firmware.ino` kodu:

- `painlessMesh` kütüphanesi ile mesh ağına bağlanır
- mesh üzerinden gelen mesajları dinler
- her mesajı JSON satırı olarak `Serial.println()` ile dışa yazar
- hata, bağlantı ve kopma olaylarını loglar

Bu gateway, bilgisayar tarafında bir Python script veya terminal ile okunarak backend'e aktarılabilir.

## Node Firmware

`node_firmware/node_firmware.ino` kodu:

- ESP32'yi hem mesh hem de WiFi AP olarak yapılandırır
- mobil telefonların bağlanabileceği `EBST-KURTARMA` SSID'li açık bir erişim noktası sunar
- `/sos` ve `/request` HTTP endpoint'leri ile mobil cihazlardan veri alır
- aldığı verileri mesh üzerinden broadcast eder
- `heartbeat` mesajı göndererek node durumunu mesh ağına duyurur

## Çalışma Mantığı

1. Mobil cihaz node'un AP'sine bağlanır
2. Kullanıcı SOS veya ihtiyaç talebi gönderir
3. Node, JSON formatında mesh ağına yayın yapar
4. Gateway, mesh mesajını alır ve bilgisayara serial olarak verir
5. Backend bu veriyi işler ve kayıt altına alır

## Gereksinimler

- Arduino IDE veya PlatformIO
- ESP32 kart desteği
- `painlessMesh`, `ESPAsyncWebServer`, `ArduinoJson` kütüphaneleri

## Notlar

- Gateway ve node firmware kodları doğrudan ESP32 cihazlara yüklenmelidir
- Node cihazı, mesh ağı üzerinden diğer node ve gateway cihazlarla iletişim kurar
- Gateway, bilgisayar ve backend tarafında verilerin işlenmesi için köprü görevi görür
