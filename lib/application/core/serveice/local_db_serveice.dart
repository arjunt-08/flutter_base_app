import 'dart:convert';
import 'package:flutter_application_1/application/core/utils/constants.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class LocalDbService {
  final SharedPreferences _prefs;

  LocalDbService(this._prefs);

  // --- Token Management ---
  Future<bool> saveToken(String token) async {
    return await _prefs.setString(AppConstants.token, token);
  }

  String? getToken() {
    return _prefs.getString(AppConstants.token);
  }

  Future<bool> deleteToken() async {
    return await _prefs.remove(AppConstants.token);
  }

  bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  // --- Refresh Token ---
  Future<bool> saveRefreshToken(String token) async {
    return await _prefs.setString(AppConstants.refreshToken, token);
  }

  String? getRefreshToken() {
    return _prefs.getString(AppConstants.refreshToken);
  }

  Future<bool> deleteRefreshToken() async {
    return await _prefs.remove(AppConstants.refreshToken);
  }

  // --- User Data Caching ---
  Future<bool> saveUser(Map<String, dynamic> userMap) async {
    return await _prefs.setString(AppConstants.user, jsonEncode(userMap));
  }

  Map<String, dynamic>? getUser() {
    final userString = _prefs.getString(AppConstants.user);
    if (userString == null || userString.isEmpty) return null;
    try {
      return jsonDecode(userString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteUser() async {
    return await _prefs.remove(AppConstants.user);
  }

  // --- Theme Mode ---
  Future<bool> saveThemeMode(String mode) async {
    return await _prefs.setString(AppConstants.themeMode, mode);
  }

  String? getThemeMode() {
    return _prefs.getString(AppConstants.themeMode);
  }

  // --- Session Management ---
  Future<void> clearSession() async {
    await deleteToken();
    await deleteRefreshToken();
    await deleteUser();
  }

  // --- Generic Storage Helpers ---
  Future<bool> setString(String key, String value) => _prefs.setString(key, value);
  String? getString(String key) => _prefs.getString(key);
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);
  bool? getBool(String key) => _prefs.getBool(key);
  Future<bool> remove(String key) => _prefs.remove(key);
  Future<bool> clearAll() => _prefs.clear();
}
