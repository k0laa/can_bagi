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
  Future<({String token, UserModel user})> login({
    required String phone,
    required String password,
  }) async {
    try {
      // 1) Token al — backend sadece {access_token, token_type} döner
      final res = await _dio.post(
        '${AppConstants.apiBaseUrl}/auth/login',
        data: {'phone': phone, 'password': password},
      );
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : Map<String, dynamic>.from(res.data as Map);
      final token = (data['access_token'] ?? data['token']) as String;

      // 2) Kullanıcı bilgilerini ayrı çek
      final user = await getProfile(token: token);
      return (token: token, user: user);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Register — backend yalnızca kullanıcı objesini döner (token YOK).
  /// Token almak için kayıt sonrası otomatik login yapıyoruz.
  Future<({String token, UserModel user})> register(RegisterRequest req) async {
    try {
      await _dio.post(
        '${AppConstants.apiBaseUrl}/auth/register',
        data: req.toJson(),
      );
      // Kayıt başarılı → token için login akışı
      return await login(phone: req.phone, password: req.password);
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
        data: {
          'name':       name,
          'surname':    surname,
          'blood_type': bloodType,
          if (skills != null) 'skills': skills,
          if (lat != null) 'lat': lat,
          if (lon != null) 'lon': lon,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : Map<String, dynamic>.from(res.data as Map);
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Profil getir — backend doğrudan user objesi döner
  Future<UserModel> getProfile({required String token}) async {
    try {
      final res = await _dio.get(
        '${AppConstants.apiBaseUrl}/user/profile',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : Map<String, dynamic>.from(res.data as Map);
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      String? msg;
      if (data is Map<String, dynamic>) {
        msg = data['detail'] ?? data['message'];
      } else if (data is String) {
        msg = data;
      }
      return Exception(msg ?? 'Sunucu hatası: ${e.response?.statusCode}');
    }
    return Exception('Bağlantı hatası: ${e.message}');
  }
}
