import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

enum LocationStatus { unknown, granted, denied, permanentlyDenied }

class LocationProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  LocationStatus _status = LocationStatus.unknown;
  Position? _lastPosition;
  bool _permissionDialogShown = false;

  LocationProvider(this._prefs) {
    _loadState();
  }

  LocationStatus get status => _status;
  Position? get lastPosition => _lastPosition;
  bool get hasPermission => _status == LocationStatus.granted;
  bool get permissionDialogShown => _permissionDialogShown;

  void _loadState() {
    _permissionDialogShown =
        _prefs.getBool(AppConstants.keyLocationAsked) ?? false;
    _checkCurrentStatus();
  }

  Future<void> _checkCurrentStatus() async {
    final permission = await Permission.location.status;
    if (permission.isGranted) {
      _status = LocationStatus.granted;
    } else if (permission.isPermanentlyDenied) {
      _status = LocationStatus.permanentlyDenied;
    } else {
      _status = LocationStatus.denied;
    }
    notifyListeners();
  }

  /// İlk açılış için izin iste
  Future<bool> requestPermission() async {
    _permissionDialogShown = true;
    await _prefs.setBool(AppConstants.keyLocationAsked, true);

    final result = await Permission.location.request();
    if (result.isGranted) {
      _status = LocationStatus.granted;
      notifyListeners();
      return true;
    } else if (result.isPermanentlyDenied) {
      _status = LocationStatus.permanentlyDenied;
    } else {
      _status = LocationStatus.denied;
    }
    notifyListeners();
    return false;
  }

  /// Konum al — önce taze fix denenir, başarısızsa son bilinen konuma düşülür.
  /// SOS senaryosunda enkaz altında GPS fix alınamayabilir; eski konum hiç yoktan iyidir.
  Future<Position?> getCurrentPosition() async {
    if (_status != LocationStatus.granted) return null;
    try {
      final fresh = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: AppConstants.locationTimeoutSec),
        ),
      );
      _lastPosition = fresh;
      return fresh;
    } catch (_) {
      // Taze fix alınamadı — son bilinen konuma fallback (cache'ten)
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) _lastPosition = last;
        return last;
      } catch (_) {
        return _lastPosition;
      }
    }
  }

  Future<void> openSettings() => openAppSettings();
}
