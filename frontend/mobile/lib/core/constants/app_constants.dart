class AppConstants {
  AppConstants._();

  // Backend API — build sırasında --dart-define=API_URL=... ile override edilir
  // Default: Android emülatör host machine (10.0.2.2 = emülatörden bilgisayarın localhost'u)
  static const String apiBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.24.6.35:8000',
  );
  static const String wsUrl = String.fromEnvironment(
    'WS_URL',
    defaultValue: 'ws://10.24.6.35:8000/ws/mobile',
  );

  // ESP32 — fiziksel telefon ESP32 AP'sine bağlandığında bu sabit IP kullanılır
  static const String esp32BaseUrl = String.fromEnvironment(
    'ESP32_URL',
    defaultValue: 'http://10.94.25.1',
  );
  static const String esp32PingUrl = '$esp32BaseUrl/ping';
  static const String esp32SosUrl = '$esp32BaseUrl/sos';

  // Harita - Balıkesir merkezi
  static const double mapLat = 39.6484;
  static const double mapLon = 27.8826;
  static const int mapZoom = 13;

  // Timeout değerleri
  static const int connectionTimeoutSec = 10;
  static const int esp32TimeoutSec = 2;
  static const int locationTimeoutSec = 5;

  // Shared Preferences anahtarları
  static const String keyToken = 'auth_token';
  static const String keyUser = 'auth_user';
  static const String keyLocationAsked = 'location_permission_asked';
}
