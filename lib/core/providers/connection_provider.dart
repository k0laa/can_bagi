import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

enum ConnectionType { internet, esp32, none }

class ConnectionProvider extends ChangeNotifier {
  ConnectionType _type = ConnectionType.none;
  Timer? _timer;
  StreamSubscription? _connectivitySub;
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(seconds: 2),
  ));

  ConnectionType get type => _type;

  String get statusLabel {
    switch (_type) {
      case ConnectionType.internet:
        return '🟢 İnternet Bağlı';
      case ConnectionType.esp32:
        return '🟡 ESP32 Bağlı';
      case ConnectionType.none:
        return '🔴 Bağlantı Yok';
    }
  }

  void startMonitoring() {
    _checkConnection();
    // Her 5 saniyede bir kontrol
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _checkConnection());

    // Bağlantı değişikliklerini dinle
    _connectivitySub = Connectivity().onConnectivityChanged.listen((_) => _checkConnection());
  }

  Future<void> _checkConnection() async {
    final result = await Connectivity().checkConnectivity();

    if (result.contains(ConnectivityResult.none)) {
      // Hiç ağ yok — ESP32 de denemeye gerek yok
      _updateType(ConnectionType.none);
      return;
    }

    // Ağ var, internet var mı kontrol et
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 2));
      if (lookup.isNotEmpty && lookup.first.rawAddress.isNotEmpty) {
        _updateType(ConnectionType.internet);
        return;
      }
    } catch (_) {}

    // İnternet yok — ESP32 ping dene
    try {
      final response = await _dio.get(AppConstants.esp32PingUrl);
      if (response.statusCode == 200) {
        _updateType(ConnectionType.esp32);
        return;
      }
    } catch (_) {}

    _updateType(ConnectionType.none);
  }

  void _updateType(ConnectionType newType) {
    if (_type != newType) {
      _type = newType;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectivitySub?.cancel();
    _dio.close();
    super.dispose();
  }
}
