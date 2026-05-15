class AppConstants {
  AppConstants._();

  // Backend API
  static const String apiBaseUrl  = 'http://localhost:8000';
  static const String wsUrl       = 'ws://localhost:8000/ws/dashboard';

  // ESP32
  static const String esp32BaseUrl = 'http://192.168.4.1';
  static const String esp32PingUrl = 'http://192.168.4.1/ping';
  static const String esp32SosUrl  = 'http://192.168.4.1/sos';

  // Harita - Balıkesir merkezi
  static const double mapLat  = 39.6484;
  static const double mapLon  = 27.8826;
  static const int    mapZoom = 13;

  // Timeout değerleri
  static const int connectionTimeoutSec = 10;
  static const int esp32TimeoutSec      = 2;
  static const int locationTimeoutSec   = 5;

  // Shared Preferences anahtarları
  static const String keyToken           = 'auth_token';
  static const String keyUser            = 'auth_user';
  static const String keyLocationAsked   = 'location_permission_asked';
}
