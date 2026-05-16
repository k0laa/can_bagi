import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'register_request.dart';

export '../models/user_model.dart';
export 'register_request.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
    receiveTimeout: const Duration(seconds: AppConstants.connectionTimeoutSec),
  ));

  /// Login — phone + password
  Future<({String token, UserModel user})> login({
    required String phone,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '${AppConstants.apiBaseUrl}/auth/login',
        data: {'phone': phone, 'password': password},
      );
      return _parseAuthResponse(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Register — tüm kullanıcı bilgileri
  Future<({String token, UserModel user})> register(RegisterRequest req) async {
    try {
      final res = await _dio.post(
        '${AppConstants.apiBaseUrl}/auth/register',
        data: req.toJson(),
      );
      return _parseAuthResponse(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Profil güncelle
  Future<UserModel> updateProfile({
    required String token,
    required String name,
    required String surname,
    required String bloodType,
    String? skills,
    double? lat,
    double? lon,
  }) async {
    try {
      final res = await _dio.put(
        '${AppConstants.apiBaseUrl}/user/profile',
        queryParameters: {
          'name':       name,
          'surname':    surname,
          'blood_type': bloodType,
          if (skills != null) 'skills': skills,
          if (lat != null) 'lat': lat,
          if (lon != null) 'lon': lon,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Profil getir
  Future<UserModel> getProfile({required String token}) async {
    try {
      final res = await _dio.get(
        '${AppConstants.apiBaseUrl}/user/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return UserModel.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ({String token, UserModel user}) _parseAuthResponse(
      Map<String, dynamic> data) {
    final token = data['token'] as String;
    final user  = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return (token: token, user: user);
  }

  Exception _mapError(DioException e) {
    if (e.response != null) {
      final msg = (e.response!.data as Map<String, dynamic>?)?['message']
          as String?;
      return Exception(msg ?? 'Sunucu hatası');
    }
    return Exception('Bağlantı hatası');
  }
}
