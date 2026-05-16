import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/app_constants.dart';
import 'auth_provider.dart';

class WebSocketProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  WebSocketChannel? _channel;
  WebSocketChannel? _esp32Channel;
  bool _isConnected = false;

  // TaskService'in ESP32 cevaplarını beklemesi için broadcast stream
  static final StreamController<Map<String, dynamic>> _esp32EventCtrl =
      StreamController<Map<String, dynamic>>.broadcast();
  static Stream<Map<String, dynamic>> get esp32Events => _esp32EventCtrl.stream;

  WebSocketProvider({required this.authProvider}) {
    authProvider.addListener(_onAuthChanged);
    _connect();
  }

  bool get isConnected => _isConnected;

  void _onAuthChanged() {
    if (authProvider.isLoggedIn) {
      if (!_isConnected) _connect();
    } else {
      _disconnect();
    }
  }

  void _connect() {
    if (_isConnected || authProvider.token == null) return;
    try {
      final wsUrlWithToken =
          '${AppConstants.wsUrl}?token=${Uri.encodeComponent(authProvider.token!)}';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrlWithToken));
      _isConnected = true;
      notifyListeners();

      _channel?.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            final event = data['event'];
            final payload = data['data'];
            _handleEvent(event, payload);
          } catch (e) {
            debugPrint('WebSocket parse error: $e');
          }
        },
        onDone: () {
          _isConnected = false;
          _channel = null;
          notifyListeners();
        },
        onError: (_) {
          _isConnected = false;
          _channel = null;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _isConnected = false;
    }
  }

  void _disconnect() {
    _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    notifyListeners();
  }

  /// ESP32 WiFi modunda çağrılır — node_ip/ws/mobile'a bağlanır
  void connectEsp32() {
    if (_esp32Channel != null) return;
    try {
      _esp32Channel =
          WebSocketChannel.connect(Uri.parse(AppConstants.esp32WsUrl));
      _esp32Channel?.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message) as Map<String, dynamic>;
            _esp32EventCtrl.add(data); // TaskService Completer'ları bu stream'i dinler
            _handleEsp32Event(data);
          } catch (e) {
            debugPrint('ESP32 WS parse error: $e');
          }
        },
        onDone: () {
          _esp32Channel = null;
          debugPrint('ESP32 WS bağlantısı kapandı');
        },
        onError: (e) {
          _esp32Channel = null;
          debugPrint('ESP32 WS hata: $e');
        },
      );
      debugPrint('ESP32 WS bağlantısı kuruldu');
    } catch (e) {
      debugPrint('ESP32 WS bağlanamadı: $e');
    }
  }

  void disconnectEsp32() {
    _esp32Channel?.sink.close();
    _esp32Channel = null;
  }

  void _handleEsp32Event(Map<String, dynamic> data) {
    final event = data['event'] as String?;
    final messenger = AppConstants.scaffoldMessengerKey.currentState;

    switch (event) {
      case 'TASK_ASSIGNED':
        messenger?.showSnackBar(const SnackBar(
          content: Text('✅ Size Yeni Bir Görev Atandı!'),
          backgroundColor: Colors.green,
        ));
        notifyListeners();
        break;
      case 'TASK_ACTION_RESULT':
        notifyListeners();
        break;
      default:
        break;
    }
  }

  void _handleEvent(String? event, dynamic payload) {
    if (event == null) return;

    final messenger = AppConstants.scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    switch (event) {
      case 'NEW_SOS':
        messenger.showSnackBar(const SnackBar(
          content: Text('🚨 YENİ ACİL SOS ÇAĞRISI!'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ));
        break;
      case 'NEW_REQUEST':
        messenger.showSnackBar(const SnackBar(
          content: Text('🟠 Yeni Yardım Talebi Alındı'),
          backgroundColor: Colors.orange,
        ));
        break;
      case 'TASK_ASSIGNED':
        messenger.showSnackBar(const SnackBar(
          content: Text('✅ Size Yeni Bir Görev Atandı!'),
          backgroundColor: Colors.green,
        ));
        notifyListeners();
        break;
      case 'TASK_UPDATED':
        messenger.showSnackBar(const SnackBar(
          content: Text('ℹ️ Görev Durumu Güncellendi'),
          backgroundColor: Colors.blue,
        ));
        notifyListeners();
        break;
    }
    debugPrint('WS Event: $event Payload: $payload');
  }

  @override
  void dispose() {
    authProvider.removeListener(_onAuthChanged);
    _disconnect();
    disconnectEsp32();
    super.dispose();
  }
}
