import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class UserModel {
  final int    id;
  final String name;
  final String surname;
  final String phone;
  final String bloodType;

  const UserModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.phone,
    required this.bloodType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:        json['id']         as int,
    name:      json['name']       as String,
    surname:   json['surname']    as String,
    phone:     json['phone']      as String,
    bloodType: json['blood_type'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id':         id,
    'name':       name,
    'surname':    surname,
    'phone':      phone,
    'blood_type': bloodType,
  };
}

class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;

  String?    _token;
  UserModel? _user;

  AuthProvider(this._prefs) {
    _loadFromStorage();
  }

  String?    get token     => _token;
  UserModel? get user      => _user;
  bool       get isLoggedIn => _token != null;

  void _loadFromStorage() {
    _token = _prefs.getString(AppConstants.keyToken);
    final userJson = _prefs.getString(AppConstants.keyUser);
    if (userJson != null) {
      try {
        _user = UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {
        _user = null;
      }
    }
  }

  Future<void> saveAuth(String token, UserModel user) async {
    _token = token;
    _user  = user;
    await _prefs.setString(AppConstants.keyToken, token);
    await _prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user  = null;
    await _prefs.remove(AppConstants.keyToken);
    await _prefs.remove(AppConstants.keyUser);
    notifyListeners();
  }
}
