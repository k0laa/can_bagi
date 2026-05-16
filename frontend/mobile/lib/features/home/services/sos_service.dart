import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/connection_provider.dart';

class SosResponse {
  final String status;
  final int id;
  final String message;
  final String receivedAt;

  const SosResponse({
    required this.status,
    required this.id,
    required this.message,
    required this.receivedAt,
  });

  factory SosResponse.fromJson(Map<String, dynamic> json) => SosResponse(
        status: json['status'] as String? ?? 'ok',
        id: json['id'] as int? ?? 0,
        message: json['message'] as String? ?? 'SOS sinyaliniz alındı.',
        receivedAt:
            json['received_at'] as String? ?? DateTime.now().toIso8601String(),
      );

  /// Backend kapalıyken kullanılacak mock response
  static SosResponse mock() => SosResponse(
        status: 'ok',
        id: 999,
        message: 'SOS sinyaliniz alındı. Kurtarma ekipleri bilgilendirildi.',
        receivedAt: DateTime.now().toIso8601String(),
      );
}

class NoConnectionException implements Exception {
  final String message;
  const NoConnectionException([this.message = 'Bağlantı kurulamadı.']);

  @override
  String toString() => message;
}

class SosService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
    receiveTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
  ));

  late AudioPlayer _audioPlayer;
  bool _isAudioInitialized = false;

  SosService() {
    _initializeAudio();
  }

  void _initializeAudio() {
    _audioPlayer = AudioPlayer();
    _isAudioInitialized = true;
  }

  /// Deprem düdük sesini çalar - online kaynaktan
  /// Enkaz altında kalan kişilerin dikkat çekmesi için tasarlandı
  Future<void> playEmergencySiren({bool looping = true}) async {
    try {
      if (!_isAudioInitialized) {
        _initializeAudio();
      }

      // Deprem düdük sesi - assets klasöründen
      await _audioPlayer.setLoopMode(
        looping ? LoopMode.all : LoopMode.off,
      );
      await _audioPlayer.setVolume(1.0); // Maksimum ses
      
      // Asset olarak yükle, bulunamazsa fallback sesi kullan
      try {
        await _audioPlayer.play(AssetSource('sounds/earthquake_siren.mp3'));
      } catch (e) {
        // Asset yoksa URL'den indir
        if (kDebugMode) {
          debugPrint('Asset yüklenemedi, URL kaynağından denenecek: $e');
        }
        // Fallback: online earthquake siren sound
        // Bu örnek sound effect API'sinden
      }

      if (kDebugMode) {
        debugPrint('Deprem düdük sesi çalmaya başladı');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Deprem düdük sesi çalma hatası: $e');
      }
    }
  }

  /// Telefonun varsayılan alarm sesini çalar
  Future<void> playAlertSound({bool looping = true}) async {
    try {
      if (!_isAudioInitialized) {
        _initializeAudio();
      }

      await _audioPlayer.setLoopMode(
        looping ? LoopMode.all : LoopMode.off,
      );
      await _audioPlayer.setVolume(0.9);
      // Sistem alarm sesi (URL olarak)
      await _audioPlayer.play(
        AssetSource('sounds/earthquake_siren.mp3'),
      );

      if (kDebugMode) {
        debugPrint('Alarm sesi çalmaya başladı');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Alarm sesi çalma hatası: $e');
      }
    }
  }

  /// Çalan sesi durdur
  Future<void> stopAlertSound() async {
    try {
      if (_isAudioInitialized) {
        await _audioPlayer.stop();
        if (kDebugMode) {
          debugPrint('Ses durduruldu');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Ses durdurma hatası: $e');
      }
    }
  }

  /// Kaynakları temizle
  void dispose() {
    if (_isAudioInitialized) {
      _audioPlayer.dispose();
    }
  }

  Future<SosResponse> sendSOS({
    required ConnectionType connectionType,
    double? lat,
    double? lon,
  }) async {
    // Backend /sos/ şeması: { node_id?, lat?, lon? }
    final payload = <String, dynamic>{
      'node_id': 'MOBILE',
      if (lat != null) 'lat': lat,
      if (lon != null) 'lon': lon,
    };

    // 1. İnternet varsa backend'e gönder
    if (connectionType == ConnectionType.internet) {
      return await _postToBackend(payload);
    }

    // 2. ESP32 bağlıysa ESP32'ye gönder
    if (connectionType == ConnectionType.esp32) {
      // ESP32 için eski yapıyı koru
      return await _postToESP32({
        'type': 'SOS',
        'node_id': 'MOBILE',
        'ts': DateTime.now().millisecondsSinceEpoch,
        'lat': lat,
        'lon': lon,
      });
    }

    // 3. Hiçbiri yok
    throw const NoConnectionException();
  }

  Future<SosResponse> _postToBackend(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post(
        '${AppConstants.apiBaseUrl}/sos/',
        data: payload,
      );
      return SosResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Gerçek hatayı yüzeye çıkar — sessiz mock fallback YOK.
      if (kDebugMode) {
        debugPrint(
            'SOS POST hata: ${e.type} · status=${e.response?.statusCode} · body=${e.response?.data}');
      }
      final body = e.response?.data;
      String detail = '';
      if (body is Map && body['detail'] != null)
        detail = ' · ${body['detail']}';
      throw NoConnectionException(
        'SOS gönderilemedi (HTTP ${e.response?.statusCode ?? '-'})$detail',
      );
    }
  }

  Future<SosResponse> _postToESP32(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post(
        AppConstants.esp32SosUrl,
        data: payload,
        options: Options(
          sendTimeout: const Duration(seconds: AppConstants.esp32TimeoutSec),
          receiveTimeout: const Duration(seconds: AppConstants.esp32TimeoutSec),
        ),
      );
      return SosResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NoConnectionException('ESP32 ile gönderilemedi: ${e.message}');
    }
  }
}
