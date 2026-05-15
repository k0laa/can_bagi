import 'dart:math';

class LocationUtils {
  LocationUtils._();

  /// Haversine formülü ile iki nokta arasındaki mesafeyi metre cinsinden hesaplar
  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0; // Dünya yarıçapı (metre)
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final dphi = (lat2 - lat1) * pi / 180;
    final dlambda = (lon2 - lon1) * pi / 180;

    final a = sin(dphi / 2) * sin(dphi / 2) +
        cos(phi1) * cos(phi2) * sin(dlambda / 2) * sin(dlambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// İki nokta arasındaki yönü pusula yönü olarak hesaplar
  static String calculateDirection(double lat1, double lon1, double lat2, double lon2) {
    final y = sin((lon2 - lon1) * pi / 180) * cos(lat2 * pi / 180);
    final x = cos(lat1 * pi / 180) * sin(lat2 * pi / 180) -
        sin(lat1 * pi / 180) * cos(lat2 * pi / 180) * cos((lon2 - lon1) * pi / 180);
    
    final bearing = atan2(y, x) * 180 / pi;
    final normalized = (bearing + 360) % 360;

    if (normalized < 22.5 || normalized >= 337.5) return '↑ Kuzey';
    if (normalized < 67.5)  return '↗ Kuzeydoğu';
    if (normalized < 112.5) return '→ Doğu';
    if (normalized < 157.5) return '↘ Güneydoğu';
    if (normalized < 202.5) return '↓ Güney';
    if (normalized < 247.5) return '↙ Güneybatı';
    if (normalized < 292.5) return '← Batı';
    return '↖ Kuzeybatı';
  }
}
