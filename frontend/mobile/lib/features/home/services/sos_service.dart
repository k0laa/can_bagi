import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
}

class SosService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
    receiveTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
  ));

  Future<SosResponse> sendSOS({
    required ConnectionType connectionType,
    double? lat,
    double? lon,
  }) async {
    final payload = {
      'type': 'SOS',
      'node_id': 'MOBILE',
      'ts': DateTime.now().millisecondsSinceEpoch,
      'lat': lat,
      'lon': lon,
    };

    // 1. İnternet varsa backend'e gönder
    if (connectionType == ConnectionType.internet) {
      return await _postToBackend(payload);
    }

    // 2. ESP32 bağlıysa ESP32'ye gönder
    if (connectionType == ConnectionType.esp32) {
      return await _postToESP32(payload);
    }

    // 3. Hiçbiri yok
    throw const NoConnectionException();
  }

  Future<SosResponse> _postToBackend(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post(
        '${AppConstants.apiBaseUrl}/mesh/sos',
        data: payload,
      );
      return SosResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Geliştirme sırasında backend kapalıysa mock dön — release'de gerçek hata fırlat
      if (kDebugMode &&
          (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout)) {
        return SosResponse.mock();
      }
      throw const NoConnectionException('Sunucuya ulaşılamıyor');
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
    } on DioException {
      // Geliştirme sırasında ESP32 yoksa mock dön — release'de gerçek hata fırlat
      if (kDebugMode) return SosResponse.mock();
      throw const NoConnectionException('ESP32 yanıt vermiyor');
    }
  }
}
