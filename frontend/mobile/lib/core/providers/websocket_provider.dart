import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../constants/app_constants.dart';
import 'auth_provider.dart';

class WebSocketProvider extends ChangeNotifier {
  final AuthProvider authProvider;
  WebSocketChannel? _channel;
  bool _isConnected = false;

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
      final wsUrlWithToken = '${AppConstants.wsUrl}?token=${Uri.encodeComponent(authProvider.token!)}';
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
          // Opsiyonel reconnect eklenebilir
        },
        onError: (error) {
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
        notifyListeners(); // Görev listesi ekranı bunu dinleyip yenileyebilir
        break;
      case 'TASK_UPDATED':
        messenger.showSnackBar(const SnackBar(
          content: Text('ℹ️ Görev Durumu Güncellendi'),
          backgroundColor: Colors.blue,
        ));
        notifyListeners(); // Görev listesi ekranı bunu dinleyip yenileyebilir
        break;
    }
    debugPrint('WS Event: $event Payload: $payload');
  }

  @override
  void dispose() {
    authProvider.removeListener(_onAuthChanged);
    _disconnect();
    super.dispose();
  }
}
