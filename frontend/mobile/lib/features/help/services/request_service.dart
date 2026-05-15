import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/connection_provider.dart';
import '../../home/services/sos_service.dart' show NoConnectionException;
import '../models/request_model.dart';

class RequestService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
    receiveTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
  ));

  Future<RequestResponse> sendRequest({
    required ConnectionType connectionType,
    required String? token,
    required Map<String, dynamic> payload,
  }) async {
    // 1. İnternet varsa backend'e gönder
    if (connectionType == ConnectionType.internet) {
      return await _postToBackend(payload, token);
    }

    // 2. ESP32 bağlıysa ESP32'ye gönder
    if (connectionType == ConnectionType.esp32) {
      return await _postToESP32(payload);
    }

    // 3. Hiçbiri yok
    throw const NoConnectionException();
  }

  Future<RequestResponse> _postToBackend(Map<String, dynamic> payload, String? token) async {
    try {
      final options = Options();
      if (token != null) {
        options.headers = {'Authorization': 'Bearer $token'};
      }
      final res = await _dio.post(
        '${AppConstants.apiBaseUrl}/request/create',
        data: payload,
        options: options,
      );
      return RequestResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return RequestResponse.mock(payload['category'] as String);
      }
      rethrow;
    }
  }

  Future<RequestResponse> _postToESP32(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post(
        '${AppConstants.esp32BaseUrl}/request',
        data: payload,
        options: Options(
          sendTimeout: const Duration(seconds: AppConstants.esp32TimeoutSec),
          receiveTimeout: const Duration(seconds: AppConstants.esp32TimeoutSec),
        ),
      );
      return RequestResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException {
      return RequestResponse.mock(payload['category'] as String);
    }
  }
}
