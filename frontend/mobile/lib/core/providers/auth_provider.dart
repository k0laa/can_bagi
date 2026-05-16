import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/auth/services/auth_service.dart';

export '../../features/auth/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final AuthService _authService = AuthService();

  String?    _token;
  UserModel? _user;
  bool       _isLoading = false;

  AuthProvider(this._prefs) {
    _loadFromStorage();
  }

  String?    get token      => _token;
  UserModel? get user       => _user;
  bool       get isLoggedIn => _token != null;
  bool       get isLoading  => _isLoading;

  void _loadFromStorage() {
    _token = _prefs.getString(AppConstants.keyToken);
    final userJson = _prefs.getString(AppConstants.keyUser);
    if (userJson != null) {
      try {
        _user = UserModel.fromJson(
            jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        _user = null;
      }
    }
  }

  Future<void> login(String phone, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result =
          await _authService.login(phone: phone, password: password);
      await _saveAuth(result.token, result.user);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(RegisterRequest req) async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _authService.register(req);
      await _saveAuth(result.token, result.user);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String surname,
    required String bloodType,
    String? skills,
    double? lat,
    double? lon,
  }) async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await _authService.updateProfile(
        token:     _token!,
        name:      name,
        surname:   surname,
        bloodType: bloodType,
        skills:    skills,
        lat:       lat,
        lon:       lon,
      );
      _user = updated;
      await _prefs.setString(
          AppConstants.keyUser, jsonEncode(updated.toJson()));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      final user = await _authService.getProfile(token: _token!);
      _user = user;
      await _prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
    } catch (_) {
      // sessiz fail
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAuth(String token, UserModel user) async {
    _token = token;
    _user  = user;
    await _prefs.setString(AppConstants.keyToken, token);
    await _prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
  }

  Future<void> logout() async {
    _token = null;
    _user  = null;
    await _prefs.remove(AppConstants.keyToken);
    await _prefs.remove(AppConstants.keyUser);
    notifyListeners();
  }
}
